Received: from mx0b-00069f02.pphosted.com (mx0b-00069f02.pphosted.com [205.220.177.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CEB7199E89
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 01:04:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=205.220.177.32
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791335051; cv=fail; b=LSmYOQhknbApIsyKko0qVspmznTI6jSNGVhrYk2tJDY2gV4MN1GmFh3Cud2rCNp8kOnR3iYD95K2n2+p9M6q0YAIuMUmPUF/vbnyIL4lG3oOQywdJh2sWEDIsAssKqEVWKEA2NYDjx7blh3M2nJz75w41RBjYW4qcGKirsYhlfQ=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791335051; c=relaxed/simple;
	bh=34+hLm/dtcXWQPAdlpSSkFezaDmXxH5dP23x4wTWEig=;
	h=Message-ID:Date:Subject:To:Cc:References:From:In-Reply-To:
	 Content-Type:MIME-Version; b=p0tfzthX5UbQ9gn1nwBw1qTeQkKeLh6lVe3VyIj/DPwBjf0OTTaqFQop37b509QGdAek3nFaZc5YTpSOYtCw0L2z3GoULG/FBz3KOCKN1G6iKPhUNOokF5bMca+8fPzKAqDLYRE1xC51GJyswDLUOctzATa5BOPxrvR0e/4l5rw=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com; spf=pass smtp.mailfrom=oracle.com; dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b=J3b6RmaN; dkim=pass (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b=fbWFjQl6; arc=fail smtp.client-ip=205.220.177.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oracle.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="J3b6RmaN";
	dkim=pass (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b="fbWFjQl6"
Received: from pps.filterd (m0246630.ppops.net [127.0.0.1])
	by mx0b-00069f02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 696LaucZ824764;
	Wed, 7 Oct 2026 01:04:03 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=
	corp-2025-04-25; bh=B3+TDSjWYrxUdsdMftEsAuH+mR2BESzInYWmHchJKoA=; b=
	J3b6RmaNJcTM1DUZj19NHp/Qeqzca3FlxZdKehInlzgeiWVZMjoFa3a+xkMoGIk4
	8i2+mRlCgVhi7eGmSNTrmgrEYLTg/a73pqIXl2q8P6vmYfTkmOeFWzxYeUJ+dZvb
	sR+TRXERLrOt6/lOwYMbKN54U3SpNVJ9KL7ME/FiULh6CUK9kwhR5wB0ZhrjSpRg
	+nsTIRB91DOnq/PIY5YW8f73eDoco8fHqkjumpQkAxpGrgCWQ7WnRqSYeou0oxcv
	uU7aDZkvEoPxUuFq6feEQ7Y99SoMjnXG4ACZMv6VuAD21rxP1Bet6s68yMU51ZOn
	gLkp26ORXaLPF1Q9blMwxg==
Received: from phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (phxpaimrmta01.appoci.oracle.com [138.1.114.2])
	by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 4h2r4bcx94-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 07 Oct 2026 01:04:03 +0000 (GMT)
Received: from pps.filterd (phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com [127.0.0.1])
	by phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (8.18.1.7/8.18.1.7) with ESMTP id 6970pMSY015525;
	Wed, 7 Oct 2026 01:04:02 GMT
Received: from sn4pr2101cu001.outbound.protection.outlook.com (mail-southcentralusazon11012028.outbound.protection.outlook.com [40.93.195.28])
	by phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (PPS) with ESMTPS id 4h4d00bac3-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 07 Oct 2026 01:04:02 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=fMhLV23ikYbqMt4Sd5hO/bEmAtFanU4Xsy1DVRtFy2E2sa0K+tSEkGkiUFnd+dGMLIQtKk6OqMZUYx/xyz2J9xleDF0Wo2KfxgSJK+2d3ZiLjsxBcJor6axeCQ67XwD2e1rfSjU52xLx4K4swiBUzvQR25DpRPmYSWnSP5O0qefOFAlU6weHDoH4mwOub9uPwZ7Ym7GVc9U79xp4BgcRnFNe3Zfkjp3V7AT/VHMUbXDRPOGjxjXZK7yvcQaZtofPccdMbhl1EzglMPLcw7XhVlkGDQU3oRihPkFR4CMTe9zgfTzp9XYlzFn7/mKVXBFLgVwEPm1J/oAuBOyW7M5BPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=B3+TDSjWYrxUdsdMftEsAuH+mR2BESzInYWmHchJKoA=;
 b=aCRdDpoa+k9GFgbM/2UHDLI0tSm0bW9u2ObWf4qbeq9ZDCPxpJcHmFUg1y/bL4paOvq6CbmXM6Mz2T0ytUKKotpnXLbUtUR6GwXxYpyrkcy8UcuydIvEewZ2N4HXFL4jk+IE6rMwIBve01bVx+4QwNBeLsx007kqXseddzga6gosBvA/ywi/MluUmPUhl4xMM49N4VrsH30cGobKoq4R9vQ+fiWKr2DnULiE5KojqT0CB4fl1JGZVHv9K1LSYuHCMuqtAyrU+QFD/RzSpgZng5s+6GBu1dSfz6TwzutToRlPflc7CcfbBx6VcvuCw7bpxjZLipaDlTaSXHd/1keOfQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=B3+TDSjWYrxUdsdMftEsAuH+mR2BESzInYWmHchJKoA=;
 b=fbWFjQl6vFKFMggg3A6yWeLqeRaZC92Y6Ps13NnmFP2E5kKp+jszwpFmpicNkWK/HBAEWzh9fCkqgEf9nzQJKinp2wC8kNxs9kodcoO52kUQFIvjPoKO9sTo33cuvXQbPLYTKD6cYpcuYET1t24kFvr4YWuuD19mV4D0qDA3Hc4=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=oracle.com;
Received: from LV3PR10MB7796.namprd10.prod.outlook.com (2603:10b6:408:1ae::6)
 by DS0PR10MB8030.namprd10.prod.outlook.com (2603:10b6:8:1f7::9) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.496.14; Wed, 7 Oct
 2026 01:03:42 +0000
Received: from LV3PR10MB7796.namprd10.prod.outlook.com
 ([fe80::a30e:ee88:c7b4:c0d8]) by LV3PR10MB7796.namprd10.prod.outlook.com
 ([fe80::a30e:ee88:c7b4:c0d8%5]) with mapi id 15.21.0472.012; Wed, 7 Oct 2026
 01:03:42 +0000
Message-ID: <8e4adbff-56d0-424c-b647-553dc0aba5d1@oracle.com>
Date: Tue, 6 Oct 2026 18:03:39 -0700
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] SUNRPC: add transport details to timeout diagnostics
To: Anna Schumaker <anna@kernel.org>, Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>,
        Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
        Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
        Tom Talpey <tom@talpey.com>
References: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
 <6213dd5a-ec6d-46b8-962a-53f05db796ca@app.fastmail.com>
Content-Language: en-US
From: manjunath.b.patil@oracle.com
In-Reply-To: <6213dd5a-ec6d-46b8-962a-53f05db796ca@app.fastmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: PH8P223CA0003.NAMP223.PROD.OUTLOOK.COM
 (2603:10b6:510:2db::15) To LV3PR10MB7796.namprd10.prod.outlook.com
 (2603:10b6:408:1ae::6)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: LV3PR10MB7796:EE_|DS0PR10MB8030:EE_
X-MS-Office365-Filtering-Correlation-Id: 967f305a-5e13-4510-d03e-08df240ed48f
X-LD-Processed: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b,ExtAddr
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
 BCL:0;ARA:13230040|23010399003|366016|1800799024|376014|22082099003|18002099003|4143699003|56012099006|10067099003;
X-Microsoft-Antispam-Message-Info:
 Sxv36omSnFYpGCWMaNaEPNNOnZHq+wG6ENSxBJj1HEGIGWrYn7gPAnkEuJ77ixM6aZZfRkS8cLCB66Om/P7EZbREiAlgufqRKdwSY90D5Ta4KaXcthkbZrJ9qLyPO2VuG0X26AIRcEBDOh+vdGDa+wOdmpKCpEN0M4SCdAYD3I73tpb2rOtAHs/ZisB+VUMYwlA6DPg/fMYUDpMGRfkHHWnb3kWCwRcU8n5rDHwbUpxSj8tlu1FGSWqhNuRv3KUcwxJljF8GtEWsi+nIBFcw1t+qww2yjM69hS2uRtStbx9U3rLyPY95sq1stbk+Cl9CHBVg4K6aDx7m9vzfMzIX1bcvmZ0jPn6jO0kiZgekz5vdfY5bZynhxD6ma1htsDJV8xwDSp0efu6sBiF2g/Z0EbrZxlxwlkxcirRqh8EmNNVKJKfzeAH8oSuK+I+pyAXi+gP4UNDmQYE3BfDA0RhQp3Y7LiecrWXK1I6qlYNDFn0Zb/RSymwEoOq0JWUgg5aHx6lF4k8rePd7DmgzYEk7+/L76ISjXzjGZMHLd7QEOYw9xpwu+wRC4gVtPf4PbLMAHU8DL/KF4bEMgG4hBwR1+UvqohYsAxG/oamAsUrojX5ZUH86CfYIZEGCi2X4KPPCS82r+sOBVdCrQvTKIOJkd07O41FEI3IhrLvVpHEzEkc=
X-Forefront-Antispam-Report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:LV3PR10MB7796.namprd10.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(366016)(1800799024)(376014)(22082099003)(18002099003)(4143699003)(56012099006)(10067099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
 =?utf-8?B?ZURhcDlLdnpJTWFwc0RQOGJvTnhpRysvTTdEVFF2cFFFS1hmWTZiWXovbUUv?=
 =?utf-8?B?YWlleW52TDlFMTY3Sktzazd5MDNDSzNLNnhvaVptTUhIT0dia1REZUZqSFcy?=
 =?utf-8?B?VUZLbXVMcFVKTEZCWGlLWUFJZGtpTEtUUHYvQUl3cGxKSUtFYkR6bHIwNjY3?=
 =?utf-8?B?MW9venlqMFo1clY3c3lXYnAzY2wxc2pmMnNjQzhDQVBqbzlHM1Y4UHBhWXZE?=
 =?utf-8?B?Q2pJa09HVitXWmJUWkdJUzdFazY2eHI2WkxGUW9FQ0gwUmZMTG1RYVJSQ1pN?=
 =?utf-8?B?b2RIblZGb1hOWTRlWE5OTElCYnhpWXVJNVRMd0VUdXpmcmNvTWVndGE4R1po?=
 =?utf-8?B?ckFlbXFYS2hNSkVBUHJJbGJwWHo5S0V0ZHpIZm9uZkp3c3FFWmxzT29qQS9H?=
 =?utf-8?B?Rnk0aWZrQVBFUFlKVGNWcTc3MzJveS9nTytYTUJXZnFGYm5FUFVqbnI3K3pG?=
 =?utf-8?B?OGNJQzhDR0xZYTdSTXk1SllpVjZOZTNGWVV4YjJodXI1TmVxNmxUcDJwUjcz?=
 =?utf-8?B?UFk3eVlndmhiWEcwaVFLYzFLbUhhcGl6bHlya3c5N1I4S3hGMVZPWklYSW02?=
 =?utf-8?B?VVNqaHZJcHN4K0NSa0N6bUp0VjJid0w5aUtxeXR3czcySlNhM0x1MzlRbDdt?=
 =?utf-8?B?Zy9WSWUrZFd0a0c4RnYwTk02cXZxeEVCUmJMLzdLS1lxUTJYbnF0TXNneWly?=
 =?utf-8?B?dEtURjRWRUI1VVZFcno5dHRTV2o5eEg0cnc2ckpvSVZxQVNGbDg3L3VDOThV?=
 =?utf-8?B?SWFiaE45OHNxeUNrbDVlTkQ2U09PcTRHdUpQR0Q1WmFiVzc1MDNVak5mU05K?=
 =?utf-8?B?dFZweCtYU3RqcStSa2E4SmNHN2w3Z2RoQUkrRFpOVElZVjAvV3NPWFZEOTlJ?=
 =?utf-8?B?TFpoekhXVXhubUYrYUwrWWtQbFJuaW9DUXRObVRzL1lVMDJrN1BjWk9FWXFq?=
 =?utf-8?B?OW11UUdjZUpUTVFMdnMyVFNXV1lYbXhCcFphbHEreDdWMTY2OWdEWHJNSGV1?=
 =?utf-8?B?M3NEMDIzZzd4bzJBWDlrVGR0Y2RMMEg4YVR0U3JGVjVXK2VRQ0loanBBRndl?=
 =?utf-8?B?LzloN2hzcFFiRHl3QS91WGNJOVF3K211Rk1pb1lUdnVCR2RmQnluMlNvN2lM?=
 =?utf-8?B?UFI4bGx5ajhUd2Jyck9Yb2djVXdmbmZNeEZmSzZsRFJBTE1lNk5ZMUxLaW16?=
 =?utf-8?B?VUVTcnJGSzI5M1k3UVhpZVpZVFZSQkxac2pEV3RHY2lIeXlEWElrUDg1TnVz?=
 =?utf-8?B?RXkwNXkvTmJGT2J3c3BHWTE2RHN4UktETUtSNXBOYlRvSEREd3ZRMS9odFpu?=
 =?utf-8?B?NjlqNXhJWEY3Sk45MzluNjM2Nk5HQWFYc1k2NllqYjZjeFhKQnpSMU52dDB1?=
 =?utf-8?B?Uk4vZ3pYY05wbzU1d2NoY1JzNkp5NHlBTW9nanRjUml0ZndXU3B4UWhTeG5m?=
 =?utf-8?B?NnExa0FNWG9mNWorcUxIVnNDdFNDeFJyUEVIamg4RGpLZExRbEMzUXRhN1lT?=
 =?utf-8?B?MEFiYkJiNVdrOHovTEdmOE44Sk1MOS81Rzd6RjdmZ0dvZE1tK01GajlhMVZX?=
 =?utf-8?B?RGhLb3N1NDBtV2NBejRQM1dxK2MwdDhDQkVkajBzdkJxSm1ZNThpczJyNDIz?=
 =?utf-8?B?ckFub1J5dCszNFB0ZmlNVFNHT0hlYVZtU0dhTkxSK1VDTVhMOTJMSWFjc2lJ?=
 =?utf-8?B?SnZ4anY3WmphTThnLy9ubmRCeksxekg1THY1NGNPRDRaNmdLL0dKRDd4OWFk?=
 =?utf-8?B?WW5lN0p4RTdXZzVuUDVWcjJoOTd4Uld3YkVEVnpnU0luTDFTakJJWFRvK3p0?=
 =?utf-8?B?YjMyUnc1cFU5VHMwSHBIZmRVbUsvMmtQNStvYzBZUGdLcVFRYUNPcUZHRkNW?=
 =?utf-8?B?aTNWZE1VVGdkNisybXpLT2h6ZDNTNHJSUU5iWVVxMC9kSFU4UUs2UlJRQktJ?=
 =?utf-8?B?dXVyRU92RG9uLzBvWmc5VHRSSHVvZmtzNjgrUUpzMmNhVUh4dnh2U2ZtRmZr?=
 =?utf-8?B?VG1mcER0Vlc3Kzc0OG5GNmRGVmVqN1N6eUdUWW5PeEdSMjRySnBBdEsvOFpv?=
 =?utf-8?B?VjhWdHVNdUxFd3NRVGZETU5IUVRrUnk1cjdWZm5HeFM2UGNPZEkzcEVoZDFt?=
 =?utf-8?B?RFF4ejVRejkzaXI5THU1OFNQK2xSQy9jWEkwOTFIS2RHQ01hZUJRb1ZTdUhs?=
 =?utf-8?B?ZDVqSkVCbHptaUhFak1pTElGUzY1RE9jazdscmUzWUV3ZjNQNDFJaFBXQ0gx?=
 =?utf-8?B?MGxaM3BFVktDa2UzNGl5d0M4SWRCbFdSZStOenJ4ZU1zL3JuWksyRDVUY2N0?=
 =?utf-8?B?SFlUOVl3eUx1QnF1WWVwQU0vWnJJQWJiMFdCdG5Rb3dQb3JDQ3Z4ejV5VEh3?=
 =?utf-8?Q?WIcAboor+fXhq1PY=3D?=
X-Exchange-RoutingPolicyChecked:
	UjldaaUbcgD/mxVtIOYHWjmDgPpxWPbCnKu/SqrCKyks3xg0q84SbKEkwXFSyATccowR7Uu8jswNwE2LZc65HwysMGlyORj0QeJ0ityF69BLN0xj95hwfRkHOy3j86rIOrZzRldKGbW1ykbe79oqTWaD/hKRvCZwxTGKuICd6ZDJmHMbqGN7vA0BgmpPTSEOp9kvIxhByhf9q3MLvjFJGhfaopriZlLquoiqD8vMCflkaDU1oZZdFylHSgWTep3Ec31VoUNS0eMTyKsLKDdXh/K22jVP2PokboMqDURlGNii9C3FuMTJeY5GSe6qOt/4uhzKBLkrBqm9hpFhr47ktw==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	FYLuHacFeMOlg2seeT8PKxVSil/IXFtL9nNQttwstRcGTNztq6Qrlw/AAOHPqHKakSwCiMjZ9467Dogha6SHxBUudH6tt2hPzy8jtS6jJrynuWH2silPFcD7O/gG8Tp99iDuk4QmmPwS62mj23icCNFhXhcvSa2K9Lkeqh0OahFyLV8LZuGKADdc+nN7TABOEWAc3dVda9dzWw6PY+VM6rIDwsRlUbVd4Ln9pGxvI+pcvUWNdRFUJSpVi7+MvXY1T+WJsepCO40kAReRWxqQKYWD6KR6GBlYgt+IjJvZ6bzpvUauG7mFKT8bWvjT75HlI/AYapxYm1nU5g5daCXLiSLWduVJiOd69MJjxPP4g4Bnc45gsVuc7siG/4EAyVKaYaXv7HsJuODK/8y4xfhIiLjZXl0XcTolmeLeodkwhVxXBbXziYu509nqMU0cFkRGWonYS/sfabpU93agsAxe2bynA55IjmNhcMTunE/M8gS+xbr09a5gWe7X4anUbSbE6N/WpMlTXJ4NQx4VywWj2fHT+EIHr09hIX+HQKczCus61pkCg4ulJYIOtIZ4xu7Uf8wo2TWg2fifT4mtWeBDlmOwkLGtwKR8Nduhvavr+o4=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 967f305a-5e13-4510-d03e-08df240ed48f
X-MS-Exchange-CrossTenant-AuthSource: LV3PR10MB7796.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 07 Oct 2026 01:03:42.6622
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: pGC80dvTsYLhoQq3LfvRrYPA61oT+9A3lB+e3TeD6megg9RFhvESmT3Jza4qIxZHizrtdO3JwP6QEtKOHHn+qWJYz9Mh7KpN3EgdDy0te3c=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS0PR10MB8030
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-10-06_05,2026-10-06_03,2025-10-01_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0
 malwarescore=0 spamscore=0 mlxlogscore=999 bulkscore=0 mlxscore=0
 adultscore=0 phishscore=0 lowpriorityscore=0 classifier=spam adjust=0
 reason=mlx scancount=1 engine=8.19.0-2609040000 definitions=main-2610070003
X-Proofpoint-GUID: zfyavhnaeFQGCdvwMemCnwuK2xLVqtF2
X-Proofpoint-ORIG-GUID: zfyavhnaeFQGCdvwMemCnwuK2xLVqtF2
X-Authority-Analysis: v=2.4 cv=BIQmP1QG c=1 sm=1 tr=0 ts=6ac59a83 cx=c_pps
 a=XiAAW1AwiKB2Y8Wsi+sD2Q==:117 a=XiAAW1AwiKB2Y8Wsi+sD2Q==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=z/mQ4Ysz8XfWz/Q5cLBRGdckG28=:19
 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=xqWC_Br6kY4A:10 a=IkcTkHD0fZMA:10
 a=660iZSQnnn4A:10 a=GoEa3M9JfhUA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=jiCTI4zE5U7BLdzWsZGv:22 a=x4eqshVgHu-cdnggieHk:22 a=yPCof4ZbAAAA:8
 a=KjRvWWDhnMZKPBrBJfEA:9 a=QEXdDO2ut3YA:10
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDA3MDAwMyBTYWx0ZWRfX7+zkbv/GwsqS
 sneDWywTPuoYfqfRvQljvLoXT69bUlRyvn60EzJcFltzDoc3ZZIUNCVXaeO0KAvslwdpy8UsgA8
 Ct5FmyZ7PU4IVcTXlqzpnaMNnG4dctKg8KO2+UtbFMIZngszVJQT
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDA3MDAwMyBTYWx0ZWRfX0Kx4X8qAPp1B
 +5oXj4BjIK2uFKsZBpS5eCtsaetTm2ubIj8ENM2TmJOTkdG9aTDKaBu4KG5Cdv5/4YylUWAOTN/
 l4dvoPdsiGJq0iILGZ0y9yXVAlLfxLPCT3sSiiulkhH54WA8c4Dv34zi+P9vKtnQxaFQwrQdlYD
 7Y4NxkghhHFzHaLlvNS5DEqVnzQCNK8I/dBWwqVxlb3IDr4LG5a0U6c+cspsKyOE7Q6a5m1STTb
 BCfCJFnMPzZWYkGveWQ5WbyfRjAcYMLyInOdwkFlrnQykwnITdZWWKSz7kJ2LiI97DMpNjMadT5
 k0hJzjTF64M7+6+2XNF6iEl9IktFpOzA7U1xI2jiOVtrKS2+5Rn28Y3otR6rV/8sbO/qq9yGJ6R
 phlQKqR8a7b+jMmkZJNmzFRY7p5DCo4P4yPGn3BhITVlYAkv/cmCxr4fudiwexzfbXNJzpxOwbz
 ZcZ62NNMftrIrUAtdlw==

On 10/6/26 2:23 PM, Anna Schumaker wrote:
> Hi Manjunath,
> 
> On Wed, Aug 19, 2026, at 1:30 PM, Manjunath Patil wrote:
>> The existing RPC timeout messages identify only the RPC program and
>> server name. That makes it difficult to distinguish a server-side
>> response stall from a transport that is disconnected, reconnecting,
>> or using a different connection.
>>
>> Include the RPC client id, transport id, current transport connection
>> cookie, and RPC task owner in the ratelimited timeout messages. These
>> fields provide a compact way to correlate a timeout message with
>> rpcctl and other transport state.
>>
>> For example, an NFS timeout reports:
>>
>>    nfs: server 192.168.50.1 clid=4 xprt=1 cc=1 owner=6245
>>    not responding, timed out
>>
>> Assisted-by: Codex:gpt-5
>> Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
>> ---
>>   net/sunrpc/clnt.c | 20 +++++++++++++-------
>>   1 file changed, 13 insertions(+), 7 deletions(-)
>>
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index efa26899bc7d..6b5e2787dc81 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -2534,17 +2534,21 @@ static void
>>   rpc_check_timeout(struct rpc_task *task)
>>   {
>>   	struct rpc_clnt	*clnt = task->tk_client;
>> +	struct rpc_rqst	*req;
>> +	struct rpc_xprt	*xprt;
>>
>>   	if (RPC_SIGNALLED(task))
>>   		return;
>>
>> -	if (xprt_adjust_timeout(task->tk_rqstp) == 0)
>> +	req = task->tk_rqstp;
>> +	if (xprt_adjust_timeout(req) == 0)
>>   		return;
>> +	xprt = req->rq_xprt;
>>
>>   	trace_rpc_timeout_status(task);
>>   	task->tk_timeouts++;
>>
>> -	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(task->tk_rqstp)) {
>> +	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(req)) {
>>   		rpc_call_rpcerror(task, -ETIMEDOUT);
>>   		return;
>>   	}
>> @@ -2556,14 +2560,15 @@ rpc_check_timeout(struct rpc_task *task)
>>   		 * connection gets terminally broken.
>>   		 */
>>   		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
>> -		    rpc_check_connected(task->tk_rqstp))
>> +		    rpc_check_connected(req))
>>   			return;
>>
>>   		if (clnt->cl_chatty) {
>>   			pr_notice_ratelimited(
>> -				"%s: server %s not responding, timed out\n",
>> +				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding,
>> timed out\n",
>>   				clnt->cl_program->name,
>> -				task->tk_xprt->servername);
>> +				xprt->servername, clnt->cl_clid, xprt->id,
>> +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
>>   		}
>>   		if (task->tk_flags & RPC_TASK_TIMEOUT)
>>   			rpc_call_rpcerror(task, -ETIMEDOUT);
>> @@ -2576,9 +2581,10 @@ rpc_check_timeout(struct rpc_task *task)
>>   		task->tk_flags |= RPC_CALL_MAJORSEEN;
>>   		if (clnt->cl_chatty) {
>>   			pr_notice_ratelimited(
>> -				"%s: server %s not responding, still trying\n",
>> +				"%s: server %s clid=%u xprt=%u cc=%u owner=%d not responding,
>> still trying\n",
> 
> More observability around this makes sense. Any reason you're adding to the notice
> here and not making it a new tracepoint for the extra information? I'm worried
> people might have tooling around watching for unresponsive servers and this
> might break whatever regexes they're using to look for this.
> 
> Anna
Hi Anna,

We added these identifiers to the ratelimited notice so they would be 
available in ordinary production logs after an intermittent NFS outage. 
A tracepoint would help only if tracing had been enabled and retained 
beforehand. In our investigation, the existing notice identified the 
server but not which RPC client, transport, or connection generation was 
involved.

I understand the concern about log parsers. The patch retains the 
notice's opening and closing phrases, though some parsers may still 
depend on its exact format. I considered a separate log line, but that 
would add noise to production logs.

Thanks,
Manjunath
> 
>>   				clnt->cl_program->name,
>> -				task->tk_xprt->servername);
>> +				xprt->servername, clnt->cl_clid, xprt->id,
>> +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
>>   		}
>>   	}
>>   	rpc_force_rebind(clnt);
>> -- 
>> 2.47.3

