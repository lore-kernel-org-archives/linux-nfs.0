Received: from mx0b-00069f02.pphosted.com (mx0b-00069f02.pphosted.com [205.220.177.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 972E048125E
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 13:45:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=205.220.177.32
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791207944; cv=fail; b=T0ZPMb1O1C2aoHyYSZdIklQIOKcqj8llG82gLzz12b1OY85PVmzPQZqYkEDg6nVVK3WzJjwMHKZw1pcCpYhhPauU6lVYPZpXnrzJEt7ZDPSROPYtrBnEsETyRFZotGyGbsYQ2A5dgYHhgxsJSsc7EMNgNux4HAyKU0eJrBbMYZY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791207944; c=relaxed/simple;
	bh=6rHgDdOusEBv/rU4u1N0zLeKBqDc+N70Yzd3Msl32HU=;
	h=Message-ID:Date:Cc:Subject:To:References:From:In-Reply-To:
	 Content-Type:MIME-Version; b=FKpWf7pXWmc0iyJNKiYipRDFBIX3tfdHuZ3utrzr4L8IqUgdemha442KaAzmLHjndow03W7+oz3fnVTDAGqowQ93+CmFDCuoQI1SJYTdrSUxhE9QWwCDEeDFRu1FrA7Kxl/Pxd0hSX4C6GQojjsl65U+eW2JEvnhD1iP9QA51VI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com; spf=pass smtp.mailfrom=oracle.com; dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b=V1x1vmXE; dkim=pass (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b=y4nt9aM8; arc=fail smtp.client-ip=205.220.177.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oracle.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="V1x1vmXE";
	dkim=pass (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b="y4nt9aM8"
Received: from pps.filterd (m0333520.ppops.net [127.0.0.1])
	by mx0b-00069f02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 695DURZQ3491240;
	Mon, 5 Oct 2026 13:45:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=
	corp-2025-04-25; bh=kmaX46TlhnEmjBcZsixUpIqvrXJKtCiB1ljr20HTdHU=; b=
	V1x1vmXEHZ611JhDs75TLMcdchYRAFMSjpbfDFmxU0IFqP3IHmz65Hln/4kghgFo
	zanVqlSb+pbqVhTfpehZqjz7mEBWXPztEWiZttaj1mHCNO/DQhJYZESb96spvNnB
	pJyv1Olkjw7XM2EFNeAXftzG269gxYL+61b7Mlvx9t3FPlwvt9iuYMxBaS2i3mch
	c2no0lhcITDa09Se6VpVrYN2wrTPBAxqtvK9tWb+3P54newQvaavngEzF70O3xdd
	AiPjVoKPfmT0eu5IMF4PAs9J1GowIeu78vjXmks0R6DYvMQnzOR9TSCu+Rs7P6fk
	onyhTrAyDxjTy7h3P6QN0g==
Received: from phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (phxpaimrmta01.appoci.oracle.com [138.1.114.2])
	by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 4h2srct0ru-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Oct 2026 13:45:39 +0000 (GMT)
Received: from pps.filterd (phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com [127.0.0.1])
	by phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (8.18.1.7/8.18.1.7) with ESMTP id 695DeE38011427;
	Mon, 5 Oct 2026 13:45:38 GMT
Received: from bn1pr04cu002.outbound.protection.outlook.com (mail-eastus2azon11010023.outbound.protection.outlook.com [52.101.56.23])
	by phxpaimrmta01.imrmtpd1.prodappphxaev1.oraclevcn.com (PPS) with ESMTPS id 4h4cyxg5wa-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 05 Oct 2026 13:45:38 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=DulBaxMNHARzSND5U2KlNbcjWAbXXcuPfGAcqGo7SS/KYuVZQOqWoLYiXaxE7eolgm00oq1gBdPypRP0iTKeA48sZVuiDXOATT6ChjHc/pb59eK9Nsfw/UxvSZy9zq/uM3aDdV++m40Q7S962C5VtD+KFZGzPrCeRQAV3Gr+Iakp9/1dFm3EIy62EQP1hSA88TL4Mhr8BAQy/7pdsLUUXdG8aeHDl4ay4DQXSbrAREbtK35etUiEPHClVlqxFpCYiLHHYi0jrrCd70zAsIExtYm2NqARVZyUzfAOV3oNRYJY/nHiUNmhSUIA1VdqYYSILzJRViGaKWczEnuOyq84Mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=kmaX46TlhnEmjBcZsixUpIqvrXJKtCiB1ljr20HTdHU=;
 b=t07t25ggwdJMCTwu3mhENahJvql6tKEgKo6ZiuGe8yqM3LlF08gKEXRsVmgRuN4OaCSiQaqDxgOl7sxUEA6UwQOoT05tlVfi9MKEehRbBK+MKG9OzuRgjcyhqxuE1r3I+l0ioTmbc9Zvrf7sGLIjvRuFOV75wfF7+qY8pqpkP/8rTUQNR8TB+9lgVJR2cfX5Ckm6fX+IP5CjMoqiujlMMmA8N5UnTlhbqkazFKbDKMsDlj6b1gxddxjmlKU85RdsJyXvmerSKaMVKArMp4OFRwoHFUXOLYPaQqjxG56zclVEurl6okYBTdz7FMxZ5zewT6zwRgPmhwXKdvN7Z5YkLA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=kmaX46TlhnEmjBcZsixUpIqvrXJKtCiB1ljr20HTdHU=;
 b=y4nt9aM8MIIvK7EiIf32HwBrvI7USbqNniGGAXfqKYdZ4YQ4pgMNAitw5wjDnCp/8Z03YpnZujxQPcy5c5N1TbUHzDU+NXShWvkK7wHfMnQeei6f6G5VzWV6glXqs2VLbSeDcRzansqEc5iYvZxZBNZlMGjgT28NAmG5K8cxjKA=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=oracle.com;
Received: from BN0PR10MB5143.namprd10.prod.outlook.com (2603:10b6:408:12c::7)
 by DSVPR10MB997937.namprd10.prod.outlook.com (2603:10b6:8:3bd::5) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.496.14; Mon, 5 Oct
 2026 13:45:36 +0000
Received: from BN0PR10MB5143.namprd10.prod.outlook.com
 ([fe80::71c3:4ee5:93a1:85e9]) by BN0PR10MB5143.namprd10.prod.outlook.com
 ([fe80::71c3:4ee5:93a1:85e9%3]) with mapi id 15.21.0496.010; Mon, 5 Oct 2026
 13:45:36 +0000
Message-ID: <db8dd3c0-0e51-4d3a-a98b-4ceb4f31daa7@oracle.com>
Date: Mon, 5 Oct 2026 14:45:33 +0100
User-Agent: Thunderbird Daily
Cc: Calum Mackay <calum.mackay@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SEQ_FALSE_RETRY is allowed for a solo SEQUENCE replay
To: Chuck Lever <cel@kernel.org>
References: <20251007204806.15560-1-cel@kernel.org>
 <ece49885-7f63-4be8-a8b8-810c9ae4580f@slotpi15m67>
Content-Language: en-GB
From: Calum Mackay <calum.mackay@oracle.com>
Organization: Oracle
In-Reply-To: <ece49885-7f63-4be8-a8b8-810c9ae4580f@slotpi15m67>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: LO4P123CA0527.GBRP123.PROD.OUTLOOK.COM
 (2603:10a6:600:2c5::11) To BN0PR10MB5143.namprd10.prod.outlook.com
 (2603:10b6:408:12c::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN0PR10MB5143:EE_|DSVPR10MB997937:EE_
X-MS-Office365-Filtering-Correlation-Id: 8f456102-6df5-4b31-f46b-08df22e6eedb
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|366016|1800799024|376014|23010399003|56012099006|4143699003|10067099003|18002099003|22082099003;
X-Microsoft-Antispam-Message-Info:
	UH7tUTcPnDtIZG73p9mLgvJi8sL4vp7b9kM9c9yS6Hh8XNxgIYhzveHxNX/dQeF4lTz+lCut9YT3aiEj31PdT9eEzXKDcHhTR6tNBB/AjxzMyQKxN5eCuB9a+Qvo5DwnANftjCMdiiJxaXNsNzjpZzS1aawNKOufBS5imO6RJPuNP1uUKamVElUtFtCd3IcDGCTUHG1oxHiqlr8aNBEXvL/LSq/gPdeEG1HbxWSigA3aOyRjGPIBgHTnesGsTp2OkU9/bFY3yewEJAJZLLFuVmk8l1HSV8Naf9D/4tzJBLxHrC3S621SyvpnjIrZyzCJ/j/hfXkK+VJf0fWTUGVM/ziH/ASO8rUtyAHkA/1/UvqWWW7dW2nLfIRP5bS+RlPfqB5fdLDjsHJsx3F0vSDu5Wu4hDx5veSZ6h9hZrkf76wifdQgJBgEDh9Mvv5J4oq4PzTqUOk8xHN26lBKbqM+39R1eh2B7A4EJxhwB9pJdsFQ5oDfI+pGkCi2FrxLRWGKFYrDBRFRXgE8NDhq3DDltY+l0kR2k73WzAVq5t2CTuaEM0HmdDl79AQ9XTO/VOZtOITLQz0mJJswdRtK1QGymOTosXy6gJ0+uNDLF9nLffwPeyV/rMOrakzKwHTfKzr/U1cFk86zeziEwh3Zbtvo+fa0JFiNZw+8PwvgZms9gNs=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:BN0PR10MB5143.namprd10.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(376014)(23010399003)(56012099006)(4143699003)(10067099003)(18002099003)(22082099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?WWprSWhwNm5OY28zWnU4WVRMNkovSm9jeFJLVmxHY0E5VVUwMVNzMXZ3V3RT?=
 =?utf-8?B?VzdraW02QlY0Q2FpY3hHRVhQTGlTaVNPZ0dmN1AwVS81cmlleVByVlFIZ2pT?=
 =?utf-8?B?ODZ4bkpmRzlhd2pLeS84ZTFyWUtHMDBCUmwyMjZaVUk5eERnUlgyOW9Xek9z?=
 =?utf-8?B?ZUhaaHhSellieXhpZlpGcjMzUUxXTW9Zd0pWcTNkelMvYmM0c3dBL2V6SHlJ?=
 =?utf-8?B?RnkwRjhmV2xiLzQ4SHVjRzJLVmFzMThBR25zUnhqZ2d3WXhVSGNuVkRNKzdR?=
 =?utf-8?B?bXRVWHlTcUdQUUd0YW5xWGpVZzhDVGh3KzExdTVuZHpDZkp0QzNDUllzN0h4?=
 =?utf-8?B?d0gyanhkdzV2UmJ3YUt1ZFJ5RHI2UnRRVHhsbmdFYkNZbDdJSVB6eEh4QUhI?=
 =?utf-8?B?aDJsZWhOTFBDbUJRNWpwcFpsd0dXbGVTWVBBZGtZbzVNMEFFZGloRVYzTlkw?=
 =?utf-8?B?emxTV21obWZNWlczNGZoTTBWQ2drWmFKWndpSDVoMG05aW9VYW9KdDZOUVh0?=
 =?utf-8?B?eDJwM3hXZXJzeUIwWWRlaklpMDVUb1NneTRseWlVcndYYjhaeERMQ1FZbWlh?=
 =?utf-8?B?OTJlT2dyYmVGL3RIdlduMjJDMlJ4bUtFdllaZGg0UEQrYjVheXpxeXljVEcx?=
 =?utf-8?B?MERYVlNYSi9pMmZDR1FkZUJ3R3FZM3plL2ZJMzZtcU5Vb2pzV3ErZHo0aVJF?=
 =?utf-8?B?eWNEOC9CVGs0Yk5UMm1pRU1SK1pkcWt0ZXFiUll3c05aKzBHMVdGY1Y1MVU3?=
 =?utf-8?B?Zm1qMTZIZktqNXY5bHdGSmNuOG1lUkVjWm1DRVQrbFpqR1lQL2MxTEViS3lI?=
 =?utf-8?B?em5sOTBQYnFEV3hTMjAwZWdpVnhtZGZvQUsrbnJUR3NDRjYxK3hxdzkzcGxk?=
 =?utf-8?B?Ly9RSkdYK1Z1clpCeG95RDkxL0JBYjNRNUZMSE0wSWg2MldCbmlNdnk5V2pJ?=
 =?utf-8?B?N0RGUW9KOFhpRElwNE1NWWVjVXljSEZJazRiTzFON2Y2VW1Mck1UZ3VYSDNT?=
 =?utf-8?B?czZwMnVvaWRlbzRObEFHMEFlSmdNUEFSM3ZFWmgzcmxYcTBWeGVGeEhaYjZF?=
 =?utf-8?B?bS9LditjNFRuQldrOG45ZE1mam1rZVVWa1VYcmRaOTExQkJ1V0cyWkgwbFhr?=
 =?utf-8?B?SVR0NTV3ay9rRWZCNGtoVkx2R0xCdEZwZkVjWFRWUW4xZWs0QkR4cnlxcGpW?=
 =?utf-8?B?SEFtVHM2TUN6ZTJ3eElyWktVeG5DN2FPVHNzU2pzUzFQVUwvWDd3aUJBVEY2?=
 =?utf-8?B?YW1nMzUwRXY2akhMcUdRWG91cFduMGsvWG0wdWFEUmtqMWZJcHpHU2YyLzRL?=
 =?utf-8?B?eHY4TS81TkE5KzY3bU9DMXlFWW9xdGVBMlFhR3hNYjhBMHpqR3lIaGZPZjg0?=
 =?utf-8?B?L0Y4a3owQ1daVDM4cEJ0OEJsVURNQTVvdTVMWHd3bWNERTlNOWx6d3lYVVNP?=
 =?utf-8?B?VUQ3eFpJbCtLcHU0eTJZcEYzajNoUWlobU1DbHhleHZ0RHA2YTVNaGZmUldj?=
 =?utf-8?B?dUY4YUZPbFhsSzcrYW9qcnJyQ0VnMkxneXVwbFhCdGlqWnltZHNyRDdjOFBm?=
 =?utf-8?B?R0k3M0oxSVY4aXhkdUJKbGFtNmxzUE84bnA5R3BPcGs4aXdzcUhpRUp5NE9n?=
 =?utf-8?B?c2JwS3NQZ0RmNWs3bEtuS0dZaW5GV1NpeGphd3hhNmJhMVh6TnhERjZoNHZI?=
 =?utf-8?B?d0UvVW1nREJUbExyTnpJK0RyRFB6YTd4UHJCSEJzbFlNTDYzSTdmTXhDV0lZ?=
 =?utf-8?B?VWxrME1PYWRVNjBDWm5uS0x5cmR6WWtwQUJDYzFjSE14WnNtSUhRS2lYWkNj?=
 =?utf-8?B?Z240djBMcTlrb1BZbjBTZXZ6Mzh4NU9xUUd2NjhHOVA5SDY0OGg4bnhUb0li?=
 =?utf-8?B?SGhqNGdJYTNoWFFkU3ZzZGg1Qnp3V2xDSWg0QTB3NHExU29CY3p3a2pHWHE3?=
 =?utf-8?B?cURDMFZETkdnb21BTEF3dHZBT2dOTzV2MVRUaHJNL3AySDJHRkI2WGNDVDZJ?=
 =?utf-8?B?Y0dKejJIV3N1bTZBT2tRa1VnVzRydW9ydjFRT0ZCQ2FUQlBLNjdrWXppUGNm?=
 =?utf-8?B?Z1Q2QXdjSVUvZzArTTlzZC9tRThGQlZ6Z3FhdXN3UEkxNkVaWU5NRVpZbm9H?=
 =?utf-8?B?S0RrbFpYNC9EcE5PS0FkSHloUUkyMnhqSXF6UVl3L3l5cjdXRE16RGo2QzMz?=
 =?utf-8?B?cDRRU0sra1l5ZTdDNDdydmFvajUrcU1IeVg3Q3RXS3lTUDU5cjYzaDhaTmVM?=
 =?utf-8?B?a0xiVFhaRHhtc0xjYllkcy9RU0dnc21KSnlmbUxXNEhpQWFmaW1ZWmtKRzQz?=
 =?utf-8?B?dXJQZVlCaVhNU054WVJTcjdhRkFQdmowdnc2aUxMZWZzaWEwRjRwQT09?=
X-Exchange-RoutingPolicyChecked:
	gNTmhC5wTmcRfC1mnJUWWadmrQOlElmULNu0VuLzJ/6b48e1xC1OAS/oxv87PyFCJzIUk626e7X/Usf+K7IVhRIxc2OuPz/N6xHLIrnehdSKZXzIoOYvwkvQqJQPx8T0TK+NyjN+xK65XyMgMDGWQf9b3ePr2e3X0yQu2zPAeGjrKhsNq7aMSNAh1KlA9X6TTXoPp+lrsIOmWZ7aL5TxaMPWlSSoOQ40bblAFa+oXR8Gaf0LDlopuS7N7851YZk72lpqeo24hHMKH32TbatbFyWoBtZCUTqJkZvREd9R3pW1RqCGDh2cXcgBwDEM0GstMJb14fq4EzQTsrQQy+0tMg==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	ajALMsdvTg0tLvhVcbs3jfpl5HYw2kCAc31VUg5SpcfWiRmfHJUo2bmx/vpI79qK7zgUIM//5a2tgTauLqvOQpYcDH6V7VH4KdiTvOSz2dISZi847TvcTJmme8rAyFe8z5/ykr1js+lULL3MdUq+hWWPZmvQDuWNkwIeqhhylW+KpVCLmWVx7vBt95NfIMnRR817E/Dmg9cR4cwnI5mZq/QF83N1sFo5/o6Wky4J4eCei6JDeLq8a8YuZdwqP8FTIvgsGxVtFy0RFI8v/gPTRxIb1ITtcnqs0Cm8RePzBihTsi44hkSXFc0z8NRBukPd4SjViRpucXhFkAV8/vJSeOZVdJW2HbnFm70nwT5pYI35PDJfVlV/ht7reCdodpt4h2Yhr2ParelIiLM9GpsR6rD0wiuxicqxjpTboAfIn29FiSxGZw+BB9XmGS9QE3E4vsyuqN3VRYv3Veujp/h1TOzu5OZHfW831NNtbKrWP8hZzRqL/LO6vhFjQhK9HF/nDUASDqXLwdjMf6r0b0/cWNBDsLX5P2E7JsD/hEwH2LYzTKgdagIy/vegGAdgS1Imr+/SZXOJfGyGG6321MA7ar77fOLgU63HgUiI8RXv2Yo=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8f456102-6df5-4b31-f46b-08df22e6eedb
X-MS-Exchange-CrossTenant-AuthSource: BN0PR10MB5143.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 05 Oct 2026 13:45:36.0241
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: hnAdghyqCyjznU+4zEGy8UBawcTtQTmOzz4fQ/XcizV6I82tJJIgw8a7hxd05xyLBxmQ4HGih19LxtLd3tZCCw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DSVPR10MB997937
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-10-05_03,2026-10-05_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0
 malwarescore=0 spamscore=0 mlxlogscore=856 bulkscore=0 mlxscore=0
 adultscore=0 phishscore=0 lowpriorityscore=0 classifier=spam adjust=0
 reason=mlx scancount=1 engine=8.19.0-2609040000 definitions=main-2610050053
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDA1MDA1MyBTYWx0ZWRfXzcXbfuMqJkvZ
 Jnb26gfpci2X0GbcvTdXJDOgIa5z6osNdc4o4O6TauxEbr0882E9CPnpu52um3OgcYTkEGymYtf
 frkYCjFBrHRleR2njkumI7OC1F8Kg0Z3FC2cyAetXiakjlGkNAcs
X-Authority-Analysis: v=2.4 cv=d/dgWhjE c=1 sm=1 tr=0 ts=6ac3aa03 cx=c_pps
 a=XiAAW1AwiKB2Y8Wsi+sD2Q==:117 a=XiAAW1AwiKB2Y8Wsi+sD2Q==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=z/mQ4Ysz8XfWz/Q5cLBRGdckG28=:19
 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=xqWC_Br6kY4A:10 a=IkcTkHD0fZMA:10
 a=660iZSQnnn4A:10 a=GoEa3M9JfhUA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=jiCTI4zE5U7BLdzWsZGv:22 a=BqU2WV_vvsyTyxaotp0D:22 a=yLKeqhJSjpyUfR__ITgA:9
 a=QEXdDO2ut3YA:10 a=QYH75iMubAgA:10
X-Proofpoint-ORIG-GUID: ITccnaAyNgdygz3-WZqCnu0f3lTlRnFf
X-Proofpoint-GUID: ITccnaAyNgdygz3-WZqCnu0f3lTlRnFf
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDA1MDA1MyBTYWx0ZWRfXyQkXpnr29VHB
 TRIqyBvuWTL6776zRmODKiZa41TLtwh/d2/ht2APKSoyhHmViu7Baz3tf/mK6j21wh6XORU7/c9
 zow3JQg1Y0Gx0XWPeC2AwBOtvlvqruTJ3+ft8MRfAbK1OYVj99jTmc4LZ92C/TzGoczMvV/WBAE
 E5La7KhllA8hD0Ci3P2Z4F3akGPDVWR49lGgeNzWt4StbV0u5x+fNVUlQ7Yo5qb6N5JFK4TsqVa
 1LFBsmkAVtE8vREaPBLReLjQyfak2l0REdelFgnU2XfK83Re9BmtJJ0NeRA86y7ywSE5HG9gZd+
 /cg5HZLr/MQ1u/vfaF0v5G7xQITFu0kQj7qZF0W1SxTFdCSvhyZ5X5hUgZSOOD80yYlgeyCuBBM
 nPjq5+LbKrZHtgVSATt/68VoEUsJZmokI/POgqmOqukSAn4z4gu1y2lfkvYx6cvIUOQ5ZrD7/pG
 mGfQqslgq9v81Ahxx0Q==

On 04/10/2026 9:17 pm, Chuck Lever wrote:
> Hi Calum -
> 
> Ping on this one. I don't see it in pynfs master as of commit
> cd4701827a82 ("Add some tests for unsupported fattr4 attributes").
> 
> Is there anything you'd like changed, or can it be applied as-is?
> I'm happy to resend if that's easier.

Hi Chuck,

Yes, sorry, I have a bit of a backlog, I'll get to it asap. No need to 
resend.

cheers,
c.
