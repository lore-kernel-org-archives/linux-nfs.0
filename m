Received: from mx0b-00069f02.pphosted.com (mx0b-00069f02.pphosted.com [205.220.177.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5A5225C6EE
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2026 16:17:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=205.220.177.32
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787242639; cv=fail; b=DENwCghusPclqLOX4n8aKpW5lNNlulI+bz5XF7j4ILC0Gpemksd7KRqfE8to3ehWfpWgF9e3jEvblJmZc3Yamzi+fewCgljGyxrjqkcqTciS7eYeCMYTKhVIJq+qxp6xE2CVX9q+D/YOFM0tZR5nWO4TCO+Azg9jJcii4bEb2MA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787242639; c=relaxed/simple;
	bh=szEY3UwUB4lgEOI5EIMqKK1cRgvJLZc7vyBqRHXGUJA=;
	h=Message-ID:Date:Subject:To:Cc:References:From:In-Reply-To:
	 MIME-Version:Content-Type; b=X9unkw58UfeD3yYnvAm223/gRZEcUtuNZ1RTgu1teh/zkWI1ZUrDK9AyC6xtPaQ/OTtN1yE73/SdQN6DvrcdmbTuLGWR7pO+uaJ5RzgaVTtp+wrIKqrr0yZpnQN2reslKRYhhi3gzrbXE3zM93nBj68YLfsamVMtRQ2QlaLb5tA=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com; spf=pass smtp.mailfrom=oracle.com; dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b=Pao57nsF; dkim=fail (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b=HqobDrcI reason="signature verification failed"; arc=fail smtp.client-ip=205.220.177.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oracle.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Pao57nsF";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b="HqobDrcI"
Received: from pps.filterd (m0333520.ppops.net [127.0.0.1])
	by mx0b-00069f02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67KDP46K1280977;
	Thu, 20 Aug 2026 16:16:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=
	corp-2025-04-25; bh=qdjIhlwAtcIXTgebAU2nkue4pGIM/E8m5KKHMGlNFRQ=; b=
	Pao57nsFcb725UroKL7JVfJvHdiJi9/2MRBbCQFXw1Ra++Sq0h1w64/9n5AeS0ak
	28//Tzoh/9MlQxr6jrpsFWHqOZmIQ+W2ic/buUCRZaAomwkHWlUwVblxiHGPabz+
	022NXlLskgHe8kIU8NUtkcK5tBI+uTrr6m7QKyJcw4Pxck35kFcirNpMQBNYvYL9
	vM5NVDn8I3Q0b97LEkrhzb4b9GCycKRESz74DeIPT8kWmPKcXzkG+k/HqKLK3RB2
	iy8p0Y7Gta6RpMpYrPOBVqHYGWgL0foLU7eCNYbs+NmoCTl64vOPlg/whI7UVu5q
	CUVg4FEk5acbg3UDuWMlEw==
Received: from phxpaimrmta02.imrmtpd1.prodappphxaev1.oraclevcn.com (phxpaimrmta02.appoci.oracle.com [147.154.114.232])
	by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 4g4yd9bqmq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 20 Aug 2026 16:16:04 +0000 (GMT)
Received: from pps.filterd (phxpaimrmta02.imrmtpd1.prodappphxaev1.oraclevcn.com [127.0.0.1])
	by phxpaimrmta02.imrmtpd1.prodappphxaev1.oraclevcn.com (8.18.1.7/8.18.1.7) with ESMTP id 67KGFACV030302;
	Thu, 20 Aug 2026 16:16:03 GMT
Received: from bn1pr04cu002.outbound.protection.outlook.com (mail-eastus2azon11010045.outbound.protection.outlook.com [52.101.56.45])
	by phxpaimrmta02.imrmtpd1.prodappphxaev1.oraclevcn.com (PPS) with ESMTPS id 4g2ejfnww7-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 20 Aug 2026 16:16:03 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Mmo9BSzhN4iU2F3NEou/H7bxuGUPp6JTxuCRmNQC8pGypcFZgtWF7JLAOUPz6w0tPR9her+B4FMRV2i3FrGmWYiJg5IHR6gK97x9HL3BhWULVTcAT2Qb13d0IERqgBwuO8LTJpYJpY3728cisseg/jb8TIcFhQK7FO2y848k/zgk1cowFyKcJS8QDcc3AJiemxDOYuAtcPsysmWEfchG51Pv78SiQ7vDbX9Gr4npFhph7/5nsJ9Eiw2NsmjSKbxljTn93dAI2j2WHT+bRFsKt/y/RVO/YVNNst8hWU8VGETG5B/v9Aox/wPHJon6o7kK4c02LM3eZQWU4lSjyK09Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Pk1GrfG8YxTQm4xDpqrpQ7Ztp0Xhf++QsQiXPtMzmJ8=;
 b=MyXMEZYONeokXzzJZ9otqS9IgoIg7drCx6WzBOlxnF+Ui8+oTWQD+rf8pU8sHb6sVW80tGFbD/BRvVBePq/DtYykZlhOkiXVq6NCR4tUtvfhROga5NvkSIhPmi3j/+DEcFIhtFXcPq89ujhbuPM7Ot3UGKE8pLl492A96W6z9xia/G9f0V+HDBNSMTa2yxaeZdW5PugGYMErKaVsh75HNT33crr5K0MRvp7u0wXRjJ9dgzfn/QaTnXSIwYVP9Mrj4y7kOliuWpJx5KSkWZwRu0mggjflLZvr46GjRL11/7TFSV7yOvO6cTsGO5Rs86HHS0p0ThPnoC7ERkadeS5wpQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Pk1GrfG8YxTQm4xDpqrpQ7Ztp0Xhf++QsQiXPtMzmJ8=;
 b=HqobDrcIBI6epByFOdWbJEyy8bkaRRpleFgMGU3Gf7m7SnzvsT8CzSlgDTS8CCAox+T0Zv2pWNoQqlEDUc5i1D8BtNdwJH2P1Aq33YIkaVghok2OMqnOFBfvlHaqm+rllvipa6IC5u1YnKsy13LFG1aA+0QcoIA32Z6eglzeulo=
Received: from LV3PR10MB7796.namprd10.prod.outlook.com (2603:10b6:408:1ae::6)
 by CH3PR10MB6689.namprd10.prod.outlook.com (2603:10b6:610:153::21) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.339.8; Thu, 20 Aug
 2026 16:15:58 +0000
Received: from LV3PR10MB7796.namprd10.prod.outlook.com
 ([fe80::a30e:ee88:c7b4:c0d8]) by LV3PR10MB7796.namprd10.prod.outlook.com
 ([fe80::a30e:ee88:c7b4:c0d8%4]) with mapi id 15.21.0339.008; Thu, 20 Aug 2026
 16:15:58 +0000
Message-ID: <8e43238e-f06d-4da1-a898-2bdc1d827e81@oracle.com>
Date: Thu, 20 Aug 2026 09:15:56 -0700
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] SUNRPC: add transport details to timeout diagnostics
To: Petr Vorel <pvorel@suse.cz>
Cc: Dai.Ngo@oracle.com, anna@kernel.org, cel@kernel.org, jlayton@kernel.org,
        linux-nfs@vger.kernel.org, neil@brown.name, okorniev@redhat.com,
        tom@talpey.com, trondmy@kernel.org
References: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
 <20260820111303.455807-1-pvorel@suse.cz>
Content-Language: en-US
From: manjunath.b.patil@oracle.com
In-Reply-To: <20260820111303.455807-1-pvorel@suse.cz>
X-ClientProxiedBy: PH8PR15CA0016.namprd15.prod.outlook.com
 (2603:10b6:510:2d2::26) To LV3PR10MB7796.namprd10.prod.outlook.com
 (2603:10b6:408:1ae::6)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: LV3PR10MB7796:EE_|CH3PR10MB6689:EE_
X-MS-Office365-Filtering-Correlation-Id: 26abe026-4bf9-4372-87fb-08defed651f5
X-LD-Processed: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b,ExtAddr
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
 BCL:0;ARA:13230040|1800799024|366016|376014|23010399003|22082099003|18002099003|56012099006|4133799003|4143699003|10067099003;
X-Microsoft-Antispam-Message-Info:
 vFgKhsnXtGcJfqPl3hXhkBvT+y5XRuism71/gJARKwfTTAhKUWcn81ZxVxVLzl3wStFavLe4HCUNsIM9T48rpi5uJHmmFi2smYmrIYKhbmpK+gdJK+XYhUBg/jo1CI4yth2DBXK3A2sRU5jdUTZTloMsdnp3CehwYxwAsnUpCaCCoSYr9eaoLaLEajglVs6JNhx9thNkYAsPvObt6i9UcshbeomM2eHnJPmzNpODx3Lhk6k32cwiod2cG9zZTExbnT+VLJhmmB941OZCPT7eDMXnagTUPrmsZa7Zyep32hKBPlEVAGT1Lcvdc6JQwbaGCOzAdr31nOCa4T9ZMqPDQUTOg4OzromY2ejSSu42X6X/BMow/MGs0KXj4c9aPeXBVK0bhhY1lmGkpb/htpMEHLPOUlDDxZrT9Y1BxNPmBi7G/BYodCce/7MRsmGsP3Wmc+QQCDI2w4TWCNZTZwG2tHAjJ/sp11XCNKtn1oV2KdhNLAOLXguQaJGD3thb90ybWYJNQ6psLeTLu+FkftdqlDZpFPiMylFKpID0d43WbirHA/HdACiMsYsAER/YDFrDMw7FWIIG61Dw43QFXux37svBolqHU4I9qQCIhXZiHduMB7tR6am2A5P0CAOvdJyijOsW6eF7QRszqNhQkhmK3aSmZZCkFdXruoW8rP5PJ4c=
X-Forefront-Antispam-Report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:LV3PR10MB7796.namprd10.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(366016)(376014)(23010399003)(22082099003)(18002099003)(56012099006)(4133799003)(4143699003)(10067099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
 =?utf-8?B?bUlDMDdxNnZodHFXZmpzeXlMUkZvbEVKMStmMVpUTGx0ZmNkd3hUQy8wWktR?=
 =?utf-8?B?b2xGdnd1Wmh3TjcwSlE1Q0JlZG9nS3B4dXJrNzRuUk91WW5wVStYZjJDU0Ux?=
 =?utf-8?B?OE83OU0rYitrbkVaUTJ5TzF2TnZWYUQ3SE8zV0xwbDAxMmJoT3h4SWExaHR5?=
 =?utf-8?B?SU1RZmliS0YrckRaSkFzei8zTXRYMExFb2R4VnZxNkNLYlJGanFZWStvd3B2?=
 =?utf-8?B?R05qTUdDcC9Jc0VVUXBqamo3ZWs2R3Q1MjFZeWl2WmplSjh0Z1VGOVpsa1l6?=
 =?utf-8?B?QmRPOFhFUk5iWDl6RDA5WGlVVzJBTkUya0dZKzN2eG5VVXVpRjI3ZE9jcHFv?=
 =?utf-8?B?cXhNWkZsUis5djNpOGNDYnBUTkhjUDRqeks3Ly9BOTFTSnRRY2QvQTBpOEc4?=
 =?utf-8?B?dkt3d0xBeXpyUUJsVE5uc2NJWkptV05pSnVPemRxdFFtZ2o0TE1aU2EyVW5m?=
 =?utf-8?B?TjloM2R4bi95elRUeHVXdEpTTXlGb1B2d28zZWEyaDUxTTVsQW8ydUlVNDJq?=
 =?utf-8?B?eWJWTmZQOXc4YnpDUFZEdksvZ2x0NCt1M0ZiTElVRDJoOVVUQjdoZzRwcks4?=
 =?utf-8?B?UEdtT2gyWURxakpvQ3hEOGhXZ3JhQlJ6TjVmanFhVU5mUVk3eDhJWVQ1NTNm?=
 =?utf-8?B?L1B6UWpMR1NzSnQwa3JsaGx6TCtGN0NET1ZTR3ZKckFQbVgyb2NTVWtjL0ZE?=
 =?utf-8?B?cjNUaFdPb0VwZWRYR01tSWxFMEFtU3ZWeXJMajk0dmhqem1BSjRob0RUVVNj?=
 =?utf-8?B?dHlxbUxIQUdvSGdEMFZSbnNVSGZucHM0alVadHFBZ05zdDZXZkI3WWVWSHpz?=
 =?utf-8?B?VjBZRHdMZFg2VkRpN3d2YXZVTk8wZ1JQQ1dqNkx1UVMxZnQ3MVgwcWtJUGtR?=
 =?utf-8?B?WU9JSWJONmFqL3NuelJQVVNLSkxMVjIwTEEzL256SDQ2U3NkT2x0WXF6NDlP?=
 =?utf-8?B?OHpaemZCN3NqN3F0SXVlbGM3ZEtzdXNjcWU1Y1YzbGlSVjB3RTdZZVg2YTYy?=
 =?utf-8?B?UnlxTWIzTjJkOWtvYmdhV0NzVVM1Ui93T3Z1LzBkck9GZGJmcjVndVBhUXRJ?=
 =?utf-8?B?NUJSTENTdU94MWc1ZzdDOGs3dHNZNHdVTzNSazJocjhjVnpZYUNtaXdCVTNE?=
 =?utf-8?B?NmU4V3h6RnJjbWdHdVJVSGlMc1dadWtmdnZXU2hGQU0vc0R1cGlKem1hY3lM?=
 =?utf-8?B?RzRmOXRYQ0NkbXBpQWVLeVZxb2RWclNlSzVyK2xIWk1tcGpvNlBXakxjQlVP?=
 =?utf-8?B?a1hJMHlYOHFrNFFqVXpyVEtIb2hMSjhobGJoVUJtRUVQT2VXL3NBWDQ1d285?=
 =?utf-8?B?eUZGTWtiTGtaQTUza21GUHN0SGlMb0NWbnhrVy92K1hWdW1rblp5MEw3VFJp?=
 =?utf-8?B?WnlabDlLNUhaaHF5aEhBdC9ocFJDdUNnZHIxeUZVQm54ZTZHNGV0RFBBcXNy?=
 =?utf-8?B?TktWVWlyN3NVL2JKSjR6Ylc5Y3JiVFZUZ1d3bk8yQndtVS9pTWl6bmh0ZWg2?=
 =?utf-8?B?c0lSaVF0Y3BQU3YxMHhOWjV3ZC81R1MweWVDbUFhZzFvY2JWbm4vN3pXcjl6?=
 =?utf-8?B?UHRKb3l4VmRMZkRWOEZoc2Z5NmdRb3czSE9JKzlhc2ZjbUVaWjJyOWh2YnlY?=
 =?utf-8?B?NmFrNXp0MGJ5Qnh6ZEdQbTRpNVJsaWtNbFk5REViT05VVjRBd2c4OXV6blJQ?=
 =?utf-8?B?QXhBd0hWcEdEOFNFWUI2eEtwQWxEaitzWGVLRXhYU1QrQUl2NTQ0UzY2QXFJ?=
 =?utf-8?B?UXpNcnBrVDMzZzlDNTdNd3QzQlA0NStYODc4NDA5TzNJaldhUTJaaEZFWXFz?=
 =?utf-8?B?S3VFb2l4a1pvWGwrVEMzU3pFaW1CMUFTSDBZYi9HWTJidERrbkhURk1VM2Ja?=
 =?utf-8?B?cUNGSnRpZEtyajc4UkViZWl5WVppUno0OHYvR0l2T1lud1ZoZ1F5T0ZoaDhT?=
 =?utf-8?B?TUtNajZIdFQrNlpWOGVPYStwcW53WUFKQnpjSXlIYXpyTDRPSkhMOTRhWWJi?=
 =?utf-8?B?aFBhTEVzY1I0Y3FKU2lCeUlPbm9PVndJNVhUNFRoMGFRUDZDVFp1OXVCUm1x?=
 =?utf-8?B?OHFQUEQ1b3VxZWt0aEkvZTJ0SlRMTFEzbUdYdWl6bndiM1YzSG5rWmNMSDNE?=
 =?utf-8?B?RnZQa0FiRWorTTZFaE9hNEFrMnh3SDZGamV6WGhPTDBCZHNybStBd1hYdElk?=
 =?utf-8?B?b0laaFhEWVhvWG8zRUQrM2VnMXlXWkQ1d0kxeUFrbUgySWpaa1hYMjNlQTJZ?=
 =?utf-8?B?MjNmQkpaSDdEalUyTEh5NkhGV1hiMnpqcTZnSmdpWkx0dnNpWE4yQ0l6dnBC?=
 =?utf-8?B?R0R6QUR1cXJsb2VXdGRVMm0yazZORFJxeUIzZlNDWVYxdUdBcmNKUzJHb3k2?=
 =?utf-8?Q?hSk2zV5Og+tsZFVo=3D?=
X-Exchange-RoutingPolicyChecked:
	gcBoramUgUt+HVTwqYOLj/Qqiz1R+L+P19sairSn8a6gM5W1BwwAWWrfkAQQB5vlnvS/6jS+pHRDZYT9P3DE/VjxIqAgK3VnqUQE66tcrmDMFhz8ZD02zErccz74md/RFcYG7PbEyyxm+4nhLcKRB65tgMgL1cv7IRmUncvf4Jib6KfMd9wF7Ecubg9BWUvFn6LHxLSXgQoQ7n0Y9SImumqT9rv3Nd2RUmlkeHlS+xsshRBUEvImJHeGQeMwRhs4UvU6hZX0Jh6GW+luyYofzIdh+qTcDa+XLVZy8Gi2VNkh7svQorASDAf3kc1wvp75tIjFlCIOqDW7CW8LFHBLLg==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	CdRHv5VSfTpze7fixeB8TZtXemDhn++maXLP4fPhKA4TVcOab0FRuhZopJvu/5LNn+SLwE/DN0sDiGJ4l5/bpBKsWjavZXSUXhKy73IgQk3RfgQ2JrfdjJxY6nfobOmUXCjTOp9+eQRDhgZkcabE5uCPnTPiKKzVCkpzLUzJLRSLb+i97i0d1v6nPEh/JrAeduojxgEyAhL/ur7jro1idklwMRNLPrY44HQQ9S3ImR8jDkpv/eTfzcbRZMjz7zCj1P6XqfAsT1AbMz950NmjmlpomPYohn6ib5W0eMJXvuk6Dykz9ojVq/uEhBbDjmNrWIzKAD5aAh4J2FyFR9fGzAzLI/XuokRRKgnc/dcvlRr7DDgYuqrjiueRdhvt32pGUT0W627CEsIKR3K3DcYISvm0Q1MBqTQ9Ro1ldL50dtw8Yl0UqfXQhGuy8getDDMnAPz9KCdYSnDTMcooNZN+XTOLihsvmwuaiIuYvxITir4ttiywsPVKJZRrtmmqsbBl8of0F6D3Evhko5FB6kSl6N3egpste2RSHnIHVKt1/BotoxhmmzJ6YajP7Dyct20E97nv7MWb4S0FXJ1k6Gk1oa2ugzpHhl9Zlr5BcbKwJkw=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 26abe026-4bf9-4372-87fb-08defed651f5
X-MS-Exchange-CrossTenant-AuthSource: LV3PR10MB7796.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 20 Aug 2026 16:15:58.7518
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: d4EFhHu0z0eahuSGyY+2Ou37HWCZaJ9+Cc8QAkmUXOi3mgi6Dqyx5173aMS8cpIwDpaaxpJ8yL6jDojeFvGwAuecz7mjt/ed0NmT/A3aswY=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH3PR10MB6689
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-20_01,2026-08-20_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 phishscore=0
 lowpriorityscore=0 mlxscore=0 spamscore=0 suspectscore=0 bulkscore=0
 adultscore=0 malwarescore=0 mlxlogscore=999 classifier=spam adjust=0
 reason=mlx scancount=1 engine=8.19.0-2606160000 definitions=main-2608200123
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Spam-Info: AW1haW4tMjYwODIwMDEyMiBTYWx0ZWRfX30WqR0UlJEuO
 7VduGJC26C4649vdgCCR+PRIZk/cUo9eBlcd/YAcAIWSMIRvzPRU1sZgrfEISzQA7nxt7sFsKXa
 GCZcZTyU2PtNWDErAbH1L1AdNzLYlIl7o2tESAQklGQkiyjmgp6W
X-Proofpoint-GUID: ibtnutttyAOJAG8sHa7vpKP6cIVmk7Mr
X-Proofpoint-ORIG-GUID: ibtnutttyAOJAG8sHa7vpKP6cIVmk7Mr
X-Authority-Analysis: v=2.4 cv=fbCdDUQF c=1 sm=1 tr=0 ts=6a872844 cx=c_pps
 a=OOZaFjgC48PWsiFpTAqLcw==:117 a=OOZaFjgC48PWsiFpTAqLcw==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=z/mQ4Ysz8XfWz/Q5cLBRGdckG28=:19
 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=xqWC_Br6kY4A:10 a=IkcTkHD0fZMA:10
 a=Sv0fKeRqtYgA:10 a=GoEa3M9JfhUA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=jiCTI4zE5U7BLdzWsZGv:22 a=BqU2WV_vvsyTyxaotp0D:22 a=RpNjiQI2AAAA:8
 a=yPCof4ZbAAAA:8 a=1zhuLJ5USHvalsO02PkA:9 a=3ZKOabzyN94A:10 a=QEXdDO2ut3YA:10
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODIwMDEyMiBTYWx0ZWRfXzVBA2cYgSaV8
 CGYgd+iCibvZPGkvptDKAIY4/XS2EhcC7D0RYWFY3vG4ISbW6voDXKqmdUrC6JG7UdQtVowCj1p
 Jyh8NgOaUJXeSpomYeUxU5kQD/GiWMIM6YrxgGSou7CuaQXIvHIs8+L5/0PLPb4RlIj5odkV034
 kC8KulS/bpRA9bVW+yUphA8nDbTtI83HMqxJ0y2+9xYE55xVcLLFf5IcDcygWT5aW7LI/O+I57P
 YyMcnYqC0xxEL0uDvkijGqQ/k44JTwRSVenegHX5PIZ+qyNtKF2uZkKed/7w+Bbje7/jHsPNKPz
 votEabDKpxm8I/VuZ59pEK7xkwYVNEQ1ufP9b5IwGpzOLVRXvJy4Oim675MISg7tULYqfgEfcU7
 l9BdqerKCRlfrXQiL1QrLK/nC3xeMXXAbPWcvfH1hhjZ5jxPxN9Q38I5rpAoaqo/AWRtyqLFYzm
 bwwRsF8PUy3cOjvrkWw==



On 8/20/26 4:13 AM, Petr Vorel wrote:
>  > The existing RPC timeout messages identify only the RPC program and >=
=20
> server name. That makes it difficult to distinguish a server-side >=20
> response stall from a transport that is disconnected, reconnecting, > or=
=20
> using a different
>=20
>=20
>> The existing RPC timeout messages identify only the RPC program and
>> server name. That makes it difficult to distinguish a server-side
>> response stall from a transport that is disconnected, reconnecting,
>> or using a different connection.
>>=20
>> Include the RPC client id, transport id, current transport connection
>> cookie, and RPC task owner in the ratelimited timeout messages. These
>> fields provide a compact way to correlate a timeout message with
>> rpcctl and other transport state.
>>=20
>> For example, an NFS timeout reports:
>>=20
>>   nfs: server 192.168.50.1 clid=3D4 xprt=3D1 cc=3D1 owner=3D6245
>>   not responding, timed out
>=20
> Nice improvement, thanks!
>=20
>>=20
>> Assisted-by: Codex:gpt-5
>> Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
>> ---
>>  net/sunrpc/clnt.c | 20 +++++++++++++-------
>>  1 file changed, 13 insertions(+), 7 deletions(-)
>>=20
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index efa26899bc7d..6b5e2787dc81 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -2534,17 +2534,21 @@ static void
>>  rpc_check_timeout(struct rpc_task *task)
>>  {
>>  	struct rpc_clnt	*clnt =3D task->tk_client;
>> +	struct rpc_rqst	*req;
>> +	struct rpc_xprt	*xprt;
>=20
> nit: Would it work to assign req and task earlier (just readability?)
> Or is it not safe before checking RPC_SIGNALLED(task)?
>=20
> 	struct rpc_clnt	*clnt =3D task->tk_client;
> 	struct rpc_rqst	*req =3D task->tk_rqstp;
> 	struct rpc_xprt	*xprt =3D req->rq_xprt;
>=20
> The rest LGTM.
> Reviewed-by: Petr Vorel <pvorel@suse.cz>
>=20
> Kind regards,
> Petr

Hi Petr,

Thanks for the review and the Reviewed-by tag.

I kept the assignments after RPC_SIGNALLED(task) intentionally,=20
preserving the existing behavior where a signalled task returns before=20
we dereference task->tk_rqstp. xprt is also needed only after=20
xprt_adjust_timeout(req) reports an expired timeout.

I would prefer to retain the current ordering for those reasons. Also I=20
am open if maintainers chose to alter it.

Thanks,=20
 =20
                 Manjunath
>=20
>=20
>> =20
>>  	if (RPC_SIGNALLED(task))
>>  		return;
>> =20
>> -	if (xprt_adjust_timeout(task->tk_rqstp) =3D=3D 0)
>> +	req =3D task->tk_rqstp;
>> +	if (xprt_adjust_timeout(req) =3D=3D 0)
>>  		return;
>> +	xprt =3D req->rq_xprt;
>> =20
>>  	trace_rpc_timeout_status(task);
>>  	task->tk_timeouts++;
>> =20
>> -	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(task->tk_rqstp)) {
>> +	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(req)) {
>>  		rpc_call_rpcerror(task, -ETIMEDOUT);
>>  		return;
>>  	}
>> @@ -2556,14 +2560,15 @@ rpc_check_timeout(struct rpc_task *task)
>>  		 * connection gets terminally broken.
>>  		 */
>>  		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
>> -		    rpc_check_connected(task->tk_rqstp))
>> +		    rpc_check_connected(req))
>>  			return;
>> =20
>>  		if (clnt->cl_chatty) {
>>  			pr_notice_ratelimited(
>> -				"%s: server %s not responding, timed out\n",
>> +				"%s: server %s clid=3D%u xprt=3D%u cc=3D%u owner=3D%d not respondin=
g, timed out\n",
>>  				clnt->cl_program->name,
>> -				task->tk_xprt->servername);
>> +				xprt->servername, clnt->cl_clid, xprt->id,
>> +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
>>  		}
>>  		if (task->tk_flags & RPC_TASK_TIMEOUT)
>>  			rpc_call_rpcerror(task, -ETIMEDOUT);
>> @@ -2576,9 +2581,10 @@ rpc_check_timeout(struct rpc_task *task)
>>  		task->tk_flags |=3D RPC_CALL_MAJORSEEN;
>>  		if (clnt->cl_chatty) {
>>  			pr_notice_ratelimited(
>> -				"%s: server %s not responding, still trying\n",
>> +				"%s: server %s clid=3D%u xprt=3D%u cc=3D%u owner=3D%d not respondin=
g, still trying\n",
>>  				clnt->cl_program->name,
>> -				task->tk_xprt->servername);
>> +				xprt->servername, clnt->cl_clid, xprt->id,
>> +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
>>  		}
>>  	}
>>  	rpc_force_rebind(clnt);
>=20

