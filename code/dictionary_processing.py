import argparse
import random
from tqdm import tqdm

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dictionary", type=str, metavar="STR")
    parser.add_argument("--langs", type=str, metavar="STR")
    parser.add_argument("--lang1-file", type=str, metavar="STR")
    parser.add_argument("--lang2-file", type=str, metavar="STR")
    parser.add_argument("--dict-prob", type=str, metavar="STR")
    parser.add_argument("--out1-file", type=str, metavar="STR")
    parser.add_argument("--out2-file", type=str, metavar="STR")
    args = parser.parse_args()

    dict_prob = float(args.dict_prob)

    assert (
        args.dictionary.split(".")[-1] == "txt"
    ), "Make sure the dictionary is a tab seperated txt file"

    with open(args.dictionary, "r") as f:
        assert args.dictionary.split("/")[-1].split(".")[0].split("-")[
            0
        ] in args.langs.split(",")
        assert args.dictionary.split("/")[-1].split(".")[0].split("-")[
            1
        ] in args.langs.split(",")

        src_lang = args.dictionary.split("/")[-1].split(".")[0].split("-")[0]
        tgt_lang = args.dictionary.split("/")[-1].split(".")[0].split("-")[1]

        tmp_dictionary = [i.strip().split("\t") for i in f.readlines()]
        dictionary = {f"{src_lang}-{tgt_lang}": {}, f"{tgt_lang}-{src_lang}": {}}

        for x in tmp_dictionary:
            src = x[0].lower()
            tgt = x[1]
            current_dict = dictionary[f"{src_lang}-{tgt_lang}"]

            if current_dict.get(src) is None:
                current_dict[src] = [tgt]
            else:
                current_dict[src].append(tgt)

        for x in tmp_dictionary:
            src = x[1].lower()
            tgt = x[0]
            current_dict = dictionary[f"{tgt_lang}-{src_lang}"]

            if current_dict.get(src) is None:
                current_dict[src] = [tgt]
            else:
                current_dict[src].append(tgt)
    count = 0
    lang1_count = 0
    lang2_count = 0

    lang1 = []
    current_dictionary = dictionary[args.langs.replace(",", "-")]
    set1 = set(list(current_dictionary.keys()))
    with open(args.lang1_file, "r") as f:
        current_key = args.langs.replace(",", "-")
        for line in tqdm(f):
            tokens = line.split()
            out_tokens = []
            replaced = False
            for token in tokens:
                if token.lower() in set1:
                    p = random.random()
                    if p < dict_prob:
                        replaced = True
                        out_tokens.append(
                            random.choice(current_dictionary[token.lower()])
                        )
                        count += 1
                        lang1_count += 1
                    else:
                        out_tokens.append(token)
                else:
                    out_tokens.append(token)

            current_line = " ".join(out_tokens)
            if replaced:
                lang1.append(current_line)

    with open(args.out1_file, "w") as f:
        f.write("\n".join(lang1) + "\n")

    lang2 = []
    current_dictionary = dictionary[
        args.langs.split(",")[1] + "-" + args.langs.split(",")[0]
    ]
    set1 = set(list(current_dictionary.keys()))
    with open(args.lang2_file, "r") as f:
        current_key = args.langs.split(",")[1] + "-" + args.langs.split(",")[0]
        for line in tqdm(f):
            tokens = line.split()
            out_tokens = []
            replaced = False
            for token in tokens:
                if token.lower() in set1:
                    p = random.random()
                    if p < dict_prob:
                        replaced = True
                        out_tokens.append(
                            random.choice(current_dictionary[token.lower()])
                        )
                        count += 1
                        lang2_count += 1
                    else:
                        out_tokens.append(token)
                else:
                    out_tokens.append(token)

            current_line = " ".join(out_tokens)

            if replaced:
                lang2.append(current_line)

    print(lang1_count)
    print(lang2_count)
    print(count)
    with open(args.out2_file, "w") as f:
        f.write("\n".join(lang2) + "\n")
