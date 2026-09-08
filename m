Received: from SA9PR02CU001.outbound.protection.outlook.com (mail-southcentralusazon11013007.outbound.protection.outlook.com [40.93.196.7])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECDC0324B32;
	Tue,  8 Sep 2026 02:57:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.196.7
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788836226; cv=fail; b=ZodoIBuT2ibsFLqLMqc9SV/h/fStJaDcfmyS2UF0jJBI8WpkHdzRJK9V/PRkSYpBgG0XIqLePv8S39qx9DAg4fSbegujuBEeiLVsNVXViXtNaZnBR1ra7ap6pJvH8bDHpkZJ0WKtqysO9t0AMBVmP9TsvwsrQghlS/phA8QJKLc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788836226; c=relaxed/simple;
	bh=G9oKb5mPbQTZWyi7K9myTbCw9Vaon2+lQEo/1IO5TBc=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=BtP04FUish6ZscLzA0FU2ogXWutV9qlEAI/63kR4qxGI8Vr6yEsr1qdoFoIKXTgyhqV3OT9SDRaLpLvOQM0DKNNg2JTRD/MRRXoCZFrP9hht3HswCgBWZzBsq5VNopwrOoyN8NfGnOgmGlUq+StMc65017mksIsuHYA/Nq36W7I=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=cAiFdvpW; arc=fail smtp.client-ip=40.93.196.7
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="cAiFdvpW"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=D89odFjd4J8fZYpZbtTTxSAQYM05otqtuD1VPTv27NrQ2HugI4DXv/f7GC7fms0U5Gs0t3R48/sYBfAEkjmALSkW5bXMXYaMn0VRpZtny7UF7v7ozPUK0vUJ/9cVbsjBA91FzpPbZVzMk7txjbJ9BiD1oqDF0P9b9096Ask5RoSanaUB3ZdQ7G/bGI2gCX0eTb1+gI2b92fWTil/TJd3NxLvEGm8spzVadtnD3eI5LwTR1jXeWA1o79rZLIKwG4WAMtLLvgFLhaW+SraYYn8UZ0r2b5Zr7IplCyIM/2z2+eapWidQz0D69g3yxdLOxYDFrsGyWR69vIK5vbHA3+Iog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=nrSqr57luulPh6wG91+g+Vft/27AmtHC/vIs3/cRylA=;
 b=BdIWVY/L7Gj1DfLWxe5luuUjZv9hTwyOkA/VjUD+DrquSN/OtdrXTdhsu5LBvbRQfzCAYUfPkcPiWROj/Ju/40G1O2kjZ5hK2rvZqkPSGB9Lfw3f4Ku0zdrQcYaJsBNQvQKK5NHP8oDK7Hn9b8J6yZ6i8wBN7OHtiDTeGedpe3hVVcyJmatYiRLx0Ef4F0oZRJuEv9YUIZjFLm/TxHg8SD8086+RvwnmZY9eFe946NimYq/BHXU8G/k9qarRiUTYz9m9N9uMs+chGWr1kMvAm+gipXD2APDZqsvvvjYW3nGRwiSBB9moKBwpinJHxOCoyegFFrNrEA+54MXjLwDiSw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nrSqr57luulPh6wG91+g+Vft/27AmtHC/vIs3/cRylA=;
 b=cAiFdvpWKSRdW4w4EtAymInXpriM+MgZw3Z7ZnjBBXHrAF9NGoUeTt5gEMlDgz3e85kahrLY/VSQrUfT/uDXHXoSGf9BFF7Qto+3R9TGTVCYX7uyzyj6mOw/MYiEoN9mDriTLKex/azj7SPVCSZkCxcKeXPmPtxugYH1tOZXXXGvsTlWDYHZ7D6LXnCLxGg9tvzWqAfQUkG3nEJ0iDO3uamebJ6ixsl9RsxGaBe3Tj3yGM3Wq11YIJu1PmT0NwlBh+PMY5ec1Va3Vk58GyaHD+raee0DMLun2ui7zJmP3buGmvJPiZNwG0kC/trBBAo522V4PhDfoqh1b/fLPfr8JQ==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by DM6PR12MB4435.namprd12.prod.outlook.com (2603:10b6:5:2a6::23) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.382.15; Tue, 8 Sep
 2026 02:56:46 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0382.014; Tue, 8 Sep 2026
 02:56:45 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Mon, 07 Sep 2026 22:56:20 -0400
Subject: [PATCH v3 13/14] treewide: adjust comments on PagePrivate and
 PG_private
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260907-remove-pg_private-v3-13-6ae22f9d9272@nvidia.com>
References: <20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com>
In-Reply-To: <20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com>
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
X-Mailer: b4 0.15.2
X-ClientProxiedBy: YQ1P288CA0016.CANP288.PROD.OUTLOOK.COM
 (2603:10b6:c01:9e::21) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|DM6PR12MB4435:EE_
X-MS-Office365-Filtering-Correlation-Id: 1050ba67-4793-448c-cfaa-08df0d54d1cb
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|7416014|366016|23010399003|1800799024|921020|10067099003|56012099006|11063799006|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	IoLTX8IdzLuQ+qwI7J3xzQ3FIh536GTL0RI4DvxcQ8JoH90kpyNRSUDmgowv4Q8WizXNjOmVTbSAy4kPZgc+lLnygMW54vYgNb9VHwRA8c/p4s20Hj/fzDVJ5i6ZkaUKhhhamXMNHp8lY6VP/e2X0BhilhxMr634ky/4syC6qdSYD1QZ2geE3wrMqWaJSa/r//ogcfLPrCNO5JHhxOQz2pwWpBQbz9RNQAWYhcWkrDibIulzv7FhIeC+zDxM7JomXYwLO74rAU5XxJNjuIFn0kkeZMTMeb88C5ef5QeGdlk7D3njaaokK/4xBYvc3Dm7kaaZRdNa+9qskZ86SYoG/san8hgCRI60KC/XmwWXDprJwHFdoJ6UOE+NsPAVVnn0BvHxSnWSJ3RbYi3QzS38QwR8aOsEs/RdaHA9tRRB51fMOdRr1UorE9kssOVCCEUN4hAlQUT1h6TzJBk/9AFbNYKdWwtIrCwFZIC7airXXmeMb1HjgrMF/8ne1P2kMbEn75cVlvv8DmZnKjHLdoO/LRtado462Uambv8ul9JtszuHhNkWPX7f6e8dOxz9HADzbJVp/3GL6z2YZmNppIG3ZlQ6wPiVDFopI1Vhwiv/kkXp9xNWuwbvxFqEUOOwUr+B+33Bl3rG8PD9tFCh5lQnrtRYhz8wrGQFh/ML/bM4KEDfr51oOkbWXUhRZrlcaUScE5mU79zyHj0Mxlt1fD+rzA==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(7416014)(366016)(23010399003)(1800799024)(921020)(10067099003)(56012099006)(11063799006)(22082099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?aWFuaGpCZ29EQUVWS2xKYzNlenVUWHd1N0hBRjZXRUw5R2dKcWV6cEdXSGJG?=
 =?utf-8?B?bUVYZ3N5MTAxNFhkYTNQa2NrVXVTeSs3aDBNam9qU1ZkcVJLM2ZvMUhkVzEy?=
 =?utf-8?B?cUpSd2diekFrSkxEVlJNVGphZ3NaWHkyMDhKQWE3QTZrcVpZYnAvREUxeUFX?=
 =?utf-8?B?cTBic2JtN0JaR29IQm9lemx0M1RLMitoY1E1SnpMSGl2b293aTA3RjRVQ1VF?=
 =?utf-8?B?Q1lWaUhpRjhIVzMwb2lseEZndGprQS9FdW5ROEltUHpqaFBHcW02Tk5rZGs1?=
 =?utf-8?B?Ti9DKytnd2JQUXBkNVJCOGUvSUN1Sjk0RUlqUFp6V3EzQzc1eXl6SkxRd0JP?=
 =?utf-8?B?eUMxZllRWVJSY2RVWlkwZ29lUTAvR1R4VlE3NnFtTGxqR0FMMGhQTHZxbWhv?=
 =?utf-8?B?bHI2WEEzR3lyMzQ2eVE0MHBOeGNOMzk2V0hDU0wyVnRDam16TTJKSGg0K0FU?=
 =?utf-8?B?WjVPNHRjTDlRQmNBZHpadHFkaHNLUmpwditPRTUxNjZxQUdMOVNSK2xyQjNW?=
 =?utf-8?B?V2hISDl6d2hmOXVEUkl2d3BwM0hnRS9JMUUxb3VHa01xd0Rka1JIMC9VNFVQ?=
 =?utf-8?B?YWw3cU5DL2xsQ2h4YWtWV0lmUEczRVVVZmxtVVhWTUJUZXBiMjVUeHQyUXlz?=
 =?utf-8?B?UTdnQ05wenVKQWtHUlJMcnBtb1R6N0V5N3RvM1g0cWE1YmllT1Z0S1ZocDMw?=
 =?utf-8?B?Y2IvcHBrYmw4aXpBSE5tWGpwVVhTdWtkdmR2RVpNNFVVWDNXTHVITElFTVJv?=
 =?utf-8?B?NXRORlNHZkU4SEl4L2xQL3p3K28xUERORzNSbzUxTkdxSlBHKytYRlN6bk5C?=
 =?utf-8?B?d2lvTWVHWnBGMlVwOFk3UFZaMnRkclVSNk1hZzhyQlBuVlJCZkx5MElFWjlO?=
 =?utf-8?B?aitqTG9WNnhINjdZMDdxNkxWb21TMUhIYWdXc240cGNLSnI2L1FyVUt6czZE?=
 =?utf-8?B?OHltbjdyNWxzc2M0RWtDZTdGT2dEQ1FSV0lUY1dKR0JSbVhBTkdJVVBsWGFs?=
 =?utf-8?B?dGI2cXV6YUlKQ1RaSUxHSkE1c0JhZG55WGtvQlMyNm4yQXplMEIyRDlPVHM4?=
 =?utf-8?B?OC9JdDNiNmtOb3hmTWJCeEI4Q1gxUzFZdTZJdEd4WDMyZWhWMkp1QzdCalph?=
 =?utf-8?B?RGkzRFJGTGJwaVVKZmNoN1BWQ1pFczFOTDA4Rm1vK0N6TEZScXlPc3BuYzRo?=
 =?utf-8?B?NkowQk9aQTdpU2xzZjVCaEIzNG13K0hsZktiU1ZIOUhIeVpyeEV5Z2g3LzEv?=
 =?utf-8?B?MjZxdzlMdEJvWENnelFhTVlLWkJ6Uyt1SDlkT3FsQTlBYitCR2lwYWg5T0Fp?=
 =?utf-8?B?ZmlUa09SRGlZaFBYaUprdTc3bUpwUHJZUkp5OGJGNWw5TVBCUG1Nb1JscVEv?=
 =?utf-8?B?S1pHNXBHWExvdC80aVR2WEVPOVE5SkRHckdOS2g0R0RtbnFDZ2FpZk1YWDc4?=
 =?utf-8?B?MFpWbmxZbG1kdGFCZEJPQUl4aElDWVBLaXBTWEF6RUVxdk5xUmVwTHgwQjg4?=
 =?utf-8?B?NHh0VGtrblJKanZJd05oaktsR2tEYkljU1Y4S0tsUVBkaFNISWs3dUN1cHhJ?=
 =?utf-8?B?d1VrV0hWSFZTbmhuUWlWMUxnWS9jZHA0Um8wMUU3VCt3c2xIV2poVHJqUkxF?=
 =?utf-8?B?YnRzS2wzU205c2lEbmhtemRBZko5Tm0rL3FHZDROWTdWUFJsVE0xeDYwSHpp?=
 =?utf-8?B?Z0Z2OFNtcXd4d216LzhvZFZVbXNhYXVySXlwMEVZUWNSOFYrbzNFcWpIMjlq?=
 =?utf-8?B?b29aTmtqY1oySUNvdG1tcWZEQk51V3V1ZXFIQXdVY0NCWHFjcW0zZ3NnZXJ3?=
 =?utf-8?B?bmRaUjByUnZuZ3A0VEFZWXBlNVl5b29pWDhGcW0vL3NjZzB1THhJcllQYlI1?=
 =?utf-8?B?VVBwcEUxb1FXT0l4YWJVSStJbFh0N1Rjc0MyanJHM3hBSklJTUp2K3YrU203?=
 =?utf-8?B?dmpDaTY0Ri9PalNlRFlpUmN1SUlSUVoxNWQ1bHpKbnVza2ZQODUvYk9OaURy?=
 =?utf-8?B?UWdFZkQrRFJscGZNRlU5dTJPSXdScFhhRlRaVXZxY0lvVDVNUGFNNzJJWTNj?=
 =?utf-8?B?aHA5MlFSemxtTVd3bTlObG9iYU4ybEZZeTgyMEhrVENqbkpZVjY2V2lOVWVt?=
 =?utf-8?B?U2xwZzlZOXQrM0cwSzg1ZDRnbHEvVG5OeHhiNlNMRzZUVGxaQ2U0R1BPNVVK?=
 =?utf-8?B?VldOeVBuZWpXK3ZLRjNHTVEvTjVCNVJZOS8zT0lmVTNubWtUR2Q2SkFEMW1Y?=
 =?utf-8?B?Yk9lQXl5RDlXdjZLOTdHb0VyWUk3SitRVGNuVXlhQUdxR2FkOWFaNk41VktC?=
 =?utf-8?Q?mZdMIQwqpU84cDxF/2?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1050ba67-4793-448c-cfaa-08df0d54d1cb
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 Sep 2026 02:56:45.8933
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: Lb98meLRXOz3e82QtRLkkTWjxqnJdTLreyzHIPenqt2r/HtATMFMnE1WGn8Wi86w
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB4435

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
 fs/ceph/addr.c           |  4 ++--
 fs/nfs/file.c            |  4 ++--
 fs/ubifs/file.c          |  8 ++++----
 include/linux/mm.h       | 15 ++++++++-------
 include/linux/mm_types.h |  4 ++--
 5 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index fad17df1d5082..f9b2ec9550481 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -122,8 +122,8 @@ static bool ceph_dirty_folio(struct address_space *mapping, struct folio *folio)
 	spin_unlock(&ci->i_ceph_lock);
 
 	/*
-	 * Reference snap context in folio->private.  Also set
-	 * PagePrivate so that we get invalidate_folio callback.
+	 * Reference snap context in folio->private. Setting folio->private is
+	 * what gets us the invalidate_folio callback.
 	 */
 	VM_WARN_ON_FOLIO(folio->private, folio);
 	folio_attach_private(folio, snapc);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index e1bdd10b35f10..38f830a6467c9 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -484,7 +484,7 @@ static int nfs_write_end(const struct kiocb *iocb,
  * Partially or wholly invalidate a page
  * - Release the private state associated with a page if undergoing complete
  *   page invalidation
- * - Called if either PG_private or PG_fscache is set on the page
+ * - Called if either folio->private or PG_fscache is set on the page
  * - Caller holds page lock
  */
 static void nfs_invalidate_folio(struct folio *folio, size_t offset,
@@ -555,7 +555,7 @@ static void nfs_check_dirty_writeback(struct folio *folio,
  * Attempt to clear the private state associated with a page when an error
  * occurs that requires the cached contents of an inode to be written back or
  * destroyed
- * - Called if either PG_private or fscache is set on the page
+ * - Called if either page->private or fscache is set on the page
  * - Caller holds page lock
  * - Return 0 if successful, -error otherwise
  */
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index e73c28b12f97f..aa0298ce451ef 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -12,14 +12,14 @@
  * This file implements VFS file and inode operations for regular files, device
  * nodes and symlinks as well as address space operations.
  *
- * UBIFS uses 2 page flags: @PG_private and @PG_checked. @PG_private is set if
+ * UBIFS uses folio->private and page flag @PG_checked. folio->private is set if
  * the page is dirty and is used for optimization purposes - dirty pages are
- * not budgeted so the flag shows that 'ubifs_write_end()' should not release
+ * not budgeted so it shows that 'ubifs_write_end()' should not release
  * the budget for this page. The @PG_checked flag is set if full budgeting is
  * required for the page e.g., when it corresponds to a file hole or it is
  * beyond the file size. The budgeting is done in 'ubifs_write_begin()', because
  * it is OK to fail in this function, and the budget is released in
- * 'ubifs_write_end()'. So the @PG_private and @PG_checked flags carry
+ * 'ubifs_write_end()'. So the folio->private and the @PG_checked flag carry
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
index c861525cda83f..0ceffe4f9ca02 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2048,20 +2048,21 @@ vm_fault_t finish_fault(struct vm_fault *vmf);
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
  * offset of the folio, in units of PAGE_SIZE.
  *
- * If pagecache pages are not associated with an inode, they are said to be
- * anonymous pages. These may become associated with the swapcache, and in that
- * case PG_swapcache is set, and page->private is an offset into the swapcache.
+ * If pagecache folios are not associated with an inode, they are said to be
+ * anonymous folios. These may become associated with the swapcache, and in that
+ * case PG_swapcache is set, and folio->private is an offset into the swapcache.
  *
  * In either case (swapcache or inode backed), the pagecache itself holds one
- * reference to the page. Setting PG_private should also increment the
- * refcount. The each user mapping also has a reference to the page.
+ * reference to the folio. Attaching filesystem private data via
+ * folio_attach_private() also increments the refcount. Each user mapping also
+ * has a reference to the folio.
  *
  * The pagecache pages are stored in a per-mapping radix tree, which is
  * rooted at mapping->i_pages, and indexed by offset.
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5413bd10fff2c..9d6c945ba4104 100644
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

