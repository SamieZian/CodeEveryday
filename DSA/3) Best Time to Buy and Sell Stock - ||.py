from typing import List


class Solution:
    def brute(self, prices):
        pass
    
    def optimized(self, prices):
        profit = 0
        buy = prices[0]

        for i in range(len(prices)):
            if buy < prices[i]:
                profit += prices[i] - buy
            buy = prices[i]

        return profit


    def maxProfit(self, prices: List[int]) -> int:
        # get_result =  self.brute(prices=prices)   # T.C : O(n^2) & S.C : O(1)
        get_result =  self.optimized(prices=prices)   # T.C : O(n) & S.C : O(1)
        print(f"The answer : {get_result}")


input = [7,1,5,3,6,4]
Solution().maxProfit(input)
# Keep in my buy and sell on different day