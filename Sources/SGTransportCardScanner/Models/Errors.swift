//
//  File.swift
//  
//
//  Created by Aung Ko Min on 12/7/23.
//

import Foundation

public enum NFCTapError: Error {
    case getChallengeFaild
    case reachMaximumAmount
    case wrongCard
    case fetchPurseFailed
    case getPurseFailed
    case getSecPurseFailed
    case fetchPurseValidationResultFailed
    case fetchTopUpCommandFailed
    case getTopUpResultFailed
    case fetchTopUpTransactionValidationResultFailed
    case getTroubleshootingTxnFailed
    case troubleshootingFailed
}
