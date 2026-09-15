Received: from SN4PR0501CU005.outbound.protection.outlook.com (mail-southcentralusazon11011048.outbound.protection.outlook.com [40.93.194.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27F7F430797;
	Tue, 15 Sep 2026 17:16:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.194.48
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789492601; cv=fail; b=Pu0Mero69KwtzqwA4giaUb6Qe+8/hGklkaMC0WAltUFsuD4/1UcmDo3UasDXffvXOCx8dpc6ktukGqBXxi3FybUsuZbSuhdbHAG2jtv39fqZypo6ta/8+zlFztiEDHuKL8IWgrOMcjid27DqwRIlXa6DUjMDxhtYpRbEJLaSnBo=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789492601; c=relaxed/simple;
	bh=lAG5PWlEvtkrE2F/SVDUQjPZ8tQfnncU/ewAzv1Uupg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=dGdp3sWlQxO0yVRAdIJn5KFjqxi42FiV+fK4HiBT1U+2CbCQ9eXSoB6QAoEtIhD3Sh5kW/m69lCWgVzhpYLQUt/MHX3s1CzTFqNG8TRXL0arXWCmxii1ENZdeU/BQ/qSw1++s0IXXblEBC2XLnrezcY98qN9JNxu9mJVDfglSfM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=qdjnEuZm; arc=fail smtp.client-ip=40.93.194.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="qdjnEuZm"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=iwwFsvFOloHx4altECsYutAjbApJwPPXiD6QFXUizuENJtzyIE8exaKrZDcNq5I7j1CLZzN3u3ISD6WbMfmpsUQmCJN4RckcRofY0QshFZrbmhoHbkvQRop+h5YKS4kEBvdfiak61L/wb9hjmyJeZtvcGY5jTfRGI+aULIZfGXZZgbhOIgFJ3Jo0saNgmRlfEd7RZFz3v9ZPsHti4brKICSnAb8UPjO1ocO8ZFz49Dd2j8K+ZJviXuuGfO78cqEl0vyoC0pMRQ0iUke1SRVEdlfpkGjgpoL5TUmVYOmDQUI/Rod8n93gL5h8XE6gRHEW1s66fNlcnu8KTVQAGxqagQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=gm4A0dC/cSIZYi95VVuBQCnE1WnlU3ZJPlPGzxqmmdc=;
 b=izs3jKvQd2SPtIHCbqSzFGoF/iXmI728U1Xlv4NuvE2aWCWp99y+/8UF7Z4R9btCS7XEV6S7MzB5QgrnbKYyDjDw4I22mF0e9yYLUWo6LsxQeAotR+60Ij38OCq8+Xxs9bPppAHUMkXoVgQtJLufv3wqxE/Q1NhsjkzA/WYubFdA+bGMA3TPA64vVgRIvjsPkXsQ4+qsoih20yCJz5VqC5FsmYVrVMuzBh42bO6fXBfbrwwwx5Vbn9AOUQ8vukhRFj86KXZuvZ5X3d85hIbyOAHQVN14MjH1edvzJfPG0QWrkK4uKQP3TT+UFB9yeLBGWXmT7WGnN2xRkrx9vaAV5w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gm4A0dC/cSIZYi95VVuBQCnE1WnlU3ZJPlPGzxqmmdc=;
 b=qdjnEuZm+PoCkspfNOFNWfGpWz5qPUaQuoTEkOpTbi+fqdQpJTQt+C4lxiilcFDnbfSiq+FGTV+fRSmCE/TCUpCLM6y/p2UBuSMu0zsZ3TVemN8SDX3CAV2s4+WZnt7LA6f2dTjX2Cyu/P/qopUr95wEH9C9IV+34J9UMfEdRrJ6BVu2Nuxo524O9pQxU/y5dJDMca7N0gyUn0b+XTcLZfM0vuag7Io98Q0jH5Ll6bqWVefpOdaDuKZvyIJkomyuTSTVq/N2StADM738facGw9b6wKIZeOjGvklwX1BS5eUtzGbKAADcRCCRvX30ruvmlVg4sgMNeiqiuzwDIZ++Lg==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from DS7PR12MB8371.namprd12.prod.outlook.com (2603:10b6:8:e9::18) by
 PH7PR12MB9102.namprd12.prod.outlook.com (2603:10b6:510:2f8::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.406.12; Tue, 15 Sep
 2026 17:16:14 +0000
Received: from DS7PR12MB8371.namprd12.prod.outlook.com
 ([fe80::23d7:9e07:1de8:d80a]) by DS7PR12MB8371.namprd12.prod.outlook.com
 ([fe80::23d7:9e07:1de8:d80a%3]) with mapi id 15.21.0406.007; Tue, 15 Sep 2026
 17:16:14 +0000
From: Zi Yan <ziy@nvidia.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@kernel.org>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 Muchun Song <muchun.song@linux.dev>, Lorenzo Stoakes <ljs@kernel.org>,
 "Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>,
 Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>,
 Michal Hocko <mhocko@suse.com>, Baolin Wang <baolin.wang@linux.alibaba.com>,
 Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>,
 Dev Jain <dev.jain@arm.com>, Barry Song <baohua@kernel.org>,
 Lance Yang <lance.yang@linux.dev>, Usama Arif <usama.arif@linux.dev>,
 Gregory Price <gourry@gourry.net>, Ying Huang <ying.huang@linux.alibaba.com>,
 Alistair Popple <apopple@nvidia.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Qi Zheng <qi.zheng@linux.dev>, Shakeel Butt <shakeel.butt@linux.dev>,
 Kairui Song <kasong@tencent.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>,
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
 Jeffle Xu <jefflexu@linux.alibaba.com>, Sandeep Dhavale <dhavale@google.com>,
 Hongbo Li <hongbohbli@tencent.com>, Chunhai Guo <guochunhai@vivo.com>,
 linux-erofs@lists.ozlabs.org, linux-fsdevel@vger.kernel.org,
 Steven Rostedt <rostedt@goodmis.org>, Masami Hiramatsu <mhiramat@kernel.org>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Matthew Brost <matthew.brost@intel.com>,
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>,
 Byungchul Park <byungchul@sk.com>, Axel Rasmussen <axelrasmussen@google.com>,
 Yuanchu Xie <yuanchu@google.com>, Wei Xu <weixugc@google.com>,
 linux-trace-kernel@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org,
 Ilya Dryomov <idryomov@gmail.com>, Alex Markuze <amarkuze@redhat.com>,
 Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 Song Liu <song@kernel.org>, Yu Kuai <yukuai@fygo.io>,
 Li Nan <magiclinan@didiglobal.com>, Xiao Ni <xiao@kernel.org>,
 linux-raid@vger.kernel.org, Richard Weinberger <richard@nod.at>,
 Zhihao Cheng <chengzhihao1@huawei.com>, linux-mtd@lists.infradead.org,
 Baoquan He <baoquan.he@linux.dev>,
 Pasha Tatashin <pasha.tatashin@soleen.com>,
 Pratyush Yadav <pratyush@kernel.org>, Jonathan Corbet <corbet@lwn.net>,
 Dave Young <ruirui.yang@linux.dev>, Shuah Khan <skhan@linuxfoundation.org>,
 kexec@lists.infradead.org, linux-doc@vger.kernel.org
Subject: Re: [PATCH v4 00/16] Remove PG_private by using page/folio->private
 checks instead
Date: Tue, 15 Sep 2026 13:16:07 -0400
X-Mailer: MailMate (3.0r7032)
Message-ID: <C87F746D-D3CD-4FB9-A50F-A2835DB750DF@nvidia.com>
In-Reply-To: <20260913203959.6b46b0b5a052aec818a7f267@linux-foundation.org>
References: <20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com>
 <20260913203959.6b46b0b5a052aec818a7f267@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-MS-Reactions: disallow
X-ClientProxiedBy: BN9P220CA0024.NAMP220.PROD.OUTLOOK.COM
 (2603:10b6:408:13e::29) To DS7PR12MB8371.namprd12.prod.outlook.com
 (2603:10b6:8:e9::18)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: DS7PR12MB8371:EE_|PH7PR12MB9102:EE_
X-MS-Office365-Filtering-Correlation-Id: 040b751e-5a2a-4578-d517-08df134d0be6
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|366016|1800799024|23010399003|376014|7416014|10067099003|4143699003|22082099003|18002099003|11063799006|56012099006;
X-Microsoft-Antispam-Message-Info:
	EdmOT4SZggvXel11Uhh1H9mF8pJyToiZ4vo+EaL4dQpqpSiRPlv1r32Dgz69iVxRKeRQA2Ast0fMgp+dtSul+ssZ/kJs2D95hmspE8OQmcfALuUDnDqNeKbNVO83v2iXLX1TgKyRNG512daoHu/3lsvC7YFuT9syyAMKYcc8Cj7sRTVCwf7hiclEtUz9K+WYpQE60SsB9HMKu1aGNd+rOH4FuYpR0yN0pEZ9QMKTScul+Ork7mxnVj5Reie3mU3RZve/Igx+fzCyG74c/PU8IYeO3UC6228cv7SfuZEYjtTK3KsezbygJexMLYcjShKX3igAX2GXZzGSorl7Mi9BPwIm77+Sj1aax9f/Sy8vPMzVa8cLugoy5vYsGLC2OtrPq6Qpg8JuCZ2tbHicv6TteAmWCBgMe4ITXR/1Q2OTVdMrlua3hQfyZvShF0+Lt/pkcoExAwGghOwaNgsKpt68C3YDegf81smiqhANEWkXKOR/pLOE7NVTzz6IGCHYv0NPj0srvj9cGTgi+w88gmqAg0OWELisn+6fTDEmj3nFvk2ZKGneX4EdIAGOAHWtDBQTiEdFxiiQtE+G0uXNbgHPDiyTqEXJ97gGwJGOZSqGQ3tTkLHMw6dlf647AS9ptFS1i40d0Stx1d8ifCCWC48sIvnPF7yU5MgpaGtihLIlJP8=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:DS7PR12MB8371.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(23010399003)(376014)(7416014)(10067099003)(4143699003)(22082099003)(18002099003)(11063799006)(56012099006);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?V3VZVW84WlRLMThCTE10TGpMWXpHUEFQclpFRGgwYjJRQ1luV1BrS0dOcFRZ?=
 =?utf-8?B?a3ZtdnQ1YUNNdXJPSFZyOHY4UHhpRktvOUpXZEVqVVN6c1BoOU95RElsY1Iw?=
 =?utf-8?B?RGpRQXVCZy9Pd01tWDIrdXZnMlB2WEFYRDYvb01QRnViQW9nTmRtYUYvbDM2?=
 =?utf-8?B?dm11N2tIeGVTaFRpMk4xdzlnMFJpUjdoc2lCRlBVK29zdHBFbVNmekhXWHg2?=
 =?utf-8?B?cXRDbi9odVA4cTFWdjFHSURLWDhsamU3NWxtVmNFeUFvc3dNUGsrNHpVWjgy?=
 =?utf-8?B?bVRkWHFQTWdWVGQ4VTRTQTY5MG9reUpLU1RndEg1b0wyNW5aM1NnNVhicmJu?=
 =?utf-8?B?RWVQTytCNmZYSlYzVXkwcm85UDFMSnZrdmRMS2k2QWxIc1dkN2ovd2swNG5E?=
 =?utf-8?B?c01GRVRUcmdCWFhXRHo3UjlyN2Q1K0xLdTdkOFRocUpmMWRFdE5tcU5Tczho?=
 =?utf-8?B?QlNmYXVJd3NFeHliRjlZS3dQUDJYeGpEbk4xUmc5ZTZyb0tRWkVJNElJbHNa?=
 =?utf-8?B?UTZoa1YxWitOOS9lMFZoM0ErZS9ZQ0RjdU9tRHdadVZ6a2h2WVBqNVZudFhX?=
 =?utf-8?B?WEFiZkRsdVpuTStVT0J3bVZRcmt2OVdZa0JMQTY5cm5Yam9ObnVIVG14Tm5m?=
 =?utf-8?B?T05uLzBrQitWWElDdFViR0NiZkhUTExhZzBuV1R0MUVIdEVIY3dKclR0WmpU?=
 =?utf-8?B?SUlYUG1ZNnpMejRZUlVvQTZ2V2tqK0hxSTZFT25kdE5FaFdNZDNsS0dQZXlB?=
 =?utf-8?B?Z0hZeldiNzZDdDhoeWg2OXVUMHI2UWh3dmpmZC81c2hJcmdybHFTbk1PaFh6?=
 =?utf-8?B?elBuMm5LK2Zka0RoUnQraGdMb0hVN0JGUkRsU1RxdVJpWG1OU2VQemU0eTFC?=
 =?utf-8?B?V2pBYWJnSjQ3WlVMMnphQVN1ekQ2RmtuY3NZUWVpcytGSUMwUm5NeFAra2tC?=
 =?utf-8?B?eTcrZG9qVmlLbFM0SnVUdjc1WGIrMGZKVUlhNmg5U0N6ZkZuVzJpbktjSitk?=
 =?utf-8?B?ZWlXU1BKNE1OcDVySWFzcTRmY0pZak1JTWVMak13dzBCRjBuSGMzM3U1WDNM?=
 =?utf-8?B?ZENLQnlPVno1ZUpEMFRmRnh5a1YvMGFQc1E1Q1dTTEZ1QlUxSzI5d2dKM0Np?=
 =?utf-8?B?S3JrcnRpRTVKeDllbVhEK3h2U0Q0OGN1ZUQxOHZGWlcyZ2NFMHA4N0xJM0pm?=
 =?utf-8?B?empNendDUkI3d3J0TXQ2WnJBQm40dEw4dmFpMWNYd09RUXJ6MU9iZjBOOS9S?=
 =?utf-8?B?VHpCQXFVUE9iWXRnVW9ibDdRdDNBTGRncExmNjFBdkdrT3NOdGtDMUs5dzc1?=
 =?utf-8?B?SktIN0dhWXl3cGt3ejl6S2lST1I5KzVpNHlvSFZLaDlQa1NyWHhvS2NoQ1k1?=
 =?utf-8?B?ajVVUzNpcUpPZ0FGdlNSTXk1Y20rNmU5QjNFN1pzT1FuSzBycnhreGJpbmdJ?=
 =?utf-8?B?QVMzbnZ3anExa3J5aVJLK2RGYVFwUEZEUHE0aFJlQlpDYlZ6aWxCd2IreWYz?=
 =?utf-8?B?MnJxOTJsc21naEJjaG8wcWR1U2NJdUg3UERBZEpZbmlTS25TWlhaeExwTU5J?=
 =?utf-8?B?Ti94c2ZEa2VIWTNQS3dpck1zeGhRajlKQnNCSnhRS2Y1Vmo4SmVnd3FUNmcz?=
 =?utf-8?B?d3VZR3VtbFFRbU5JdTkycCtrMTc3SkEyc2tzSWhuYjh3ei9FWllkRUtKcUZj?=
 =?utf-8?B?VkVHRnBpZkprbTB6Q0Y5OWJsUThJcUg4b3hmejhoWkN2ZWFXK1FkM3V2djN4?=
 =?utf-8?B?SDN0bUdvd2h1NWVHZFgraU5leFVVMXR6UGxPVjA1ZzdjRGxycXNqTDQ3MlB6?=
 =?utf-8?B?MVBMWGxyTFF6RTk3SDBySmdvZ2dHRDBKK2lROWF0cGJYZnlteFpwOWIxVEtG?=
 =?utf-8?B?MWEydVdIc2hOLzlxaWQzTzhjck5zajVaSVhpcVU4QmtzV1VZb081Q0lUK2ht?=
 =?utf-8?B?Y0ozMnAzTDFMeWJzWDhwK2QwL1JjNkZONExrY2RFM3VpQkwzRzlYTG94amx4?=
 =?utf-8?B?RXhGZ3R3SzBFeGs1Z2F4dE5FZlh5WXIwQzJYNEw1L2JXU3FCYUQ2MkV4ODNl?=
 =?utf-8?B?cGkyWmxnbHh6R1B3K0krbzgvVHVWbHVwbXZDQzNWKy9TWjVacERyZjRxc0J0?=
 =?utf-8?B?VHBFUW9kNVFhUVZOTWVldlFkVjRQZjNVUjZBam9YM3dBKzViSGFmVEFkOTFs?=
 =?utf-8?B?QmlIZHVFdXcreUdIeWwrT0hma0oxOE1VNjVHeXFMMTJRYXlQUWJ1UStNOFdD?=
 =?utf-8?B?ek1Rd1YzbGxvM1lneHJWaC9UOEcxV0xjS1l5TUJ4V1hmTHM2d0lEUWNWMlMx?=
 =?utf-8?Q?1XlVQwkgpA6kYbW734?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 040b751e-5a2a-4578-d517-08df134d0be6
X-MS-Exchange-CrossTenant-AuthSource: DS7PR12MB8371.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 15 Sep 2026 17:16:14.4277
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: yP9mlXsqTt1fzeF09feTD+wBnvQ4TzeslAIXm2l/hTA0PyUaCtr/LSo5CBpsWAAX
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH7PR12MB9102

On 13 Sep 2026, at 23:39, Andrew Morton wrote:

> On Sun, 13 Sep 2026 22:23:58 -0400 Zi Yan <ziy@nvidia.com> wrote:
>
>> This patchset removes PG_private to make space for upcoming PG_folio for
>> identifying pages from a folio (more details in Note below). Instead of
>> checking PG_private, all code is changed to check page/folio->private !=
=3D
>> NULL instead.
>>
>> MM people are cc'd on all patches and subsystem people are cc'd on the
>> cover letter and corresponding patches.
>>
>> Patch 6 is picked up separately in f2fs tree, but since mm-new does not
>> have it yet, it is sent for MM testing.
>
> AI review claims to have found a pre-existing critical level deadlock
> in f2fs:
>
> 	https://sashiko.dev/#/patchset/20260913-remove-pg_private-v4-0-848550f75=
74e@nvidia.com
>
> it also had a few things to say about this patchset and, as always,
> hugetlb.c.

It seems that Sashiko overwrote my patch reviews with the reviews to
Matthew=E2=80=99s md patches. :/ I wonder if there is a way of recovering t=
hem.

>
>
> Thanks, The MM bits appear adequately reviewed and review of the non-MM
> bits are, as usual:
>
>   Great to have but I won't permit lack of other-than-MM review to
>   block MM improvements.
>
> So I'll queue it all up and shall push it into -next after a few days.
>
> Acks from non-MM maintainers are appreciated.
>
> If a non-MM patch appears in linux-next I'll autodrop the mm.git copy
> of that patch.

Thanks.

Best Regards,
Yan, Zi
