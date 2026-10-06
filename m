Received: from mx0b-00069f02.pphosted.com (mx0b-00069f02.pphosted.com [205.220.177.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29A00374E67
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 19:56:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=205.220.177.32
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791316588; cv=fail; b=fqVluB5ExJfEzbd+irBf2zoiL7LtPfdSgZIjrbumTkw79FC5BEwSED1mo2CfZUJBA2DameiB0r8g4dx/IyDvZcor1QfUTl/nW9781Jgr2I/X4DkZqPs3t89N2XEO5MO6FQtw6SKoWiH0/uWxSLebfhEluPNIaLjQn0Lsjo+SBqc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791316588; c=relaxed/simple;
	bh=takS9X56oXpQPcmA7OydJb617JwdodhZMTsTS1RbsIQ=;
	h=Message-ID:Date:Subject:From:To:Cc:References:In-Reply-To:
	 MIME-Version:Content-Type; b=KxSuq3FauJR8tC1DS03bXlveA2yKRSXx2GmErzUUs+SZDppmOXqpw9uko+OfTq3VsurWVTr56DRep1qhg3U02krVsMmUWOAZtiN66homiXzn3X7SxNFembFiCFQyqrOQ8HkBioJLAzBfhmN+Qx3ZQSQDcSIn2ACw14IK9z9tfLs=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com; spf=pass smtp.mailfrom=oracle.com; dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b=hRtENF4k; dkim=fail (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b=nd77x2g2 reason="signature verification failed"; arc=fail smtp.client-ip=205.220.177.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oracle.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="hRtENF4k";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b="nd77x2g2"
Received: from pps.filterd (m0333520.ppops.net [127.0.0.1])
	by mx0b-00069f02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 696FXmHn1931812;
	Tue, 6 Oct 2026 19:56:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=
	corp-2025-04-25; bh=takS9X56oXpQPcmA7OydJb617JwdodhZMTsTS1RbsIQ=; b=
	hRtENF4k/f3qNT28rlZg1XcEoGjwDq+w9NhPZFW4rMK5pfpePt82hTGrIXZ3KOe3
	7sVDyLu6HtOvLWrj7CGVOJiy+pycRt/EcXrcpC46gqN9FDRUWUxqSvfkPXWjrQEB
	atZ0AdMtwnGjeLe0OboEKSn5Gc6b6ieUXRH6KTxtpSFdBr7glIS5VBTI6pprEs95
	72tYqDkGh1xrlFvDWG9IQ430RijrR61XLUTBNKKaza6jfkP0WKF7aZEzVjaXjxmF
	+mGyGfa0vmmjZReUqGZgpevaACdJZMRKd7Y6Oe8hBaMdSun4lqFKdga/+fvM9fpZ
	0vRrew+gvqsIqizAGN+96A==
Received: from iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (iadpaimrmta02.appoci.oracle.com [147.154.18.20])
	by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 4h2srcvmey-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Oct 2026 19:56:10 +0000 (GMT)
Received: from pps.filterd (iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com [127.0.0.1])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (8.18.1.7/8.18.1.7) with ESMTP id 696Jpfje012214;
	Tue, 6 Oct 2026 19:56:09 GMT
Received: from sn4pr0501cu005.outbound.protection.outlook.com (mail-southcentralusazon11011062.outbound.protection.outlook.com [40.93.194.62])
	by iadpaimrmta02.imrmtpd1.prodappiadaev1.oraclevcn.com (PPS) with ESMTPS id 4h4cxjumyu-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 06 Oct 2026 19:56:09 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Yh4IbeDJ4+xEphsAPDAZE135WHk9ajIRkYBXFy3RqrfvW+ucPOqZcCT4Qsg4an3RKbZcooqfVOHeSoYTV9J9gmkFMID+r7rVajA8b9fOIZt3shsSg5wc8eoW4WwY3RPKzi3MYxzLx7vHcspkIHMxrNAauchx7kXNaHNOzcwu58uwHhlKHyRNx0g4z+hFxu6BJ2tQWyHek7YeZgUcq8U4jtnPp5yHbrOMdRyg1tmAEF8oCzon2Nibl/CAIPc+g46sW9SNtVKqLJtDTlJx/31QivLV25MzjZvdh64yzJgdRHFBSfPEOsjv2ZU7rg7GtH+5JgbaOOMwrNnZc1+QUZsYXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=nwxa3HIukyi8lfWCyOYxoi2FpgBW5yylircxZMaqZ3w=;
 b=bsyZpd9gGgZlCriNZjSt8AqJ3EaSAQAqXH2g9FWDDjM/7TzUUK2ebXkZ4FRADEkDmob9jpIXLGYAGklRRNpIPekrjD5fwrd0C86s2tT9Iwq7xUOfo5qOTMS/6O/+n1OrxsMfSOa7wPUGMwvbNHJdxiggTHsLFVXfzXJ6oR35ap/T7LnV9bgpXmceM5G08aEQ79lmF6gblUs40+/P5mXJhobDkELo4PzWwa1NBI6U8nXx2HNKxjJ7ftOBep9z9GDCVjKqsVK3aNCWe73u6mYNX9EOG71paWGQQD4O/Cv8wpkNbD4l4x8f7+7RYpEzD+Z9JsZe8Xw15Zx86WYqFC10Uw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nwxa3HIukyi8lfWCyOYxoi2FpgBW5yylircxZMaqZ3w=;
 b=nd77x2g2knOIbVTros7TaZ0eSqMvf1WdtKw0ZGduu/wRP+g0r7Mx7kGA1pMgKHU5qDBQZBG7Jzb1ygoqXml397KaiTWHcnp4Td3iiOGTrpz8obWA2g2E+pl/fri5g/4AXDALJ1jHArsqZf+B31vEIUKEBWCxdV8NlZlPDyuD+gI=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=oracle.com;
Received: from LV3PR10MB7796.namprd10.prod.outlook.com (2603:10b6:408:1ae::6)
 by IA3PR10MB8322.namprd10.prod.outlook.com (2603:10b6:208:576::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.496.14; Tue, 6 Oct
 2026 19:56:02 +0000
Received: from LV3PR10MB7796.namprd10.prod.outlook.com
 ([fe80::a30e:ee88:c7b4:c0d8]) by LV3PR10MB7796.namprd10.prod.outlook.com
 ([fe80::a30e:ee88:c7b4:c0d8%5]) with mapi id 15.21.0472.012; Tue, 6 Oct 2026
 19:56:02 +0000
Message-ID: <a1dcc6d0-8199-495f-8492-1c56165e5ade@oracle.com>
Date: Tue, 6 Oct 2026 12:55:59 -0700
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] SUNRPC: add transport details to timeout diagnostics
From: manjunath.b.patil@oracle.com
To: Petr Vorel <pvorel@suse.cz>
Cc: Dai.Ngo@oracle.com, anna@kernel.org, cel@kernel.org, jlayton@kernel.org,
        linux-nfs@vger.kernel.org, neil@brown.name, okorniev@redhat.com,
        tom@talpey.com, trondmy@kernel.org
References: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
 <20260820111303.455807-1-pvorel@suse.cz>
 <8e43238e-f06d-4da1-a898-2bdc1d827e81@oracle.com>
 <20260820185922.GA511595@pevik>
 <2d9dc79f-1d98-4a6d-9dbf-201fc8a90828@oracle.com>
Content-Language: en-US
In-Reply-To: <2d9dc79f-1d98-4a6d-9dbf-201fc8a90828@oracle.com>
X-ClientProxiedBy: CH2PR18CA0034.namprd18.prod.outlook.com
 (2603:10b6:610:55::14) To LV3PR10MB7796.namprd10.prod.outlook.com
 (2603:10b6:408:1ae::6)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: LV3PR10MB7796:EE_|IA3PR10MB8322:EE_
X-MS-Office365-Filtering-Correlation-Id: f045b08f-3fd3-46ef-a015-08df23e3d971
X-LD-Processed: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b,ExtAddr
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
 BCL:0;ARA:13230040|23010399003|366016|1800799024|376014|22082099003|4133799003|18002099003|4143699003|56012099006|10067099003;
X-Microsoft-Antispam-Message-Info:
 MuCpUd+ySt4bJJfqbzGeCnzJenXV0vAQ9uxUjgX34cmsNbLV8+SvMakPz9byKire2zYHXN4OgLlqYv4FXZ0KwVIJv9vw8iX4ZvnQ+I2fAmsq+OVh7zwUgGkpSxxATi6IoRz3qbH1McFXrZ5eYC1prZr01+jQQ1ksigNtwM4gBzjdUgBklWEI6z5UVm6hNSZKWy0KV1cIMxWkjy6I02YhqoY/gYVzsa7Ck20QCvMfbzUd4/zfSQkgLM0IiERClqAhlBIcl/iF7zPpJdTJNzvMWgdmhZP20+dyiPigCTD7wpToeHfXiDzrSUvQCeKdKIYgT8rRSgXd/5o+Hhi3f4Le4QM/5CV3RbmGxFGmkXMo+liMVklhY12uGvs4hu8hLcDlYhfPFy0mH9gqemtmWnG14YXB7nVhiiFMF76o0XLV3ITdGcAZoGiw9L1HHmNbl4ZXoksrInNufvcVCIc9ogVI0DmSDHWugSolB826/sVaYq0d8CrB8sKGIztII87A9GYWM3RDac80vQkVggpak+aSARvMqat3RhLeEwtDTmDMmx164kiJWALdRvpP9xUG2bctHlGv0NFluFhPopBBY0I4z95bqYXT6qJWVant/42YYxezISFIvgoFOOjrPmjxaYm3Rwh+0bPqD9leTbcBWFGbMtWRDrO7dy+O3nRP3RF3S4g=
X-Forefront-Antispam-Report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:LV3PR10MB7796.namprd10.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(366016)(1800799024)(376014)(22082099003)(4133799003)(18002099003)(4143699003)(56012099006)(10067099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
 =?utf-8?B?NFVUbXo0TXlpa2dkdFlYM1ZXYXBSRHZ2OE9TcjFvVUxNTG10Z3k0MFRheHk2?=
 =?utf-8?B?NWU5WWZkSHgvRWk4blZITy95eTJLSVZINTRJeXFvMUp5R285VUpTLy9YMzJt?=
 =?utf-8?B?TmFJNzF6U3lqaWhEMEhMaXFYUVFrQm4vV0Z1VzFtWm5IbHV6VWpNUEx1Wnph?=
 =?utf-8?B?eEQxMEhaZ2w0R2RFQXlQUXdOMVc5SVBVd0NvZXE1ZTVHdFJQVG82UlVGb1pa?=
 =?utf-8?B?TmxxSVIvSUp4S1NlMW05TUxjOHBkdVlxQ3lJU3ZwVjVvYzIxLzhQMWVVQ2ZM?=
 =?utf-8?B?NHJleDBOQTZhalpkeXVtTTlYaUYxV1U3OWFsWE9XZHlYUWRMazhGNnBQRmFz?=
 =?utf-8?B?bngwV05qVVBrMWFaOWJ2WUNGTU9JMVMzUjFuNFR0bUgra05iaGFKNWFEeUhp?=
 =?utf-8?B?MWRSMkdzQ2RaeWkyaG52ZkxOVnJVeUlvanZpWVlaOFBiT25qUFFPblJKQWhW?=
 =?utf-8?B?RVhJdERvNGxwdWw4QXBBUnN3NFVrcUM4bTk2UUhnN0RXbDRHWmJ2ZW9abDBp?=
 =?utf-8?B?djMyWU1saW1PR0NVcG9NOFJLbHBENG54bFFKL2JtdmJsbzd1YU8rTFpXL1pB?=
 =?utf-8?B?d1hIaVFMa2poMXMxdGxXMmY3clZ0SmZ4L2p6dnpnWlMrc2ZOM1pTK0F6dXdI?=
 =?utf-8?B?Q2dVb0xiOHloM3VURFdYL08vbDJvM1Z6V0xSd05aaXZRNTRzQ09KSWZVcElJ?=
 =?utf-8?B?WGVYeVdOYXArakxETU0rVnBlTlhBZ3BjWGpSVnp6Zy9BOUh5dGVCY3hUYVBi?=
 =?utf-8?B?R0hRL0MycjRaQXdySzh4cW5qK053d1dhWHJEeWw3TG1WcEpEUkl4TjN0QWJo?=
 =?utf-8?B?OUtxNElabGd0NkZ6b2Q0d1dZdWUyeUE2QUFYQk1zR3Baa2VBaWp5U2lQa2VL?=
 =?utf-8?B?MTRzaHJpWVhqNmNjbDNUL05SckwzQjBuSTBEV3pBT1lSMDdzWFFGVTNtM25H?=
 =?utf-8?B?ajk5YWlNWngxV2wrcmgzWjFPU1FWNTNWMm1tTjlDdm84TElVa240VWhiVno1?=
 =?utf-8?B?ZkpSNWZXTVN5emRHbUtDQjZibGM3WFVaNkxsREptbUdLQ1pKazE0ckIvU2dF?=
 =?utf-8?B?bmNvUkpHTG5aYktYbUZBcHBaY2YxQ0syQTdXRTVSMlMybHlOUm1xVE9tcG94?=
 =?utf-8?B?MUE5Q1FQV3FLUU5qR0RlZER3L2hnanRnTXVsL2N0TnQrZ3hrT2NScGF1My9N?=
 =?utf-8?B?Q0tMamxrWVp0MGwrSjE5eTZHaGFvaHZIZWM4eXpVTXpMVjhaaGt6WUhlSEQ1?=
 =?utf-8?B?dmoraWgvaGRMd3RUTHRVM05FSVB5ZUxsZjRUVUZxRXYrWDBXS1dQWGIyZ0du?=
 =?utf-8?B?dnR1UlJETmp2UmRvby9POS9uWTRINWk0VTBJb2RKa0VxT2pJWDFPRU41cnpn?=
 =?utf-8?B?VUhHbjVwWm9TQ0J5bW1TaGI0T05WM2xQQ05MZzdodVRjVWFNU3dHY253Q21W?=
 =?utf-8?B?dDdBY1Z0UVp1NnRrTHJ5bFhxNStCai9zTnpmcUpoNTQvUHZKNXB1NWVLbGs3?=
 =?utf-8?B?clVjdkU2NjJZelFJWitIMVd0d25xMzBkZ3Nza0ZDL2szdjZ4SHcvODRtcURR?=
 =?utf-8?B?VlpsczFxMDhUejlaeFBQVGlpU3kwUXpmRkpvSHJXOHY5WU14QjdzWFNsYWlU?=
 =?utf-8?B?SHFHeUN2dGs4UXlPZjhhK0laeWtUV2xJd3EyWjZ1VEZCeGoydnUyeUJST2Fk?=
 =?utf-8?B?SUdKUHpydENpNWxXNS9qbi9WTUtvUEwxcW1nR0JBU0JOK3oxYjc2a2IzYjRD?=
 =?utf-8?B?Yzd5MXE3QWlBR0ErTlNlR01KSk9qaWVncHdJcHR6eFU2Tk02S2pZcnh6Wm5m?=
 =?utf-8?B?TVJKdEtkL1J6bnhxYnZVYzFQbXdZdEgrTjR5WG9mSUVscDNtdCsvVHozbW9t?=
 =?utf-8?B?a0Z2WHY5bHZuWWZYa3dhS3daNWQrRDJ1UXpzakZjZ2dUeFJoaWx2SGJoKzRy?=
 =?utf-8?B?M2htQXJZVmgrZEFBcEdSSVM4WVl2Q1ZLR1B3ZXJTOGRkSHplUVFyWEo0bEFr?=
 =?utf-8?B?c2FRT1IyTE00WUlhSTYyeFl6ZUdvYWdOaFhiUTZvMXNJWVVQVHB3L0FkVVpI?=
 =?utf-8?B?dDhlTFNRZkVORTh1NmJjZWFaYm0zUUpyYnR6dUJxMzJCUXM3dGJMLzNrTVkz?=
 =?utf-8?B?ZVk3akxMNlY1ZHIra3grbm9ERGVmTmgzcWJSZFVYSDZVSUljTUZ0T1V6M285?=
 =?utf-8?B?SDVpM3dUZkdPbkI2ckFwbk1KSnZka0xEbmxza1p5RlZlS3hUYUd0WlEzL0li?=
 =?utf-8?B?Y3U3eVhDd3BqanF1NmN1V3A1QUExRGg5bEpaMGtkbFQ3dGhOc3FValc0TzNh?=
 =?utf-8?B?T3NFQWlZWjhRY0UxcTZrcDlIbGhMVDVSaE9pTzQwRkoxd0xKUHdPUGQ1NldY?=
 =?utf-8?Q?GC+5YTvZT2h8jKLE=3D?=
X-Exchange-RoutingPolicyChecked:
	yBN0N8gYU8vG2nLP04RBg85YFPXeDZUqcRfrBNCr/XeWg80mhY6vCQsUjr1fUY0NHSfARTGwsgwV9NHZH1foPylv3GE2K8JidntdFfh4J6EzpFiXxO1cuxEey3vCYlzQSgqBsm5dA6JoMk9ESGWFj+/WsUlxTFzYdHZaVuhw7N+2vTlI/XxPT1z8YEPSxRNoVm8P/uLcHeJlsWBVWy8OH4b92nJ73Olp5lM3/c7L/8sR9DSczSMnTQ5A3Myudaoi90SOZHKPd2sKR7IbFXpdssF40qf42pnm4ZJMUmaNPEBSowRJNVyaoLPy9wb0sAZUbaqU3Wcf9Yi0R5p9BntlXg==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	S1YHiEviOdps6qHO0nomw3JZuJvdERSomd3Pho22ZN/mrxuIIRJcgLVvgyKSpw3WbsKzcNtxBbHICuY9LbpGtdx7ELwR8GZbHJ3QRVFua8QMJABXWcns7Y6LnpyaI4H3wNB3KTSS39msxHJMhXnBxO4xZsY55lV4WBhknVWAOJ5fk8tIRm5REqtsJDFr12OJP3Xkn5OY9gOxgAebASuSZiFFGeSzvXjIxQvICZDaMUeWVL3zkRYcLi64jVLOla+tFwuNqtk7oH+BKaK+nR3NLgWO2TMvYJ0pYv2fic9W4ubFCfzCjMdLdfFnKYbHlrwV1xsp8IRxBgHA3VCiBGhsL9VMN2DqBQ84j0l5pFuOSuyNOub7XRNRPDJcKWCemLK5o+vViG322nOKYhUfeSM/6lnbjCJst+13R2l+F5diFlPwvM6DLrtyv9a+4mFWxWpUpbQ6vbz392/SpuIduEpKZyPg+/bJ6KV3OejiewwZAgKUXc0Uxk5SPW+KTxH/bJCLLU+V1xX1x1Xvw3Xx0pfXCCSfPIF6LS5T0tP9+x1j+KN8SypWvpO3KfRP3xbXZm/6jlIKmuwTvl37jT11d6QCtPzv/8vR+vI/hXe6KKtksDo=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f045b08f-3fd3-46ef-a015-08df23e3d971
X-MS-Exchange-CrossTenant-AuthSource: LV3PR10MB7796.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 06 Oct 2026 19:56:02.5031
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: rSQnW/UNHDxpZIuCYiveU6GlF0hc7zzzKlhBBbhdC8YBBk1ZKSa1F15RDqeLadXQHEmhDs7MzztpeY8+L21Xn/nM6YuG32vYKfn9zN4k1Z8=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: IA3PR10MB8322
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-10-06_05,2026-10-06_03,2025-10-01_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 spamscore=0
 phishscore=0 mlxlogscore=999 mlxscore=0 malwarescore=0 lowpriorityscore=0
 adultscore=0 suspectscore=0 bulkscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.19.0-2609040000 definitions=main-2610060079
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDA2MDA3OSBTYWx0ZWRfX1uFaflU/uD9h
 IN+LqApDDh/44LI+LuUcf3xynzv0Ksf9V7ET4si0o6mjZqEjFRz2d0zGUx1VhKLbFs9+nrZTCHP
 GVKOAR/MzCE+VJfjCBKv0txriqkBuj5L9wSGUffHW/gXyOXd1P1W
X-Authority-Analysis: v=2.4 cv=d/dgWhjE c=1 sm=1 tr=0 ts=6ac5525a b=1 cx=c_pps
 a=e1sVV491RgrpLwSTMOnk8w==:117 a=e1sVV491RgrpLwSTMOnk8w==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=z/mQ4Ysz8XfWz/Q5cLBRGdckG28=:19
 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=xqWC_Br6kY4A:10 a=IkcTkHD0fZMA:10
 a=660iZSQnnn4A:10 a=GoEa3M9JfhUA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=jiCTI4zE5U7BLdzWsZGv:22 a=BqU2WV_vvsyTyxaotp0D:22 a=RpNjiQI2AAAA:8
 a=VwQbUJbxAAAA:8 a=yPCof4ZbAAAA:8 a=HaBJo5juDEynQVc03m8A:9 a=3ZKOabzyN94A:10
 a=QEXdDO2ut3YA:10 a=5yU3S35YU4bGjq-dph-N:22 a=Bho9c0fBagfJEIQBS7DQ:22 cc=ntf
 awl=host:13537
X-Proofpoint-ORIG-GUID: ERcw8yPbvqRRZ-AXXqPJpCRHQwXGhuzw
X-Proofpoint-GUID: ERcw8yPbvqRRZ-AXXqPJpCRHQwXGhuzw
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDA2MDA3OSBTYWx0ZWRfX6rQqXWMFN2a+
 LGjuI4crsTdD6f8z616AS1yF9BTVB0h8X5Ji0mdvQNhSJg4KYoQYnaKqSuBlMlYxPm0Qa7EKqtV
 uAD6lK0J+KOD7c5tZOC1/s/FLPCY/hAti209nLJKHXx0Cx8W4bj2OdQN2RSbGENAdMXaIbX8A17
 FsNa0C3N6En3nQvNW0vTEAIpOOeeAc5sL3NpaV1Bk2z8cvpjZdRwo0SPhV0hD2e8GX7/tS332IM
 59yO54PuZAYxHgFAPxttc15yvy2E6SJQPkleiZTO/nVvUTkjg57Lw4CZ8nfplZ4ZH4xHMJA4y57
 d8iXEsDmYTiEB2CE86iuvGyejv5z+Gj5nuj3VECCW+nZy8dAlEpxyKYaEmZMlJSFVIUiza26nln
 AovC2ADizLDcSQUvjIEgboTYI40CMOYNPVimIN8EtdI6AipT4D6YzzDakUMsa/4Y5IgJwRoMBnQ
 2ciUlSQ1LkOpSkh4mDOPBaovL8BwBhJONu7GPpa8=


On 8/31/26 12:33 PM, manjunath.b.patil@oracle.com wrote:
> On 8/20/26 11:59 AM, Petr Vorel wrote:
>> =C2=A0> On 8/20/26 4:=E2=80=8A13 AM, Petr Vorel wrote: > > > The existin=
g RPC=20
>> timeout messages identify only the RPC program and > > > server name.=20
>> That makes it difficult to distinguish a server-side > > > response=20
>> stall from
>>=20
>>
>>> On 8/20/26 4:13 AM, Petr Vorel wrote:
>>> >=C2=A0 > The existing RPC timeout messages identify only the RPC progr=
am=20
>>> and >
>>> > server name. That makes it difficult to distinguish a server-side >
>>> > response stall from a transport that is disconnected, reconnecting,=20
>>> > or
>>> > using a different
>>
>>
>>> > > The existing RPC timeout messages identify only the RPC program and
>>> > > server name. That makes it difficult to distinguish a server-side
>>> > > response stall from a transport that is disconnected, reconnecting,
>>> > > or using a different connection.
>>
>>> > > Include the RPC client id, transport id, current transport=20
>>> connection
>>> > > cookie, and RPC task owner in the ratelimited timeout messages.=20
>>> These
>>> > > fields provide a compact way to correlate a timeout message with
>>> > > rpcctl and other transport state.
>>
>>> > > For example, an NFS timeout reports:
>>
>>> > >=C2=A0=C2=A0 nfs: server 192.168.50.1 clid=3D4 xprt=3D1 cc=3D1 owner=
=3D6245
>>> > >=C2=A0=C2=A0 not responding, timed out
>>
>>> > Nice improvement, thanks!
>>
>>
>>> > > Assisted-by: Codex:gpt-5
>>> > > Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
>>> > > ---
>>> > >=C2=A0 net/sunrpc/clnt.c | 20 +++++++++++++-------
>>> > >=C2=A0 1 file changed, 13 insertions(+), 7 deletions(-)
>>
>>> > > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>> > > index efa26899bc7d..6b5e2787dc81 100644
>>> > > --- a/net/sunrpc/clnt.c
>>> > > +++ b/net/sunrpc/clnt.c
>>> > > @@ -2534,17 +2534,21 @@ static void
>>> > >=C2=A0 rpc_check_timeout(struct rpc_task *task)
>>> > >=C2=A0 {
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct rpc_clnt=C2=A0=C2=A0=C2=A0 *cl=
nt =3D task->tk_client;
>>> > > +=C2=A0=C2=A0=C2=A0 struct rpc_rqst=C2=A0=C2=A0=C2=A0 *req;
>>> > > +=C2=A0=C2=A0=C2=A0 struct rpc_xprt=C2=A0=C2=A0=C2=A0 *xprt;
>>
>>> > nit: Would it work to assign req and task earlier (just readability?)
>>> > Or is it not safe before checking RPC_SIGNALLED(task)?
>>
>>> >=C2=A0=C2=A0=C2=A0=C2=A0 struct rpc_clnt=C2=A0=C2=A0=C2=A0 *clnt =3D t=
ask->tk_client;
>>> >=C2=A0=C2=A0=C2=A0=C2=A0 struct rpc_rqst=C2=A0=C2=A0=C2=A0 *req =3D ta=
sk->tk_rqstp;
>>> >=C2=A0=C2=A0=C2=A0=C2=A0 struct rpc_xprt=C2=A0=C2=A0=C2=A0 *xprt =3D r=
eq->rq_xprt;
>>
>>> > The rest LGTM.
>>> > Reviewed-by: Petr Vorel <pvorel@suse.cz>
>>
>=20
> Hi Trond, Anna, and Chuck,
>=20
> Could you please let me know the next steps for this patch submission?=20
> Should I wait longer for review, or are there any formatting or=20
> submission issues that I need to fix?
>=20
> I also noticed that the Patchwork event shows the patch as "Not=20
> Applicable":
>=20
> https://patchwork.kernel.org/api/1.2/events/?patch=3D14757794
>=20
> Could you clarify what that means for this submission?
>=20
> Thanks,
> Manjunath

Hi Trond and Anna,

I am following up on this SUNRPC client patch. Petr Vorel reviewed it,=20
and his question about the placement of the request and transport=20
assignments was resolved in the thread.

Chuck clarified that the Patchwork "Not Applicable" state reflects NFSD=20
tracking and does not indicate a decision on this NFS client patch.

Could you let me know whether this patch is suitable for the NFS client=20
queue, or if you would like any changes or additional testing? I am=20
happy to send a revised version if needed.

Thanks,
Manjunath
>=20
>>> > Kind regards,
>>> > Petr
>>
>>> Hi Petr,
>>
>> Hi Manjunath,
>>
>>> Thanks for the review and the Reviewed-by tag.
>>
>> yw.
>>
>>> I kept the assignments after RPC_SIGNALLED(task) intentionally,=20
>>> preserving
>>> the existing behavior where a signalled task returns before we=20
>>> dereference
>>> task->tk_rqstp. xprt is also needed only after xprt_adjust_timeout(req)
>>> reports an expired timeout.
>>
>> Understand, fair enough.
>>
>>> I would prefer to retain the current ordering for those reasons. Also=20
>>> I am
>>> open if maintainers chose to alter it.
>>
>> +1
>>
>> Kind regards,
>> Petr
>>
>>> Thanks,=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Manjunath
>>
>>
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (RPC_SIGNALLED(task))
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>>> > > -=C2=A0=C2=A0=C2=A0 if (xprt_adjust_timeout(task->tk_rqstp) =3D=3D =
0)
>>> > > +=C2=A0=C2=A0=C2=A0 req =3D task->tk_rqstp;
>>> > > +=C2=A0=C2=A0=C2=A0 if (xprt_adjust_timeout(req) =3D=3D 0)
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>>> > > +=C2=A0=C2=A0=C2=A0 xprt =3D req->rq_xprt;
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 trace_rpc_timeout_status(task);
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 task->tk_timeouts++;
>>> > > -=C2=A0=C2=A0=C2=A0 if (RPC_IS_SOFTCONN(task) && !rpc_check_connect=
ed(task-=20
>>> >tk_rqstp)) {
>>> > > +=C2=A0=C2=A0=C2=A0 if (RPC_IS_SOFTCONN(task) && !rpc_check_connect=
ed(req)) {
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 rpc_call_rpce=
rror(task, -ETIMEDOUT);
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return;
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>>> > > @@ -2556,14 +2560,15 @@ rpc_check_timeout(struct rpc_task *task)
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * conne=
ction gets terminally broken.
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 */
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if ((task->tk=
_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
>>> > > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 rpc_check_connected(task->tk_rqstp))
>>> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 rpc_check_connected(req))
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 return;
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (clnt->cl_=
chatty) {
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 pr_notice_ratelimited(
>>> > > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 "%s: server %s not responding, timed out\n",
>>> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 "%s: server %s clid=3D%u xprt=3D%u cc=3D%u owner=
=3D%d=20
>>> not responding, timed out\n",
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 clnt->cl_program->name,
>>> > > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 task->tk_xprt->servername);
>>> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 xprt->servername, clnt->cl_clid, xprt->id,
>>> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 READ_ONCE(xprt->connect_cookie), task->tk_owner);
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (task->tk_=
flags & RPC_TASK_TIMEOUT)
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 rpc_call_rpcerror(task, -ETIMEDOUT);
>>> > > @@ -2576,9 +2581,10 @@ rpc_check_timeout(struct rpc_task *task)
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 task->tk_flag=
s |=3D RPC_CALL_MAJORSEEN;
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (clnt->cl_=
chatty) {
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 pr_notice_ratelimited(
>>> > > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 "%s: server %s not responding, still trying\n",
>>> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 "%s: server %s clid=3D%u xprt=3D%u cc=3D%u owner=
=3D%d=20
>>> not responding, still trying\n",
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 clnt->cl_program->name,
>>> > > -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 task->tk_xprt->servername);
>>> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 xprt->servername, clnt->cl_clid, xprt->id,
>>> > > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 READ_ONCE(xprt->connect_cookie), task->tk_owner);
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>>> > >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 rpc_force_rebind(clnt);
>>
>>
>=20

