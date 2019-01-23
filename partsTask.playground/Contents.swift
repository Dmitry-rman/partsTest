import Foundation

class PersentConvertor{
    private var _divisor = 1.0
    
    init(percentAccuracy: Int = 3){//По-умолчанию точность 3 знака
        _divisor =  pow(10.0, Double(percentAccuracy))
    }
    
    //Поскольку массив передается по значению в функцию, то размер в памяти примерно = 4 байт * Кол-во_входного_массива * 2 + 29
    //Вычислительная сложность линейная O(n) * k + n, где k, n константа
    func percentsOf2(parts: [Double]) -> [Double]?{
        
        for value in parts{
            if value <= 0 {
               return nil
            }
        }
        
        let roundRule:FloatingPointRoundingRule = .toNearestOrEven //1 byte
        let totalParts = (parts.reduce(0, +) * _divisor).rounded(roundRule)/_divisor //O(n)//4 byte
        //print(totalParts)
        var result = parts.map { (value) -> Double in //O(n)*5
            return (value * 100 * _divisor / totalParts).rounded(roundRule)/_divisor
        }
        
        //Увеличиваем или уменьшаем последний разряд минимального числа чтобы сумму сошлась если это необходимо
        while true{
            let sum = result.reduce(0, +) //4 byte
            let epsilon:Double = fabs(sum - 100.0)//4 byte
            let minAccuracy = 1/_divisor //4 byte
            if epsilon >= minAccuracy {
                let minValue = result.min()!//4 byte
                let changeValue = sum > 100.0 ? -minAccuracy : minAccuracy //4 byte
                //print(result)
                if let row = result.index(where: {$0 == minValue}) { //4 byte
                    result[row] = minValue + changeValue
                }
                //print(result)
            }
            else{
                break
            }
        }
        
        //print(result)
        return result
    }
    
    //Функция вычисления с проблемой округления суммы результата
    func percentsOf(parts: [Double]) -> [Double]?{
        
        for value in parts{
            if value <= 0 {
                return nil
            }
        }
        
        let totalParts = parts.reduce(0, +)
        //print(totalParts)
        let result = parts.map({ round($0 * 100 * _divisor / totalParts)/_divisor})
        
        //print(result)
        return result
    }
}

extension PersentConvertor{
    func runTest()->(){
        
        let header = String(describing: self) + "." + #function
        
        let partsTestInput = [1.5, 3, 6, 1.5]
        let partsTestOutput = [12.500, 25.000, 50.000, 12.500]//Измени значение в массиве чтобы получить провал теста через assert
        let results = convertor.percentsOf2(parts: partsTestInput)
        let successTest = results!.elementsEqual(partsTestOutput)
        assert(successTest, header + ": Error parts")
        
        let partsTestInput2 = [1.5, 3, -6.0, 1.5]
        let results2 = convertor.percentsOf2(parts: partsTestInput2)
        assert(results2 == nil, header + ": Error on validate input")
        
        let accuracy = 1/_divisor
        
        for _ in 0..<100{
            var input = [Double]()
            for _ in 0..<5{
                input.append(Double.random(in: 1..<1000000)/Double.random(in: 1..<100000))
            }
            let inputResult = convertor.percentsOf2(parts: input)
            let resultSum = inputResult!.reduce(0, +)
            let epsilon:Double = fabs(resultSum - 100.0)
            assert( epsilon <= 1/_divisor, header + ": Error on \(String(describing: input)) sum of parts \(resultSum) must be 100.0 +/- \(accuracy): \(epsilon)")
        }
        
        print("Test success")
    }
}


let convertor = PersentConvertor() //let convertor =  PersentConvertor(percentAccuracy: 3)
convertor.runTest()

let data = [45.31245, 4, 3, 4]

//Правильное решение
let result2 = convertor.percentsOf2(parts: data)
result2?.reduce(0, +)

//В этом решении точность суммы не укладывается в число десятичных знаков после запятой
let result = convertor.percentsOf(parts: data)
result!.reduce(0, +)

