Received: from DM1PR04CU001.outbound.protection.outlook.com (mail-centralusazon11010053.outbound.protection.outlook.com [52.101.61.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B1803D3488;
	Sat,  1 Aug 2026 02:17:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.61.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785550648; cv=fail; b=fwE0P1TeUtTsX3YFPMdXuMedKUHNFAK3EmUcIN8vO/kW4srruPdm5QKBT02ZCMGPb4kkwEflhx755pjsy/RJU5QAhFlexTaYkf/2YNgH16BY27hYiXZm+FvQjvZTVbDg0oSYwP1Tqay1ZaNWrr133iFz1DabnyxThxyIBRWcFls=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785550648; c=relaxed/simple;
	bh=d1qronFy9w/J6Cgcl7Cn9sKuhG1MUxv1S4B+7W7oq5Y=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=GaR0xU6EeSpUJieOmVI1mIkO6/M3U/a/vZ4Zh5d20/j3rQqkhtiGOEMiBjsCUlXuCr/AasHKJRvI8jtaDMiRzmNGXRTDgBwzvXNaIE2CLLuGBnPBVMY7YuastEXKn5NoAq/NvgerODb+LdeMs8C8MhgTQNrpUhSPEEJaN4kV934=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=bQtJCjRc; arc=fail smtp.client-ip=52.101.61.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="bQtJCjRc"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=I7l9fgb+NuvuD+R5anVs9JYMUi9a35IiDvgs/M65huGyuB4XSkdcBFj96Qsd4fQvL+LYnCokcXI6YGNTMlUR0kRWAJcIqrrVFxwK1GqQbBT4G9mkU2Rtpb+gn3tfpqHFukVs+XDyiDlcfFXpgM6SfqhEKNEeMH8odAUvqlly9le4c5AAxlWKeJRxAwj5Gnn8e4oQP/kEpiJ8THYPCLFJNFAEis4FQ3uqsLh7sfktPtylKAhNuVq566pkwHsggmeS9yGNlWqyichD7oEh3WCkdI/EWxpxh5be4NNvmHAbubTIlg3U8hBOvdgGZKAOptr9V2j1Adpw2ZK1njjfNDT93g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=/N0f4pNTjlrvvsqDiA7ch3Ptmh4hKaDn1JOzG+v4I3A=;
 b=otux9MDqIdxHs+pCSiXtdqclJAYl+aMcQIF2miG1l8auumH8RAVQU45YSDDmdqPlBbRrKdGXePSBT47PY96SIUaKZoQAFHE6QsPHY/lxVFiPMXwFD7WtzHN2BkunjPTJ3GjhlIT6bSxw5/QpY8JZQqcPo89uSXkMoW/G6IoLetO44duPs2nJ0WHB15KS17gY04/9adoKp0Q9fJG0XSXA2obOWIWuOjb0Fsey2qeXVPEpvIrvimLa9ejG3l9ArcW79Yw8kOixwaTKjA23ZUTMoCR4lF9SldsS69a3r1Gf1arnPyKmXGySPDW/2sm+PtB6hr8w4HKEkJctyJZ6e0MIrw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/N0f4pNTjlrvvsqDiA7ch3Ptmh4hKaDn1JOzG+v4I3A=;
 b=bQtJCjRcuc2HBPbuaVO6OGBKCBrhVaAsY8lmE7Ex1778BBK+IMVFgysRjbdvIzrFCaRgzn/qbt3MShUxgoiBRXklSIW+UCoAFsug+YoZ9y0O+vr3gBCzirSzNoQ2oEdnwYo8VbYvNpkI7Z0QRlfXFvxXLEkWOD5nMfIB5CbXCYbKyN8g9/Syo9+3EhGFsfZTED9pkxmvZIzyYoVpol+fDs572bq2BSRYUkcxPKDDlrdOxrOyE+JdAdHLO4OcDbwFg6RhJ5T39fdew36thYM0bD8bsjVlGiUVXTYicIv60i+Rt9ugM99iXTtLs9cc5jbSaIpcvhH0cP12p9ZTmp/gGw==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by PH8PR12MB7373.namprd12.prod.outlook.com (2603:10b6:510:217::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.270.16; Sat, 1 Aug
 2026 02:17:19 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0270.015; Sat, 1 Aug 2026
 02:17:19 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Fri, 31 Jul 2026 22:13:36 -0400
Subject: [PATCH RFC 13/14] treewide: adjust comments on PagePrivate and
 PG_private
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260731-remove-pg_private-v1-13-142c97ba3562@nvidia.com>
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
 Zi Yan <ziy@nvidia.com>, Ilya Dryomov <idryomov@gmail.com>, 
 Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Richard Weinberger <richard@nod.at>, Zhihao Cheng <chengzhihao1@huawei.com>, 
 ceph-devel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-mtd@lists.infradead.org
X-Mailer: b4 0.14.3
X-ClientProxiedBy: YQBPR0101CA0267.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c01:68::27) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|PH8PR12MB7373:EE_
X-MS-Office365-Filtering-Correlation-Id: 6e22c095-4377-4be3-2299-08deef730352
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|7416014|376014|1800799024|23010399003|366016|11063799006|56012099006|10067099003|18002099003|22082099003|6133799003|921020;
X-Microsoft-Antispam-Message-Info:
	OoYjSdhMB5/FfsvCLddwvHB3YtSqnSfRwAi2zUiLB3su4ahtVUwmwZpCFMxQd4VdnBKSiNSc/SztlIWSIGBg79kFjjGjBqNKL3942KARlODfOpGbrpIRfo+q2j/V7OwXX+KowJFPKGZd7wD62ww7NWgY7oY2gW0N8n0AGrs55SFHExmPgCLS4NExcTmjDFnaqe9lU659BDghGWhgVj5Zy5eqIleeFyopNPKNH0N7Tk4GpqxYWV4s5FTqTRsOGujCs9CdqtP8O9e482a48Jplnn+P+RWxDVMpRLp8QJ9cVG+6aCjDbaj/Xi3Li/cXLSRCuy75tW56lefPqC8QlruEpD7vpq2jIMBHxyz4dtnP8xCPe9ae/P2v+OEl90R14Z51vi6FWuCm0TyHS11233FRvyeNAK6FeFxn8ooz2YWMQS5STzBSJeslpXLSpJ7HXWnTTSw6oxsvPIvtNseb3B1mL9dRcssOMbqGXEKGfAZiUFrHBGX2VbR7G7mPJK/dskgRY+IEZnCvqha4ujE6bJvtYqksSsgiRfyRX+rDQzQzjOy5PAUkCF99pMfSv9V2DYJ+RNY6V1/kkDweSd+Z0AEJebIE5AmewKabCHJnac2l00cONWwKU44AoNqXel1wkqSYSmNF1JchPRWXn0bhrZ5mbX1pRK6Mafy74mJ7zLkmDVbG1GtMze2JrpjIMJ2WuyX2DFNf5Wa40SR1DlxVe8DJlA==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(7416014)(376014)(1800799024)(23010399003)(366016)(11063799006)(56012099006)(10067099003)(18002099003)(22082099003)(6133799003)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?VFM3bzBmNVZ1WE15SmtDV004UFVkc0E5MDNqQ0Z4NEpVU3FUdTVndXQ4RVJr?=
 =?utf-8?B?RFc4eU1GY1dSY2U4ZndQVVFhSWZsSnZlelFXbWUvdkxGQXN0Z0ZRQjc1cENn?=
 =?utf-8?B?S25UVkNHQXZ0VDBxL2lmQW9Zd0NRdjI2RjY1NTRiTUxxcFZLNE1zTkRDdFVz?=
 =?utf-8?B?Ujh0WnpuQ2c0WFJrQURrTHdYWnE3NWFHMzhib3ZIKys0TnpTQ1ZvNlZ5ZEZT?=
 =?utf-8?B?OGYzU2JzdWJUQXBpbDdQajR4bkd0dGp0emFuTmR6eVdMeS9ESjhmeTdQRC9L?=
 =?utf-8?B?NU4xM3pvMXR3d2JOaGhaVER1MDRsRVo2cTRpTHFRdGdNbExqZnl0YWdqRFY5?=
 =?utf-8?B?TGJpeHYxNk10SE51NklHLzlKSWZQdTFsTkl5KzNydlV2QUlLcmYxSFpHMzY3?=
 =?utf-8?B?YlhvbWdwU3VCM3NoKyszc2JMcFZRL1hFK0JTQ1RGaU1tbEVualVHRDBaNzRx?=
 =?utf-8?B?SEtpcEhoYjB0TUd0VnNQckpqNUtCc2UrR2xPN2FlZFlDUzZSWlB2NHRWWHJL?=
 =?utf-8?B?anUyRzFRTmJoYklEZXR3T1FUQnFIcU1XZkxTeEVuYVEvU2JKVVFVSG9qY0gr?=
 =?utf-8?B?S3hlSGh1dzIrYTVucURtYU9HVXdMRnd0YVNGTVVVMnNoQk9QRHhITGZNZmx0?=
 =?utf-8?B?VmNHY2FYRTlWNm1FVWtVT0NuU3NtdUxHMDl1eDZOYTZPempRbDhvWXZJSWxC?=
 =?utf-8?B?c2gwanNKbnpNemM5UklxNmdhOGxLbDg3SitiWmIzbk5kaDc3dmFhWjU3d0hY?=
 =?utf-8?B?ejRLVmVuei8vTGpKdURleDBzSU9XV3BmdGI4dnhVWFBoaXFlUk9Nb0JRR0R4?=
 =?utf-8?B?b0FQYnJrdXRSM2dqN0k2TGE0T1hRa3pNMUo5V0VLNlpoZkVWVHYybjNsZWxk?=
 =?utf-8?B?K3JqYlA2UXlHbU9oZjNHOVcwdzRYVnBuTmNWaVU1eDNnUUc1V1JKS0RDTWFE?=
 =?utf-8?B?WWxWUHFnZjhxU0EvQTUrYm9QMFAxOFRZdmpIY1ZWUmJtTHEwRVNXS2NqWFV6?=
 =?utf-8?B?dWo1eTh1MlltenpQYlpyYlV5czJnMHdzQzljTGx4R0V5ODljUFIrc3RnYzFt?=
 =?utf-8?B?M0QrYktVbU8zRVJuK05ObFJ6NEtITngrUS9SUGxSZDhZSWl0MU5DYkhVb25p?=
 =?utf-8?B?REsyTStFZWhITUR6ajU2UmsvR0xNNk9EY3B5NFZlMkoxM3R4VE5hbDBQYTcz?=
 =?utf-8?B?QS9LRkVheUdWc0hvbzFycXlZTDRhNDd2L0x5cldoblNmL1VtbDJzNUE4d3hv?=
 =?utf-8?B?d1IwT0EvRkNnemxLOUg2NW03cFJaT00xV0pPQ0hKcHZzRkFKNEFUYlAraWhP?=
 =?utf-8?B?RmQzWTY5djRadVk5WXE4Zi80Qm1IVVhLTjVLWklxbGN4RE1hQThTQUN0YUNX?=
 =?utf-8?B?QlJxWCtMOHZHdU91ZE1vWGQwV0U5c1g1aXdpaFl5TlQ3UUZLNWQvMG9kRTZv?=
 =?utf-8?B?VkV5cXdrUUVySlAvdEliMXBrZjU0a1hITU5ka1piMUNUcGl2VG5DZXZQa3Ay?=
 =?utf-8?B?ZzFPSU51NkJNYW51eUoyUXhMT2JoMU9CaEpmRFliMXVtRXV2T3hIQndWOXpu?=
 =?utf-8?B?VnlyZWRva1FZZklmcVpieGpPN0R4dExMclI2K25rS3I5MnZ5NnFPM1lpVnB1?=
 =?utf-8?B?OWJjandxWkNtcVI4cFJqeFZBVXd0dldOSnc5Y0dya0UwRUhWckZDM1ErN2hR?=
 =?utf-8?B?N0dnOHg2Qm9BRGcxc2lyZDFtQTZTYmpoK0xFYlpBVk9zdnJtU3QrN3U3MXl6?=
 =?utf-8?B?dFRaSjlBWEJENm9iSUQ2NVdUNERMWTdZT1JWMllDMFBtSHY3WFJiY0NGQmZh?=
 =?utf-8?B?ejJTNGZKN2ZMeGFqOWJOdkpzTnZUakVJaHQ5OFEwb2VQQm9PZXFNcGNET1lD?=
 =?utf-8?B?MHJYWkRiUDU5UHRYdkFaYmcxUENmYzVGZUp0L1puZ2tObFpxaDJFQWtzMGJn?=
 =?utf-8?B?YVB5bStNTHVER3Z1M3M2QXovWlFrdmJ1WUNTMTV4VFE1RXVTZkpVNFVtV1pH?=
 =?utf-8?B?d08vQ2paQjI4cEYwZ2lQVFZoYUgxMVNnbEc2U1lXWGZyOWRVWXZ5T2hWcXpw?=
 =?utf-8?B?T2ZWTEtVVDNFK2ZQbVVVZ1hIajdVUlJ1WGg3K09yQ0crY0UxYVkveTQ4MmhN?=
 =?utf-8?B?WTFOL1lRYm5lWWpucE5qWTZVdDVaUGdORGJXaENkUGFiY2Q0aFdHcHozQzNM?=
 =?utf-8?B?WWN0YVVFRDNiNGlyaytXN29wNFpYU3JTd3l0aU9ZMHRaZm1hRHU1Ly9FTEZr?=
 =?utf-8?B?L1FRYUI5UHJmNDFuOWcrTzVhMEkrR1VWQzJBNlZpNHQvOTlvRmxydnVDajB4?=
 =?utf-8?Q?VLdTzrwyJUPM9wnHtc?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6e22c095-4377-4be3-2299-08deef730352
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 01 Aug 2026 02:17:19.0090
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: ZQcx0wEAAgsbUx6XDbEcd5FLzcwsmT5S3CHB9eIdlHDg8VSDseD9ewnL8NjsLF5S
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH8PR12MB7373

PG_private is going to be deleted. Adjust related comments to refer to
page/folio->private instead.

Assisted-by: Claude:claude-opus-4-8
Assisted-by: Codex:gpt-5
Signed-off-by: Zi Yan <ziy@nvidia.com>
To: Ilya Dryomov <idryomov@gmail.com>
To: Alex Markuze <amarkuze@redhat.com>
To: Viacheslav Dubeyko <slava@dubeyko.com>
To: Trond Myklebust <trondmy@kernel.org>
To: Anna Schumaker <anna@kernel.org>
To: Richard Weinberger <richard@nod.at>
To: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@kernel.org>
Cc: Zhihao Cheng <chengzhihao1@huawei.com>
Cc: Lorenzo Stoakes <ljs@kernel.org>
Cc: "Liam R. Howlett" <liam@infradead.org>
Cc: Vlastimil Babka <vbabka@kernel.org>
Cc: Mike Rapoport <rppt@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: ceph-devel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Cc: linux-mtd@lists.infradead.org
Cc: linux-mm@kvack.org
---
 fs/ceph/addr.c           | 4 ++--
 fs/nfs/file.c            | 4 ++--
 fs/ubifs/file.c          | 6 +++---
 include/linux/mm.h       | 6 +++---
 include/linux/mm_types.h | 4 ++--
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index 92074db8732ac..a4a463a9cef0a 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -122,8 +122,8 @@ static bool ceph_dirty_folio(struct address_space *mapping, struct folio *folio)
 	spin_unlock(&ci->i_ceph_lock);
 
 	/*
-	 * Reference snap context in folio->private.  Also set
-	 * PagePrivate so that we get invalidate_folio callback.
+	 * Reference snap context in folio->private. folio_attach_private()
+	 * triggers invalidate_folio callback.
 	 */
 	VM_WARN_ON_FOLIO(folio->private, folio);
 	folio_attach_private(folio, snapc);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 851d93a099889..fa3389d766d52 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -485,7 +485,7 @@ static int nfs_write_end(const struct kiocb *iocb,
  * Partially or wholly invalidate a page
  * - Release the private state associated with a page if undergoing complete
  *   page invalidation
- * - Called if either PG_private or PG_fscache is set on the page
+ * - Called if either folio->private or PG_fscache is set on the page
  * - Caller holds page lock
  */
 static void nfs_invalidate_folio(struct folio *folio, size_t offset,
@@ -556,7 +556,7 @@ static void nfs_check_dirty_writeback(struct folio *folio,
  * Attempt to clear the private state associated with a page when an error
  * occurs that requires the cached contents of an inode to be written back or
  * destroyed
- * - Called if either PG_private or fscache is set on the page
+ * - Called if either page->private or fscache is set on the page
  * - Caller holds page lock
  * - Return 0 if successful, -error otherwise
  */
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index e73c28b12f97f..61d6a56b8c8a4 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -12,14 +12,14 @@
  * This file implements VFS file and inode operations for regular files, device
  * nodes and symlinks as well as address space operations.
  *
- * UBIFS uses 2 page flags: @PG_private and @PG_checked. @PG_private is set if
+ * UBIFS uses folio->private and page flag @PG_checked. folio->private is set if
  * the page is dirty and is used for optimization purposes - dirty pages are
  * not budgeted so the flag shows that 'ubifs_write_end()' should not release
  * the budget for this page. The @PG_checked flag is set if full budgeting is
  * required for the page e.g., when it corresponds to a file hole or it is
  * beyond the file size. The budgeting is done in 'ubifs_write_begin()', because
  * it is OK to fail in this function, and the budget is released in
- * 'ubifs_write_end()'. So the @PG_private and @PG_checked flags carry
+ * 'ubifs_write_end()'. So the folio->private and @PG_checked flags carry
  * information about how the page was budgeted, to make it possible to release
  * the budget properly.
  *
@@ -1509,7 +1509,7 @@ static vm_fault_t ubifs_vm_page_mkwrite(struct vm_fault *vmf)
 	 *
 	 * At the moment we do not know whether the folio is dirty or not, so we
 	 * assume that it is not and budget for a new folio. We could look at
-	 * the @PG_private flag and figure this out, but we may race with write
+	 * folio->private and figure this out, but we may race with write
 	 * back and the folio state may change by the time we lock it, so this
 	 * would need additional care. We do not bother with this at the
 	 * moment, although it might be good idea to do. Instead, we allocate
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a93eaf7aae545..fc33cc1914273 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2073,8 +2073,8 @@ vm_fault_t finish_fault(struct vm_fault *vmf);
  *
  * A pagecache page contains an opaque `private' member, which belongs to the
  * page's address_space. Usually, this is the address of a circular list of
- * the page's disk buffers. PG_private must be set to tell the VM to call
- * into the filesystem to release these pages.
+ * the page's disk buffers. It tells the VM to call into the filesystem to
+ * release these pages.
  *
  * A folio may belong to an inode's memory mapping. In this case,
  * folio->mapping points to the inode, and folio->index is the file
@@ -2085,7 +2085,7 @@ vm_fault_t finish_fault(struct vm_fault *vmf);
  * case PG_swapcache is set, and page->private is an offset into the swapcache.
  *
  * In either case (swapcache or inode backed), the pagecache itself holds one
- * reference to the page. Setting PG_private should also increment the
+ * reference to the page. Setting page->private should also increment the
  * refcount. The each user mapping also has a reference to the page.
  *
  * The pagecache pages are stored in a per-mapping radix tree, which is
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index b5d4cd3b067bf..f15290dde16d3 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -108,7 +108,7 @@ struct page {
 			};
 			/**
 			 * @private: Mapping-private opaque data.
-			 * Usually used for buffer_heads if PagePrivate.
+			 * Usually used for buffer_heads.
 			 * Used for swp_entry_t if swapcache flag set.
 			 * Indicates order in the buddy system if PageBuddy
 			 * or on pcp_llist.
@@ -675,7 +675,7 @@ static inline void ptdesc_pmd_pts_init(struct ptdesc *ptdesc)
 #define STRUCT_PAGE_MAX_SHIFT	(order_base_2(sizeof(struct page)))
 
 /*
- * page_private can be used on tail pages.  However, PagePrivate is only
+ * page_private can be used on tail pages.  However, it is only
  * checked by the VM on the head page.  So page_private on the tail pages
  * should be used for data that's ancillary to the head page (eg attaching
  * buffer heads to tail pages after attaching buffer heads to the head page)

-- 
2.53.0

