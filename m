Received: from SN4PR0501CU005.outbound.protection.outlook.com (mail-southcentralusazon11011018.outbound.protection.outlook.com [40.93.194.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AF3E36E48B;
	Wed, 12 Aug 2026 19:58:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.194.18
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786564739; cv=fail; b=OSYJPkPcLAbnMg72lX1fsrH0AHQJmEW4hIo9lzgypC6P9RH031AjjqnF0j6UNp6na6yFl3XUtUBwWuKN74IoZkwhxIW5+Mz9CDVXeHCjkd0xnkMeAp4WtdJJE60vuYsTuYSaZGSuU0uT/yAsAWww7Fgr0i+XB1U3BLJmAepniDY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786564739; c=relaxed/simple;
	bh=oF52jy3RJn2uTWRIYAjq4oXnhvpaJMSgq38jABBS9Pc=;
	h=Content-Type:Date:Message-Id:Subject:Cc:To:From:References:
	 In-Reply-To:MIME-Version; b=XhQEJogiPOYui/V23gEyaIfhA+H2KQuKfqGRI6qO51qtO+5km3pIQe3/OS/uJVqCWh9vI95aFJ3CJ+zQtsHkg6pEKx1oKHmKUtU4O3lWDxO66MAvXaItJ23/FG4BrBZe3oewEffEGk5ys6zE4wJ9FobPgOxHTUD+ihx+twYBp3c=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=g3qJQXou; arc=fail smtp.client-ip=40.93.194.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="g3qJQXou"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Nj6iqxz49GfzxzLdyLMbbfl77Jg+n2OFlhal0mNEXOJ4oGYWBBJkgBeuOpkAyfjOx5T5zVwUYuL4bBD5s6CLHWtPjd/Ww7SXHtdQ5+6XRt0ADjRQPezgeLSrHgtKP3enR0MEZA8KB1jf9RFSPb78DoVMFVhLJ1SpqXNgw+XCszvmVYST5doycF6ugC+a5wQy27s3CZm9xFduVQml14KMDGrTyg0Y0fScjrG44Ui/3sI/zPzY5nL250M53WZWByDBaqT8wXnTObD0nA/fPQE3o91gudbrLdvYQ96DiHtpB3wMuMjYHsRjE/1VwpF1jErWh8K5MobxLP2SUZNL3E+1JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=oNy2RlgN+93tij2pItmSE+mEg9Su1aKTCJppfcTAfps=;
 b=wJHpI5zF+cUKWp33b4qiIXC4LLlzyCa/ezP59wQmWeb8BpkflYAev1DgcUZEar65z6GmypFr6LOCWYybwbGLfiSKZ0QeSA4kj+RMKSSGSFc+fQpWwWt0mNFliWnv0eBxK1jEifC/nal+SvfqpKg+53KBU8MQbCA0hfPr5fOvKlgoTYpR7O4f6fH+9+67qgWoIYkehbiIbq5axSmDBBtWOT/YrAl8Q7sNYQ+Lxi3LVPa+H19yHIMW9hbC2m/7ZdJjK84DTUR8+5WAuiOWTjcIzvEDXQVd6fkka8psVgQdHVxXGlqbVA7vrtfccYBbd2G8bd+vIvMQpv5irEH3sGkr4A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oNy2RlgN+93tij2pItmSE+mEg9Su1aKTCJppfcTAfps=;
 b=g3qJQXoucKN4LiEgQ9UU3YOV/1AcEAuDuLSVgL9WCgW2zVjxoT4+PrvgtbHBDSqDFUkYsuSyPdh3oTVOYsfsnMLDz3hqeOj4JOfCEUeQ98NvHG1nE2ZWwn73mCXY2xbH2N/9AnUUl/dtpYOZqeYBlmn7H3W7n0/trjmWaeoir41gSeLcJxTBWSwQHpemoYeejLdB/wwjUTSeA9QO9xU4VxibbTaazzg3E2thq4cq3HHnRfxI7UZNtAuhAGF5dfaAr7Uov9VY4CJQ41ntrluidEN/7uPwsyahtY9PEs4QsHULTFH6xrWkVQ1F5kVcPWUnvThQZk+Q/c8Uwi9XjSn1qA==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by SJ2PR12MB8135.namprd12.prod.outlook.com (2603:10b6:a03:4f3::13) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.315.14; Wed, 12 Aug
 2026 19:58:53 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0315.014; Wed, 12 Aug 2026
 19:58:53 +0000
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8
Date: Wed, 12 Aug 2026 15:58:50 -0400
Message-Id: <DKN8CAY6257F.6TB3KM9OX4AV@nvidia.com>
Subject: Re: [PATCH RFC 13/14] treewide: adjust comments on PagePrivate and
 PG_private
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, "Zi Yan"
 <ziy@nvidia.com>, "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze"
 <amarkuze@redhat.com>, "Viacheslav Dubeyko" <slava@dubeyko.com>, "Trond
 Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Richard Weinberger" <richard@nod.at>, "Zhihao Cheng"
 <chengzhihao1@huawei.com>, <ceph-devel@vger.kernel.org>,
 <linux-nfs@vger.kernel.org>, <linux-mtd@lists.infradead.org>
To: "David Hildenbrand" <david@kernel.org>, "Matthew Wilcox (Oracle)"
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
X-Mailer: aerc 0.21.0
References: <20260731-remove-pg_private-v1-0-142c97ba3562@nvidia.com>
 <20260731-remove-pg_private-v1-13-142c97ba3562@nvidia.com>
In-Reply-To: <20260731-remove-pg_private-v1-13-142c97ba3562@nvidia.com>
X-ClientProxiedBy: YQBPR0101CA0188.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c01:f::31) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|SJ2PR12MB8135:EE_
X-MS-Office365-Filtering-Correlation-Id: b08462ee-0485-4256-f9d6-08def8ac22be
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|1800799024|376014|7416014|366016|4143699003|11063799006|56012099006|10067099003|22082099003|18002099003|921020;
X-Microsoft-Antispam-Message-Info:
	O3k5fabA0ZwgSZA7eGIl1YsQm/52dhAiwJFGse/HtG5BRVOyq4IS4jhvnBL18BJH501aCBbGpZUkzuHmffwsLCBTcuxY7u27odzg47HYCB20t8+3dDwWy8mQ8RzmOSm9Q4FmFwvqNI0a/HZQk7KN2/EQ7Gdiqf6yEV+28hX1yCqVgybtm/lw2vjfbgRo8sVSrhaJPrzNhJcOPw1xAnxWeBrM9uNC51eQTgrzlORX/jmrRqFwhxV+ZMDAewvl+xJQdlB4WiK9lCR1nb2R5hxWMW4Yot4hfuPA2bOzaMX9fMTXbGscqw3W0C0SoxZueVjq1QqH44zBBZXDWUemdXTiuy8hIp6W0plLIiNd2it2Sfxho4vRt2UpKR4Abs2gkr+vZ4PfedXwqUdcyNX71H64+S3lerASHTGveHe77AzLmafHnziS5J2y3xZgeOZvAXmW9cl8G6uF2ukMuCoaZpmEUdoff8JWDJXVUeny74CXkRjb56h7FY60HuaBKC+X3hKi15MIMGlZSpK6eoXwL1Ck8gkB+CbwW7RVRUo+IbUfLVSdNoV7XAFWcX7Bl/0dIYLnTz4MN++xyuf3pyOTOzDr0J6xUCHEBkD93CxyUXpM+BIeIRER/F1j3YWfS9eXPdgeVDgYhxeqmSkky9a1ewdnIMghgUz6Nrk7DHsweoJ1QkplcvW1pNy5uoqcCLFJDHLrXLDdE+fl/Pmytw1BYY1oPg==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(1800799024)(376014)(7416014)(366016)(4143699003)(11063799006)(56012099006)(10067099003)(22082099003)(18002099003)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?Q1ptVml0enZ2QnRQTnNZVHRaYU0zeko2ell6OXYzV3RFV3pRSnN0RHZFcS9S?=
 =?utf-8?B?cldHWXFWVnpiWUJmNWlNbnRXVTkyV05QN05TYllRem9BSXpYSUR3QlFFMjRk?=
 =?utf-8?B?SlhUdjJlNWxMMTdGRHZnTnJTd01pWUtvZ3hCVDdoVUFIRXB1dlIzMGpPekkz?=
 =?utf-8?B?bVpZRDlmanRKSzA0S1ZNbjQ4U2FRV3lvZkVJMW9wY2lNY0FoMjBENDlraGdY?=
 =?utf-8?B?U2IrMHNHdXV5Y3NuUjd3eDR4ck5ueC9TSVo4dVlXM0xIRE9nWHhOQi9EdEJr?=
 =?utf-8?B?QUFwekd6WVo3dkNPQlRTc1RYdUVwRFpjTkhsT2IzK0NFZktHdDVPZUtKSjVj?=
 =?utf-8?B?NHVNY042c1UycjVWdXJka2N2dkRoS3d4RVQ2b3NSWnRDSUdmZmZndmVmeHl4?=
 =?utf-8?B?NTFXRTJlRWRsczMybnMwT1RBQlRKS3pHM1VLYkZETVk2OUFmcDljaFByYkJZ?=
 =?utf-8?B?azRrK3VDbndKL2lJbHl5Z05xQ2h3bWNET1N5OWJ2WjJTTnIxa2tZb1hGSXBH?=
 =?utf-8?B?SkZ0bUxLWVo1eTZUb3QzTkVVTlJ3Z2ZvVVdTeU1OVWhXY0s5cnQ2OTlqcVA3?=
 =?utf-8?B?eGhMUDRJWTBPeFV5NVE5cDFlZjNaM0ZVVlZBalZvZXUvTmRGNmlRdFhZOEF5?=
 =?utf-8?B?c1JkVmxtdTkrWCttLytRS1cxTktKRDN6ejZUZ1hkNzlqTFpWVXlHaFEwVEFo?=
 =?utf-8?B?L2RVNzBFOFN2Y3R2S1M5b0JnOTlFRVJZUzJZYnhpNnczTGY1NWRWQ1ZPYjEv?=
 =?utf-8?B?YXF4Wll2UkNsYjV4K0FRQmhjZVk0aTc1enpMM1NoNmRyVzZxRWpOTVdtQ0tW?=
 =?utf-8?B?T1ZUWDZORzdUdGI4V05VVnYwUlNHbkU3SVZmQ1JsVzRsVHBkMWRZSGNhbGJO?=
 =?utf-8?B?dU43c2ZSTnFDS0Fyd3NBRHJReEMwYko2WGs3NFlJUGZrVWpiVjdMSHF0T3Rp?=
 =?utf-8?B?TVU4MS9RWUp6UHQyeEhuQUVjb3ZxVkZDOFZZZittanlFY24vTjExdXF1MTJ6?=
 =?utf-8?B?Ung0cXVtTVpvMDBxNHJaZVpHZ1ljU05WZjEvajNEa1lTeEJ0bmZnSmo2TGpY?=
 =?utf-8?B?VkJzalFnTUZhK3VPa2F4ZnFTYXJVYThXYklCOURZVm9XczdTY0wwQm04UXZq?=
 =?utf-8?B?V0JVY25EZW5WRmx0c3ZMcUhFT1BucTJqcCtWQnEyemhOeDV2Ykxwc3BBWm55?=
 =?utf-8?B?QUNLOFBOdkZ0YzAveTFEcURLYTJqdWRXWjdHVlh2a2VvSDEvZmhLV2RpMHcx?=
 =?utf-8?B?NWxrSXNuK0J1TDMyUEVHejVvSXhaR1ZRd3VHYWlka3A2YkdlNG9FeEM0VDE3?=
 =?utf-8?B?bk1Yc244d29jbzFDMXo1dnJVQ2ViUUtVNjl3U090eHp1V3JNcXRFREoycFBR?=
 =?utf-8?B?bkt1MGp2emdacldMQzQzQkxJTlNtWEdRRGo0QUZCTm5pVGVOYWlmNW9yaGlS?=
 =?utf-8?B?QUxCMXB0NlFBRE9WQ0MwUnFQWExpTnczem9EeG1WbjQxWnZhMXptU1RMUE1Z?=
 =?utf-8?B?UGppMUJzbHNEU29sUFp2eURxWXVPN25Mc1htU1pLa1BXbW9PYndnd3lHaGhF?=
 =?utf-8?B?d21IOW4zeEV3Q0RCNHc1cXlvNldMVUNuNDhadGtHSGUydit0ZWxiWXV6NFor?=
 =?utf-8?B?UDROWG1KYTVoM1dtMVBhQlNudlczUTVyK1IzQksrVVlRVWxHc2xHcmM2SlFw?=
 =?utf-8?B?S2p1a1BBME13YnRxVnJKc3FkU2ZDNzMza0pSS0FPdFo5L0d6dmtXem1uMTNN?=
 =?utf-8?B?MzRhb3FrQ1dTdUNGS2w4NU5iQW4xTU9nVXpRcVRxR1d5R0VsSFpXUEFxa1ow?=
 =?utf-8?B?bTBNUy9TT2Z5bGI2cDRwT3g0ZHJvU1Q1TUpQalBPbGRVMjZmZUs0WkJrMldE?=
 =?utf-8?B?eVJkOWdhOU1qTUoyV1FiWEw4b0RYeHJSRlByNlM2U25xdFlDL1k0TkV5M0dQ?=
 =?utf-8?B?UVJTNlZMNXFLMDA2ZlNZVVVuMmVRbFNxTWN3Zjk5UFJ6TWlJa3d6b09wRngz?=
 =?utf-8?B?d244ZkkwWnhReHh4TzJLUnhVcUZwWk9jK09zWmdMMVA0eVQ4ZUhnMERyczhZ?=
 =?utf-8?B?cHpiNVpwdFRKOW9zVE9yV1Jrbnl6UWFjaFFDRGk3a3JXQWdSSmNRdWREdzRj?=
 =?utf-8?B?ZDRhcXJvZDRSOGZZM2pmRUExSU92VlRNcHdvSjFRc1dEKzZiWnYwcytuSjNt?=
 =?utf-8?B?OFpDVkhGN1RZZnd6dHFOT3N1WkRmQnJNcmRaZjBucUFmQ2Nqa1A4TkUyVHFi?=
 =?utf-8?B?SG5DckYxK2ZVbjVrdEZEMFUva0pINUkveTBUN1hERUVHVHJwS1BjSDdhczZs?=
 =?utf-8?Q?jAyPRolBpbHKn1g3B5?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b08462ee-0485-4256-f9d6-08def8ac22be
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 12 Aug 2026 19:58:53.5945
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: y/TFg1csI58uyq/xgiwRdSzyd07LLBUfTmwVbyvGI713Du7jncc2KnxKFxE2CEMg
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ2PR12MB8135

On Fri Jul 31, 2026 at 10:13 PM EDT, Zi Yan wrote:
> PG_private is going to be deleted. Adjust related comments to refer to
> page/folio->private instead.
>
> Assisted-by: Claude:claude-opus-4-8
> Assisted-by: Codex:gpt-5
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> To: Ilya Dryomov <idryomov@gmail.com>
> To: Alex Markuze <amarkuze@redhat.com>
> To: Viacheslav Dubeyko <slava@dubeyko.com>
> To: Trond Myklebust <trondmy@kernel.org>
> To: Anna Schumaker <anna@kernel.org>
> To: Richard Weinberger <richard@nod.at>
> To: Andrew Morton <akpm@linux-foundation.org>
> To: David Hildenbrand <david@kernel.org>
> Cc: Zhihao Cheng <chengzhihao1@huawei.com>
> Cc: Lorenzo Stoakes <ljs@kernel.org>
> Cc: "Liam R. Howlett" <liam@infradead.org>
> Cc: Vlastimil Babka <vbabka@kernel.org>
> Cc: Mike Rapoport <rppt@kernel.org>
> Cc: Suren Baghdasaryan <surenb@google.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: ceph-devel@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-nfs@vger.kernel.org
> Cc: linux-mtd@lists.infradead.org
> Cc: linux-mm@kvack.org
> ---
>  fs/ceph/addr.c           | 4 ++--
>  fs/nfs/file.c            | 4 ++--
>  fs/ubifs/file.c          | 6 +++---
>  include/linux/mm.h       | 6 +++---
>  include/linux/mm_types.h | 4 ++--
>  5 files changed, 12 insertions(+), 12 deletions(-)
>

I will fix the issues pointed out by Sashiko in the comments from
include/linux/mm.h, fs/ceph/addr.c, and fs/ubifs/file.c[1].

[1] https://sashiko.dev/#/patchset/20260731-remove-pg_private-v1-9-142c97ba=
3562%40nvidia.com?part=3D13

--=20
Best Regards,
Yan, Zi

