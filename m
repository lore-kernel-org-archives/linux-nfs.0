Received: from CY3PR05CU001.outbound.protection.outlook.com (mail-westcentralusazon11013030.outbound.protection.outlook.com [40.93.201.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C25A955930D;
	Tue,  8 Sep 2026 17:22:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.201.30
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788888156; cv=fail; b=QbXyQYBy/mmKNPQvjxGSdEk6w9gSGkauwUszTmuj90dMnzEXmYVC1PTUqEQ7NyFaWRIr+LLtKdhGaWt8zVnzVT864Ued4CyxSlVRD/gf6mvVBvZlfG0nthme5X59247Id3sTTT6RZ9Lm0AbCd7T8u5bOWSl8h3tnQc66w09rJ8Q=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788888156; c=relaxed/simple;
	bh=Ykwuep17Qql8becRVvJrHUIs7YuM1Vs3YaRQlAXshz4=;
	h=Content-Type:Date:Message-Id:To:From:Subject:Cc:References:
	 In-Reply-To:MIME-Version; b=RRyXKjWovQcE5rRgaXDYwmaLdkx+yXBaB/8ED5BTUE85k/rP1RJ5N2SA2VlyRxvg5Fc/iOm7vgnXIrRF5u4fknNRh1sW7hv5TakTGFztUMkQ6JFWeNW/H3cdGUavQSVoc7avfsaRYqjDE7DmK4W7IzIxVJTMJ7IRUOOXOhBkJoU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=XRMUwSX4; arc=fail smtp.client-ip=40.93.201.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="XRMUwSX4"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=NIkjaevOyxTs6RD+k+sHJXP0/tdFOFfShY3egJh6bXNvt2AdoYQnVhfa0Hae05CR4TXaPDSG8Cl3ItcV77rKGPNodTxMBN/LPwP2Ec+Zxp0aMT7eY+R8eeYw4ztJd96s1rQPT27zLqTCQIfWJH7u4NUVNG2Ra9jC0inwXSUcaR3sXzLg5qXjFsrAA8wV52bjTEf4ocNBJpGujvltrNqdJZ5tIo3sj0Z8Rcnduzo7gSqBYZOV0IPvXT2aOe8orLiPyyEGnpmBYQB2FgV/ndIx72PCYxE6tp83UD+IFoIo0CcCkgz2DP2xjU1CXpjPr6PmVYniGThhTi3a9UObXYcbfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Ykwuep17Qql8becRVvJrHUIs7YuM1Vs3YaRQlAXshz4=;
 b=HVXWBefIdFPzFvPE/vEwMMahz2XGEmOgzEq+S+vNxKwYhT+e7/sFht8fmRWqhMY6Q0z3koONAMLRwRKBQsI65zG6KyqfeAwv35Bnvs7glWnTmZGXlON285BB8P4RCQTwSMzFmkvNEXCczmebU9sUUCvok/2mV3O2BxpAXRapKetByiDDw/ooX7CchnBGvuzhxr3Aa5g5M87qmjrCicmTbXwiofNWo+NpjyedABpqPPl3FUFt0f1fK4/J4VgBnVvbUHbw3UZBPhdDmfb3ujF3FxlhgDPMoo6Ks5PHUqPPx3rha+/PwUDyN5xwAT8yLEeFBY6BVjAdIce96Vcj8blO9g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ykwuep17Qql8becRVvJrHUIs7YuM1Vs3YaRQlAXshz4=;
 b=XRMUwSX4Ex5uUoaJW7ZGcugO8c9e7BkCYLxSuwtwo8LGdpriYvrxZBUs0LVbvkvkx0mNIbb5WW4kK/UqBv1rScla4FU0i+lbnQjQ1eyW/j0YOhfkLwUJnfDlioIJ4AKIbp1lLC67XvzhwHYQu6xyAxlH9cn1TcD811AmdMO4SEoK5nUkdIb+0ZHho4khu8cDUlMs/SLciSYjTLASeEMlSawGZZlTzGRr2E+RIecYKehm9/fuArT2q5opql8eBpP5pxTNyvLXSjo3BuL9kzxWf9wqJLKP4rHXSfmNbxANcz+o55wy3uus3CDkxRYXzpOpO8pb4FWnbcI9Ej9rRWEHnQ==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by SN7PR12MB7955.namprd12.prod.outlook.com (2603:10b6:806:34d::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.382.15; Tue, 8 Sep
 2026 17:22:29 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0406.005; Tue, 8 Sep 2026
 17:22:29 +0000
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8
Date: Tue, 08 Sep 2026 13:22:28 -0400
Message-Id: <DLA3XA4C0IVB.2WTPA12X6KY0D@nvidia.com>
To: "David Hildenbrand (Arm)" <david@kernel.org>, "Matthew Wilcox (Oracle)"
 <willy@infradead.org>, "Andrew Morton" <akpm@linux-foundation.org>, "Muchun
 Song" <muchun.song@linux.dev>, "Lorenzo Stoakes" <ljs@kernel.org>, "Liam R.
 Howlett" <liam@infradead.org>, "Vlastimil Babka" <vbabka@kernel.org>, "Mike
 Rapoport" <rppt@kernel.org>, "Suren Baghdasaryan" <surenb@google.com>,
 "Michal Hocko" <mhocko@suse.com>, "Baolin Wang"
 <baolin.wang@linux.alibaba.com>, "Nico Pache" <nico.pache@linux.dev>, "Ryan
 Roberts" <ryan.roberts@arm.com>, "Dev Jain" <dev.jain@arm.com>, "Barry
 Song" <baohua@kernel.org>, "Lance Yang" <lance.yang@linux.dev>, "Usama
 Arif" <usama.arif@linux.dev>, "Gregory Price" <gourry@gourry.net>, "Ying
 Huang" <ying.huang@linux.alibaba.com>, "Alistair Popple"
 <apopple@nvidia.com>, "Johannes Weiner" <hannes@cmpxchg.org>, "Qi Zheng"
 <qi.zheng@linux.dev>, "Shakeel Butt" <shakeel.butt@linux.dev>, "Kairui
 Song" <kasong@tencent.com>
From: "Zi Yan" <ziy@nvidia.com>
Subject: Re: [PATCH v3 11/14] treewide: remove folio_set/clear_private()
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, "Trond Myklebust"
 <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>, "Jan Kara"
 <jack@suse.cz>, "Matthew Brost" <matthew.brost@intel.com>, "Joshua Hahn"
 <joshua.hahnjy@gmail.com>, "Rakie Kim" <rakie.kim@sk.com>, "Byungchul Park"
 <byungchul@sk.com>, <linux-nfs@vger.kernel.org>,
 <linux-fsdevel@vger.kernel.org>
X-Mailer: aerc 0.22.0
References: <20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com>
 <20260907-remove-pg_private-v3-11-6ae22f9d9272@nvidia.com>
 <e5aa6ce8-9691-44ca-b655-670c192292a2@kernel.org>
In-Reply-To: <e5aa6ce8-9691-44ca-b655-670c192292a2@kernel.org>
X-ClientProxiedBy: BL1PR13CA0025.namprd13.prod.outlook.com
 (2603:10b6:208:256::30) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|SN7PR12MB7955:EE_
X-MS-Office365-Filtering-Correlation-Id: bca78bea-ba91-4490-1eab-08df0dcdc270
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|7416014|366016|1800799024|376014|10067099003|18002099003|22082099003|56012099006|4143699003|11063799006|921020;
X-Microsoft-Antispam-Message-Info:
	BjXwo8QZ8HHYtKWXMJGaWg1xV7Kn1OG5Ro6mohcLUs5/X9PPApJvjGhLROaKaJYiT1itRCBj6Mk4Jpo0kqVb+JnaHI7x6Hff4vQTeA1w4GweVY2AslRDE1juWUeP5c4GmO4xQSvrUG15pGyQNG1KbSnC3BmepIaAxQ28ypGPA9xoIvQdwPpOSkQr6gHecw2eVzxVamci2jjzjU2uh4uGdSwKLFm0AM5ZcGimfP0oNqsPK+Zpmtve2vOI6jE/6IU+s52NGqNZQdAX/uRx1+DBpgITQas6vJ/NlESVMqQJmeNanjpDbqn+X6Bfs8nBUkhxVMgmKEhhfSTgvhW6SPg/fKenmGlwyOx6R2blK+5H9YG1JAK04c4KOX5yHfZc9zrJoT+diPI3pNj8QugJzPdAT6aq3/jAPsAmzg443q+wca1EnSoAE36LOhMSEL45IjJzNnhtdeDt6vgL8oj7/P94TRVjtsGv+z3ls5AThbrUdYAN94VFAZqjb1v6GiLo2so3AJiCWdGb+jAimzH+oTJ1Ty7VOyw6DySaZVqC212O2+hqPIgSMW/kgJiP2ymYlnr8XD7ySoZtO3qOGgL2kprKblyGOzmoe3EimrPL2TkDpXqsYO2mrgb190AlG4y1wLzqXq1w1t8owCS0XYU44xEL5kNkJN8P9PeETWEWIMG3Ugex21Kri0z3Buy7rK72oOoV8S5b2EM4SguKsOKsm63WtQ==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(7416014)(366016)(1800799024)(376014)(10067099003)(18002099003)(22082099003)(56012099006)(4143699003)(11063799006)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?NVRETDBpellqbi91b1lNOTVsSitrd0kzTmpSSWZXYVl5OE1GRUdvcThtVHpk?=
 =?utf-8?B?dlludnd3SUU4SXFMOEpJTWRBekJRU0k4dVdsT2tlNHNzQ2xVaGh1Y21vMStE?=
 =?utf-8?B?NXg5MUI4ellET3VXd3owcXZxbDJ1a3haQmZnMmVmdTBiMVN5OTE1SU4wbDhO?=
 =?utf-8?B?N1hqalZHbEl3M0RtVE1UYUFLQzlrZ1VTYnZCWXBlemR3d2tOK3BkNWxzYzkx?=
 =?utf-8?B?ck1DUGRteGg2WFpoR2F0MHZTRzVXZ3R0VkYydFo3S1MvTlhqRkVUS2d6b2Fm?=
 =?utf-8?B?NzN3U21PSlhvbDRSUHZtaTFuR1g0WmtBdUlYRldjR1pudUdaam4zT1R4alNh?=
 =?utf-8?B?dXhnaVA3QW1QWlZKYm9tWVkvaXZHeGZDZnpUNSt3d3N3aGdkSmg5OWVWTnZ3?=
 =?utf-8?B?Ynk1aWVuUUFZWUxiSm12MVZ6Q2srUVlhMmVJL0ZwWXVKVDduWnhQTDBqVW9m?=
 =?utf-8?B?QVkvK3ZVYVdyUDF2QlJ4WFJUbUpiTXJuRDVsNDBMNkpKZXpZdG84UFdSN3M3?=
 =?utf-8?B?akRKU1dkclcvRm9hS3B6cFM1MmJyM0FxQUNrNGVkQVZCNExaY1NDdEpJVjhZ?=
 =?utf-8?B?dVN0MWtrTUo5NUpMWFZzNTFkUHZsTlN5NW5ZdHpHejZEQ0wyb1dsZXdlM2Zj?=
 =?utf-8?B?bkx6dTlLOW8wYXJhY3lsUHV2SjlFcnNrbGtCV3luRDROL3ZwQWtVaHNybWZR?=
 =?utf-8?B?K2ZCb3JPT0ZGb2ZmTXFObU1wYjA0aFdjTUxseFVBZXlrblh6OEdkTi95YUYy?=
 =?utf-8?B?Q1BDNzlkbVRHUTQ2NlRxUnBNR0xubFZURFl3cUNqNFVaa0tLNXYwU0lJWGtn?=
 =?utf-8?B?TzErU1RVejlwOStrRkV1eURIYjJ4bVZ1aUZNRXVqYnVJYVJBS2h5alVJQnVJ?=
 =?utf-8?B?Y1d2bWJyYWwyOVRSN1MwcVBoMkoxY2JsQ05qVFY0V3VWdWdOWHBuTVBJZko5?=
 =?utf-8?B?RityQXRTcERNSFFLL2ZPVW9Pd08rbHpBMlJsSGhDNGFSVmdOTWpLV2E2SnRL?=
 =?utf-8?B?QmJrZlhpSjFvd1dOVHVNZlFuWTRmbzhRV2xKamFDdXhTZjhveU1xZU8yZUVF?=
 =?utf-8?B?ZExEMkc2VXNzOVNPVHJPdzJYNGJrbzl2OEVwcTEyQUlORHVGdGFzZFZ4SjRz?=
 =?utf-8?B?dENLclZQM285WHlpd0xuTnFVVW1HVk5xYk5Fc3o3dG9lZXB3eEl4eW9NLzdt?=
 =?utf-8?B?dFVySHl5RFlUenhGOWpVNGFMNFRmUGkxbDlEOFFSNnIwSDhDeHRtNG1nQkpW?=
 =?utf-8?B?NGdpK1VCb1VtR2lncHVnbmg4MXB5eTl0YlZwbEZoL3k3TTJsOWZ6aW1LSkg1?=
 =?utf-8?B?MDlQSlJNZUpFK0NLamZ4bHRWS3JabytQb25zNE1vMjJ2eVkwdjNaOEpXWW8r?=
 =?utf-8?B?ZGNyLzJVcGg0ZXdSZE1aQTVnSXpUcnRWZ2s5YXBUQmpQanNaTGpSR3pnV3Jk?=
 =?utf-8?B?ZjBIR1AxNHJWa2JHYUdvTWxBMmJjTEZoZnIxd0dNeW9RRGx3clViYzNTRHJl?=
 =?utf-8?B?ZDIwVjVVMTdLNjVwV25OUzk0SG4vSWZ6bktUZUZsQm1BeDIxM2h4TC85aitH?=
 =?utf-8?B?LzlTbVc0STVlc2wrVEttSEJoZWtJWi9mbE9pN2NaYVcwY3hqb0dBNHJYdHlj?=
 =?utf-8?B?ck9kbUNnNDRyelluRit3SmRpWk9GOXViTjRuT3ZkcmlQTnVLS2xmdisvWWgy?=
 =?utf-8?B?UzNTWVhSeW0xMTJrbnhLUE5ad1dnNDlkY2FEMnkyb3U0NTErai9ZYzV6dExN?=
 =?utf-8?B?VzNmejlnc2ZqOHlEa0VLK2ppMDVRL2lBdGZWNTFLT0c3cGVaakFmdTF3WC8w?=
 =?utf-8?B?WTkrOEVLZEQva1pqYmdtMHlkSlY0bmtEa2JIYStpS3lkMEJUNXQ4V0dFaDNJ?=
 =?utf-8?B?Sk0zRElSdk5XS2IwZkhVbWFESVdZR1M4YUJCaXN0L2dhb0NGSUsrVExNRDM3?=
 =?utf-8?B?K1luVWUwUzlsSTlCRnd5L2JFYzNEaFR3RmlrbjR3Kzl3aTZTYW5lc1Z1emxQ?=
 =?utf-8?B?d2ZwRzI2a3Y5cFEyS05SclE4Ukt4S2NYU3JKenNoclg5c1ZiK2VOaEF2bmFD?=
 =?utf-8?B?QzZXM3dLK2Z2Q29lUHNYNU5Vb3NmOGpyRXhNWUZ3eUdEeVlFOGsySWZQeEEw?=
 =?utf-8?B?QmkrUDJxd3dTM0NCZ1ZQRTh6eWhvV0dGc2I1bFRwRURGb3FqdVNJT0Q4ZTNT?=
 =?utf-8?B?cENXTFFmNmMyWFloTFdmaS9tbHVLbEJVSkJlNndIQkpVdjZ4Rys4RHdBbmpK?=
 =?utf-8?B?c0I4ZEI4WHpNRjRzM1BUQkNEY3NuejIxZVUyM2VKQ1hlY2cxZUZ6SXNFa1RV?=
 =?utf-8?Q?ZBpuBxrDDM+Kzjc6Lb?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bca78bea-ba91-4490-1eab-08df0dcdc270
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 Sep 2026 17:22:29.3417
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: pPpdIHT2uC8t7lv9rpX4GOEVjWyO9mOW94uGHahaYVzctn183acwkFwUfqsKfWcX
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN7PR12MB7955

On Tue Sep 8, 2026 at 1:01 PM EDT, David Hildenbrand (Arm) wrote:
> On 9/8/26 04:56, Zi Yan wrote:
>> They are no-ops now. Remove them.
>
> Subject should likel y say that you remove folio_set/clear_private() *usa=
ge*.

Will adjust it.

>
> Acked-by: David Hildenbrand (Arm) <david@kernel.org>

Thanks.



--=20
Best Regards,
Yan, Zi

