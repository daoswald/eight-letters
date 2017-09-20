// count


#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <vector>
#include <iterator>
#include <cctype>

const std::string DICTIONARY = "/home/davido/repos/eight-letters/lib/dict/2of12inf.txt";
const size_t MAX_WORD_LEN    = 8;

std::vector<std::string> slurp_filtered_dict (const std::string& fname) {

    std::vector<std::string>    buff;
    std::ifstream               infile(fname);
    std::string                 line;

    while(std::getline(infile, line)) {

        if(!isalpha(line.back())) {
            line.pop_back();
        }

        if(line.length() <= 8) {
            buff.push_back(move(line));
        }
    }

    return buff;
}

int main (int argc, char** argv) {

    auto dict(slurp_filtered_dict(DICTIONARY));

    for(auto& i: dict) {
        std::cout << i << std::endl;
    }

    return 0;
}
