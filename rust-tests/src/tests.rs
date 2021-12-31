use super::Loader;
use ckb_testtool::ckb_types::{bytes::Bytes, core::TransactionBuilder, packed::*, prelude::*};
use ckb_testtool::context::Context;

const MAX_CYCLES: u64 = 10_000_000;

#[test]
fn test_success() {
    let mut context = Context::default();
    let contract_bin: Bytes = Loader::default().load_binary("razor");
    let out_point = context.deploy_cell(contract_bin);

    // prepare scripts
    let lock_script = context
        .build_script(&out_point, Bytes::from(vec![42]))
        .expect("script");
    let lock_script_dep = CellDep::new_builder().out_point(out_point.clone()).build();

    // prepare cells
    let input_out_point = context.create_cell(
        CellOutput::new_builder()
            .capacity(1000u64.pack())
            .lock(lock_script.clone())
            .build(),
        Bytes::new(),
    );
    let input = CellInput::new_builder()
        .previous_output(input_out_point.clone())
        .build();
    let outputs = vec![
        CellOutput::new_builder()
            .capacity(500u64.pack())
            .lock(lock_script.clone())
            .build(),
        CellOutput::new_builder()
            .capacity(500u64.pack())
            .lock(lock_script)
            .build(),
    ];

    let outputs_data = vec![Bytes::new(); 2];

    let h1 = Header::new_builder()
        .raw(RawHeader::new_builder().number(1u64.pack()).build())
        .build()
        .into_view();
    let h2 = Header::new_builder()
        .raw(RawHeader::new_builder().number(2u64.pack()).build())
        .build()
        .into_view();
    let h3 = Header::new_builder()
        .raw(RawHeader::new_builder().number(3u64.pack()).build())
        .build()
        .into_view();
    context.insert_header(h1.clone());
    context.insert_header(h2.clone());
    context.insert_header(h3.clone());
    context.link_cell_with_block(input_out_point, h1.hash(), 0);
    context.link_cell_with_block(out_point, h2.hash(), 5);

    // build transaction
    let tx = TransactionBuilder::default()
        .input(input)
        .outputs(outputs)
        .outputs_data(outputs_data.pack())
        .header_deps(vec![h1.hash(), h2.hash(), h3.hash()])
        .cell_dep(lock_script_dep)
        .build();
    let tx = context.complete_tx(tx);

    // run
    let cycles = context
        .verify_tx(&tx, MAX_CYCLES)
        .expect("pass verification");
    println!("consume cycles: {}", cycles);
}
