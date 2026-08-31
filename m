Received: from CH5PR02CU005.outbound.protection.outlook.com (mail-northcentralusazon11012005.outbound.protection.outlook.com [40.107.200.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A28C737C911;
	Mon, 31 Aug 2026 19:26:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.107.200.5
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788204366; cv=fail; b=HzCvOKfFo9ugxtFJ+iD4wUNnhATq6ckTYRp3Ttj+oO2D/nakZEHfnpmJ4id7EHiytw+vaE2qwmDE9lo1wa4cGEi10Z9L1/mKki70y+5Mip2acHpmmMMpOtIdL5C1eUtW2zfadSR/dpX1FdCUlbgEAn4YJrJ+tli4b4UPJC8a8qs=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788204366; c=relaxed/simple;
	bh=4zGG3F4y9ZxLXAr8xFku3h+krWrEkhGq6KJCkInB24c=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=Ymac2L8GYqHo5qhEGe2/kbi1caLuWShPULEGx/5a8pTccIJGNWEw6pWHfdH9ndUpcVJd7nEQugZf71wzibndxKhU+AVSoF8n4/qXtTcKin7q2OorRCPProZzMQrwc5lLBIqiSwKUdde1Sm/PMJia3frNSgPesbqA9W1Y4DXtJ5E=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=fJ6FJOp/; arc=fail smtp.client-ip=40.107.200.5
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="fJ6FJOp/"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=YqrIARDt+wre83+RMRmK+oQlHlLSBN9tJuRsmYieuL9MWtxPllZxu13pi4SZKIdcCaitj+/4lVSW0ssDGCOZODp2pR3cDOZviR90dWdJDVO0bAMlUYUnMqWZNVhaTqESImIzx1OMviNtRGxTuKfGCOyY6FBikPszzfwAFRop6z/HvIGj/2D+lRxRm0LLHrj1c/lmvjpI77ZQeHqAL+ErcrbxioAS6Cdixhn0tP4KybhlTBIsSjak87SA3DW0Ttpk+6/rHpQSN/vLkwcTn/eY+zdrBE56+VSJ4BJGyhxS50wp+elzNuvOetVcRn4Ck9oSFl4Wjk0U0Aa7yyayy8LkyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=RjyqvtfBBlSxPQWh0x7FDeUVapoLG79pHCjYhlTljVs=;
 b=ky373oexwEOZnMhU3HW2XRh4zJEWIyqapl8qPw3ldgFK80Ej+DmtMRj9LSQPzDy9kX0o2qfWQW3Gr0QEvH20He+t0wWu5wMCHLUVJUD0YRd2TVTXK9d+uprAFA13KVCe0XDqJakD1Rdy2BehOiVd3V9HIUI0CIybEUE4tjaWxH7vP8rf/cAc5ysg0zmm+T/RDnVuG3phRlCi+dMGNrWhvRACzEWq6DUobc7YeqDif7gYY/7j8v1z1TJVDpjvkH4gEOn7C/A/ukMvUPK8rRrCClBonHbLI2g+hPxlOHRIdDstwaK8daU33nfqDhrARdTDZrbpxZxSUGDMhrh6LNuadQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RjyqvtfBBlSxPQWh0x7FDeUVapoLG79pHCjYhlTljVs=;
 b=fJ6FJOp/x/n+HMWfrGLXu0BFEIj+r5TTLbImWLqkQvIo/lqAYbeBQR1F1rjl6KhJM/EkJky9+XPcecVAQahukx8UBSdf57XfvbXFbSw7ejHemloq+IjPAopUlkiUcpcCmEzaalfdTYuw1afJ2Qt4lfRgvTcxPtSK/AXgwyShaNPts0ivcT9zEOgvHxZaFBBJIpE1INTn3KoyTQAmOR+zELzM/Bq3dJvyfwwJCvrA+ykyhL1wmu/izwx0gTUdJ0xyo3lwYYTMruSikwnOU9q94bAqjLPk1JGw+/fyFZdTO/3CtRPNBJ8TcSbofAt/A2c7KoSaKfKzQcsnZQ907CZLVA==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by SJ5PPF0C60B25BF.namprd12.prod.outlook.com (2603:10b6:a0f:fc02::98a) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Mon, 31 Aug
 2026 19:25:58 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0360.008; Mon, 31 Aug 2026
 19:25:58 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Mon, 31 Aug 2026 15:25:36 -0400
Subject: [PATCH v2 13/14] treewide: adjust comments on PagePrivate and
 PG_private
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-remove-pg_private-v2-13-3668159cd9e8@nvidia.com>
References: <20260831-remove-pg_private-v2-0-3668159cd9e8@nvidia.com>
In-Reply-To: <20260831-remove-pg_private-v2-0-3668159cd9e8@nvidia.com>
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
X-ClientProxiedBy: YQBPR0101CA0315.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c01:6c::16) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|SJ5PPF0C60B25BF:EE_
X-MS-Office365-Filtering-Correlation-Id: 78bc9ccf-88f4-4f5d-49f8-08df0795af1b
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|366016|23010399003|7416014|376014|18002099003|22082099003|56012099006|11063799006|10067099003|921020;
X-Microsoft-Antispam-Message-Info:
	ThSdE5GGLZTT/nuw7A0dqkxVQwB2qU9PRMPgQa0Xl05QBDC53fhI3fckqnudjEKmBDTE88+260sZHGF8FKM8WXX6ecP2X8o6z4Cz+h2WRxAgGJq5ExFLIYtChJMdGthZZDOxgzfxv340/ulhSvIozPN8UQaD1TVsHQvuF2n7+9IuGAM4bJ2MsIdFgzeDHjm4WoyQJO/imJz7HJQ1C/HR6+uDGEGeVKcMZiVnUpGkQjDd1y5WBbQM4WzJum1KQT4T4n1Y1YbyPZ0qGPLg0l6Zdjoy+AvM0u2vwhcOJuMnp12EEZ8iRbx+5qvbrAdwdF88aOaQLgXPNEAofUJsDPTURSGrPpBesBoiSkRoW7JUSdyDxJR5sImZizTpSmiwqc2jkTYFBtre5JFzJ+bWCO31lpcWjkEQROpn95izxMlUCwxb5iYuhuMXUeTYFlLzE6b8YxIxpc4o36MyC1S8jMfle0ESJL91yjt0lfjbmab9Vki1tJCpP41JpEfMD9au6Ay+ir7ZdNEl8PfVZdt5iER9Deqd31L9oeJUEeeJsUE63H8OTy+vPa6ly+G/gMUusrWVzHp6TrJnXo906H87KwcKlkWkXdN0L7NtPTWz0nEG0y/GIy49BdKZJxXVk8bpkrTjHref+LKiSpYU5EvIwBjHoXrw6zZMU9ys1wFB0t4vVdpKCljqUu1rMTgwa3oBsDcM3W9fgh84RUgoQi98dblgRg==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(366016)(23010399003)(7416014)(376014)(18002099003)(22082099003)(56012099006)(11063799006)(10067099003)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?R1ZjUTdTSWptNThBM3R1dWxza1hKSlBLek9YVmZSdGI0eDdvazFQcjZCeVdE?=
 =?utf-8?B?ZWVlaHYyd0pUQmJvTmNvMnk0NUlGMlJjdmFBM01UanNEMmFQZzR0TGhpQmMx?=
 =?utf-8?B?QjFaMGlFeTFmRHl4d0FmQmFseTFnVkJFd0dTOEVxb2ovMzdpSDRaMStLRXJq?=
 =?utf-8?B?bDd1VGtxUXVTdTZUUXZiRGQ0SENxWThTSy9qRjRkb2h4LzJFM0FyNDcwd2w5?=
 =?utf-8?B?VGdYL2FEZmlnSVBsQlJaN3luZk9TbnhiWkJBVXlqSW03MDAvZlBqSzlkOE9V?=
 =?utf-8?B?VGxzK0RUYU5tRGhBVjhXaFZFNWNhOVg1U2xGaURlRzBGWXFqOCtsN04zekww?=
 =?utf-8?B?dGs0RG0wUDZQejkxTE5ZSHZLeDdOUWhKSnFWSUMrMkc2c1hENWRkL05wcm9Q?=
 =?utf-8?B?OHk4cWVmVTF4ZWs4THhrVk9rLzl3RktIcDhLWW9ZaStlL3N3dTJQaHlHMCtk?=
 =?utf-8?B?eTJ2dWxSQjhqUitsSlpBazVmdDVsS25xdkxaWklRaXJlVS94TlpISURaWmRQ?=
 =?utf-8?B?SzZlVFMvVytDdVU5bWNDUkQ4MjIyVXc3VDNkYldKWXF0d21lclpSa0JZcElo?=
 =?utf-8?B?c2VCZmZjamx1WHo4VVd2RDJjd0l2TFF2cUFxQVB2UFNSRk5WNzNoSTJzaXBV?=
 =?utf-8?B?aXpRTngzVHZ5ejdnR3Y2Z3Ezd0tLOW1POHZ3ODhNVXVvMXZNblE5UklCWC9k?=
 =?utf-8?B?TVRiRENpbDZWcWtXeVhmQzdhZE9GYmt4YmpmSFNVMHZTRlRLVFRoUFNXWlJm?=
 =?utf-8?B?L3FIV244OTA5STZFcmJQc2hXVk1jdnZvb1VvUjBIUGZuY0dvYnhKTXpqNDAx?=
 =?utf-8?B?NldjWm8rYmJzVGtXbDFPTzZxRXlVRjJER2h3ZkJlYTJ4YWZyekNiVzZnS3ly?=
 =?utf-8?B?aGJmZFBnYUoxbXQ0c1pNbkc0OGJwWFhyUXFUQ2ZpVjZrVzQveGVTYUNpcStt?=
 =?utf-8?B?cThwcEI0M0lEY1ovcWVBSlZKK3VQSHFtQmRZZVJWMCsyT3orZEcwRGR5YmJy?=
 =?utf-8?B?Y1crVXYxN3dSQklCM0VvMHVzUGFGSFJhdlVYNFJaem54a1pIeVJ0dXl3SlZC?=
 =?utf-8?B?ZkNvSzAzdmtTMS95NXJCZVZEWTJsakh5eldGS2EvOUJVTlI2MW04djVoMzFT?=
 =?utf-8?B?cXdKb2JGb3g3Sk1nRm9IOUZGbUNXbC94US85WUc2MEV1K3gvWWxML2gvZ0E1?=
 =?utf-8?B?Q2trK1hhN3hxRzdLdmRvRGUzSHNWZE5hNzlvS0VPemlFWVhsYU05OTlHcWlL?=
 =?utf-8?B?VEVxWVpwQlVyS0h0Mm9hY2JFMFozQmdvVzZ4VUJHclBNeWU1V2xwRVBUMzV5?=
 =?utf-8?B?d08xZDRHM01nQWpYZ2djb0xTalR2VlNFdnBLcEFzNkhpQUJHU0w0VGh0TVJw?=
 =?utf-8?B?SmlBclZYbUpkeHpKT25yZmlIcW1ZTC9Zbk5zSGR3dmhKd2ZhUGJOOWV4ZzBa?=
 =?utf-8?B?b2ZVVkQzZTMzcGhvR1ZUSVhML2kxazFnZXUzeXNDWXdMVzd3U3Q1eXBxUFY3?=
 =?utf-8?B?Q3BBMk5Ma0xidVVSTFRBQnRYVVFnKzg0MEljazZjWU9yQUFxQzdQNWN0SjZH?=
 =?utf-8?B?azBFemU5ZndvR0lBendsck1HYisrRGNZbTZxdzYvOHlxUUhrTklDd0ZaYWlH?=
 =?utf-8?B?SWZqNk53dUFNOEREZzV6Rll4OEs1SjFlNThGT1crQU1acWVCQy9KVzdjeWhj?=
 =?utf-8?B?S3ordGhveEJEdXhKQnArRnBuNjY2U1dVUFZEOTh2MGh2Q3hrOHVrdVZLY0Z6?=
 =?utf-8?B?UWhBS0FQZ3R2MHpjdWhuZ3hwYS9kS0hQVnk5YzBZNG1haU16SWNwOUd4dUVz?=
 =?utf-8?B?bzByR2VLSmRSeTNxQlVUcXdRK05KQ0ROZFdKbS83eWRnV25GRllWN0hXYURk?=
 =?utf-8?B?SnA5VTV3ZGk5ZTY5Mnl1SkhGckYrOFFTcXk1eXR2ay9TeDZkbGN1T21YdnpF?=
 =?utf-8?B?V0hFRmlzbjBSNDJtVEN2NFJPcGJZTW9TNm4yNDZwKzczQU1YSUE3SldETnQ5?=
 =?utf-8?B?dkNYSXd1cGVyQ2d2OTVYVzVDTmlYR3pFdGxsTGp2U1VuUW1HME5QM0k5YVBx?=
 =?utf-8?B?WkdrcXBLZE5zcE1oQkpqOW5rUURvZUxLQVBPMmRVMlNJMHdqclZmQmxTa2w3?=
 =?utf-8?B?WTdhYkxJQlo3NHI0YnYxRHo0SnI4ZWdIZWxNM1hwN0p3bStlMStON1dEa0tx?=
 =?utf-8?B?dkhTSFg4Q0R4a093ZW42RU1PaUZUOWt1TjhLeXhsQm9HSUdRMjR5WmZiM0xN?=
 =?utf-8?B?aEtML3ptUk0vY1g2Tk8ybGNRVldJakdvSmJlZEp2S0luWTI4VmYreHRybjVZ?=
 =?utf-8?Q?ATgZNVnOmzpoQSE68C?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 78bc9ccf-88f4-4f5d-49f8-08df0795af1b
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 31 Aug 2026 19:25:58.0584
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: c4D+bONIoe+hJjLC3tCtYFp3gZo1ni4TTzhIrcQAIKslfsqrXAibpTfmeO7KLioJ
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ5PPF0C60B25BF

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
index b5b60f3ad58dc..2855739a0f379 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2075,20 +2075,21 @@ vm_fault_t finish_fault(struct vm_fault *vmf);
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
index 6d815f6440c94..e35aece38b933 100644
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

