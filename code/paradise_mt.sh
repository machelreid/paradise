langs="en,fr,es,de,el,bg,ru,tr,ar,vi,th,zh,hi,sw,ur,ja,eu,ro,si,ne" 
DATA=data-bin
PRETRAIN=checkpoint.pt
mkdir -p $OUTDIR

$HOME/miniconda3/envs/py3/bin/fairseq-train $DATA --fp16 \
  --arch mbart_base --layernorm-embedding \
  --task translation_from_pretrained_bart \
  --source-lang en --target-lang ar \
  --criterion label_smoothed_cross_entropy --label-smoothing 0.2 \
  --optimizer adam --adam-eps 1e-06 --adam-betas '(0.9, 0.98)' \
  --lr-scheduler polynomial_decay --lr 3e-05 --warmup-updates 2500 --total-num-update 40000 --max-update 40000 \
  --dropout 0.3 --weight-decay 0.0 --attention-dropout 0.1 \
  --max-tokens 2300 --max-tokens-valid 2300 --update-freq 4 \
  --save-interval 1 --save-interval-updates 1000 --keep-interval-updates 10 --validate-interval 10 \
  --no-epoch-checkpoints \
  --seed 222 --log-format simple --log-interval 20 \
  --save-dir $OUTDIR/checkpoints \
  --langs $langs \
  --restore-file $PRETRAIN \
  --reset-optimizer --reset-meters --reset-dataloader --reset-lr-scheduler \
  --ddp-backend=no_c10d --skip-invalid-size-inputs-valid-test --pretraining-task denoising_translation

