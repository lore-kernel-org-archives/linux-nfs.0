Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=205.220.165.32
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792715667;
	b=gQPTAZ+Bf/PFH/Q2OmOPyZL4SvmWJdCjm0WnNXeAeyCAltxXclshLVRtdGMmUd+Fevga
	 ni3YdXVTk8gymjlJFXKAOnrLdTIXZFrelaOram1dwZ7SW1b+5GSGzHgXW3BzsLzmNh7Lj
	 ROfTnOQQWRRsPQFW5HPT7OQkdSkr1jhke9SXjqvx7IKcKMybkWSLsbtpXPwyjt8aZP7co
	 UcCG4ds82h2WK+g7FA1vBDgRKZhJsjypGmP85ugEKa2qsUjDZpVmB0UZUnbbnXbdewhLp
	 Ov4MwVTgoxIAWAfFeVV5dZe/lZZ/CAosbX/+h9CSpGVPCUemFMA4eNu32d659wF2v4A==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792715667;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 DKIM-Signature:Received:Received:Message-ID:Date:User-Agent:Cc:
	 Content-Language:To:From:Subject:Organization:Content-Type:
	 Content-Transfer-Encoding:X-ClientProxiedBy:MIME-Version:
	 X-MS-PublicTrafficType:X-MS-TrafficTypeDiagnostic:
	 X-MS-Office365-Filtering-Correlation-Id:X-LD-Processed:
	 X-MS-Exchange-SenderADCheck:X-MS-Exchange-AntiSpam-Relay:
	 X-Microsoft-Antispam:X-Microsoft-Antispam-Message-Info:
	 X-Forefront-Antispam-Report:
	 X-MS-Exchange-AntiSpam-MessageData-ChunkCount:
	 X-MS-Exchange-AntiSpam-MessageData-0:X-Exchange-RoutingPolicyChecked:
	 X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount:
	 X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-AuthSource:X-MS-Exchange-CrossTenant-AuthAs:
	 X-MS-Exchange-CrossTenant-OriginalArrivalTime:
	 X-MS-Exchange-CrossTenant-FromEntityHeader:
	 X-MS-Exchange-CrossTenant-Id:X-MS-Exchange-CrossTenant-MailboxType:
	 X-MS-Exchange-CrossTenant-UserPrincipalName:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped:
	 X-Proofpoint-Virus-Version:X-Proofpoint-Spam-Details:
	 X-Proofpoint-GUID:X-Proofpoint-ORIG-GUID:X-Authority-Analysis:
	 X-Proofpoint-Spam-Info:X-Proofpoint-Spam-Details-Enc;
	bh=2R3lxUctAZzhyaUj3k/jqvTmDVJzgnqtQyNdrxQ6w/A=;
	b=ceJO7stF2gxJrrlCRrfBe5HeEZyQ3R6oz9lPFqrIgJKJ476bEw5U3aPycVg0aXzcycTj
	 EeTY45kre4rIxy0uV5JgRWU7vbLHkwB0ZBgvwCjeyeXS26hwNIMnKF/NpPpHgTQgh4yiF
	 1GzFOQlyWpPce9h/TU8tp3lUPRI818Hiy92uoC09DaQShTOp69hSXlaVJ+zQxwAJrzbmJ
	 rZe5OK5v5Ax1KV5uujVAy/tRsdakve8Ym8VLKXYfgca+H8cUOW0KWgBxeKk0SEFLn4uan
	 mPIi8+G+LJwOG5yERARWlLdEA9SaywnZb/jLfhF2hMeZkyTf5NkjbDCw6fqy1TzI+fQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=oracle.com;
	spf=pass smtp.mailfrom=oracle.com;
	dkim=pass header.d=oracle.com header.i=@oracle.com header.a=rsa-sha256 header.s=corp-2025-04-25 header.b=o9dOzwaC;
	dkim=pass header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.a=rsa-sha256 header.s=selector2-oracle-onmicrosoft-com header.b=wTptA0gB;
	arc=pass header.oldest-pass=0 smtp.remote-ip=205.220.165.32
Received: from mx0a-00069f02.pphosted.com (mx0a-00069f02.pphosted.com [205.220.165.32])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56D44606A32C
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 00:34:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 56D44606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oracle.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=oracle.com header.i=@oracle.com header.a=rsa-sha256 header.s=corp-2025-04-25 header.b=o9dOzwaC;
	dkim=pass (1024-bit key, unprotected) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.a=rsa-sha256 header.s=selector2-oracle-onmicrosoft-com header.b=wTptA0gB
Received: from pps.filterd (m0246617.ppops.net [127.0.0.1])
	by mx0b-00069f02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 69MJu3MY3984295;
	Fri, 23 Oct 2026 00:34:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc
	:content-transfer-encoding:content-type:date:from:message-id
	:mime-version:subject:to; s=corp-2025-04-25; bh=2R3lxUctAZzhyaUj
	3k/jqvTmDVJzgnqtQyNdrxQ6w/A=; b=o9dOzwaCPizB6YD0I8OUGty8V76W1ys1
	d34W/QC0Y6X4pfTXwcX2qX5ONF67GN7aQpRZI7GklDGloCk+70hyw8e+J+YltuOI
	FoBA3YCfPVbiMRvN57cQ7Li5goWuFR/+epZ1UOp9Xn4b0Uv6wOq7GiiJdr5uWgeg
	uggg3BOri4Y8CXCycrkmgukLdt9QrEjxQ8dnSK4KYSmfc6hoisQA78LkuAvvvN/T
	uKF90lmsRReDuNLREbKgKq8wbODQ4Zech7ZdNcs9K/clX1eIq+qoR6tDk1337QMy
	9Cgdt7ipecrQRk2clVUryclEj+w9JU3l/cbwsrfSmpL9q+dDZIeFZA==
Received: from iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (iadpaimrmta02.appoci.oracle.com [147.154.18.20])
	by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 4hdw4gda1k-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=OK);
	Fri, 23 Oct 2026 00:34:25 +0000 (GMT)
Received: from pps.filterd (iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com [127.0.0.1])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (8.18.1.11/8.18.1.11) with ESMTP id 69N0UUEE2331838;
	Fri, 23 Oct 2026 00:34:24 GMT
Received: from mw6pr02cu001.outbound.protection.outlook.com (mail-westus2azon11012052.outbound.protection.outlook.com [52.101.48.52])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (PPS) with ESMTPS id 4hfw3mg2f9-2
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=FAIL);
	Fri, 23 Oct 2026 00:34:24 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=LTXcj05ejkWH6+dEzEbChxRlaLv3CHyfTGiktMj5IZwFrkWplMeVtSHWw55OvNCPqcya6497Dkkrk93JiaLpq1jUh98o3aPHAcfUmDAlpCXct8aZ0c9tPhCRVOv4EBSgdv+xTVW5VWiPyOjRSTMGmx8PaqldfZ2Hk3b0BMLDLhYrDFA3DP1UMtudakKsLZxMStJip+KQCWv6p87KzGOy78w3tQb+f1EC+LnjJwa3bpGQR9G5Vp98pl2cQjPtFW/KbAS3HfxsCKeCL3VkYKk7Jvng7qxVZG1SaTC/yIXL5GO7RoHqjDEcso5lEx7cmzjI3ydbsnWOSkVP3vnj8gffmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=2R3lxUctAZzhyaUj3k/jqvTmDVJzgnqtQyNdrxQ6w/A=;
 b=zK2pu+8q+FImOXxhL/6Ju6LgytbUf0QmwhO6xbbOwv8I0qY1EG4iUn4xBTNrD9m5UgD4o5dty91Kr4FbNwCyUE4hAZkoxHVDrj1pgm+056FqoW7lWMLxtusWkpCGW9duzUKJGtEWr+IS5Obc+choifGlj4AqnHKltA0v2M3n0AhDLC5Eg4uG7ITPPn6n7573t5bRg3HRI9a97dClmp8gbEfOZ7rwUYXnDKzkM7SAuevLLAsRyteg6kme3iLRWiEEULj8/v1kzanZ/CvnxrDlCUoMVYz063rVPJVM6wDHBpkyk1RicI0LqNKk+9fduAvtKUKj/8tclvL9i8+N5SIrcA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2R3lxUctAZzhyaUj3k/jqvTmDVJzgnqtQyNdrxQ6w/A=;
 b=wTptA0gBkUKktPULN43hWTMCXJTaMha+55OJK+2QKurC2BINp/8p19TeznM8wvi0Wa5Vnes+z7YWJjiJU3xEIgeYdLZ/4ZYahtE3UHUvCNURyFeauiezR7rnxrV7pGXayie7zIPIQ2ebQq4O6lN6SzU+9ns+IQzsdqPfU342+Q8=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=oracle.com;
Received: from BN0PR10MB5143.namprd10.prod.outlook.com (2603:10b6:408:12c::7)
 by SA1PR10MB6446.namprd10.prod.outlook.com (2603:10b6:806:29f::15) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.546.15; Fri, 23 Oct
 2026 00:34:18 +0000
Received: from BN0PR10MB5143.namprd10.prod.outlook.com
 ([fe80::71c3:4ee5:93a1:85e9]) by BN0PR10MB5143.namprd10.prod.outlook.com
 ([fe80::71c3:4ee5:93a1:85e9%3]) with mapi id 15.21.0546.016; Fri, 23 Oct 2026
 00:34:18 +0000
Message-ID: <69d414de-c16f-47c2-9cfa-5c336ba32291@oracle.com>
Date: Fri, 23 Oct 2026 01:34:16 +0100
User-Agent: Thunderbird Daily
Cc: Calum Mackay <calum.mackay@oracle.com>, Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <cel@kernel.org>
Content-Language: en-GB
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Calum Mackay <calum.mackay@oracle.com>
Subject: pynfs: change of repo
Organization: Oracle
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: LO3P265CA0031.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:387::20) To BN0PR10MB5143.namprd10.prod.outlook.com
 (2603:10b6:408:12c::7)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN0PR10MB5143:EE_|SA1PR10MB6446:EE_
X-MS-Office365-Filtering-Correlation-Id: d7d70b01-74b2-4f26-41b4-08df309d5faf
X-LD-Processed: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b,ExtAddr
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
 BCL:0;ARA:13230040|1800799024|376014|366016|23010399003|10067099003|56012099006|261022105027099003|18002099003;
X-Microsoft-Antispam-Message-Info:
 kp0n7Rq1EFcafb9zqy+IqgvXLAGV2wqxKqj+sI28qZlcnsVbbzcfqKFeMVOLxr4AF6gOstggtbe6QmYCZRuVkaCk8NKaWH5YTK6U1+n5ICf303PklVOgYWiD7F1W9KNX5MvmxcaftGoYkcEzQu0zBznT4Yals0h24Dp69qYKULp65jQAJIDf5MvLVzJYZB2n4uyplYEdMpx2TOAQ4tMTyr14dX8EY3aJYVyBt4L04MQjcTUiynVBZX18SYZdHT6MA/PcAPVHu4/jxNgeEQq+OQdqenwAbHfR2RBQDeMFDhwiV+/scEoZcEIPvwdRoHldLYeQCdfU4vkjClwlMaTj7B1WAJRjGEVPk9YqaaYINQ+nt8ETmra9/3n1/AZb0ZxBS1E8tiA7i22nVb6vZw8S2wItLOhXMAKxoIcEnCxRKg4jxEpLoAAsYC4dsdK+SoYM/sz6hWwVFLXm/NlyY6/dNfqF8UFyeAtHprfj/eINjm6yYBWDRY43V1GGSmu/wEUWifuFOrLdBQIOIZQ/jPFElf4xH9hjPVk8TZ9dBT/64Wfmgy9sELIlXak+b4llGFPJ/qhYRE1T2rjtA0jc9hX8DQuAWc3cKCXK9S30CEKNN/SMxzDTLq75QCO2RV0HKscLQY3za6hTIDHCJspOTOeEnxzSJMMxWIFx9yW/+UwBNjM=
X-Forefront-Antispam-Report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:BN0PR10MB5143.namprd10.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(376014)(366016)(23010399003)(10067099003)(56012099006)(261022105027099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
 =?utf-8?B?cWtqWlVESzFqUVk5VkpMWGxtMWJyeEs1d1JqMVF2SkFxSW9yTHdXNmdubWZq?=
 =?utf-8?B?cVpQcCsrc09vbDlEUDNWUDc0bmxXUjd1aEppOVF0VEhwaFpEUno1ZlNjYWVS?=
 =?utf-8?B?a2pPTGRsVnV2R1A3RVZ1UFNGTmZ1QW5wek04d1NjbGxMdmdaelpJcnN5Mkoz?=
 =?utf-8?B?N3RGczRmMkpteGhwRUJYTWtpbStvd241OGd6a3hocFhBSkkwVFpTWkZlcVYy?=
 =?utf-8?B?OXNwOVZVZ1Y3MEFzeERPVnJ1NndwRHcxWUVOY1pjeUtaYUN3dURjRDJlWDlm?=
 =?utf-8?B?aFgxNi9BUmloQ0lNZjFwU3pWaGEvOUNtTE5ZcEYzMVQ5aGtRa1IyWHViZ1hP?=
 =?utf-8?B?UTJyZGxiZHJHRWE2eXhCbnQyQS9Qcm1POWlrVXk3VUE2T0w2TldUellYK3ZT?=
 =?utf-8?B?cnV0TEFjSjhGUHg3WjVBT1YrUTB6QTRBQjN2Ung1Y0pIL2RKQ1lKK1YrZ1Vj?=
 =?utf-8?B?RlI3V1JIYnZaL0YxVlhNWG5MVFJLOTEraXk4VzFhdTRJd3d3NzcxazlNVXVI?=
 =?utf-8?B?Q1RXSXA5U2U3cXYyMEhCeEtNNGxEMk9iMjBaZDRiK1YzYnAzSkZOTWhQOE1K?=
 =?utf-8?B?cVY4Q013bWZTOVI0Y1Bxbmp3SytYUVdja213WmRvZk9wSldNNU9LeXhwUVJU?=
 =?utf-8?B?bGtlb2xRdy9YWlY3QldNcERPSXBEWElJM3ZMRG0zYXhjVmxUK2F5UXlCVUV3?=
 =?utf-8?B?UHExWUs5bTF6VFpBaU9UNHBxMzFjRUJDT3dMWmpKcktsN2ZjSjY2T2VhNXU1?=
 =?utf-8?B?WWFOZzdzUW9OM0JFeXZ5M3F3Qkkrc1pseEJUUDB4R25pNmtnamZHeXZCb0Rx?=
 =?utf-8?B?d2w3dDgrL1drd0J6YnRiY1g0Z28rbWxmRDhMOXdjcFBWTTJiSml6VmJaN1U1?=
 =?utf-8?B?TGQ5bDJidFZhTlduZW4rY3E4bVdVamJEdjUxTVFPRG5nK1dHL0o5aHQ3eVR0?=
 =?utf-8?B?dHptK3JaRXdQMnBxODJkbUZRSHZXcVB5cjdSamFJbmkrakdIb1VhSGdjTUlk?=
 =?utf-8?B?TUcwdjYxOUsvVFB6WFMweFArMXNHRVlpSGlNMjNSRnFWSTRWNFM1YUxTNE5F?=
 =?utf-8?B?d0VVRThrV3grSnVuWUxZYTdodWJibEpjNHFreUo0QTNHNUIybHM0VU5tWmp3?=
 =?utf-8?B?cXVWcHhWY3p3blZyUDEzUjVUREx2OE5XT0RSdjBEcFhxbnNjQ003SmFDVzR1?=
 =?utf-8?B?U1JEbGczbGNyWllhK0QvN2YrVWVhZFZrVnFuSDRDUk1JRk1ETWluQkJNUXBN?=
 =?utf-8?B?SEhyaXBWR3VCaGlyQk85ZmhWUXNGZlpWdldFRC9rK2Jkd09ITjZYM2wxMU40?=
 =?utf-8?B?eTE2VXNjWHYxQjZrKy90L1RTQ09EQ0x4QXF1QmJDaFk5bkFGd05lMGM3Lzls?=
 =?utf-8?B?b2RJMFVjeHJ1YjJWeEFlNkJWUUVVekhSbm9wdExqU3pReGI4dHBwREZ1SlNx?=
 =?utf-8?B?RmMvbjZsVHM5amZYZkxBU0N5RE9valU2T2s2WWlZUUY2VktBRkw5NERybHlF?=
 =?utf-8?B?S2xLaXFBTWVoS2EvWC9SMVhVZGFzSDR4M2xDamo5c3JkRFk3NkUrblNkdlMr?=
 =?utf-8?B?Q3JlQzJENEdsbTZLbHFCOXMyQXdXS0FjcFFkdUdMN3ptVVlaYW04em1Cekx0?=
 =?utf-8?B?eDJDM3FBYUw4NXp5enJFLzE3S1ZUZWNSdzA2blZHSFVqR2ozenRCeG9sUDJu?=
 =?utf-8?B?c2h2U1RINS8yOVBldVQvNy9FTHhsNnAvM2NJelRGcWd6cEsrV0FBamkzRy9D?=
 =?utf-8?B?RkVPK0xkZVRTRmx3RWs2d0VQcWNUYUdhRllQd0dtaTZaZldIM0lQTzhIUTFE?=
 =?utf-8?B?T2lidDZyTGljcDU3cjZER1BvWGlFRU5wSHpPQU9raHUrOTc4ancranNMVlBa?=
 =?utf-8?B?MG1YYUZWVVJJaHdqTktlNVF2NHpqM0ZsT0k5MWhSUGJ1YU1jaG4yelFJZURo?=
 =?utf-8?B?WDNuSjhJSlBROWFUUlpMNCt0R05vczJJMk5odkZJS2crT1BJZmkyeklZa3E5?=
 =?utf-8?B?ZmFya2tQd3VtZEU2ZVJ3dVcvam9Nb21taTJRUitFM2RuNkFqRVRIMzlyMEor?=
 =?utf-8?B?OExhMHJrU2tJbm5JL3g1UGFMbURjenFxWi9pYXV3SmE0RDBwaFNsMXBFbE1l?=
 =?utf-8?B?YXlyTlVPT0dRbGpOSUl0S2ZhMWdkVG00bDQwaytlVW43Q2svbnA1Z3daZ0RW?=
 =?utf-8?B?MjlDWGEvZ3RhdjJremFzTDhrOTBzRVYvRVFqczVlQk5ZQWgwcHcvQmYwa09x?=
 =?utf-8?B?SGpxNVFVY3JvenArTVM1bHVVNkh6Z2x1MTdQZGJZNGUzUUhqL29ZSWl4UXpt?=
 =?utf-8?B?c0Q1LzFrcGZ5RzJwWlQwOU9tUnBodUxadTNSbjFWZnk4WW85MGVVdz09?=
X-Exchange-RoutingPolicyChecked:
	h42MZ17FdVfgrsmHNk+8LvCn2Br4k8gMSp45MjoAnDghctLXj1ZX4nktot1We4HgsXdjEfq4pSKKisnSuYOcCCGyms0PYuFHpTFdPo/iahrxfHfhI9mRbn+Evoga4/jdKLqdM8pNOe9+VzZqx/zv8CpL7ETIZSH53bbtYGfGFlPtN1eLHBuhufWnOciezntcVg2brzkVV9aXsNyUF30dd6aeAzCf4TV5+NqFSd6ndOrUB8C6/bLIULzU1xTwqSj0Y0mCMdFuiuGwEmQ5Ir834Uf6B/3a++H5pirM7buCi8N1A1OICXKIhORIZuAdikKYxNezrHWn41qftND2XIKLpg==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	VIqNT3lfYiSNqMY7+9VMcJmIRUeLzysot72oESnjuGq0gR2preDsgWTrIeseytcYxJYPUeXhSzPHh+zwPvVVxDACkdRZOWBpagxhUN9AV8E1i4JAhsmlGFAR3FIU3mUTyz6ipUU323zVbgpTuITINvOI6lMU2ZzGeCcqifB9tXEHz40K0uMwg8z8CD2KK6ho1G2aQ74+jQ+e/BoHqe/3xK/EQ0Tm85cGjtW3vUTsC6hAtvvY/d3VEssNKb/nt2Mm3KzmBo1sSXX/1Qls5AaLrWvgnKBSOdZJUH8x1C52oFKm38C1/D6NFe4eKsRok95Ok/SD1Pmc3lgtZbTBQ0Nrx7otZvKtAfJNBSvZ77TY4bR5ldTq5YoMqZlSnfhcbf8fQlWZNrOFo/VJG2wwvvcJ8A8StubVH92uxcLlVx609r8n/8ckt1cScHEZr69ZaGK6PS7O72XT3aHR/+aiJoSgSgModMObLWN5Ib7Ezn5LfzvgiK2eLVPv77l3Llo/AklEV/J+SdURr8KS/zemppHUEVMUpe6pGeV1asJvOuTa0kunqGtIVbfkG7dhHpeu8LKN8JUrzczflvC/eiYxzcG0yn8qzYFyOUpvOWC0rZPhA3I=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d7d70b01-74b2-4f26-41b4-08df309d5faf
X-MS-Exchange-CrossTenant-AuthSource: BN0PR10MB5143.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 23 Oct 2026 00:34:18.4596
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: Q2RoGCcxqgU1VfLvNp4ozIOz1bLZqgnDKcET12PqYJsSJ7snc4cKAb7di7Jtgdx41FUFZqOkcG0QtqBZ4FrCqg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR10MB6446
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.138,FMLib:17.12.100.49
 definitions=2026-10-22_07,2026-10-21_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 mlxscore=0
 spamscore=0 lowpriorityscore=0 bulkscore=0 phishscore=0 suspectscore=0
 adultscore=0 malwarescore=0 mlxlogscore=951 classifier=spam adjust=0
 reason=mlx scancount=1 engine=8.22.0-2610190000 definitions=main-2610230001
X-Proofpoint-GUID: xyTLeFXAIM-j2WXgxCvjnGq-3sTZYOY4
X-Proofpoint-ORIG-GUID: xyTLeFXAIM-j2WXgxCvjnGq-3sTZYOY4
X-Authority-Analysis: v=2.4 cv=DuTDa2/+ c=1 sm=1 tr=0 ts=6adaab91 b=1 cx=c_pps
 a=e1sVV491RgrpLwSTMOnk8w==:117 a=e1sVV491RgrpLwSTMOnk8w==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=z/mQ4Ysz8XfWz/Q5cLBRGdckG28=:19
 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=xqWC_Br6kY4A:10 a=IkcTkHD0fZMA:10
 a=660iZSQnnn4A:10 a=GoEa3M9JfhUA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=jiCTI4zE5U7BLdzWsZGv:22 a=7Gl3-_t3PgB9XO-mQDs3:22 a=NEAV23lmAAAA:8
 a=P6JkxrBpAAAA:8 a=VwQbUJbxAAAA:8 a=yPCof4ZbAAAA:8 a=hhvsTkdmcTqS_Tkw4oQA:9
 a=QEXdDO2ut3YA:10 a=dwOG0T2NmQ8MtARghG3a:22 a=5yU3S35YU4bGjq-dph-N:22
 a=Bho9c0fBagfJEIQBS7DQ:22 cc=ntf awl=host:13537
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDIzMDAwMSBTYWx0ZWRfXxfDXKruQ8SNp
 t2rTxJomsRwza+i7WGc/dRVmaMUNCVCETMJLTj7FUjI2+ywhLElgp4TFGklnP9HrQUbDWffTCPF
 1TL9qaGb2p8E+34ASGnSRjwKBl3PEIN2idsyJndW6RMrKO+l95rT
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDIzMDAwMSBTYWx0ZWRfX/ws/WP6Pb7CS
 9Sd+wxlUFFMo2uIbHx3DMeWzRiZU//+nEEpwqPt1rooKtCvFOpz9re7fFxeWPk+JrUTWKU9Yz84
 JBUPSMO/Voo2b9+r7TuJeTo16AJ85kdbixXhbvGy7+fOIQaPGlgKRg/HCL7ZWxBJS6lYeX7mdUS
 5L6Rr4RtqY68oEWGvpdOxKfpK3VedYUJINy5KGjXXHLJ5Eixo+odfPqkVLfTESyl1onXBCVkRi9
 sspjMJ4br9g5qm+n586zQ1LSgngdx7Y7XCzzoyy1FV6y0+eZOZrhUpIvZ93I56ApANAT1rXoDMz
 YHsUayxLl9TbhQob4UWZ9lAy5sfdurn0o2BB7zzrn525SYkcEc9/629XBsGYqtZL++fkbi8dtd3
 ifsle/Oo05+zb/yx7jyC2Qq+9k+RS3Oo3RkbBSXPAoWyeCYoxbsOwUJbreil8FVnl7nn/CYj0FR
 WNJLMn8Yt0C+r0ECVMjihnOLms5/LF7MUlJ3VpdM=

I'm pleased to report that we're making progress on applying pynfs 
patches, and have moved the pynfs repo, to:

	https://github.com/linux-nfs/pynfs

[The old repo on git.linux-nfs.org is no longer current, and will be 
removed]


A huge thank you to Chuck and Jeff, who are doing all the heavy lifting.


Please send all new pynfs patches to all of:

	Chuck Lever <cel@kernel.org>

	Jeff Layton <jlayton@kernel.org>

	Calum Mackay <calum.mackay@oracle.com>

and please cc:

	Linux NFS Mailing List <linux-nfs@vger.kernel.org>



If you've previously sent a pynfs patch that has not been applied, we 
will get to it soon.


best wishes,
calum.

