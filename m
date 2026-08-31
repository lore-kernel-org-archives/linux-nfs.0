Received: from mx0a-00069f02.pphosted.com (mx0a-00069f02.pphosted.com [205.220.165.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F188136F8EA
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 19:34:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=205.220.165.32
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788204872; cv=fail; b=L74ylnOQYmrqdYQS93lzMX4CVmUwfXSRlwsskn+r6hs6oejGj437enQkXPRPEVyh57QhTKaGbvdzENXh18fhoj9QjwDPE4Ga7CXTBU0eOLaUyRQxrMpDwbuhIbyOFXpKzuXFluKWDrrUqTUUJHkpb2ENEDgoUbSHMbhSNqLbag8=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788204872; c=relaxed/simple;
	bh=Bmq84MxXqZdSE1S2eoSKKtfDW2MNSSP9xZejCXa3wxU=;
	h=Message-ID:Date:Subject:To:Cc:References:From:In-Reply-To:
	 MIME-Version:Content-Type; b=UzoRn8SBnnQcLqgIX8Rw78+Nno0/CxxUCeVa5gIIxer0ANb7K/b/ymdFL6ux1hfWmtAX5uBWzXZG6+VHAEPKFiSjBXv5lojMMYsPM6PgVrIT5iS5s3GZzjUyf3w1of07rGscybxwV9g2S0fq0zb4CRyskQ9W3OFngue4/UvE51Y=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com; spf=pass smtp.mailfrom=oracle.com; dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b=aeZUbrVX; dkim=fail (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b=GK+dBtov reason="signature verification failed"; arc=fail smtp.client-ip=205.220.165.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=oracle.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oracle.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="aeZUbrVX";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=oracle.onmicrosoft.com header.i=@oracle.onmicrosoft.com header.b="GK+dBtov"
Received: from pps.filterd (m0246629.ppops.net [127.0.0.1])
	by mx0b-00069f02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 67VGBieS2165149;
	Mon, 31 Aug 2026 19:33:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=
	corp-2025-04-25; bh=Yx27YAAjdTrg7Zi+1gfbi7q6//aCy0VOUob9jd8sMXs=; b=
	aeZUbrVXT0GoxUVy+r4qyYD0ZTIy0sZtdDCHXFk0Zmpx2DNIVRclkxpFN/wy5J61
	rMzCgTwWOTJzKkEZ8zPVyb6Wa4pZniotpJQj6M7fL0mEjuGCNnh7MUXmsyB+SHE5
	4EER1AUg4zFlGFVO9HimnZHhgLstt1xOOKZgaN4jzuluGDxp36fjJgqeycVZv1CX
	1AjdG3ioa8o9F8SWVlebWvBGHONRW1moXlMNltYYfm1roCvKhOVhOYqZ0xt6OPbV
	BV4viAgRS4yHl3/yVFr8F7WtialpTal6JsReoSbgi/ry4QdviDrsh91yMTM7PKSL
	j14FRe0t6CmU6bh5hCPjcg==
Received: from phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com (phxpaimrmta03.appoci.oracle.com [138.1.37.129])
	by mx0b-00069f02.pphosted.com (PPS) with ESMTPS id 4gbqa7k8yh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 31 Aug 2026 19:33:12 +0000 (GMT)
Received: from pps.filterd (phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com [127.0.0.1])
	by phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com (8.18.1.7/8.18.1.7) with ESMTP id 67VJP7HS002032;
	Mon, 31 Aug 2026 19:33:12 GMT
Received: from sa9pr02cu001.outbound.protection.outlook.com (mail-southcentralusazon11013031.outbound.protection.outlook.com [40.93.196.31])
	by phxpaimrmta03.imrmtpd1.prodappphxaev1.oraclevcn.com (PPS) with ESMTPS id 4gbnvdascv-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 31 Aug 2026 19:33:12 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=wzApTR0JJg/Qff1pmp+/ACwzwq8ULomTUOn7uqa8GPhs7uOCcGOriib1xRa5v5DuH1W8YtwyjJFC2F6KQGBjqe1j8gYr4cJFQ41sAz1ACYPjyrSEfZ+MBDt+Cpj/J4Qr4KfIV2FlZtDqBFGU04BSFr6QHGT4FIN8a/psFx6TYA+o8/tKUoEot4FlF13WzyiWYVrn/9gQqW1mtIGLcYRz8CHXwRI1vu7yC7wgPb02xvyxK9zSvQnkfHhg+ttN9ZemwusijMYSPTAq6X5hieTgDlbYOFpN9nJL9yyfrmWysqbjoKZju+kM26I2gYCt4CBI0Ppsh7BEOM5lh/JwzHc7/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=aHVI6pL7G+4YGN63NneZwqgUJnwbwtr38m2XQ0Y9Cuc=;
 b=UHDxJdyw0SwYY3g0BRuYCAdEy4u0arfjDCKzz448XHST4UUuwAl3eYdqUjuVxaH6k+8nJE+CFREz9vVfr+Aeibz3XwfrjNhXbQm0UANfsAGs+YQGCk0D2h+4IKICojS8bBhrxqxwaT914Fs83yFdlLTLA5J5Et+DicrjmLJlzEeIm6fOp7vuiPy/mtY2th/yZnx7nqecvEkX1q6gHa5NoVZINmQCpDetT2IVN4U1iNvtmHUP+044oLJ17eXDulT+4Z313J/Sf7tVK4WftnwwBJH7SOhweo1S8RiaeGFmLeAcV29kxrvkh2sTBHgo+4FPkHRdn6D5WTvOHyZb1S7h9g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oracle.com; dmarc=pass action=none header.from=oracle.com;
 dkim=pass header.d=oracle.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=oracle.onmicrosoft.com; s=selector2-oracle-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aHVI6pL7G+4YGN63NneZwqgUJnwbwtr38m2XQ0Y9Cuc=;
 b=GK+dBtov8UU42fRKobdxstcdTn6fEqq/guTU/jj05GYwsp53PyD/H/ckuu+WCy46wd6OPwyWn+393qno6Txi56riJsurcqrWwzB8GDM8zXzVJXHotR693+uoEBezvdj9cP4iK/JL6y7fMOphqEf0pdtfdaxd4BiN/Cd4I7a0Gtk=
Received: from LV3PR10MB7796.namprd10.prod.outlook.com (2603:10b6:408:1ae::6)
 by BL3PR10MB6042.namprd10.prod.outlook.com (2603:10b6:208:3b2::13) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.382.10; Mon, 31 Aug
 2026 19:33:06 +0000
Received: from LV3PR10MB7796.namprd10.prod.outlook.com
 ([fe80::a30e:ee88:c7b4:c0d8]) by LV3PR10MB7796.namprd10.prod.outlook.com
 ([fe80::a30e:ee88:c7b4:c0d8%4]) with mapi id 15.21.0382.007; Mon, 31 Aug 2026
 19:33:06 +0000
Message-ID: <2d9dc79f-1d98-4a6d-9dbf-201fc8a90828@oracle.com>
Date: Mon, 31 Aug 2026 12:33:02 -0700
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] SUNRPC: add transport details to timeout diagnostics
To: Petr Vorel <pvorel@suse.cz>
Cc: Dai.Ngo@oracle.com, anna@kernel.org, cel@kernel.org, jlayton@kernel.org,
        linux-nfs@vger.kernel.org, neil@brown.name, okorniev@redhat.com,
        tom@talpey.com, trondmy@kernel.org
References: <20260819173055.1956882-1-manjunath.b.patil@oracle.com>
 <20260820111303.455807-1-pvorel@suse.cz>
 <8e43238e-f06d-4da1-a898-2bdc1d827e81@oracle.com>
 <20260820185922.GA511595@pevik>
Content-Language: en-US
From: manjunath.b.patil@oracle.com
In-Reply-To: <20260820185922.GA511595@pevik>
X-ClientProxiedBy: CH2PR18CA0018.namprd18.prod.outlook.com
 (2603:10b6:610:4f::28) To LV3PR10MB7796.namprd10.prod.outlook.com
 (2603:10b6:408:1ae::6)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: LV3PR10MB7796:EE_|BL3PR10MB6042:EE_
X-MS-Office365-Filtering-Correlation-Id: 2f300f8a-b529-48f5-a959-08df0796ade4
X-LD-Processed: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b,ExtAddr
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
 BCL:0;ARA:13230040|366016|1800799024|23010399003|376014|10067099003|4133799003|4143699003|56012099006|18002099003|22082099003;
X-Microsoft-Antispam-Message-Info:
 G50xha/nxhdWlfnZSF2mIt7MsAdjSlfspN/zTWTcYe5xz9+jwZYS06HL1XRltad5c3gYQ0RBgi1z7G/aIQp1JghtTNzSBVlBa1dq0SLMHNOl+NDr6EkDMzMhw2ZO//104BXy34P0YclqdiWIwSqFTgxfYB2vdi7Qk1HhHKiDTS6eQs7+sd0xlFFfN38M7W89ayW/lE6L5S9Ay8vCYAljWPWBD3YMo7a6nslmdWE2xyHCLikSSTKmfL2SdIRwyln68Y5tPa0B14l1GBs22RdH49V70blcvzGGdTjdwUzSKI85o6BcNpWCaN15HjrLFmfHcgzt5A88AGtmxnIj68XXzb+BApyoNeVkpddrvsx1v5nQI7QMEu+1xkKV7/mP7itX4p8m0nkFV6EAtnEjoO2eewXgKB5LO3KDAHNB6WZtdBrV1d2+++3CEfMimhuiT5fbAd9VEfwkp3n5zPEMlFQWqwlZtTjxcU0ABKePJOSEABoH3HA/k+2xsjxtTrx3N7srWsHQYUTphCzOO2oEYwu0S0xBtESGs+Ogkw8hbqiWiAFzis0n898rqfr7u7p6ajMEwh50F3c4Dvdk0J425x6ecfqh85K8r4NxQq0k4R7r/Guv+DOdR6mxKYxxpijZMuskgD+hYjXrazWkNa0Rh83cinpxOC6zgJNnIVmOZMKSkao=
X-Forefront-Antispam-Report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:LV3PR10MB7796.namprd10.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(23010399003)(376014)(10067099003)(4133799003)(4143699003)(56012099006)(18002099003)(22082099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
 =?utf-8?B?dndBazdNR2tHK1VqM1U2Y29ObzlSeVhSaDJ5dG1UTVk4ZmxYbU9JKzZva0tS?=
 =?utf-8?B?SzM1bUdqV1QxcS9tUFFEcXBhSU9HZ29tWXN6TnZaakcrYVFKQkYvNnVhVlh5?=
 =?utf-8?B?VUExbUcwV283ZHRZZEhySytpeWJGcjJoZG8wSm5zSUE2SGdDcWE4SFFRQXNw?=
 =?utf-8?B?amxGRjBEeksvcmFraWYxUzFHOU0xZytIcVRWZzZiSXNKRExYZXZSU2FHL1RD?=
 =?utf-8?B?VTk1dkdSTjQ3SWV1ZSs5NGx1TFRDRGt5WVlnWFdjVStTRUNUZHEyQWhlbS9l?=
 =?utf-8?B?M1dNZ2pmWndqNG9yZjNhTXFSdTJCRzdyRTN0ZnU2LzhZMU5zM2szSk9mVHlp?=
 =?utf-8?B?SUszRHhGZXlINTEwUXo5ZEdHMHpTWWxUOUtITVBVOHhKTnpHOTdWeUFIcjRu?=
 =?utf-8?B?NHV1MW1GUUVMZno3bjN4MHl6b3JtdTVqLzFuM2ZyeUJpTTZScXhDbjJSeklD?=
 =?utf-8?B?VUZ3Y2pXOURsR1FObmVBbUpXbmh5QjB0NmRQcVZhdndzSFV3VWk3R3k5Yyt3?=
 =?utf-8?B?bDg4ZytRU0U0eEoyUmcwTnp2ZnB1N2FXclpKQVA2ZFFaZG94ZlhnSjhhemh6?=
 =?utf-8?B?NVlKaUc2YUgvdDAwK1FFYzlubDdBeEcyYzVjQjNEVWFGMWtLYUcwZFN5VlNl?=
 =?utf-8?B?dXp4aW5LK0VScEd4UndEZE1zZVNGeU5qOTFLZU94V1BWSFF0Sm5rbzBNdEhO?=
 =?utf-8?B?VU5PTkVDcDRwSEd4UGJzK2JFUWc2eXN0eGg2MmozVTk1RVQ0UXZRdXErVWVp?=
 =?utf-8?B?NnhKRzNDenpEUmxGWVVVZ2ZVSG9KOGozQjhGNXJySHJBbkJJZjZPbU9ZcmRZ?=
 =?utf-8?B?VTM3ZUZFYzVDeUNYNm0rWnVHc3dvV3FEeUViSzZRZHNHdW9kZnNHN3RGZG1T?=
 =?utf-8?B?Zi9ESFR4WGUrdXRHUzRlUUdhQmtLTmNsODdqMFQyYTNtc0luSkRURmZ5eDYw?=
 =?utf-8?B?MXlNS2M5U2JSSnlkYXAwams4YThOcFhsbDd0VGgrbU5YS0tLYzJrUWpjTWlY?=
 =?utf-8?B?RGxGSit0b0NvaFkyZVE5cmdUbVh0dGYxNFMzR0Vla2RwaHllRmIrSU5RUzZO?=
 =?utf-8?B?MmlDQnd2V1N5akZUdEhMejVPbkdoZEE2c2Y1NFpOY2VQZ1RYc25JN0ZETDhq?=
 =?utf-8?B?M2NScTJ1Y3JITDcwZ083QVVBb2Y0TUc4TVYvd1ZiQzZ2eFFYc1JYTVBwbERo?=
 =?utf-8?B?UVFVbC9CeVcxdzE1MXltY3B2V1oraE9tY1c0dENyVUNhL3NwT2lrbVZEMU56?=
 =?utf-8?B?L0FwR1NSSFNmNW1RcTdQU0FwbE9DYmtFeFdVMHZMVXNvK3RqOHNDV1R3eisr?=
 =?utf-8?B?MDVDUExBWWQxMHd5Q2ZCQU9WbGJQVDdNbkwrTnVYOWlndytBZU1iOGxmV3hW?=
 =?utf-8?B?TUE0VkMvbmtVSEpIcndDWnhPQkVRUmgyaC9VTGNFcFdQdWErM3huWkhsdU44?=
 =?utf-8?B?R3ZxYkVVeXdIZTJRTmtmTW8vQ3hXaVl4THRjVUhPMkQ1aHl0SERsUzlWNG43?=
 =?utf-8?B?c1ZmdllCcVpTM0NzNktic1diY0RUMlM0N1pxYyswMkNoNGUxSzdGbDZrbFhE?=
 =?utf-8?B?SUdmaGEzVUNoMUMyZ1lZUlhjc0hQOWhFRUxWb251ZVNnTHlUSE04UjJwMmZX?=
 =?utf-8?B?eEtmTFI3UGdZaTNjSmQ5b1g5TVhCTW1YWGRnbGdXdmxNUUo3ODBwU0pQTGdY?=
 =?utf-8?B?L05iSzdORFFFeUsrZ3VDTjhDYjlpakcvbjJXS21GTHJjZGhQRlB4b1lsTlNs?=
 =?utf-8?B?VERJUWlNRS9RN1E3N1E5ZjN0bmpoZDRCSmxOUjFTeVRXZXF0cVN6Zm9aMk9U?=
 =?utf-8?B?KytTODczdzA2T2tkL1g3Y3ZMQjNVR1AxYkE3Mkl3bDhQKzN6SFZyU3N0RnFX?=
 =?utf-8?B?eXNsbzFveWZmc3pSZmpQTWFETFVFSDZERWZVTEYzNDlyRkZocEtTL3gxTHg2?=
 =?utf-8?B?dzRaSEdVbzJYUnd0MklrM0cycUdPYi9qWjREamRBRkswU2RhekVka2I4OS8x?=
 =?utf-8?B?UE5LSnNkWkx3UGI0czJvbkkreDB6cU4waGxSTUZVb1BsaWlFZlU5bSttNGor?=
 =?utf-8?B?NDUwdkxPU2VnMjNyVmRLZmd2WUE3UDJwQnM1U012b0k2R1hXRFVNVmtwREho?=
 =?utf-8?B?STZzSzkzdUhJTUg0Q2VpQ1A3SUxjeERJYnRJQUdZdUNzL2k3Z3RENkZtMnI3?=
 =?utf-8?B?UUR4bk1tWThGejBoeklLeFVieHc3ZE5FRUI3anJra0FsMGtDbkRDejFMM2hp?=
 =?utf-8?B?a0pEeFdBQWx5RGNRRFJHTW9OTFpETDlCR2wvOVVDdDZIejdRM081TVBUYUVS?=
 =?utf-8?B?TFRKOHR0enlmVXJRNU94YUJ0czd4SXJSNk1qd0p4cytsUzE3T0tha0JHeW9K?=
 =?utf-8?Q?s0eenWQEX32Ozi+w=3D?=
X-Exchange-RoutingPolicyChecked:
	JIEmNR7Ay3O1M8dLGBd/+6dT0+vZFxtGa43Cy8OauIW/oYBoYJ3pJZEaipzkmXi3C8TKu6uSKRv+Tm2AjN1KBzxTLvmFOIfoH7FVCmiIDPER7AlSbthagtkt9mFqh/Zg8fOFMCXHq/jsgBplC+oOTErBO6Td561xUIWrwWTH6RxqsFsjUlj1tqZhXL7o7ryelVPKA+nOBdon6Ih5Fg/mPrWp014AnxXrA+QRM9c9zaVo0YQfz7vRsiaaNkYyszjlh1VsOHEzpv7UPuMduV6RPWbdVeW0CNwE48b204FFjCqjNnGf/h0g13UPQvVoWBzVYx+x4aolJhnv89+sFwWQTQ==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	aLoPMX3X19mkT+Y4U2FkSxvzhdTiaV4s0F1kjfvROhFTDggp/r6Uc9CSkLW4KqKUjUX218MmtUNKWdbOx8FaN9YgEzkgURNOhNLZEeNDuUG0HedGB5NPlqdL9Laxu4hAUkYNfdUCa7XPugEpchkNGToXy0wMG+pUHSNeHz5eb4jEHT5iFwoNz1VEuatYWI722D6sExYuM6andv+rod3neQ1KBEp6BP+dy4qOL8Rt6YnIqyPjjXoIWWeojr05pRsPdkBjuAdUEkQU+4CfHvatGmjv+KeMkP0+5hAl2AegSCXSxCOr4k4qfnIrIWPQLINkGz9Ibn+yPv0lgCWquHWVuGwBFqjD97PqdTgwZl/LYCp5uSlP2MtlA+FmSiJs3U5reg63UcnTTrFavwXZwwR87xY9XVAHpM1B9PSbsgo1h3gZSvQsG2Fq3oiX/1yDqe0EyXsUFHzoNV0gQnzwfka+rMM938lotJ7J9OuNH4mpUhthOw+OxztKeqYQI6NyLpCgRoP998KOoOiws8QamSkIZZVVPXUPqokwF+liJ76YfkyyKTkHM+s6yb+g1bgQ83eRhE2O0aMfRAcz4DfuYtm2mHIwygiOjbKj4WbA1OKx3CU=
X-OriginatorOrg: oracle.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2f300f8a-b529-48f5-a959-08df0796ade4
X-MS-Exchange-CrossTenant-AuthSource: LV3PR10MB7796.namprd10.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 31 Aug 2026 19:33:05.9404
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 4e2c6054-71cb-48f1-bd6c-3a9705aca71b
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: YPZ9n0RTB94jRF84p6+xwwA8hTlF1rQCW2oWHXEUoKAYliLLPssI9AFe7HhxnZAxYvWiR7l4JOfNQQ6iHtT3/KPmouZY1eJKPVKcAESyo4c=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BL3PR10MB6042
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-08-31_06,2026-08-31_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0
 lowpriorityscore=0 adultscore=0 mlxscore=0 spamscore=0 mlxlogscore=999
 suspectscore=0 phishscore=0 bulkscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.19.0-2606160000 definitions=main-2608310168
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Spam-Info: AW1haW4tMjYwODMxMDE2OSBTYWx0ZWRfXxOmAizviWpXF
 XOvWmWJ+ePHiiCafAOprtccnaVDfSqblR0bPN33lMascrx4cPYQC23kTljz96wdJUBCi/flCRmF
 7fYKATYyaodTfBjsaWCPZ0OzD+iSNt9qCM8S20Mtfc23Oj8fG5vr
X-Proofpoint-GUID: t7J3GmGgHqdlmrWDV5nHfyj-nmpFwUOz
X-Authority-Analysis: v=2.4 cv=DPu/JSNb c=1 sm=1 tr=0 ts=6a95d6f9 b=1 cx=c_pps
 a=WeWmnZmh0fydH62SvGsd2A==:117 a=WeWmnZmh0fydH62SvGsd2A==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=z/mQ4Ysz8XfWz/Q5cLBRGdckG28=:19
 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=xqWC_Br6kY4A:10 a=IkcTkHD0fZMA:10
 a=Sv0fKeRqtYgA:10 a=GoEa3M9JfhUA:10 a=VkNPw1HP01LnGYTKEx00:22
 a=jiCTI4zE5U7BLdzWsZGv:22 a=EIcjfB9IiI4px24ztqRk:22 a=RpNjiQI2AAAA:8
 a=VwQbUJbxAAAA:8 a=yPCof4ZbAAAA:8 a=Tv5zQYVXGwV-74ZgAYoA:9 a=3ZKOabzyN94A:10
 a=QEXdDO2ut3YA:10 a=WmVTiCyuxqgg3mnwYu6p:22
X-Proofpoint-ORIG-GUID: t7J3GmGgHqdlmrWDV5nHfyj-nmpFwUOz
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwODMxMDE2OSBTYWx0ZWRfXxEkFg/plmeTv
 R0BTflOx4DfcdJztWmM8dXxVVArjHV8mqG8UhcZHOoSRPqwv9A2zuW7AydcackXKFmCjynl+/5H
 OOD1efT85XCMBOYGRC82GwA5z+secTliv/FYPw39TMmQMJ87Z8/1lAntxRKQ3ubrbbTJoofXQPf
 +gfM6xuaLDVxeXcEiCA3UebKTY7ShFwlGC8ZdErNvATB7JkSYzyQLBw3vcBV09O9JfyK01l6rlc
 HpAAos9tah1anM6fbMM4GKoRq9UUQF99CTd0mPPccI+vAaf3xAQ2QDIJSZoiMZeBPvy0KmTywte
 nmxyew3yn2l7irDK9fjx+ewBVKzv4cxYbVxXI3GwUejICASTava3OyEv31lvtvkkPcLelrocPeo
 VvHWncLdDp0JBNyBecvQqP8+lKlgS2qnbyMR7DVpijgbyjwdl8V118CSJEL1jQLnVKuN7deWfYm
 /aO3cxt39oV3jv0phBw==

On 8/20/26 11:59 AM, Petr Vorel wrote:
>  > On 8/20/26 4:=E2=80=8A13 AM, Petr Vorel wrote: > > > The existing RPC =
timeout=20
> messages identify only the RPC program and > > > server name. That makes=
=20
> it difficult to distinguish a server-side > > > response stall from
>=20
>=20
>> On 8/20/26 4:13 AM, Petr Vorel wrote:
>> >  > The existing RPC timeout messages identify only the RPC program and=
 >
>> > server name. That makes it difficult to distinguish a server-side >
>> > response stall from a transport that is disconnected, reconnecting, > =
or
>> > using a different
>=20
>=20
>> > > The existing RPC timeout messages identify only the RPC program and
>> > > server name. That makes it difficult to distinguish a server-side
>> > > response stall from a transport that is disconnected, reconnecting,
>> > > or using a different connection.
>=20
>> > > Include the RPC client id, transport id, current transport connection
>> > > cookie, and RPC task owner in the ratelimited timeout messages. These
>> > > fields provide a compact way to correlate a timeout message with
>> > > rpcctl and other transport state.
>=20
>> > > For example, an NFS timeout reports:
>=20
>> > >   nfs: server 192.168.50.1 clid=3D4 xprt=3D1 cc=3D1 owner=3D6245
>> > >   not responding, timed out
>=20
>> > Nice improvement, thanks!
>=20
>=20
>> > > Assisted-by: Codex:gpt-5
>> > > Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
>> > > ---
>> > >  net/sunrpc/clnt.c | 20 +++++++++++++-------
>> > >  1 file changed, 13 insertions(+), 7 deletions(-)
>=20
>> > > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> > > index efa26899bc7d..6b5e2787dc81 100644
>> > > --- a/net/sunrpc/clnt.c
>> > > +++ b/net/sunrpc/clnt.c
>> > > @@ -2534,17 +2534,21 @@ static void
>> > >  rpc_check_timeout(struct rpc_task *task)
>> > >  {
>> > >  	struct rpc_clnt	*clnt =3D task->tk_client;
>> > > +	struct rpc_rqst	*req;
>> > > +	struct rpc_xprt	*xprt;
>=20
>> > nit: Would it work to assign req and task earlier (just readability?)
>> > Or is it not safe before checking RPC_SIGNALLED(task)?
>=20
>> > 	struct rpc_clnt	*clnt =3D task->tk_client;
>> > 	struct rpc_rqst	*req =3D task->tk_rqstp;
>> > 	struct rpc_xprt	*xprt =3D req->rq_xprt;
>=20
>> > The rest LGTM.
>> > Reviewed-by: Petr Vorel <pvorel@suse.cz>
>=20

Hi Trond, Anna, and Chuck,

Could you please let me know the next steps for this patch submission?=20
Should I wait longer for review, or are there any formatting or=20
submission issues that I need to fix?

I also noticed that the Patchwork event shows the patch as "Not Applicable":

https://patchwork.kernel.org/api/1.2/events/?patch=3D14757794

Could you clarify what that means for this submission?

Thanks,
Manjunath

>> > Kind regards,
>> > Petr
>=20
>> Hi Petr,
>=20
> Hi Manjunath,
>=20
>> Thanks for the review and the Reviewed-by tag.
>=20
> yw.
>=20
>> I kept the assignments after RPC_SIGNALLED(task) intentionally, preservi=
ng
>> the existing behavior where a signalled task returns before we dereferen=
ce
>> task->tk_rqstp. xprt is also needed only after xprt_adjust_timeout(req)
>> reports an expired timeout.
>=20
> Understand, fair enough.
>=20
>> I would prefer to retain the current ordering for those reasons. Also I =
am
>> open if maintainers chose to alter it.
>=20
> +1
>=20
> Kind regards,
> Petr
>=20
>> Thanks,                   Manjunath
>=20
>=20
>> > >  	if (RPC_SIGNALLED(task))
>> > >  		return;
>> > > -	if (xprt_adjust_timeout(task->tk_rqstp) =3D=3D 0)
>> > > +	req =3D task->tk_rqstp;
>> > > +	if (xprt_adjust_timeout(req) =3D=3D 0)
>> > >  		return;
>> > > +	xprt =3D req->rq_xprt;
>> > >  	trace_rpc_timeout_status(task);
>> > >  	task->tk_timeouts++;
>> > > -	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(task->tk_rqstp))=
 {
>> > > +	if (RPC_IS_SOFTCONN(task) && !rpc_check_connected(req)) {
>> > >  		rpc_call_rpcerror(task, -ETIMEDOUT);
>> > >  		return;
>> > >  	}
>> > > @@ -2556,14 +2560,15 @@ rpc_check_timeout(struct rpc_task *task)
>> > >  		 * connection gets terminally broken.
>> > >  		 */
>> > >  		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
>> > > -		    rpc_check_connected(task->tk_rqstp))
>> > > +		    rpc_check_connected(req))
>> > >  			return;
>> > >  		if (clnt->cl_chatty) {
>> > >  			pr_notice_ratelimited(
>> > > -				"%s: server %s not responding, timed out\n",
>> > > +				"%s: server %s clid=3D%u xprt=3D%u cc=3D%u owner=3D%d not respo=
nding, timed out\n",
>> > >  				clnt->cl_program->name,
>> > > -				task->tk_xprt->servername);
>> > > +				xprt->servername, clnt->cl_clid, xprt->id,
>> > > +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
>> > >  		}
>> > >  		if (task->tk_flags & RPC_TASK_TIMEOUT)
>> > >  			rpc_call_rpcerror(task, -ETIMEDOUT);
>> > > @@ -2576,9 +2581,10 @@ rpc_check_timeout(struct rpc_task *task)
>> > >  		task->tk_flags |=3D RPC_CALL_MAJORSEEN;
>> > >  		if (clnt->cl_chatty) {
>> > >  			pr_notice_ratelimited(
>> > > -				"%s: server %s not responding, still trying\n",
>> > > +				"%s: server %s clid=3D%u xprt=3D%u cc=3D%u owner=3D%d not respo=
nding, still trying\n",
>> > >  				clnt->cl_program->name,
>> > > -				task->tk_xprt->servername);
>> > > +				xprt->servername, clnt->cl_clid, xprt->id,
>> > > +				READ_ONCE(xprt->connect_cookie), task->tk_owner);
>> > >  		}
>> > >  	}
>> > >  	rpc_force_rebind(clnt);
>=20
>=20

