Received: from BYAPR05CU005.outbound.protection.outlook.com (mail-westusazon11010027.outbound.protection.outlook.com [52.101.85.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5ACD2F7EE4;
	Fri,  5 Jun 2026 20:00:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.85.27
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780689645; cv=fail; b=NgTiAcrC6wdxgDl85XGxS16zDXkp4qPhcpmCrwMAYf9fZEuSZfABIv+e+iWXu/5hBukwEN4E8p1GOj1M2iP6ksAE1+rjqrdKoKpnvODi2myRVvrTJhu1jvacGNy9f5eY50Vg2Nxbgt6an98GbN2lF9JhhACvqY9NN6oLHtUmXNE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780689645; c=relaxed/simple;
	bh=2klKS93xTFBkF7G2hFYdTaiAj3eDEU2ZRY9kMPiiZ44=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=Kgqin0PZ6gHEzE2g4SddH1dMDv+kQhlKEgShmJpGswylfnl2uPTupU9aN3AtuNyu51oHLDag3oA/PvEodDtyqH9W6zzqzI1w4ugWB4o8hp+LcMr6wwNgED5z2NOrDENqeN0ID4qLSMIslZqUVcxmwxfp13kHJmPhjuYpJvZYoaA=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=DD2z4jsy; arc=fail smtp.client-ip=52.101.85.27
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="DD2z4jsy"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=zQTB0SklLi/WOLoSCk+Cl4D/BD910D2s/K4kCnvi4AkOXlXGuFThUKS94olBmMcgAzzeis+WzBal8EdRuRJ92qkTLgPQ9ceCHuQMEJWHoaWfOJt+RzzL+7tIQz74jkAAygYS45GFZToctUskq0DgIF29uPVoCsJKgdSgc6+7mQaT5Iyubh/0Di/Pv0AMxZK6m59dDt0xLTS95bGBNZdbQ55PNK8e7WLZKSG842LSEiFQu/K3fEIUXk5RLXJrkAYLdykyu8leJ9QSsvjGOwp0r4dATTvPEztTTFhwvoWDFH1T8nZrCAOQOzP/elnkerdYxPoHd68ZtKalJoYUlZ9lSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=X+M2yMvkz4zRFeGB1xh/r0CkQMDOS6FpMdhqPYWHxZE=;
 b=kDw8+RENro+krsySv1m1yJEKIN79jVIIO7y+zJpQzvIl0WEuvn7R+/QUGCxcul5kTKp85rRHGOGtQtXKO/wENaU5lYdsVXzm6DR/ta4owsHZqNciVDKzxxattmv8aR0FYNEwTmTw0F6Sr0crZ45L/+B8Br8OOLrCazr5t2sHJuI/HwZ+Vz/tKpBXOjDPaHiwPgzMtokg3MaY+dI+agDYCcQFDtsHMeA5dq9/07o3MysdhPIbVVo7dcIOxVnUYmjL2xqxx4qG8gjiuqzBywveXIK2YY+38Mecihnp+hpTqIWsZrY/wwQf6ug8Aenz9F0wWlyk1AlQ6efsReNCkavYGQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=X+M2yMvkz4zRFeGB1xh/r0CkQMDOS6FpMdhqPYWHxZE=;
 b=DD2z4jsya3BpIoNMyFO5fTh+iaFIA67TtMc5P/Xthcx21KDGdDzbXcIs2MwjX2PiTmqAhsVyMEfz2XiJKtjnsGQeXElmFM95FMj8NExu1z2NeWK5UIUdnTRdTjCGJsVi94+Jj19YmVGfYV9ljHfIGBTIJk/yVNspdlU30/YIrJoQrSQDdePHyBPhTQYTUfUXUhpY+ljs4bGpnmqxPwYjdi/RJuE8+dJj2vSnGvUFXvyCmkRKQWKnVJ+fa44aqn2QyxK/4BfiXJmWPhVsvyB+HRo883bDCn5MgWIhDI0K77NvCjCQok7eKO7/h0qB4NK3wG4xPSZKG6HcRTjxvlNH5g==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from DS7PR12MB9473.namprd12.prod.outlook.com (2603:10b6:8:252::5) by
 PH7PR12MB5760.namprd12.prod.outlook.com (2603:10b6:510:1d3::20) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.92.7; Fri, 5 Jun 2026
 20:00:39 +0000
Received: from DS7PR12MB9473.namprd12.prod.outlook.com
 ([fe80::f01d:73d2:2dda:c7b2]) by DS7PR12MB9473.namprd12.prod.outlook.com
 ([fe80::f01d:73d2:2dda:c7b2%5]) with mapi id 15.21.0092.007; Fri, 5 Jun 2026
 20:00:39 +0000
From: Zi Yan <ziy@nvidia.com>
To: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Cc: Jan Kara <jack@suse.com>, Mark Fasheh <mark@fasheh.com>,
 Joel Becker <jlbec@evilplan.org>, Joseph Qi <joseph.qi@linux.alibaba.com>,
 Ryusuke Konishi <konishi.ryusuke@gmail.com>,
 Viacheslav Dubeyko <slava@dubeyko.com>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>, Chuck Lever <chuck.lever@oracle.com>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
 Dave Kleikamp <shaggy@kernel.org>, "Theodore Ts'o" <tytso@mit.edu>,
 Miklos Szeredi <miklos@szeredi.hu>, Andreas Hindborg <a.hindborg@kernel.org>,
 Breno Leitao <leitao@debian.org>, Kees Cook <kees@kernel.org>,
 "Tigran A. Aivazian" <aivazian.tigran@gmail.com>,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org,
 linux-nfs@vger.kernel.org, jfs-discussion@lists.sourceforge.net,
 linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 00/17] replace __get_free_pages() call with kmalloc()
Date: Fri, 05 Jun 2026 16:00:33 -0400
X-Mailer: MailMate (2.0r6290)
Message-ID: <3FD8E1FD-6E18-46D9-AE93-00FA1A66C775@nvidia.com>
In-Reply-To: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
X-ClientProxiedBy: BY3PR03CA0007.namprd03.prod.outlook.com
 (2603:10b6:a03:39a::12) To DS7PR12MB9473.namprd12.prod.outlook.com
 (2603:10b6:8:252::5)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: DS7PR12MB9473:EE_|PH7PR12MB5760:EE_
X-MS-Office365-Filtering-Correlation-Id: e1f642a8-14d1-4c68-c651-08dec33d1de8
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|7416014|366016|376014|18002099003|11063799006|22082099003|56012099006;
X-Microsoft-Antispam-Message-Info:
	Ixoveqn+yAQ2eRyV6ifOvSrOBaXYJL+YtioS6rxReZqeStemeHMPyo7pO+iDdrQlgygJbIIg5jt/DEGqupARKlhsmST5vrXfMsrE4jakpczCL/qxQFf5urWhqRVm/iaom/cJsP2v9aoguoU1/wUNSfT9TaaL2LM1Wm/kI7p1sgMoqJ+9J2dGMe3iuZH7V664pv1XzQQNDF1W087661YJy+JjrnSdd45LR2bV1fnN/Pil3xMEWtEXVMhCXgjuLF+14uYN3gyHnqZvje5mvLddcWcFacMMGHLYN/qG6/Z1+425WxUoy2tJEftp3EHL7tSNY1Dd+gRcY7ABekOlvXEZCEvgjk2+yblj6tIJ3DTXpwv8OeuJp/SFCI3SLZDw8j9SaruK78lfZQZWYR+nrc0mm5/4dwOpdJaEVq688ImGu2pc8LGimmCV16MgHL0QJjn4k9aQXUmDeQIs1ubcjvrHBNo8zI2sZ9cLlK76c8bVyrVeTKMpqdO1KuEkzMn6eosWR23tczdYo88ea5VCEV5yyO1wGmHhnOJUQaiR1/Yk/VCDokCIIhEpORYXj+T5bA9/ovoSFqpKVXg8jZpmbkADn+wenZqe/jKYtooQxRZDOJie/k5hmVPf75m44ZGxZ4/eFXqQSZn141ZZ39kXDEZshuizuNZLRoH+IMSCdGcWM40ho8Uvq1YsVaJ9m2CPfcsyz7RXS9S/XhA2h1yDR/N0zg==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:DS7PR12MB9473.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(7416014)(366016)(376014)(18002099003)(11063799006)(22082099003)(56012099006);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?w5C050b6NMHjP88KaETUbDECBm+ShWeYRo6dToP/6yhKHQULJ+qah0sHB5jK?=
 =?us-ascii?Q?4iZNeddA8JLBQd7FLY/1PSLq4q0JZ03HpX0n+M0A7c85H4NzBjZNgvEPLsKf?=
 =?us-ascii?Q?11Q7urTDObwfVxERitOHUvbiFtGGBBlj65Fgw+ALA61lJHwH/SVb8PEE4F44?=
 =?us-ascii?Q?SDzBfISRMEWAhAhauE8DgMH+p/xi4JM2yzblJUMAxhys24dDlw5MU0h4EWI5?=
 =?us-ascii?Q?D94fhcTggHXHVT8kF8l/yl8AaU78V8JYGRczLn5M6cpH40eLSnKPw5ngoyGJ?=
 =?us-ascii?Q?7QnTo51eh25H5H19+w3w41JwqmkZ/1ANDFZpOX+iH5jrLOwgJPDQVktlwALJ?=
 =?us-ascii?Q?xkgzoJAE90ywm+l47OoCNlUuN1oOoEgN74hSZGj2YdUgv4b5TKY2e176tCNy?=
 =?us-ascii?Q?I+PAO+JK+g+uN5gKri7KNRNEgX+wGshRGutJxM94LdYiOe8mBWGjvXSCKgBd?=
 =?us-ascii?Q?OhL+mPAjLvszXXW2CyBaQO+5EkAHGWh7xyMiUks/XaNegLoheS6+YtGeU42n?=
 =?us-ascii?Q?a/9hwkcDVBmvlSYHNAI61DRRywhCQOvnAzCS2KIzp06oDHPQqmhQKtQByEkH?=
 =?us-ascii?Q?v+sz9oN7UJinvEur/22hK9otPhpC/rUHsOnueU/1Wdv146BNWmM7gUikNyex?=
 =?us-ascii?Q?UKtAMB+Xnk4yNtA6sGq22j1Bais6FPuoEhA5qIla412xbTwcXwKLEg86nhlv?=
 =?us-ascii?Q?Fe0dGhTpcPOr7NMzsMIaDdmTgQAPitFJgy8QvUzlhEA71UwmmPJo/sShtMJW?=
 =?us-ascii?Q?LkTcNMh4qj7ovOj60Xwuvn3kJ2q6J+hsnocYoDUeH5GE6cAh7wcKllghptOf?=
 =?us-ascii?Q?IV3+dlZdDOboNHpBfTR4o5c5BYsbjlm6JkHoc9iuCLDXsAw0IvjjQJQUDoXj?=
 =?us-ascii?Q?BwyK/M3YoxhT0QlP2tRnLYtLc/HZvsklo1alK0HxhkroZYZ8D2mA7mkRd+mj?=
 =?us-ascii?Q?wnQPxtACQiP2OQ9V+wrEu2i5e9Cj9wDLP8/pinkK30/Dh1qAlF2ftnlWmGU6?=
 =?us-ascii?Q?CThUCsJlVVoF669SOZnx7HlQvhuZrFHHw96yZzeecwo4V8Ov0HrghAuOx41R?=
 =?us-ascii?Q?468srmOTp3P75zAGCnwJWV3+nESKLb2VBnZkaODRxHK1+gcYWCzP1cA8dxsL?=
 =?us-ascii?Q?63KRlNIlL4HcEP6ToDhFoWL24KmBLSZ2rtgeYUbKrZMfjqv8qCMjfUKFtWom?=
 =?us-ascii?Q?geeUUTkjJlKIomtALrVZ1wMfcCJulaM6IjH5B2N6DhYzwyC19v4ovtQnp8Jo?=
 =?us-ascii?Q?sWOmBBD/BhEi94MPAE4sJoUvGHDJ0pCOAUqOf7a5p3LZVh+jnqqFRmXDHUzR?=
 =?us-ascii?Q?vYy8/1dER2+4eqyuthQp/9DTq5MAu7aXbERIa7SchxJLpAlln/Afts3Us9qt?=
 =?us-ascii?Q?r+ruCDP2mkCFmNhcWakPDAyepVfVNwDi4rKiCCyHlV5DE+4fjsGNcQFdi1vD?=
 =?us-ascii?Q?kQ+EL77Y5JDA57X8kd4TSt7/SspPk1ow4PythomXayeoMHtQa7Jgx+OTITJu?=
 =?us-ascii?Q?//g1TLPp5KlVsfkEarZRNb8e0eivgvkOKSnjY+I9X3dm/PxApH+BCJFut28N?=
 =?us-ascii?Q?BuPPF5Ot0Ko7/gJ3BPCtsnLVCPOkUbzWYp68CEcDhL89uel97Kw0YLku8fcN?=
 =?us-ascii?Q?ACwX/7iMVNMt05Nsz4nn4bOFZ5S5ZP0A9QWSW1VTSGJSa+Ab+E3WHIN/Qp7i?=
 =?us-ascii?Q?zMBcfn014oayzteFEXf3RFO6lP2Q2UMke6QYg4NbxwMvO5dQ?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e1f642a8-14d1-4c68-c651-08dec33d1de8
X-MS-Exchange-CrossTenant-AuthSource: DS7PR12MB9473.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 05 Jun 2026 20:00:39.6543
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: oSheHpPghBqB5eDG3xHA2UkgkSSWKnyI/WSGz/s7BUcddnFxK+E9Qx7ObiJjnaFn
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH7PR12MB5760

On 23 May 2026, at 13:54, Mike Rapoport (Microsoft) wrote:

> This is a (small) part of larger work of replacing page allocator calls=

> with kmalloc.

Is the goal to get rid of __get_free_page(s)()?

Thanks.

>
> Also in git:
> https://git.kernel.org/pub/scm/linux/kernel/git/rppt/linux.git gfp-to-k=
malloc/fs
>
> Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
> ---
> Mike Rapoport (Microsoft) (17):
>       quota: allocate dquot_hash with kmalloc()
>       proc: replace __get_free_page() with kmalloc()
>       ocfs2/dlm: replace __get_free_page() with kmalloc()
>       nilfs2: replace get_zeroed_page() with kzalloc()
>       NFS: replace __get_free_page() with kmalloc() in nfs_show_devname=
()
>       NFS: remove unused page and page2 in nfs4_replace_transport()
>       NFSD: replace __get_free_page() with kmalloc() in nfsd_buffered_r=
eaddir()
>       libfs: simple_transaction_get(): replace get_zeroed_page() with k=
zalloc()
>       jfs: replace __get_free_page() with kmalloc()
>       jbd2: replace __get_free_pages() with kmalloc()
>       isofs: replace __get_free_page() with kmalloc()
>       fuse: replace __get_free_page() with kmalloc()
>       fs/select: replace __get_free_page() with kmalloc()
>       fs/namespace: use __getname() to allocate mntpath buffer
>       configfs: replace __get_free_pages() with kzalloc()
>       binfmt_misc: replace __get_free_page() with kmalloc()
>       bfs: replace get_zeroed_page() with kzalloc()
>
>  fs/bfs/inode.c             |  4 ++--
>  fs/binfmt_misc.c           |  4 ++--
>  fs/configfs/file.c         |  7 +++----
>  fs/fuse/ioctl.c            |  5 +++--
>  fs/isofs/dir.c             |  5 +++--
>  fs/jbd2/journal.c          |  7 ++-----
>  fs/jfs/jfs_dtree.c         | 16 ++++++++--------
>  fs/libfs.c                 |  6 +++---
>  fs/namespace.c             |  4 ++--
>  fs/nfs/nfs4namespace.c     | 15 +--------------
>  fs/nfs/super.c             |  4 ++--
>  fs/nfsd/vfs.c              |  4 ++--
>  fs/nilfs2/ioctl.c          |  4 ++--
>  fs/ocfs2/dlm/dlmdebug.c    | 24 +++++++++---------------
>  fs/ocfs2/dlm/dlmdomain.c   |  8 +++++---
>  fs/ocfs2/dlm/dlmmaster.c   |  5 ++---
>  fs/ocfs2/dlm/dlmrecovery.c |  4 ++--
>  fs/proc/base.c             | 16 ++++++++--------
>  fs/quota/dquot.c           | 11 +++++------
>  fs/select.c                |  4 ++--
>  20 files changed, 68 insertions(+), 89 deletions(-)
> ---
> base-commit: 5d6919055dec134de3c40167a490f33c74c12581
> change-id: 20260522-b4-fs-5e5c70f31664
>
> Best regards,
> --
> Sincerely yours,
> Mike.


Best Regards,
Yan, Zi
