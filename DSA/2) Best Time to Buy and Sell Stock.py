from typing import List


class Solution:
    def brute(self, prices):
        result = 0
        for i in range(len(prices)):
            for j in range(i+1, len(prices)):
                result = max(result, prices[j] - prices[i])

        return result
    
    def optimized(self, prices):
        if len(prices) <= 1:
            return 0
        
        buy = prices[0]
        profit = 0
        
        for i in range(1, len(prices)):
            curr_profit = prices[i] - buy
            profit = max(curr_profit, profit)
            buy = min(prices[i], buy)

        return profit



    def maxProfit(self, prices: List[int]) -> int:
        # get_result =  self.brute(prices=prices)   # T.C : O(n^2) & S.C : O(1)
        get_result =  self.optimized(prices=prices)   # T.C : O(n) & S.C : O(1)
        print(f"The answer : {get_result}")


input = [7,1,5,3,6,4]
Solution().maxProfit(input)
# Keep in my buy and sell on different day