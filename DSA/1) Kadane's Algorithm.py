from typing import List


class Solution:
    def find_max_sub_array_with_sum_and_index_from_start_to_end(self, nums): #[-2,1,-3,4,-1,2,1,-5,4]
        if len(nums) <= 1:
            return sum(nums), 0, len(nums) - 1

        max_sum = float('-inf')
        current_sum = 0
        start = end = 0
        temp_start = 0

        for i, num in enumerate(nums):
            current_sum += num

            if current_sum > max_sum:
                max_sum = current_sum
                start = temp_start
                end = i

            if current_sum < 0:
                current_sum = 0
                temp_start = i + 1

        return max_sum, start, end
    
    def brute(self,nums):
        if len(nums) <= 1:
            return sum(nums)

        result = float('-inf')
        for i in range(len(nums)):
            current_sum = 0
            for j in range(i, len(nums)):
                current_sum += nums[j]
                result = max(current_sum, result)

        return result
    
    def optimized(self, nums):
        # Kadane algo
        if len(nums) <= 1:
            return sum(nums)
        
        result = temp = nums[0]
        for i in range(1, len(nums)):
            temp = max(nums[i], temp + nums[i])
            result = max(temp, result)

        return result
    
    
    def maxSubArray(self, nums: List[int]) -> int:
        # get_result =  self.brute(nums=nums)   # T.C : O(n^2) & S.C : O(1)
        # get_result =  self.optimized(nums=nums)   # T.C : O(n) & S.C : O(1)
        # print(f"The answer : {get_result}")
        print(self.find_max_sub_array_with_sum_and_index_from_start_to_end(nums=nums))



input = [5,4,-1,7,8]
Solution().maxSubArray(input)