Received: from BL0PR03CU003.outbound.protection.outlook.com (mail-eastusazon11012033.outbound.protection.outlook.com [52.101.53.33])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76DC0280318;
	Thu, 10 Sep 2026 02:12:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.53.33
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789006344; cv=fail; b=lmw3spE2NNAajB/jrgcvTo9Bqut3MefekV4ozpYT6oBRQalg3bpfp+qu91++KyBzce1nQe/DYU8HPgvLZGyO4ux4dnzp17M8SFN3bubORmVjC69mVLcxBfq16cK0n8ICJAlwGyhMFnCXvY3TrXPhDEy4H16JRCplPFk75pQgZ2o=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789006344; c=relaxed/simple;
	bh=yyK4wlQwe09SITpFrWIGcbFXS/j69YYjzzAywZpktTs=;
	h=Content-Type:Date:Message-Id:Cc:To:From:Subject:References:
	 In-Reply-To:MIME-Version; b=n969aDCLUam+BzL+k7uO7VZdH13SkW+8mMivvPLVsACOilTcFiv14c7SqcOfg9E6Sz7o/8U1WgAnoFwA6xos0cQZEgbmuOfMCcEzDEraihxWmMzZpv3CymmoIbRG4Fba41xz/0scatDSvMehVDd7GN9WqIFrzUIlrgzLHaQ7dxA=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=ohW90PuX; arc=fail smtp.client-ip=52.101.53.33
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="ohW90PuX"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=BcZ3EDe4p0rNJK6Nl4/HStl3Z0OOkXwtKygS0YFz7+sx1DKMDxnBRdH2kaYAqOgDfQdQLFLgpaIlHQMz37IftpuW/HMSrDjUK1EM/w5FVda4Gi2APFFVYvewhsDGRl2zNNHbyhDXVEbad/0dkTzffifnF5k1fpwwPRgrPiTqTaM1xGCmAjzVM4B87sL+YKHVBVgh0Hq2yvUWZFlRxhH65ymcuai0XMG1TSX9jkip8b62BXzv1tHQqICQzACNAVAXWMQGikvd1mVGYgQ++DKsNCqZY8XAzXiaCZt7Amq8atew9RmxvogEUDd/B2YtKOtA9EPvu+AhnU5NJXWuO/Tkew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=yyK4wlQwe09SITpFrWIGcbFXS/j69YYjzzAywZpktTs=;
 b=q4IOfAXxAK5OcxFxt+9VSTCqZrgLM9ErJcVHEeCIpzPT/TWhbWx5YRgAsPGtqPq3WgqBsPy5gVf+1UjNMYllj7j1agH8jM6oDEyxG5hfOjW8t9dsyTxdMp7pckdS+DQs5tpgsKoqi6cipPaODIgBNNp7JoR8mA3ieaKHtDC9UWd0V34QPbEfR99wtbZD1eiWznyEZPdDByX5hnbbPCUIGcdBhQLVLzBcyhTUWpOkLHoxAzWY/DBxnqP8/63OYFxkDc6qYlbu8mGaIFWyoA5RpTpKM4eVvZQEcYTEYePLfp534eN/tD4yq4nDrxJoDZ3cMssx46M5QCc8BS/fE7t64w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=yyK4wlQwe09SITpFrWIGcbFXS/j69YYjzzAywZpktTs=;
 b=ohW90PuXUnbGoeVTmRiKhvkIez0nMLPWLf4QvG0aRyY4csKPy9VucI//6+9U/lyPhmaJxoDPQlbhVefb8OMLP8cyBuW/pfzxb/6KwhbtwYV+MuB+kwte0StHvvuNZdaYEeNtpwz9F86bNV+A07/Iji2mRXsKVz5CWhx6kuhKM7YPbiAnA3CTIuKUto+5jCSufd31evyFeKFF4ofPv5x1ii6x/HlhQqAR1iLfcHWFKAjavhIllOIDGKGb8d6a2I6oltLuSL61F2YMlqjMLh4/xhEZ5ypxKhBX+ISI03+EJuWAbT8EaMhzQNsszrhwY/HncMdqny/TiD6lyu15tS5wtQ==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by CH2PR12MB4183.namprd12.prod.outlook.com (2603:10b6:610:7a::24) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.406.7; Thu, 10 Sep
 2026 02:12:16 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0406.007; Thu, 10 Sep 2026
 02:12:16 +0000
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8
Date: Wed, 09 Sep 2026 22:12:15 -0400
Message-Id: <DLB9TGGY2VXO.OBBZC2WW5EHA@nvidia.com>
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, "Ilya Dryomov"
 <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>, "Viacheslav
 Dubeyko" <slava@dubeyko.com>, "Trond Myklebust" <trondmy@kernel.org>, "Anna
 Schumaker" <anna@kernel.org>, "Richard Weinberger" <richard@nod.at>,
 "Zhihao Cheng" <chengzhihao1@huawei.com>, <ceph-devel@vger.kernel.org>,
 <linux-nfs@vger.kernel.org>, <linux-mtd@lists.infradead.org>
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
Subject: Re: [PATCH v3 13/14] treewide: adjust comments on PagePrivate and
 PG_private
X-Mailer: aerc 0.22.0
References: <20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com>
 <20260907-remove-pg_private-v3-13-6ae22f9d9272@nvidia.com>
 <54a48bae-aa0e-4833-91a2-5b5908356255@kernel.org>
In-Reply-To: <54a48bae-aa0e-4833-91a2-5b5908356255@kernel.org>
X-ClientProxiedBy: BL1PR13CA0327.namprd13.prod.outlook.com
 (2603:10b6:208:2c1::32) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|CH2PR12MB4183:EE_
X-MS-Office365-Filtering-Correlation-Id: 4d0a63ec-d13f-4d89-4ad5-08df0ee0ef4d
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|366016|1800799024|23010399003|7416014|376014|10067099003|56012099006|4143699003|11063799006|22082099003|18002099003|921020;
X-Microsoft-Antispam-Message-Info:
	a9mMbP+tNzNQSDQh5XvLFHJiSXepgnScIrvJaOUBRPYRPrqIyVTib+5JDnir+xIOKp43+noT6VCzNgMaIRSlXFl+WdAR9W74uh5ETH1g7YTtwUeX97Jm9odk3zSHtCqmhF9ppTviGWeUA65KEALtUuCFntXKa+qt7aAQYnJWLA+tp0MDIsHT5oETQHHMtJHhFVCQCVUnVw+4uYTqgNcdrpTzcyjNmdAGynvdQAP+w8Rl02+pW5w3gPCqdfXIbi3RQOqNaYTm1yrG2U8peSxKqK5D2isAZL6duL6Cqpel2Sg3b3Gt4K/PtCWEZLfT4fnwj/R+3fE/OzIa7V3DCTmhwfDZoRwns03swQWMA5XIdT8pupNSUS5ENRpn9S5vMwVhe0c4hfZx0WcUUhtatpAK4RpDWE6q/9/vCL+2GNvMJnYAGwFlqVhEv+rW3/41/4tyvehrb/el2gHElj70ITngLvNCaRhMxDf/k8CWLwqEgTdTN+t78xq2Brm5lURfOKtC74mQvW/QfBj3g50SDTZJRpmmb9THQQRIDyjqSAJYmx7B2iQ58X/deJC8MPYBrNYX83VTEuaeHHwG1XQTbG/pl/tr/xRrZD9uQslJOtbnaqJJJM1t/7ddGAXWjjgguiQ6vVvBpxzzv6uYQvYcSFBMAqIhxL1qM5nNYXwy1uPHizFPXRWjVkgr6wb823R9p0es+TKrfH+cUz/IkfC4xXYV/g==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(23010399003)(7416014)(376014)(10067099003)(56012099006)(4143699003)(11063799006)(22082099003)(18002099003)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?ZlUwQVhwMTJNdWtFeXFVMk9QQ2VRSU1pbmhTa3BwVjFyc0xwQWw2ZGkvSDZF?=
 =?utf-8?B?Uk9IaUpDWE9XQXF3L2l3NGZqYXhURDFCWmNCTDlTRlRCYVplcGVxcVB0b2hk?=
 =?utf-8?B?NmRMQlBKZDZBUStjdDlDMktRL1QyQmRnU3I0ZWRsMnBCV1hKL3BKRG14MHNh?=
 =?utf-8?B?ME9KL1gvbDJ2RlZsVDd1NGZPWUJtNjB3RXk2U2xhOEx0aHcxdlBHSytZYkNk?=
 =?utf-8?B?Yk5nUUMvY3hTK3YrcXdxMmNhb2dMZlN6R0oxdWJyaHhqdWVyaDIvTjJGYzJv?=
 =?utf-8?B?Z3pFNjdIVTJ0OGJrRnQwZG81SW5Yb1ZJUndhTFhUZXBKQmVxWFdHVWJiVDRp?=
 =?utf-8?B?ZjExTVF2d0xIN3JkV1BTUVFCV2VaTUZCa2Y3dk5QVVh2WjJaejYyaGlZdVJU?=
 =?utf-8?B?OVFLamI4b0k0VkNUaWNxalVveC9kN2dqc3d2MW1FMzFlSEN4NmdwcFFWZ1NH?=
 =?utf-8?B?OW9JZzc0U1FPenZlZTZ0SkVDMERPZGZOWnBRSjZRK1REMzlqK0Q2d01iVEJv?=
 =?utf-8?B?cHBhZFRaTElhSVdITmFkTFhlN3dyeUdEV1dFTWVEVU96SVIvVUJ5STlHWTlY?=
 =?utf-8?B?VVZRRVd3NUV2MzlQM2QxdUJ1Z0l5emhXV3kxWGVqQU92WDNlMFl0bUpuWk50?=
 =?utf-8?B?RDhvZ2pxTWt1VkVPL0I2NHBvay9HZU8yVUhsTDNEd24yTUxVSGwzVlVxd2FR?=
 =?utf-8?B?elBYWWJ6Y3FMeFNReWFiZHYxTmRTV3NlZ1lwbUQvUDJScjd2RXplbFJzMlM5?=
 =?utf-8?B?MGF3THN0UU5QWEJhdG53MTY4T2pEQ2tnZFRjT3RnK0xLRUtqdWxNb3g5NGRV?=
 =?utf-8?B?VnVheGxtMWhLYXJNRzZNck5wREttQWdiSWUveUhyTm4wdnBETFdkaTcyVjE1?=
 =?utf-8?B?bFd6RytPaDJvdjRLSTRSSVlwUXJCNjljMXJ2cllCODlnNmJ1TGJORkFzSW8r?=
 =?utf-8?B?V2RtV3MyZ1BIcnMxMG1oUzlXUlBid1RSWGlHaml4RmdWeUVPWkczMzdsYiti?=
 =?utf-8?B?YktZdEtnaTdiWWNQWU1pYjMvRm90Ym05UThVcnp2UEFIYUlXaU9VbnAxNFRQ?=
 =?utf-8?B?aEFhQWY4Q1lsZ2FyeEIwWWNoMURKaXdIUHpNRXAzSjFXWjBNNEtSS1JWeFJi?=
 =?utf-8?B?M2twTEprcWJxTTAzNmRydGo0dmlPS2FnYWFRRTFZWGVvaEdxbElkaDR0YXdy?=
 =?utf-8?B?MktSNm44cy9XeUVGdmpxOHRVSVExeU9xbzhtUktzQ1NueGl3SXp5WEZWVEtv?=
 =?utf-8?B?eG8wYlhhQW5XZzROaWMvOWhVWFkrMjZxSGhMS1VweExTaTk3dTZvRFI1UDNL?=
 =?utf-8?B?YVVYVjdVRHJxWmFBVUNZRlRjOGlNV0NTaEpDK2J1NWtwSit5WmxyWjM1dk9t?=
 =?utf-8?B?ODdRK3l6RlMvQmxyei9Rd1VUMGVKZWZwQ3R5ZlNxeUhMdTI4UjJ2SHUvSk0x?=
 =?utf-8?B?UEx5RVpVN0JuRHBCdlk1RHRwbUR2ZGlzYVo5T25sSTVPUlpEZ29mOGpYM0VP?=
 =?utf-8?B?TEtCbFdtTlZObkQxOHpaNDJhcmkzUkNOM1UzaDJHSGd1VlNRclVQbCtlam9k?=
 =?utf-8?B?d01EWVA3TUoyK3VWVjdBUlVWTndQUW03ZXYxYUU4M0xxczkwZzVKbXp2d3lP?=
 =?utf-8?B?aGUzNFdnVHpJd3FPNEV0VW9ucjVGL0VBVHFSYUg4bXFGKytDUGhmcnRNbTlC?=
 =?utf-8?B?OHB1TnFnMUo4dVgzSlRISGxpN3ZJckoyZzU2cFRib2ZHTVFrQVZoQk44a2pS?=
 =?utf-8?B?V2Q5blM3TXl1dVBVSFNIOW1QbXFjZWhmME9TeHlPbXpyT2t4VTk3NWJKekEz?=
 =?utf-8?B?Yk1KQkFQL2h2em9ZZS9YT3JZOURlUWtqYXZSVTUzODMvVmZPMHBBMHlEZUtr?=
 =?utf-8?B?RU1abTdoVUgyZkx6VmxUcTBYOCtkVlVqVU5palY0eVNsYUc5OWIzRmptWnBh?=
 =?utf-8?B?UlNTMHJ3c0g4ekVQNkoweTdKR0J3UjlNYUtlKzAyclVXMVhrOUZncVNxc1FX?=
 =?utf-8?B?MitYdjlPVlFWRGRkSEhEZ29IcHhqbTN1VHJEOTBYTUVEaityeGFRM2FhYWhR?=
 =?utf-8?B?K205Qk4vWm5scDRFN0JqUVZlMytiUVl6L2w2NE1QYVZwQkV0SXl6OFNXMHc2?=
 =?utf-8?B?RkpFYkpVaHZhUXNmRC9LdERqTjdyWHRDSm85OVFGTkZWWnYrckg3Z1JPQUZN?=
 =?utf-8?B?MUt1UXBwS2Z5K1Q1Tm45YUtsVDUwTk8vb1JSeGlaMFVRVnNKZjIzcSt4QmlI?=
 =?utf-8?B?V05vYXJBanlFaFhUa1F5UlJrckxYR0tUQ2FXTTlLdGpYb2xVSWhVN1VvZUNF?=
 =?utf-8?Q?89ZXKRbSlixj7Mhy3I?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4d0a63ec-d13f-4d89-4ad5-08df0ee0ef4d
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 10 Sep 2026 02:12:16.1977
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: qo5gWPo2di48TXSgXP7CqDR0gX+PhhUjjNTFXUrZZknl/la8jD+OfD8qwDw6iAUd
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH2PR12MB4183

On Wed Sep 9, 2026 at 10:27 AM EDT, David Hildenbrand (Arm) wrote:
> On 9/8/26 04:56, Zi Yan wrote:
>> PG_private is going to be deleted. Adjust related comments to refer to
>> page/folio->private instead.
>
> Thinking again, I think this is misleading.
>
> PG_private is defectively already unused for all of these cases, no? In t=
hat

Right.

> case it's rather a documentation fix. (could some of that go into patches=
 that
> convert away from PagePrivate, like in the previous patch?)

Will rephase the message and fold comments in previous patches if
possible.



--=20
Best Regards,
Yan, Zi

