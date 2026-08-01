Received: from DM1PR04CU001.outbound.protection.outlook.com (mail-centralusazon11010053.outbound.protection.outlook.com [52.101.61.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83DDD3CAE80;
	Sat,  1 Aug 2026 02:17:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.61.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785550644; cv=fail; b=elvG6y2nA/XjTwerwtBkWL3WT3v8n1JurH+zmir2IFsIUZ8QrwLjapGyVsO1qi0Em1vSgJplZxMZV7cC72CknxGB6Gtnm5qUt+v1Bq6ldlVJRAd1N1Tq1PiGXEHAw2bZj2keX10Kt8johWoMU3ngPLFiy8mftuRPvwr259F1aLw=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785550644; c=relaxed/simple;
	bh=IKzuYV22urpgBlckYLv37cjVTy0l1Lhd1u2gOTETy/A=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=s5PH+Vb9van+fRt3I1zhmBlfDSEn3oylbg2Juj9yAYGOlSkgfqb7CIBVGkdf8fjzTD01XuVCtSHVh8HV8HPelXQQF1FTjwPdHW8PuaRk2WZUCM6VXII8ldMZ4sOUE7nKv121mJ9XTCBCLdeP83IKmcE0grxUzd2g1RmZjHUeVlM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=a/U1vveT; arc=fail smtp.client-ip=52.101.61.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="a/U1vveT"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=A+OPzzjghyU8z52C/Gb87aqfOxdgsqToV/iwlAJ2rD4/RtK05siMA308H1Sq/tRdDuQxbaHGwCoPLfEW3vZuxaI/Evtn/0MNtXYRBhw4TU9ISo5u0pG4uontvoa2zfSmV4v9vH9XDlUsWPZyWtbSX8tYxqrMHeiZUGp2inoZ8u/UnexQJmQ7dXBXm16aR/IMW2WlS92h4uNogYi+9MTjJU7/5lkG13IdSe3pto+HHGQqXUWtu0YS309P9kUmPN/yd6RSfnRAwGJvPbBc36+BVQbcr1JFy//1ihXCtkI59PJmKlGdBR1Jxr44MlkOhDNftkOzu4OzGkSEnIoGWX+6rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=n4lozvq9uKgvd0bpywWGfYya+QgCvIFqHmjtqhue0JU=;
 b=Ifa48KguS2w236QnAAb+m58XsdBFHaTn4ybD54/nQgIKpY/tAOlq5h41DqUMagkDLuPocXPef2uik1RgsDmAqqKOwRu8BCoQg5MFCw7hfQxhaz03p+OX+RNmvwJSjwMAVP5tvXcW/B+ZYnOnmnjk5Lyk8D+z9dqxC37dm1GOWn6aTb3dWK8w7ZM+v+ot2Kmw3hjrRwb6bpaHZwCHfx0cA5/hSM21+oiuOU4I7keROH0yGhtWbdNO6FCjf46Vfl30JrTgFr3bTx7Aqwb6ypOeKb3VO4KdTylLjVgr2TpuWzTylomOPqQYdyqX2hxrmZTqASeFKLuX+V05M3BSyd2G+A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=n4lozvq9uKgvd0bpywWGfYya+QgCvIFqHmjtqhue0JU=;
 b=a/U1vveTLmBgVl8qTFHn0YktC/JpfARhY4LQyKNQWh00Daek+8F9N605nXuYzWlcnynpUEk1SqcvAPiNgxByHmQn9b2sD3xL0qaeHESPeC+527ZbWiplwA2ZDlcf1JWoORDTdcYFFF30nMeBiQg2LmjkQsvNSELYD1iQAf/PcdVO6rF1fEqpBH1UjqCYZOh5okp3BhKqpgcBsotz7+dtePR0+nawZk9Ld2W3Kx1vl4aEkZ9K29+1lFZInerELBZqyKtq/FPTqT5pthfULj2Mo1znvVF7oq96oAgugR3Wx9/VzWwByHhKU61kfUWQd3HYhRW0YYMTSFTBjkqbEJrgpw==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by PH8PR12MB7373.namprd12.prod.outlook.com (2603:10b6:510:217::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.270.16; Sat, 1 Aug
 2026 02:17:16 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0270.015; Sat, 1 Aug 2026
 02:17:16 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Fri, 31 Jul 2026 22:13:34 -0400
Subject: [PATCH RFC 11/14] treewide: remove folio_set/clear_private()
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260731-remove-pg_private-v1-11-142c97ba3562@nvidia.com>
References: <20260731-remove-pg_private-v1-0-142c97ba3562@nvidia.com>
In-Reply-To: <20260731-remove-pg_private-v1-0-142c97ba3562@nvidia.com>
To: David Hildenbrand <david@kernel.org>, 
 "Matthew Wilcox (Oracle)" <willy@infradead.org>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 Muchun Song <muchun.song@linux.dev>, Lorenzo Stoakes <ljs@kernel.org>, 
 "Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
 Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
 Michal Hocko <mhocko@suse.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, 
 Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>, 
 Dev Jain <dev.jain@arm.com>, Barry Song <baohua@kernel.org>, 
 Lance Yang <lance.yang@linux.dev>, Usama Arif <usama.arif@linux.dev>, 
 Gregory Price <gourry@gourry.net>, 
 Ying Huang <ying.huang@linux.alibaba.com>, 
 Alistair Popple <apopple@nvidia.com>, Johannes Weiner <hannes@cmpxchg.org>, 
 Qi Zheng <qi.zheng@linux.dev>, Shakeel Butt <shakeel.butt@linux.dev>, 
 Kairui Song <kasong@tencent.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
 Zi Yan <ziy@nvidia.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jan Kara <jack@suse.cz>, 
 Matthew Brost <matthew.brost@intel.com>, 
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>, 
 Byungchul Park <byungchul@sk.com>, linux-nfs@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org
X-Mailer: b4 0.14.3
X-ClientProxiedBy: YQBPR0101CA0331.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c01:6b::23) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|PH8PR12MB7373:EE_
X-MS-Office365-Filtering-Correlation-Id: 8ecab2c0-bb39-479d-696d-08deef7301ce
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|7416014|376014|1800799024|23010399003|366016|11063799006|56012099006|10067099003|18002099003|22082099003|921020;
X-Microsoft-Antispam-Message-Info:
	xXx87EjiaXGsntcE9tDyl1M8js9rolJZmrjYvTlux1aiVm2yDP/iix5PW/wQC9yO0yeDINafCEVYHN4mwTB21rXXMBeLuccdlmBAcz8bIObykZO2ZmmMfp0wON8T5gii2oBS6SVBPJ5YmPjQnF23mG/xiI4bRrVEx89B/u74pWsFljH9aHbFU1Pw3G8wYXkDEfXetIE45WZDnctL5PvLr/DPoJTsXKS3S0UkgsmD5191S7caNn0NCcQgZPtbUEcbZ1oDas4M4E2agvDVc1vCqy0c0NFY3cUcr16eECum2BAfV8MFhMbyYAP5DiwhtLOEDtd7vYqcUFeHlfQWu0XAJk4idMmlML0k/ASWFIVFsgTnv7L0AMqhe1tbxgtMAEZmcE9Ix5SQUHFUBs91uIu4TjWizx3zapF58N7IQ+hEzyN9rQJSIgcnBYtetbUhtgY87o+phcnPja/mh0aWQIiJefFRTJVxiPBMP1+AAXZ46MyQG/kB7zpjVeBytqncMx75ou8NqLZFOPsLpcrzPBpLsbax8FPAT5EIpB6Q1lGPjh1qiB8QEKUWgDShaStn6f5iMxNvvJCKyue7QL7T1YiIp/FlETNGahI9vsxlG2sPGpKEx9tsMfdzyWLvW5q+JldZwiG+e11xb6iXMJsMtEcGomSPxijZqJduxBvbC3K6M0DsnV4B6pBFrU6m6ViOsTQed4K//SkOJdLcEJmZwoR7vw==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(7416014)(376014)(1800799024)(23010399003)(366016)(11063799006)(56012099006)(10067099003)(18002099003)(22082099003)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?NlVuMGQ4aDdjRmUrRnlxVTBobW16NVpicVBZQUR3S1RYOWh1VzdGSFk0anRl?=
 =?utf-8?B?bXV5aDc0c01sazBaQkdpN0tJbHUxNlVuMFpuSzRjZ3lpVVhScHBQTCtvU1Vu?=
 =?utf-8?B?dkFxMHBKQnM5bTlFVzIrNld0UU9IR1R6ZzgxQlBvQUFZVTV4SHB5TVJ0YmI2?=
 =?utf-8?B?R2o5SGFaQnpsOElBdkdCdjZyMVhKOFlWR21VVzNRTEM1RCt1N0NWR2NVMGNj?=
 =?utf-8?B?V0RQaFBOZy9zUk1hYkg2Z3l6R0pMZXZQcDI5UFpXRnJRbnEvelRmV1BaMmFm?=
 =?utf-8?B?TllubFk1QXRnS0d5QW96WG5ieWdLSFdkN3pXYmhGTXRCY211L2N5aDJTM25B?=
 =?utf-8?B?MlI5dGhCZXpJVEYvczcweXQ0NmZSczVwU1EvdGM5MVFFckg2ZHlVd3Vqcno4?=
 =?utf-8?B?L1hiaGZuNmI0c2x4aEM2dzhzbkdGd09XbnV0K2tacXEyR2RQanJRT2VjekU4?=
 =?utf-8?B?WjFGWmJoeTluSm1WOXVhOEp2TGJqYzZVZ0dlem5hb1cybnN4K3VkaHB5Qjlp?=
 =?utf-8?B?Y2tKWGFyWGpWY29Ubzc4TFFVRUE0R2RHMEhRRHBrajlaUDZ5aGJDUE4xTjNX?=
 =?utf-8?B?dTdYMUsrR0dDc0V4K2IzN29ZVEFHaTJIWktKN1pzRGlyMGVrYjdBVEkrWVA0?=
 =?utf-8?B?WDFTbzhWaWJPVWJMWkFWYk5lcTJDZEtjOGhYZnRjUW5RbExycHBMNjVUQTBT?=
 =?utf-8?B?Y2hOZ1cwd281eDZqcXMzZFcva0xTbDBaWUowWDBNcXpuZjhEU0h1UzhMUVRm?=
 =?utf-8?B?eDBGM0FINXhBU04vNU12U1Z0RG5xbXdNY3orYTVLdi9VSDE1MDFXekZ4ZjdB?=
 =?utf-8?B?aVMzZDZZV3QzNHd1ZCtON21WT0dlbXRoUzVsTDlpM1Vqd3ptejNvTkYyZGhh?=
 =?utf-8?B?Z2l4U294YUVNRFdHcjN1ME9mM2NGNXhoK1dzVWF3c0NTZHN1bW9teitZQ0Nv?=
 =?utf-8?B?QWNJT3UxQ3FoTENpYkVidXRPWXRJdHhvUXFGU3cyRXNhNFVDRFByUzA2U0JN?=
 =?utf-8?B?bm9KYVpBT051cVNKRnEvN3laUlBOK3NSS1d3M2ZTcmNVL2RwaldoSjRTQ1ZR?=
 =?utf-8?B?M21UTGpnbjd5dGdSM0o0ODVqalkzK21vUU1TbFJmTmtDVk56dDNXL1Fud1dj?=
 =?utf-8?B?a0taU3ZkQUR5THJ3Ri9VTVZjaE5hTUtCd1k4YUxNWFptR1lJL1Nub3ZxYzlR?=
 =?utf-8?B?MGNOMGxUZDd5L3E4cCtXVEVVU01NdmpRdWg3SzI0dVVienowZ09oWHYxRGxC?=
 =?utf-8?B?UHVTeC85cU9CZzhNNXBsOGh1RGVDVmZlazNmeW5yejN2NFpVS2pobkdsa0pj?=
 =?utf-8?B?d3dZTkZ0dlN4K0xkencxa095THVHRWhRWFc4dnluT25Ibm1NOTNUNWtsY290?=
 =?utf-8?B?dFpXaFNEVkFFdTFVZGJTNlJkUk45cmYzaFJ5cWJFRjVESGpCYnJCelpjVU9z?=
 =?utf-8?B?RW56L21xVHJNbXViQmo5cHZoK0cxR25hZnMxSEIrN0Y5aXdlcXlvWkNUU2RQ?=
 =?utf-8?B?TTNFcnMxTm4wdUtreXV0bllNQmhDWWNWbWsrQzdJN3J5WGd1Szh1djZ1bU1u?=
 =?utf-8?B?SFRMNGpBS3NBdkVCQnFqT1JBQVZXZVpWYWhGS0J6UmpJZEZOWFV5Zks4WUVH?=
 =?utf-8?B?MmRxYVRPK3RENXRkS0M1R2tRLzNJblRsRmRYWFRydmpzdGxPNHYzdlg5Nkpx?=
 =?utf-8?B?WVRacS9QZ1dpMmN3cWF5QTdzcStZVEg4T291RXQ0THNJSm1DMXRJdHhWc0pZ?=
 =?utf-8?B?Z3E0WFJ5b3grVW9XRGxxekpuRFNIUWNZc0ZrSWpqMndzMHFNdTZxTWFIS0cr?=
 =?utf-8?B?MDVsK01RZnJVZGtsZCtUVVlkY2tRNzR6a3d3ZFJTWk55NU96eFBvZmkvOGkx?=
 =?utf-8?B?SWJmcUVUUmhDTmpxdGF4Z00rY1gzS3VybklMMHl1OEh6T2RJaEVHUk9WS2JF?=
 =?utf-8?B?bUVHWTJlS25rQkRjWFNkSXVZMzhjZkZPZFNtSk81L1hPcExlNHRrYjEwcmNu?=
 =?utf-8?B?cFdGWjJ0RE51NHh6aWh4SFNCSGZVTk1yOEtLV3NLN25jdUhLVWVtc3FpMDBi?=
 =?utf-8?B?aGt4RmMvNjZvQWRxbkR3azFqMVMxQU9xdXF1alpqd1NzdkRQWGlNRW1UWm12?=
 =?utf-8?B?T1NXUzQ2aFIvNm5vajkvbSs0SzhpUnh6ZGNleFp3OFh4amcwRWdSNVFqM04x?=
 =?utf-8?B?V1gxYXdWRjNFaVZ2QkNVc0I3YW44c1MvTms3c0lvM2EzWS93UjkrQ25FUHpy?=
 =?utf-8?B?TmlEOHA5bW56NnErM014SkdFTW42TnZDM3g3a242UDFxREdHcUk5b1EvSjQw?=
 =?utf-8?Q?zc1g8ducTZMR6q2UzC?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8ecab2c0-bb39-479d-696d-08deef7301ce
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 01 Aug 2026 02:17:16.4542
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: xze2rfAkupGrMuxDrHONTIIQw96llD4yJRlCuVcVqci2rjnLmVIgTbcB/1xZdUdl
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH8PR12MB7373

They are no-ops now. Remove them.

Assisted-by: Claude:claude-opus-4-8
Assisted-by: Codex:gpt-5
Signed-off-by: Zi Yan <ziy@nvidia.com>
To: Trond Myklebust <trondmy@kernel.org>
To: Anna Schumaker <anna@kernel.org>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@kernel.org>
Cc: Zi Yan <ziy@nvidia.com>
Cc: Matthew Brost <matthew.brost@intel.com>
Cc: Joshua Hahn <joshua.hahnjy@gmail.com>
Cc: Rakie Kim <rakie.kim@sk.com>
Cc: Byungchul Park <byungchul@sk.com>
Cc: Gregory Price <gourry@gourry.net>
Cc: Ying Huang <ying.huang@linux.alibaba.com>
Cc: Alistair Popple <apopple@nvidia.com>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 fs/nfs/write.c          | 2 --
 include/linux/pagemap.h | 4 +---
 mm/migrate.c            | 1 -
 3 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d2b03ceaeb4f1..d7e50ecb4edc3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -717,7 +717,6 @@ static void nfs_inode_add_request(struct nfs_page *req)
 	nfs_lock_request(req);
 	spin_lock(&mapping->i_private_lock);
 	set_bit(PG_MAPPED, &req->wb_flags);
-	folio_set_private(folio);
 	folio->private = req;
 	spin_unlock(&mapping->i_private_lock);
 	atomic_long_inc(&nfsi->nrequests);
@@ -744,7 +743,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 		spin_lock(&mapping->i_private_lock);
 		if (likely(folio)) {
 			folio->private = NULL;
-			folio_clear_private(folio);
 			clear_bit(PG_MAPPED, &req->wb_head->wb_flags);
 		}
 		spin_unlock(&mapping->i_private_lock);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 90904a4d173b7..5ca5aa365f319 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -594,7 +594,6 @@ static inline void folio_attach_private(struct folio *folio, void *data)
 {
 	folio_get(folio);
 	folio->private = data;
-	folio_set_private(folio);
 }
 
 /**
@@ -629,9 +628,8 @@ static inline void *folio_detach_private(struct folio *folio)
 {
 	void *data = folio_get_private(folio);
 
-	if (!folio_test_private(folio))
+	if (!data)
 		return NULL;
-	folio_clear_private(folio);
 	folio->private = NULL;
 	folio_put(folio);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 014fcb745d210..1d84766f12a18 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -838,7 +838,6 @@ void folio_migrate_flags(struct folio *newfolio, struct folio *folio)
 	 */
 	if (folio_test_swapcache(folio))
 		folio_clear_swapcache(folio);
-	folio_clear_private(folio);
 
 	/* page->private contains hugetlb specific flags */
 	if (!folio_test_hugetlb(folio))

-- 
2.53.0

