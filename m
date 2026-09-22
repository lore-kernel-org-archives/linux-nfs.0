Received: from DB3PR0202CU003.outbound.protection.outlook.com (mail-northeuropeazon11010021.outbound.protection.outlook.com [52.101.84.21])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCFF823C51D;
	Tue, 22 Sep 2026 00:49:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.84.21
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790038166; cv=fail; b=Ln59C0R/kD+Dql5P19vj9L8aJrhfeTYjilN4WqeGPP8ABsgu/r/JagymJxW18qwgrQeEyUys0w8P59n9VGZIdiJKXqn20bAAm53gxCaG41mhXGPynHGEGeogzIr88AEgeAa6gk6ko8lT8jDF1iJE2DCxN6CUMKbIjbKlAmW5HpM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790038166; c=relaxed/simple;
	bh=SUlxFK9QWZE7hCVBSGFIvrBBEoxUUDGQDoXArA40iTo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:Content-Type:
	 Content-Disposition:In-Reply-To:MIME-Version; b=GYlgmO1sJwWlZ0bc3yRPQ8xBu9cHqgRt/ny/kTBgtTuZvpUkne2EYFloB31nMefyRSRjW5h7OorXtqFr1Gxj8Jzy5Ehr+0ArNjXXfWFqs7b3CNw3Z/z4/LEvPNVPkASZTn/3RXRurmw29CebNcSQuHd5REfm7k2XMqL7wtStpLE=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.nxp.com; spf=pass smtp.mailfrom=oss.nxp.com; dkim=pass (2048-bit key) header.d=NXP1.onmicrosoft.com header.i=@NXP1.onmicrosoft.com header.b=PdeJ3WLD; arc=fail smtp.client-ip=52.101.84.21
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.nxp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.nxp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=NXP1.onmicrosoft.com header.i=@NXP1.onmicrosoft.com header.b="PdeJ3WLD"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=IAh/lEbyYq3heDtJGuHhfyXOweGDwLPlTG78fUgPBOV2J89Jz9zW7Me9a7sR7L/oLPwiUDevpmb8eZVimOGOGI5mn3KzIsGG0FCw3PFs9UDyfbLI9ImHVz6XC1xANZFzodKWcS06dl93Lb6n2p3yKRVZImy1Kc5QJdaH1b/Opd3yAF7uYBMnbYkpBbhIzwyi4a2+kAduk2vE72ASWHGhU+H8YNWX+/gYR09JT586clc63LP/L4CK+8S15ZVxzJsLZrhaJlU8NpzKW7QQ9eJz2K7l6Lo6OP1hSvUHQqkWT4YKQndmcMMDljJYL6Ho1cf3R8+7tJ1aUx5kZgiUZ/Zbsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=0h9x9cwnMNzsuewzisqluTXPGjcfpt983eV+rnZIjYs=;
 b=Shu5VbtT/zKichh/G/TJ2Yr8mXxViz26kDreKNmmYfMqPMpRJGpWJ6DM9kFiwOu5EX+DsQ694FcQnAfL6xQ2fSF1A8pNditvvZ82dAZ87SeNGRzWyLJiyDydmZfF68i6VgX8+s4ic5CrIR6fJH6GRZd7tYT4sH1aFomsYCaearURkq75MCoaohgI7fei7E4yeWNEc+pPAwjXfsTdgD5cWezTPoXLHd8UF9GLM1RT/IA/8SOEW66pxxXipe362iOtStIVCDE1qWiI/z0hNux6MngBLFwcIact3eIxaUyqqfCVY4It5ELw5+XJqfpWmbw6WtMCpUJSY8HP0Uiu0S1Zsw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oss.nxp.com; dmarc=pass action=none header.from=oss.nxp.com;
 dkim=pass header.d=oss.nxp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=NXP1.onmicrosoft.com;
 s=selector1-NXP1-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0h9x9cwnMNzsuewzisqluTXPGjcfpt983eV+rnZIjYs=;
 b=PdeJ3WLDSxNPdrLBwg6rnk27w4kezD7RQlSyrhMj+FR1hs/wmDivzE4/YhxOPaH45Gud0Lsr+NUtMDr5tBaFSC1Wo4sveAJV5Mo2+ehx19qavfjmyYCGxuDRdTDW/Q3vaecWcBDwkcXUbmIItfm+HHtqmVmu/IvzMmsqCAkekCyuOtZYBBcoo3PCEjXf3AWlLkfqkE1IPh8HkkfIWEtwke/1LgFdDceRQkIX4fm3UsSBsHa1QGLriMSyfF8XHHZ56Y9qf1+9r/IBndvHQ970ASnawUwcxq438u0k0ZorjMHDcGsofv51ndnyRYm8sRMb3lbTnQLBfSGlmqISuBv9Uw==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=oss.nxp.com;
Received: from AM8PR04MB7874.eurprd04.prod.outlook.com (2603:10a6:20b:24d::9)
 by AS8PR04MB8198.eurprd04.prod.outlook.com (2603:10a6:20b:3b0::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.428.16; Tue, 22 Sep
 2026 00:49:21 +0000
Received: from AM8PR04MB7874.eurprd04.prod.outlook.com
 ([fe80::ac38:1699:6f18:c5d9]) by AM8PR04MB7874.eurprd04.prod.outlook.com
 ([fe80::ac38:1699:6f18:c5d9%6]) with mapi id 15.21.0428.015; Tue, 22 Sep 2026
 00:49:21 +0000
Date: Tue, 22 Sep 2026 08:53:43 +0800
From: Peng Fan <peng.fan@oss.nxp.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>, linux-kernel@vger.kernel.org,
	Peng Fan <peng.fan@nxp.com>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: use assign_bit() where applicable
Message-ID: <arHRl5JvLVEBoSLk@shlinux89>
References: <20260920022714.3145751-1-peng.fan@oss.nxp.com>
 <7c7d7b6a-38a9-477e-9bcd-1f9c53a160c5@app.fastmail.com>
 <arB/ixTLqjuyrSUr@shlinux89>
 <ddab3a7be440dcd860b254bcd2dc213c1a3cc538.camel@kernel.org>
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddab3a7be440dcd860b254bcd2dc213c1a3cc538.camel@kernel.org>
X-ClientProxiedBy: SI1PR02CA0044.apcprd02.prod.outlook.com
 (2603:1096:4:1f6::6) To AM8PR04MB7874.eurprd04.prod.outlook.com
 (2603:10a6:20b:24d::9)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: AM8PR04MB7874:EE_|AS8PR04MB8198:EE_
X-MS-Office365-Filtering-Correlation-Id: 81c8899c-98f4-4ddf-c927-08df1843572c
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|366016|1800799024|376014|19092799006|7416014|23010399003|11063799006|56012099006|4143699003|10067099003|6133799003|18002099003|22082099003;
X-Microsoft-Antispam-Message-Info:
	xtG7M3quFBDCeNfHo8YYCkQyA4WGs+yUqYRnMAbeENEG0ef75fPHerdK6s0R8OiMIUf2+jfhEhXLEJrJIgR8pVvVU0mNB0rGQDYcAqqF4UcZMKsR/s4ycRwys+3T3fyQNmfDm/FmuCm+4BZA5Pi/GnyRnDxrP3JP3MkyB2y3Zji5vva1egI78lCEi+hrUVgdeq77MoLu1aFhY1mUt8+kzN3uV86lPKJPrZpnzYeSaQ02ZiW6A7FlE9cBvmNiwRHXjkbRGQoZbyGQeM7CHstNMWGuRU9MzNR+MVOC5A8p0xvlcdsR/G3UfCR0AiyJBg8Q5rBW2T1O+GN2bHXDwivAOJTD5rk6uGMLl2lF0ucUh3Z9d5ldc/qboqIFxBL2m2gpXhEZfWQxpuzzWA6rneXmDgKoxIj4l+VOgxie+My6xs65uuznLS8dZOZzrHxqPnFPzIpeO5nmhfZQd3lZrYbMsVyP6EfVkZxcIuYCJOsMuWv027QAQfAYn/PBJDD8i4YVjKM48V+w0ObTihk6lqTU0qepNddXI8oVsDTodLvGcsExrNOEiRBL9rzYb7Hqlecz72MZz+S99oKaej7n/S7C/K0bVJ/xBXLSSrBkBklwOzI=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:AM8PR04MB7874.eurprd04.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(376014)(19092799006)(7416014)(23010399003)(11063799006)(56012099006)(4143699003)(10067099003)(6133799003)(18002099003)(22082099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?vFJgGk6I5/RnUaZFKRiEUIUVBlcQNMiUn0kNo9a/Vc66dlQzmyq2MUxNB7FQ?=
 =?us-ascii?Q?LmI3g7MouNpXaYuue3Hic8Jz7yI8n5a+j82zvRSPmAv8/g50bkJH4c9YGK24?=
 =?us-ascii?Q?UJCptWJ5Sg1DexenOgAyGvUOHgzT28IP0sNvfq4RHTWnl2cPIrm6m5nkcguk?=
 =?us-ascii?Q?QNUjDkbwsdWpqkXSi8KmR2xeCYyAfAxMIB0GNsr/2TsjY99gFhWSRL4dcgZn?=
 =?us-ascii?Q?H6rRNxIgVaJyDP8WP324MoOVwiG0Rk0xuxnWJievDScn/+NW9hRG0GsmnxiD?=
 =?us-ascii?Q?6l3rPLk6ekZnZz6roRxRmj7bb0lBwd7G06p8p93XTvyi0AonQRS/wf10r/3k?=
 =?us-ascii?Q?G9+bqlB8z8vy0cfrbhQsMIU+5bvAEIhDHMwfxIxAQV65b8vgasWQE9RBtx7O?=
 =?us-ascii?Q?VauF3gUCmTDds4QCft7hl0sOpZOfzExOKikKh2z3mOsA2zxbfplFnSosAtLv?=
 =?us-ascii?Q?y60aVoI8yLzwd1Bp3/f1ZzP1IiNw+48rPdN4Oi4HmGGASV1ksufRLwC9GhjA?=
 =?us-ascii?Q?9T9u/0jdN9vBLPPmuP6L5T3cJpCQHF531N2z1NEggXsB9CLEPVzaWFUnofW8?=
 =?us-ascii?Q?SqB8+fKkYs/yOo2dwJPOW5OefiaIcLkeqK0m2UY565UQQv1E5jWI0G7gdHuz?=
 =?us-ascii?Q?F2ln0LB93dqhqvG+31BleXHnDylS+CGCu0m7TzURI/V3zOwVRf+EMPZhCOcR?=
 =?us-ascii?Q?AzVvHlC+PFKbhwJxnCkXceSiFWvp6HzSj/HbRwYhqdCETECaZ17kkP1HZu5J?=
 =?us-ascii?Q?kUbt0G1GSRbuVvjL13T74JTaVGROE/K8IYaeCy85Rb6fSz7VVscbukV6GNhu?=
 =?us-ascii?Q?c6teLv1tODbHkmTGGKcNL9fy9HXXxymjn+WG6Y+5wc+SXbwwyh4S66/UYV37?=
 =?us-ascii?Q?PR86yqsRLn1V7Gvl1Tlaqzbw3ja3Wv+PiF96Kr/22Gpnua/GN/wKHgfyMtG+?=
 =?us-ascii?Q?3/BVOEOa1ht7NPbKN8BkwkqCQiIpoljd73UfdzwIx7txokZlyyp0FS+2/Swr?=
 =?us-ascii?Q?HkD79JRapWmaZbx9QHCB9zMkwKFZEAQbz8auutGLVYfF/Srt2qWwNHL4ehSH?=
 =?us-ascii?Q?arohJWziBzgKcsvqJYWVmduJ+7dgL1sL43nzyjWHoyC10iKU652EzcDRO01y?=
 =?us-ascii?Q?p/UhvpmSLkyvGyJbpXLjRMVhujI1cnF0TfZWS6q3mMhd+pOtvxfHkH0eJVxL?=
 =?us-ascii?Q?5DxLLA80nR5Mt3StahQVFUK+H7I5aEQBt7G2X/g+0ZUsVMRiQfLmuQlk2V8E?=
 =?us-ascii?Q?itOJ9HXlPd5a1hNVtouj/Qv1px9c1n12asMqjRG/1tKGUETNWkGKumE4nqBu?=
 =?us-ascii?Q?yyCpMH2BAN5XQiBw72YXNoYyHt5Xcaj8wrlBEA8KU6M/9F98r0fqWqHiPRpg?=
 =?us-ascii?Q?3vmwoQyyfITPnNeMtjcoh1ldPTOqYQx29BENz5iCCRYczzd5phPMl680SJDQ?=
 =?us-ascii?Q?01NS2FViQnFqYjWJgbz8AeqjL+4c0cp5YUJ2iSEkdiU7qJ8EGoxEsviusMpo?=
 =?us-ascii?Q?5PqhZkHZtSy1ozCYMDZBwIpzmU1YhCKbawOnZv6FmSS7UoLbPD96GuTXpLLR?=
 =?us-ascii?Q?A4m3T4zezlK3Wk3ZYWpCOEAG6iC7uQjm2zTKoPoFx2Juty9SPjR3M9kg23SF?=
 =?us-ascii?Q?NrTF9eRo67vOuvC+a6KeUdVHro15igQ+GOdNmoFAJUq41VwjF99nmSjRRIKJ?=
 =?us-ascii?Q?fs4oNkJ2eRij1E63Z0iBM1z66PIF8YPLm6cGUXdPl9FDOTMFdjo+XSqaXRpw?=
 =?us-ascii?Q?6iexCRAIkC6HPiL/0jQfSSwr1nBqY+qkp6rJL+3LnIr+5ZrQUwkh?=
X-OriginatorOrg: oss.nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 81c8899c-98f4-4ddf-c927-08df1843572c
X-MS-Exchange-CrossTenant-AuthSource: AM8PR04MB7874.eurprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 22 Sep 2026 00:49:21.7227
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: Qehri/j6t/dJvDorqR394NxrsikEE5INv86/4bduG1M0C/Ki5+07NHLAWtBjfrY6dJswzfo8hQGZliVnAh1GnT5XaCN6+IFugTsntnzy3ZKLuDWGGZg73d0hkiQFHAs3
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AS8PR04MB8198

On Mon, Sep 21, 2026 at 09:46:05AM -0400, Jeff Layton wrote:
>On Mon, 2026-09-21 at 08:51 +0800, Peng Fan wrote:
>> On Sun, Sep 20, 2026 at 01:22:00PM -0400, Chuck Lever wrote:
>> > 
>> > 
>> > On Sat, Sep 19, 2026, at 10:27 PM, Peng Fan (OSS) wrote:
>> > > From: Peng Fan <peng.fan@nxp.com>
>> > > 
>> > > Convert open-coded if/else with set_bit/clear_bit the assign_bit API.
>> > 
>> > The above sentence explains the same thing that the diff body shows me,
>> > so it does not add value.
>> > 
>> > But I don't have any context here: why is this being done? Is there some
>> > kind of tree-wide clean-up underway so that a new feature can be added,
>> > or is this patch just a one-off change?
>> 
>> It is just a one-off change. I don't group other patches to use assign_bit()
>> into a large patchset, just separate patches.
>> 
>> Free to drop if it does not make sense to you.
>> 
>> 
>
>I think the problem is that you haven't explained the benefit of using
>assign_bit() here. It's now 2 lines instead of 4, but that doesn't seem
>like a substantive change. Does this create better assembly or
>something? 
>
>Without a clear benefit, this seems like pointless churn.

commit 5259401ef8f4b ("bitops: let the compiler optimize {__,}assign_bit()")
may give some information:
"
    Atomic assign_bit() is less affected due to its nature, but let's
    convert it to a macro as well to keep the code consistent and not
    leave a place for possible suboptimal codegen. Moreover, with certain
    kernel configuration it actually gives some saves (x86):

    do_ip_setsockopt    4154    4099     -55
"

I did not do such build test to compare vmlinux size.

If you need me to do a image comparation w/o this patch, I could setup a build
to see whether there are size reduction for the functions that this patch
touched and update commit log in V2. Or we just drop this patch. Both fine
to me.

Thanks
Peng

>
>> > Including a URL that points to an explainer, or making this patch part
>> > of a series would help orient reviewers.
>> > 
>> > 
>> > > Done with Coccinelle semantic patch:
>> > >     // set_bit -> clear_bit => assign_bit
>> > > 
>> > >     @@
>> > >     expression cond, bit, addr;
>> > >     @@
>> > > 
>> > >     -if (cond)
>> > >     -        set_bit(bit, addr);
>> > >     -else
>> > >     -        clear_bit(bit, addr);
>> > >     +assign_bit(bit, addr, cond);
>> > > 
>> > >     @@
>> > >     expression cond, bit, addr;
>> > >     @@
>> > > 
>> > >     -if (cond)
>> > >     -        clear_bit(bit, addr);
>> > >     -else
>> > >     -        set_bit(bit, addr);
>> > >     +assign_bit(bit, addr, !cond);
>> > > 
>> > > Signed-off-by: Peng Fan <peng.fan@nxp.com>
>> > > ---
>> > >  net/sunrpc/svcsock.c | 18 ++++++------------
>> > >  1 file changed, 6 insertions(+), 12 deletions(-)
>> > > 
>> > > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> > > index ef7ac080fcd3..d7fa0d1de3ef 100644
>> > > --- a/net/sunrpc/svcsock.c
>> > > +++ b/net/sunrpc/svcsock.c
>> > > @@ -352,10 +352,8 @@ static void svc_sock_setbufsize(struct svc_sock 
>> > > *svsk, unsigned int nreqs)
>> > > 
>> > >  static void svc_sock_secure_port(struct svc_rqst *rqstp)
>> > >  {
>> > > -	if (svc_port_is_privileged(svc_addr(rqstp)))
>> > > -		set_bit(RQ_SECURE, &rqstp->rq_flags);
>> > > -	else
>> > > -		clear_bit(RQ_SECURE, &rqstp->rq_flags);
>> > > +	assign_bit(RQ_SECURE, &rqstp->rq_flags,
>> > > +		   svc_port_is_privileged(svc_addr(rqstp)));
>> > >  }
>> > > 
>> > >  /*
>> > > @@ -941,10 +939,8 @@ static struct svc_xprt *svc_tcp_accept(struct 
>> > > svc_xprt *xprt)
>> > >  		slen = offsetof(struct sockaddr, sa_data);
>> > >  	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
>> > > 
>> > > -	if (sock_is_loopback(newsock->sk))
>> > > -		set_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
>> > > -	else
>> > > -		clear_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
>> > > +	assign_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags,
>> > > +		   sock_is_loopback(newsock->sk));
>> > >  	if (serv->sv_stats)
>> > >  		serv->sv_stats->nettcpconn++;
>> > > 
>> > > @@ -1290,10 +1286,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>> > > 
>> > >  	rqstp->rq_xprt_ctxt   = NULL;
>> > >  	rqstp->rq_prot	      = IPPROTO_TCP;
>> > > -	if (test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags))
>> > > -		set_bit(RQ_LOCAL, &rqstp->rq_flags);
>> > > -	else
>> > > -		clear_bit(RQ_LOCAL, &rqstp->rq_flags);
>> > > +	assign_bit(RQ_LOCAL, &rqstp->rq_flags,
>> > > +		   test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags));
>> > > 
>> > >  	/* Completing one message stops ->read_sock with whatever
>> > >  	 * follows still queued, and no path from here re-arms XPT_DATA.
>> > > -- 
>> > > 2.51.0
>> > 
>> > -- 
>> > Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
>> > 
>> > 
>
>-- 
>Jeff Layton <jlayton@kernel.org>
>
>
