Received: from DM5PR21CU001.outbound.protection.outlook.com (mail-centralusazon11011011.outbound.protection.outlook.com [52.101.62.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C776931578E;
	Mon, 14 Sep 2026 02:24:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.62.11
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789352679; cv=fail; b=KHlwFaeUoT/ZFIVdVad1pCI3Z3UShAXsWjCXiCsS8Zv4Da+LWtN979oq6J5Cipkxkz6f8/nKApJTMQglqG0wKrvFCLPky4oSW9Gwg4CGpaMXwkFy/YjmHNzLNQ0AxdvkqlcdbsHBx/6i3iQ4BsHsI/4ktbbJnp9w7cEyk1FjLaE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789352679; c=relaxed/simple;
	bh=S6sOBPvP5NSt2R5aohmgskBC896GVQvdkiS8CEgLTy0=;
	h=From:Subject:Date:Message-Id:Content-Type:To:Cc:MIME-Version; b=mbigKSGCTB7IrvAD2spUigfZb5eguxYeITJwTdGv/h80dyDajIkq/3frcl0EkbQP8F0SWokM8gHJgSlMucKMKQN/X6fvR7iOlrL7yYF9zD7N389Yw+fIQ1HVq3CXS8gL/nOZ9TZbqSroWf58Nnp8CJfRA2oh4YpfrRnI2o53ojU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=Td+0Uxeu; arc=fail smtp.client-ip=52.101.62.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="Td+0Uxeu"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=RuH9vyjuYaid+zILzXrJrBV7OItP/6/TaUIQi0nBptyYKtiDiU/aolayw+RQamS95Fzg9hJ6tj6E5nnFpjx5vvopnryJhmJ/+n061jItD35cETPUHbqOqfhf5MIvs49CafSFXVPZnOoYnJouAGWDLqSho58fJBO0PcquMXI0euhFhzTQsku/Qo5aEvg9c14MP3C83Dgb/Uhmjg5HZfnuz26Ifc4kOLbv+loMFfym5nP9J0SI+3qVsn2OCyXQJ71UfJjLex3EuLoSFZdQSiAJ/Afo9RUzfonQcB76hxwBdexq+vWQfWPF01QPSJiK4l88NaGaRwRmxWcJLALRBUV9cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=tvB0TSP3lu5xd3D2C+aiQSNa7p4jdAISkxA9X3SgoOc=;
 b=FOpKPUalL+ZKzBHLhfZ6Vue1SUn7Ley72wD6mi9CUAnfuPPzx9CTOO1SR6fgAxg2eVtO5b4OtARRGMH5N0JbmPuD8iWTXstNQLCC+VTxJKQ01ZVpx5UIh/epZcbcvHAN2Qex4LEG2TDr6QssdKXd8QD+OYIdnb9h3CNv58N0nTnKmkk3GjUAFAzeqJZ6ZKOUZyOKMg3wpUcwc+guOMS2GBxH6i6wFh/HAeFA1E7RL3+6Ne3qX6en6lR7P8L6zLtvmBaZDX+VXKTtXRkaf+NrVlMoravfYWsgsASnrX2SgNY35bqi6vu+x/nrpXaxhihfligXJywRwWgr6N5D+rubDA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tvB0TSP3lu5xd3D2C+aiQSNa7p4jdAISkxA9X3SgoOc=;
 b=Td+0UxeuJ5XwD7k8zm6yDw1VXgIgLHuCWQhFVM0O1fEgKvCkktTrsRpHLTuSQFlSJglYmy98LGI99hAxpqXe7mdib/USXhShZhS7ejHTM/BwxeVdP3y7eyJREk10ljuqn/2p+9n3imx+Is67VykaGznn6nkpqMNl4VSJ1+8uuBCf2M7tRERmW1dbcVsKpUD96sRdWN6pd1aPBwaLZGlIy4Bea7yg5DlsUxfwxG3d/JXD+DuA/75bsdMcT/CSgVYGg8lp36cb0PH/voalbuwPTeiopxpxLOXIIE3SqB7M05KKlsIioUu6M4TiRWxfkahYS7u8ipHzxbfcsNDtlylJBA==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by DS0PR12MB6486.namprd12.prod.outlook.com (2603:10b6:8:c5::21) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.406.12; Mon, 14 Sep
 2026 02:24:14 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0406.007; Mon, 14 Sep 2026
 02:24:14 +0000
From: Zi Yan <ziy@nvidia.com>
Subject: [PATCH v4 00/16] Remove PG_private by using page/folio->private
 checks instead
Date: Sun, 13 Sep 2026 22:23:58 -0400
Message-Id: <20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/23OzQrCMAzA8VcZPVtZU+2HJ99DRGqXbTlsHd0oi
 uzdrUMY4o7/QH7Ji40YCUd2Kl4sYqKRQp/jsCuYb13fIKcqN4MSVKnB8IhdSMiH5jZESm5C7mu
 0oLyujfQs7w0Ra3os5uWau6VxCvG5nEjiM/1qUmxoSfCSiwN4q+9OHhWc+0QVub0PHftwCVbCb
 BOQCamUEUfrK4vmj5ArYUu9RchMKIcAta0s6N8v5nl+AwHWcy45AQAA
X-Change-ID: 20260728-remove-pg_private-cfe926c7f83c
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
 Zi Yan <ziy@nvidia.com>, Minchan Kim <minchan@kernel.org>, 
 Sergey Senozhatsky <senozhatsky@chromium.org>, 
 Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, 
 Arnaldo Carvalho de Melo <acme@kernel.org>, 
 Namhyung Kim <namhyung@kernel.org>, Thomas Gleixner <tglx@kernel.org>, 
 Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
 x86@kernel.org, Mark Rutland <mark.rutland@arm.com>, 
 Alexander Shishkin <alexander.shishkin@linux.intel.com>, 
 Jiri Olsa <jolsa@kernel.org>, Ian Rogers <irogers@google.com>, 
 Adrian Hunter <adrian.hunter@intel.com>, 
 James Clark <james.clark@linaro.org>, "H. Peter Anvin" <hpa@zytor.com>, 
 linux-perf-users@vger.kernel.org, Juergen Gross <jgross@suse.com>, 
 Stefano Stabellini <sstabellini@kernel.org>, 
 Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>, 
 xen-devel@lists.xenproject.org, Eric Biggers <ebiggers@kernel.org>, 
 "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, 
 linux-fscrypt@vger.kernel.org, Oscar Salvador <osalvador@suse.de>, 
 Chao Yu <chao@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, 
 Tal Zussman <tz2294@columbia.edu>, Gao Xiang <xiang@kernel.org>, 
 Jan Kara <jack@suse.cz>, Yue Hu <zbestahu@gmail.com>, 
 Jeffle Xu <jefflexu@linux.alibaba.com>, 
 Sandeep Dhavale <dhavale@google.com>, Hongbo Li <hongbohbli@tencent.com>, 
 Chunhai Guo <guochunhai@vivo.com>, linux-erofs@lists.ozlabs.org, 
 linux-fsdevel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, 
 Masami Hiramatsu <mhiramat@kernel.org>, 
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
 Matthew Brost <matthew.brost@intel.com>, 
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>, 
 Byungchul Park <byungchul@sk.com>, 
 Axel Rasmussen <axelrasmussen@google.com>, Yuanchu Xie <yuanchu@google.com>, 
 Wei Xu <weixugc@google.com>, linux-trace-kernel@vger.kernel.org, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, 
 Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
 ceph-devel@vger.kernel.org, Song Liu <song@kernel.org>, 
 Yu Kuai <yukuai@fygo.io>, Li Nan <magiclinan@didiglobal.com>, 
 Xiao Ni <xiao@kernel.org>, linux-raid@vger.kernel.org, 
 Richard Weinberger <richard@nod.at>, Zhihao Cheng <chengzhihao1@huawei.com>, 
 linux-mtd@lists.infradead.org, Baoquan He <baoquan.he@linux.dev>, 
 Pasha Tatashin <pasha.tatashin@soleen.com>, 
 Pratyush Yadav <pratyush@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Dave Young <ruirui.yang@linux.dev>, Shuah Khan <skhan@linuxfoundation.org>, 
 kexec@lists.infradead.org, linux-doc@vger.kernel.org
X-Mailer: b4 0.16.0
X-ClientProxiedBy: MN0PR05CA0019.namprd05.prod.outlook.com
 (2603:10b6:208:52c::26) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|DS0PR12MB6486:EE_
X-MS-Office365-Filtering-Correlation-Id: 58b806a8-7031-4f61-010f-08df120744e8
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|7416014|366016|376014|1800799024|6133799003|18002099003|3023799007|921020|10067099003|56012099006|11063799006|5023799004;
X-Microsoft-Antispam-Message-Info:
	uw4TP9xiaMyZIvIwMa32j3fGc17IpO2wUcD60ElgnQhs73y/FOYE9fUIpBI2nR3HVAx0lKAhr8hTl8TUpmTVMGYTd/m/IRrjtnotO5ehj8wSa//D08/3w7mB0CqGBcpCdTY3tPsjF6LFG2apQV1iMR7g6pv/cTa6H7tdPrVUlQeTFRQtxKuzQ5cYY+KjqTYdsg4m/BpegV51Mwxz0r4EO47yuY5hA++MKhLFwEB/+CGnICKvyQgX7A7/vEY9Qv0xC0+Ygz3u7a7D6mTQ3osA0DXA6L9ob0JUVXukEC19ue6PifLZsltomqqCyHZQsgym7Iz1W7HFSFJx9AANsJVeLzLDc3V4IicoGoPiE8VvinUHc3rRAwKqovz9D+OrIpnbgYVZbHWqRM5bDv6jjWxHNKR9RWZ9LFb5h94xE8B+cWFSohjx6aEM2HMcCCBt8HXucScSnmJ5NdIXWhLdQmn1SDa3I8ST5wrPmqIV4BY9jQX/hKmb5ylNHKxnmEPA4etqr3+9nc8zTiKWTWmvgbxrgZNeNQPpNbOQQ9mQ9f+WoNAr1vrpCOMnuwc+GmFtNrAqvjiSsuLP2bNLva5KUUfMq+qpW7DMW2Z6Rj157qLyOHER+4D7xk7Um0MkJSrx1AVZZPP80xAZxfSp3CQB/SfqHfGhHvsVgxoZinU7ICq2+OnMnm2hIUTR7/V5xpN9dodcyWjDo0UgPBbljPBHIMa5Kg==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(7416014)(366016)(376014)(1800799024)(6133799003)(18002099003)(3023799007)(921020)(10067099003)(56012099006)(11063799006)(5023799004);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?SFQvOVdTcHVpdDRzNkM3WWVxcWx1cE45czRqZjhXSXppYVlYVkUyYTAyeFYr?=
 =?utf-8?B?ejI1a2JON0I1RkNuOHJwWVlWbzVLLzRQTEpKNmJFYnVFRTE5NkFIQzZlVGtI?=
 =?utf-8?B?Qkpqbno5MGJkRzRWYnl5VG44ZmMyUWU0d3pqLzFZeTRsZFFIQ1NVMVhIeXFk?=
 =?utf-8?B?UFA2Nk5NYXl4MHErd0NpVVgvUEhkcGptVjZFVnJVcVN2MnRZVndOMUhaWXp3?=
 =?utf-8?B?ZlgyNWlpV3JjK0hhbDVNZTJRYllQN2d5MUpOZU00SllmaUVtbkVBcEgrNmZz?=
 =?utf-8?B?M1FhZFNNSHlZUUx3ZXF2R1A0NmYzalpiZk82anp3WlRYU2lzdTdVbDJEKzRS?=
 =?utf-8?B?QzBCZUdJWFFLOWZjbm8xTFl2TkE1Q2Y3L25PSUVwUC9zbkIzM1JWVDVFVmhJ?=
 =?utf-8?B?QkRvUTJxZFlXSDh1WGNCUGI1WGZLTnZqVk9HMC9ZTGc0aEJEeE5UTXVKZ2ZG?=
 =?utf-8?B?dkIwaEljTVFpTnZiUXlXU2ZRRnhpNUNlTTVOcTQ2a2piNHo2SEFHTGxWVWF6?=
 =?utf-8?B?a1hmVmlydko0L3FEUmhFOXhwR3Q1NnZvTzJGRmJKWlQ0elZ5OHg3R0JzT0dv?=
 =?utf-8?B?RkoxSm4rWmRrTXQvRXR3Vkh4aCsydGkvNnIrR0lRNHI3ODFVQUdmb1V4LzNr?=
 =?utf-8?B?TzViVDRmaWI4b24rRUdncHVyMXUwdzFiSE5jcUcveTZVTDNuKzd6aDdQSTBm?=
 =?utf-8?B?U1EzTGliZnh4U3BubVdBZWhMK2dLRmp4TlBRRFFqTnZieCtHN3FZUThsRVhN?=
 =?utf-8?B?Zm1wRk55ajlkOWtRQXNmdU5kb1RhYmJyalNMMmFydFk5R0JJVE94Ym9LL2NZ?=
 =?utf-8?B?NHBXMEZZWEJsZ0trbFNLVG1DZTdNOHB6WEIrdGh4bkNLMDhBbmlXUVBiTGJy?=
 =?utf-8?B?V1VJc1F3OTRNazZabjIrdDIvUzFyeHA4cVZQcGZZM3hGTkZDT2plczVvQTJl?=
 =?utf-8?B?UnRaRFBVOGpFS3hYM1dFMXY5RUM0UVE2Rm8wd2RtK1dmU0w4L1hRS3RRblBU?=
 =?utf-8?B?cTJwWXdTZ3ZWaThIcE5qbnlEcHE5am5zZkJNdjFYT0hHa2JDbDFlSG5tS3No?=
 =?utf-8?B?Mi8xa3hVRThWY3ZrcC82MThWY2lIY3FkdlN2TStjcjc2d3p1eVFiYzl6cTl4?=
 =?utf-8?B?L0ZML0s5U0pJeFpLTytRSklzdzhEeVFVV2lOOTVhSTdielB1ejVEZTN6SVRG?=
 =?utf-8?B?VFRSN0F0ZUU0RlFqS045RWp2QVNVZXRTUkU5RFdUVzdRdFJUNDJlNHdnSStN?=
 =?utf-8?B?Ull5eWdMeDNRWEFjdDhyTXB6Sm9ISXB0QU9kaEtTMmYyYm9VcElXMU9mYTdy?=
 =?utf-8?B?ZUV3ZlJFSFBCSlpnNkJQZXpQRmFzNGo2OXB6dUo1V3dRSEs3YmRqTjEyOVVp?=
 =?utf-8?B?V0h4dENzQWE1QlR2aFNOTEJTdjYrWU4vTC9DMjd2dDFVYllaa3JiRnBRNE1m?=
 =?utf-8?B?a2RFRW9tOXNDbDd1OW1LVFNPWEMzOW9BUlViNXB4ZmU4bXhzaHlCVWhNUnJk?=
 =?utf-8?B?bjVFc3RBdkgxM2w2d3ZPT0RITEk5SXNiek8zcmw3aitXWFBrbjZsdWxLRVR4?=
 =?utf-8?B?VUQrTlhvTVlQeGJ6Y1hPYnBjYXNBK0NWWmlKeXQrMy9EOUc4L2YvN1FxL0dM?=
 =?utf-8?B?N0FueGRwN0d6d3dnMkRvaHRIS2UzYytsN2Q5dlQ2RXJsS3NCRnZmUFZjY1o4?=
 =?utf-8?B?Zm9Tc3UvVVZDVUhWU2d3cDhMZTFCc2oyM1kxcFhBdE4vUUZQY25ZamQ0OUM3?=
 =?utf-8?B?bUZUa09Mc1VsUis0akR2dDJ0UjBqM2dwTUxDNUFuRkZOL1FNK0pPY1ZIYjZB?=
 =?utf-8?B?OUpUUm9TWWIxbi93Tnc4ZUZQRHJFNGVTK1F3dzREN3FrWmFzemZYN1BNcWVq?=
 =?utf-8?B?K3NvS3lzbFJVZ2ZQcWJXcjE4SSttZzJPN3BJQzJuWEYvT29NbVB5NUJXbkJv?=
 =?utf-8?B?Y0dDK2pKbGRIWXNBSTVVTjUwY0ZKQm5VdDE4Rk1GbjFQdGhmeTdLaG9Mc2VQ?=
 =?utf-8?B?R3JFTjRkL3FOUmhBQ1owZDNFRE1LbEJGWjVTaU5OaDROUEx3RExuWWk0MXRo?=
 =?utf-8?B?bmx5cWF2b05KWVppOGcyNkxBN1loY1hWYlpVTElBRkJaa3lHUkM3WmpjcU10?=
 =?utf-8?B?QmJ1ZzJ3YlcvbndqOXpSSGx3M01FVGdRczh1WGpwaDJYdHp6UmVaT0VtRW14?=
 =?utf-8?B?VHc2cEJrRi9aSEJoVjJMZ0dGSkQxb3F2enJhWnpYMlNoTzlEUnd1NkhIcjlW?=
 =?utf-8?B?Tm9WVHdodVFxbFJ4elF2SGJ1OFhGNXZQM0hTUjZTMU1yOHkwLzk0MkxycElV?=
 =?utf-8?Q?4B0cEUcbG9+81FWeZZ?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 58b806a8-7031-4f61-010f-08df120744e8
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 14 Sep 2026 02:24:14.1529
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 5QuzN4mEfAUXhsNUNhNjvq1VqrMux8K6U5WQLP8azuRWxVympQ+TSMu0urb+FhBH
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS0PR12MB6486

Hi all,

This patchset removes PG_private to make space for upcoming PG_folio for
identifying pages from a folio (more details in Note below). Instead of
checking PG_private, all code is changed to check page/folio->private !=
NULL instead.

MM people are cc'd on all patches and subsystem people are cc'd on the
cover letter and corresponding patches.

Patch 6 is picked up separately in f2fs tree, but since mm-new does not
have it yet, it is sent for MM testing.

Overview
===
Most code uses folio_attach/detach/change_private() functions, so folio
refcount is increased and decreased when folio->private is set and reset,
respectively. There is no need to change them.

Changes are needed for exceptional users:
1. zsmalloc uses PG_private to indicate first component zpdesc page and
   page->private is used to store zspage in zpdesc. To remove PG_private,
   is_first_zpdesc() is replaced by pointer comparison.

2. kernel/events/ring_buffer.c stores page order in page->private.
   Replacing PG_private with page->private != NULL works.

3. drivers/xen/grant-table.c stores xen_page_foreign in page->private,
   where on 32-bit, a pointer to xen_page_foreign is stored; on 64-bit,
   page->private is used as xen_page_foreign. PG_private check is replaced
   by page->private != NULL on 32-bit for xen_page_foreign deallocation.
   On 64-bit, page->private is cleared unconditionally since {domid=0,
   gref=0} (xen_page_foreign can be 0) is valid.

4. fs/crypto/crypto.c stores a folio pointer in page->private, PG_private
   checks are replaced by page->private != NULL.

5. fs/erofs has two different uses:

    5a. folio->private is used to form a reversed list of
    the outputs of readahead_folio(). readahead_folio_last() is added to
    output folios in reversed order, so that ->private is no longer needed.

    5b. folio->private is used as an in-flight I/O counter. Convert the
    code to use folio_attach/detach/get_private() and add bias==1 to the
    counter to avoid folio->private being zero.

6. fs/nfs/write.c: folio refcount maintenance is in a bigger scope than
   folio->private. So folio_attach/detach/get_private() is not used.
   Nothing to change.

7. fs/f2fs uses attach_page_private() to first reset folio->private then
   immediately sets PAGE_PRIVATE_NOT_POINTER bit on it. Change it to use
   attach_page_private() to set PAGE_PRIVATE_NOT_POINTER bit directly to
   avoid folio->private == NULL gap inside set_page_private_##name().

8. hugetlb uses folio_change_private(folio, NULL) without folio refcount
   maintenance. Change it to folio->private = NULL.

After the above changes, PG_private ops are converted to
page/folio->private ops.

folio_has_attached_private() is added to check filesystem-only private data
by excluding swapcache and hugetlb folios, because swapcache folios overlap
swp_entry_t swap with ->private and hugetlb sets its own flags in
->private.

Note
===
1. KPF_PRIVATE is removed after PG_private is removed.

2. Documentation/mm/hugetlbfs_reserv.rst is outdated, so I did not remove
   PG_private related text. It should be rewritten.

3. PG_folio is planned to be set on every page from a folio in
   page_rmappable_folio(), so folios with any order (currently
   PG_large_rmappable is used to identify >0 order folios, but not order-0
   folios) can be identified. Then vm_insert_*() can correctly reject all
   folios and rmap code will only see folios. Eventually, page_folio()
   will return NULL for non-folio pages by checking PG_folio, but before
   that all existing users that treat compound pages as folios will need
   to be converted.

Tests
===
1. allmodconfig build passed.

2. zsmalloc is tested using ext4 on a 1GB lz4 zram:
    2a. zram load + zsmalloc compaction;
    2b. concurrent zspage migration via memory compaction;
    2c. confirmed that multi-page zspages actually formed.

    Details: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/test_zsmalloc.md

3. erofs is tested on images created with -C4096 and lz4hc, lzma,
   deflate, and zstd algorithms:
   3a. cold read of all files, verify checksums match source;
   3b. readahead + reclaim/migration race.

   Details: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/test_erofs.md

4. fscrypt is tested on software-encrypted ext4 with writes to exercise
   bounce pages.

   Details: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/test_fscrypt.md

5. f2fs is tested on an image with inline_data,compress_algorithm=lz4:
    5a. INLINE_INODE — lots of tiny files;
    5b. REF_RESOURCE + general writeback — buffered write churn with fsync;
    5c. ONGOING_MIGRATION — force GC / page migration;
    5d. ATOMIC_WRITE — atomic-write ioctl path.

    Details: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/test_f2fs.md
    (I did not run xfstests)

6. MM selftests passed.

LLM use
===
Claude was used to form a concrete plan on what code needs to be changed
and how to change them. The plan was reviewed by Codex until no issue was
spotted.

Plan is at: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/plan.md

I then followed the plan to make code changes. I did bounce ideas with
Claude how to change fs/erofs, since I did not like the original idea.
After each change, I asked Claude to review my code and git commit message.
I also asked Claude to give me test plans (see above).

At last, Codex was used to review all patches.

Comments and suggestions are welcome. Thanks.

Assisted-by: LLM
Signed-off-by: Zi Yan <ziy@nvidia.com>
---
Changes in v4:
1. dropped set_page_private(0) in balloon_retrieve(), since page->private
   is cleared at that point.
2. simplified the comment in add_hugetlb_folio().
3. additional cleanup for f2fs to remove fio->page uses and convert
   PAGE_PRIVATE_* flags and helper to folio-only.
4. added a comment for __readahead_advance().
5. added core-mm split/migration interaction information on newly added
   folio_attach/detach_private() for erofs.
6. renamed folio_test_fs_private() to folio_has_attached_private() and
   merged the commit introducing folio_test_fs_private() into its prior
   commit.
7. adjusted the patch subject: "treewide: remove folio_set/clear_private()
   *usage*"
8. split "treewide: replace PagePrivate() with page_private()" into three.
9. moved some comments in "treewide: remove PagePrivate() and PG_private
   from comments and docs" to prior patches along with code changes.
10. used PG_folio instead of __PG_folio to avoid additional
    code change in __def_pageflag_names().
- Link to v3: https://patch.msgid.link/20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com

Changes in v3:
1. changed folio_test_fs_private() to check PG_swapbacked instead of
   PG_swapcache for excluding swapcache folios. Because folio->private and
   PG_swapcache are not set as a whole, making folio_test_fs_private() give
   false positive, whereas PG_swapbacked is always set for swapcache
   folios.
2. added __DEF_PAGEFLAG_NAME() to show __PG_folio instead of open code.
3. f2fs change is picked up at
   https://git.kernel.org/jaegeuk/f2fs/c/5ad9409a9533, mm-new currently
   does not have it, so the patch is sent for MM testing purpose.
- Link to v2: https://patch.msgid.link/20260831-remove-pg_private-v2-0-3668159cd9e8@nvidia.com

Changes in v2:
1. removed is_first_zpdesc() in patch 1 and open coded the checks.
2. fixed wording in patch 2's commit message and clarified page_private()
   also works when ring buffer's AUX page order is 0.
3. removed the empty loop in 64-bit gnttab_pages_set_private().
4. clarified folio->private will be reset to NULL by
   fscrypt_free_bounce_page() in the commit message.
5. clarified why hugetlb needs to restore hugetlb_vmemmap_optimized.
6. renamed readahead_folio_reverse() readahead_folio_last() and
   reimplemented readahead_folio_last() by adding a new readahead_control
   private member, _forward, and a new helper __readahead_advance().
7. added a bias, 1, to erofs I/O counter, so that folio->private stays non
   NULL between folio_attach_private() and folio_detach_private().
8. converted more call sites to use folio_test_fs_private().
- Link to v1: https://lore.kernel.org/r/20260731-remove-pg_private-v1-0-142c97ba3562@nvidia.com

---
Zi Yan (16):
      mm/zsmalloc: replace PG_private with pointer comparison
      perf/ring_buffer: stop using PG_private as AUX page high-order marker
      xen/grant-table: stop setting PG_private on pages for grant mapping
      fscrypt: stop setting PG_private on bounce page
      mm/hugetlb: use direct assignment instead of folio_change_private()
      f2fs: stop using PG_private
      f2fs: convert the ->private flag helpers to folio-only
      erofs: mm/pagemap: add readahead_folio_last() to avoid folio->private
      erofs: use folio_attach/detach_private() instead of direct assignment
      mm/page-flags: check page/folio->private instead of PG_private
      treewide: remove folio_set/clear_private() usage
      ceph: replace PagePrivate() with page_private()
      md/md-bitmap: replace PagePrivate() with page_private()
      buffer: replace page_buffer() with page_private() and delete it
      treewide: remove PagePrivate() and PG_private from comments and docs
      mm/page-flags: remove PG_private

 Documentation/admin-guide/kdump/vmcoreinfo.rst |  2 +-
 Documentation/filesystems/vfs.rst              |  6 +-
 arch/x86/events/intel/bts.c                    |  3 -
 arch/x86/events/intel/pt.c                     |  6 +-
 drivers/md/md-bitmap.c                         |  7 +-
 drivers/xen/grant-table.c                      | 11 ++-
 fs/ceph/addr.c                                 |  8 +--
 fs/crypto/crypto.c                             |  2 -
 fs/erofs/data.c                                | 16 +++--
 fs/erofs/zdata.c                               | 13 +---
 fs/f2fs/compress.c                             | 35 +++++----
 fs/f2fs/data.c                                 |  2 +-
 fs/f2fs/f2fs.h                                 | 99 ++++++++++----------------
 fs/f2fs/segment.c                              |  2 +-
 fs/nfs/file.c                                  |  4 +-
 fs/nfs/write.c                                 |  2 -
 fs/proc/page.c                                 |  1 -
 fs/ubifs/file.c                                |  8 +--
 include/linux/buffer_head.h                    |  6 --
 include/linux/kernel-page-flags.h              |  1 -
 include/linux/mm.h                             | 35 +++++----
 include/linux/mm_types.h                       |  4 +-
 include/linux/page-flags.h                     | 43 ++++++++---
 include/linux/pagemap.h                        | 64 ++++++++++++++---
 include/trace/events/mmflags.h                 |  2 +-
 include/trace/events/pagemap.h                 |  3 +-
 kernel/events/ring_buffer.c                    |  7 +-
 kernel/vmcore_info.c                           |  1 -
 mm/huge_memory.c                               |  3 +-
 mm/hugetlb.c                                   |  7 +-
 mm/migrate.c                                   |  3 +-
 mm/page-writeback.c                            |  3 +-
 mm/vmscan.c                                    |  2 +-
 mm/zpdesc.h                                    |  2 +-
 mm/zsmalloc.c                                  | 24 ++-----
 tools/mm/page-types.c                          |  2 -
 36 files changed, 228 insertions(+), 211 deletions(-)
---
base-commit: 3833e2f6aa6bf6af169f78a27843dfa2804be5a6
change-id: 20260728-remove-pg_private-cfe926c7f83c

Best regards,
--  
Yan, Zi

