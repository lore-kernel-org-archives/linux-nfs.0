Received: from DU2PR03CU002.outbound.protection.outlook.com (mail-northeuropeazon11011064.outbound.protection.outlook.com [52.101.65.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67B071B87C0;
	Mon, 21 Sep 2026 00:47:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.65.64
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789951627; cv=fail; b=IkDfqLxff9Z84mQup6iM+HEPYe6sNt1Dk7W2unXejkUtwHIFPASeJol1H6Hagy1wBkMvk7QGulkYxionL4zJOuOt8gLywK2XEDM22Zh0wFUeCNOe7FhFauBF5nX6ykm/xQzcqQP7/MjuOoL5zl9CyeqIGW4iby/+/qM4JWgD8ug=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789951627; c=relaxed/simple;
	bh=TdXbxqzX5+PwID6ZqJRY4g2Yu2NcpxWD/9lNylNw9Sk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:Content-Type:
	 Content-Disposition:In-Reply-To:MIME-Version; b=evBvVbZjyHVIJLNGMoak3pPDgLyQTgYGwrGqnVQ1MHCffOCmvxt6zwUPUmbKhBKbM/31rEJDDKe0rmx3pALKu0KJJPDwpLIBx1kEuHcUG/w7Ck9+cpmH0RHmSZXeOTC2ntS9z0yhe5b1dz6kmrWhVP2qIf+xDNpJf0Oj8xIx7Jw=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.nxp.com; spf=pass smtp.mailfrom=oss.nxp.com; dkim=pass (2048-bit key) header.d=NXP1.onmicrosoft.com header.i=@NXP1.onmicrosoft.com header.b=rQ9e/Qp0; arc=fail smtp.client-ip=52.101.65.64
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.nxp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.nxp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=NXP1.onmicrosoft.com header.i=@NXP1.onmicrosoft.com header.b="rQ9e/Qp0"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=U06YkODNOK6jE9DUYiLl7jnsMnXclCYgILegHNgkVFkhXwoErbq0ePTCuKyteA1jRvtfSerHVwIV1rbIdrOixDChqRt1gmB2avTURo3LcCIJ5/3PMKYs278V55V8hRQO4YxAyH9wZbQ67fpQLD4qTcpEUqQnO85fcLHJ5armTKGCjyDqc0F0v7o2hLWhmmFU1kd8XnA9fJ8rrBHvb+hyK4NMbpxp38YVsVmlMJyKBZUl7Y5BUYGrDAGJ8ENC/I2eq3N4d2ide4GvmnMjL7aJUtbhV/91PU64IsXFy0fYW3ErqduD1aZtY/jS1fOHMO0hAwkjtnSpXdzLbROSblKoNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=cu42hVvq820UJfC1013KjU3VDv8hM7OEetdxo4ucpbQ=;
 b=XZIt5/ijMpmp1SAH/iU9idKUVgkUsJ1JfpFsRxjl7dSOLcojwvKCnGEgFI1eDWwo3GaRPuZDy9DXJJSV6UjIXtGUSJ2Hi3hsZHzVBCfg6Vzl62SDRJ9Du1Gqne7KtUJrOd/rRMs/AFyGof3E4RTT6wKsKqI/tjftVY75ABhARGsaJu81ca8h67fGVKR/aixbWDkNIhwpfpGKr0WT6tYeEBTvmRzBCLg9YmkTipqlgeqL8aumAqVJ0N8Emci9KpEtU6A+CzVx8xKF5Yngx99qAl3g3/i0IM0VLJlpvgwsY8yhZ6v7w3e4GMnp04abGVbBpGTUDIfR5Vnal7hl3MED7A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oss.nxp.com; dmarc=pass action=none header.from=oss.nxp.com;
 dkim=pass header.d=oss.nxp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=NXP1.onmicrosoft.com;
 s=selector1-NXP1-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cu42hVvq820UJfC1013KjU3VDv8hM7OEetdxo4ucpbQ=;
 b=rQ9e/Qp0Jay8ZAwUEn1WmHiRWFEscf60pwBMZ5IPSulpdnN6yDPCkyUHsHG/bIS9RI7dqgYR783o2pqfLsIhwKzNoQJ+kLcUr0ogbDndWLjmon4XKdNBuqxi8GnI0T7moGpc0QE9x/HHnIfnJP+/5SSpCzuYr4qDVbClTcV3HcqWHuXMfM0ictAp+BMIoqJPptRWB+gO6nXHoyAkTmG6FMw922lcMgheY5VcebkRUXOdB0aUWV/takUDns2h1xHEhJCkmJGakGKuZyk1W6TXbNHsQNDwoM+yrBO7k9mUQpHMFOgV0LmsMlyaJPTjnrJ+u3xzdNpIA/UlM7qvuPuhzQ==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=oss.nxp.com;
Received: from AM8PR04MB7874.eurprd04.prod.outlook.com (2603:10a6:20b:24d::9)
 by AS5PR04MB9770.eurprd04.prod.outlook.com (2603:10a6:20b:654::5) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.428.16; Mon, 21 Sep
 2026 00:47:03 +0000
Received: from AM8PR04MB7874.eurprd04.prod.outlook.com
 ([fe80::ac38:1699:6f18:c5d9]) by AM8PR04MB7874.eurprd04.prod.outlook.com
 ([fe80::ac38:1699:6f18:c5d9%6]) with mapi id 15.21.0428.015; Mon, 21 Sep 2026
 00:47:03 +0000
Date: Mon, 21 Sep 2026 08:51:23 +0800
From: Peng Fan <peng.fan@oss.nxp.com>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
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
Message-ID: <arB/ixTLqjuyrSUr@shlinux89>
References: <20260920022714.3145751-1-peng.fan@oss.nxp.com>
 <7c7d7b6a-38a9-477e-9bcd-1f9c53a160c5@app.fastmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c7d7b6a-38a9-477e-9bcd-1f9c53a160c5@app.fastmail.com>
X-ClientProxiedBy: MA5P287CA0083.INDP287.PROD.OUTLOOK.COM
 (2603:1096:a01:1d8::15) To AM8PR04MB7874.eurprd04.prod.outlook.com
 (2603:10a6:20b:24d::9)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: AM8PR04MB7874:EE_|AS5PR04MB9770:EE_
X-MS-Office365-Filtering-Correlation-Id: 993ceba7-058a-4e61-77c2-08df1779da34
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|376014|7416014|1800799024|366016|19092799006|10067099003|18002099003|22082099003|56012099006|4143699003|11063799006;
X-Microsoft-Antispam-Message-Info:
	twcB0SdGVWVZa6K6vvdlXZKDoOMRsaqymalMrx3RqEs84rUL01DSbyFuX7DGFOa2W26QvFPX0TxlSeflMLx5JzgjupDv5aOFop2bnsx15253GnANHWPJARAUoqLopP2uOuVtq7NFJlIcsUH498idgpvgjA14HrGpQ3om+U81UDKRjeMZ67e09w+NCb314wqsFXNs/pEhSXgWJFT7hC5Si5rLc5UvbeLst7pBrKZ05VQ41CS6AJnvESqhLUmkKw4GukfxovdqdU4Pl8+Bfu6oH4at5Zvw13Gc8oOMsRoOfQBGCrtKp5nLv/c3jsPOhwIVZcVKIuUto5qOTYbFQmfZLLMTPmg5wje8hhrEYW8SJTn73ACh7iA7JFcHVBgVq3pGGQqpqw2Ua7X4i1IHoCziAr5WhPVQj5ZhdiTTI+cp6nVXw2CEOWf5ruLYY+s/EzI5ygcMjWbn0W+qaiYu9kzMq/d6GpI9zYo0nXPKKtfYpWbBk679HWZpkWwDmM0P8lL8nrMatgwVoqzFFguf5YICiRUI52XIdSCJO+FZaN8e7iRu+jM6nHYpMJkApsPiBAdSGb/NUN7v0OUmkb0U0XZeMeG0LpDMq4pfxH6ySbUECt4=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:AM8PR04MB7874.eurprd04.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(376014)(7416014)(1800799024)(366016)(19092799006)(10067099003)(18002099003)(22082099003)(56012099006)(4143699003)(11063799006);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?2K0j9Q6z8PrYqKisjt21iZxU33Dftt13jheNLTcdwdAh4S1LiRxuBbFQW39r?=
 =?us-ascii?Q?fQkj2UOe4zmhM2gKou11jZhH+/xfAZKYpqrDZF+ndY9oWb6kPRJ53m9iAz8d?=
 =?us-ascii?Q?2Bhp6lqks85s3NlX7e8X68DFxuFz8rZsHNgjPeV9z0mWrUxql578cGDjzX7q?=
 =?us-ascii?Q?ty8qgN7bXu61aJXLaKF5sKncD63tI+84HxUjHfBZ4/Zussw1HzApw4k0Vee2?=
 =?us-ascii?Q?xxbLRtBKTGLJBXu60PwYntI5lP/rLaA6+sBGCEpxtSKhJXpx6vX78f8dIkuS?=
 =?us-ascii?Q?YDK4xN+Ri8rseR/mYHNvFdaLLViAvy8EmmKePZ3T5y0/y0pzRzFr5pVekYKr?=
 =?us-ascii?Q?IXmEI75kiE06wNAlN+yBnN+oGkGwzGBTsGgwAMZT+jWETzYXC/fzW0U0kmwX?=
 =?us-ascii?Q?CSQuMqxJmiDVujPMSFszhHV56SGvTqvfM1IkWM/3518TlgXpfGjBAgxFk4M5?=
 =?us-ascii?Q?y2Gn/9GS2VBPgB390Qjc0aE1+FTOw9SfyJOnS/c/yisP1tqyurIJRIte+Zco?=
 =?us-ascii?Q?/f1koXLIeGrnr7EKksCkFQoM5PHoECe60p8to2NuTO0Fo37vThXLqkmDbLzm?=
 =?us-ascii?Q?osEB/xCiEYXfA1AEP5I+lF2Pzy6ibSDHb+UgNHG1srOKy/gLChQJ3P5nZSma?=
 =?us-ascii?Q?EalOP8XgfYAFUl/oUCr8zxR6PCrrDbRHcIfqbF6mnXJUgL9N6xK/MmaVUequ?=
 =?us-ascii?Q?e55MoRovtupy8CFokIgycazr9z5TRgKnsq9RNMHjHiskaN+HUz50U4kRxhXv?=
 =?us-ascii?Q?C01Vef7jJn541AzrK8Pi4cuQaL1Pi7eYopWcoxoV4XZDtOCsj+arEB4grKg/?=
 =?us-ascii?Q?7CjmbuxOf9x9cJUdJINmwxEXi8FnrWBpHe1ggxFZWYCmqEqMDwdu1ofpBa/4?=
 =?us-ascii?Q?A1ZA+W0Hj3D6/tXynqevYKE4PeLIdaYYAvLvw0BqT70buasyctFIQ+KuqIkB?=
 =?us-ascii?Q?6YaYxy18LZ+q9vI0D6eq8tYEfSuy8T4Odbn4zhti0B2eHo/QZnkbzp+HFrG6?=
 =?us-ascii?Q?g8GzjHhVIE92EpJg75Sq+it9rKH3P3NngfjZs6YC+tda9qHKi9kIO1RTVmtJ?=
 =?us-ascii?Q?+7Svnim8TGKqjeQmMaSedlMyAzw2e43LaLJOSbgu36I0BPymq2WdeiiklCZj?=
 =?us-ascii?Q?fhJWGl2qFgsqnEiG76N6VEX35fFjXb7OGt5CQ+Zpyu4YPALeMTqoHyi6OLGM?=
 =?us-ascii?Q?WUpY+NySShZnv3s6rb1AiMJMFzf7qwALpllEmmZK5yH+D4OZTxIfx6m//7Y9?=
 =?us-ascii?Q?QBBh0HTIW6hNSbnwRweOq1TKdzPLNjMHB6cJRBh4cFskAaFZPddux4DdsTFO?=
 =?us-ascii?Q?x7Wj+YRBVUbyvfaO6juS3IkUW7rt8IsvqoTaloEZ2li3Gf82Nxs9+e/efhwG?=
 =?us-ascii?Q?9Vwi6/HH7ucSb6zON2ISjS9PILfkydBP7f2prrmVSL6kDGUtEKP39pGWhJBI?=
 =?us-ascii?Q?s6oywZVxNQWU1wAcVO34AuQ+EW0FMo3tBS+82n2S1c7Xu84YBErLzNtT9xRy?=
 =?us-ascii?Q?Ravb11HUQSmx1rbYOP9AHUXOHqdOyZ4Iclu6u6SBC4g+/IAPMCioxLS3VDTZ?=
 =?us-ascii?Q?2v/2pRXxvAn5Pxcvw6jw0r1Ma7K7zF0bPf+DelXjuMhcCxhtaOrZnLf3iII6?=
 =?us-ascii?Q?1FcknBpzra8Oi2FpdzUUV4QQIiGwtPoHcADEsEKzNjElC5MLRVavKwmGKCve?=
 =?us-ascii?Q?mJ5YrwazpFHyxt40Lfmk/BZu7hdlTOILnONPesLz9V7CPXj4YBA7BT1zRwmb?=
 =?us-ascii?Q?1VHGLF2fnpdsEyNxmip9R7eDaqgWYSQ0eAs8MG1TgcJJMwW5Yv8e?=
X-OriginatorOrg: oss.nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 993ceba7-058a-4e61-77c2-08df1779da34
X-MS-Exchange-CrossTenant-AuthSource: AM8PR04MB7874.eurprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 21 Sep 2026 00:47:03.1319
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: nvNGlL1FUyJ0pcFHiz7A3TfVFa4tzcs2Wse7SOJkDyvr9kMTLFzZ6srqKFYDRMylCsFifKplIPD3nitY/B881eLCKtfSPB/iqX/Bk5SF6LzNpnuyfZQ5NXJy9OHOabwA
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AS5PR04MB9770

On Sun, Sep 20, 2026 at 01:22:00PM -0400, Chuck Lever wrote:
>
>
>On Sat, Sep 19, 2026, at 10:27 PM, Peng Fan (OSS) wrote:
>> From: Peng Fan <peng.fan@nxp.com>
>>
>> Convert open-coded if/else with set_bit/clear_bit the assign_bit API.
>
>The above sentence explains the same thing that the diff body shows me,
>so it does not add value.
>
>But I don't have any context here: why is this being done? Is there some
>kind of tree-wide clean-up underway so that a new feature can be added,
>or is this patch just a one-off change?

It is just a one-off change. I don't group other patches to use assign_bit()
into a large patchset, just separate patches.

Free to drop if it does not make sense to you.

Thanks,
Peng

>
>Including a URL that points to an explainer, or making this patch part
>of a series would help orient reviewers.
>
>
>> Done with Coccinelle semantic patch:
>>     // set_bit -> clear_bit => assign_bit
>>
>>     @@
>>     expression cond, bit, addr;
>>     @@
>>
>>     -if (cond)
>>     -        set_bit(bit, addr);
>>     -else
>>     -        clear_bit(bit, addr);
>>     +assign_bit(bit, addr, cond);
>>
>>     @@
>>     expression cond, bit, addr;
>>     @@
>>
>>     -if (cond)
>>     -        clear_bit(bit, addr);
>>     -else
>>     -        set_bit(bit, addr);
>>     +assign_bit(bit, addr, !cond);
>>
>> Signed-off-by: Peng Fan <peng.fan@nxp.com>
>> ---
>>  net/sunrpc/svcsock.c | 18 ++++++------------
>>  1 file changed, 6 insertions(+), 12 deletions(-)
>>
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index ef7ac080fcd3..d7fa0d1de3ef 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -352,10 +352,8 @@ static void svc_sock_setbufsize(struct svc_sock 
>> *svsk, unsigned int nreqs)
>> 
>>  static void svc_sock_secure_port(struct svc_rqst *rqstp)
>>  {
>> -	if (svc_port_is_privileged(svc_addr(rqstp)))
>> -		set_bit(RQ_SECURE, &rqstp->rq_flags);
>> -	else
>> -		clear_bit(RQ_SECURE, &rqstp->rq_flags);
>> +	assign_bit(RQ_SECURE, &rqstp->rq_flags,
>> +		   svc_port_is_privileged(svc_addr(rqstp)));
>>  }
>> 
>>  /*
>> @@ -941,10 +939,8 @@ static struct svc_xprt *svc_tcp_accept(struct 
>> svc_xprt *xprt)
>>  		slen = offsetof(struct sockaddr, sa_data);
>>  	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
>> 
>> -	if (sock_is_loopback(newsock->sk))
>> -		set_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
>> -	else
>> -		clear_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
>> +	assign_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags,
>> +		   sock_is_loopback(newsock->sk));
>>  	if (serv->sv_stats)
>>  		serv->sv_stats->nettcpconn++;
>> 
>> @@ -1290,10 +1286,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>> 
>>  	rqstp->rq_xprt_ctxt   = NULL;
>>  	rqstp->rq_prot	      = IPPROTO_TCP;
>> -	if (test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags))
>> -		set_bit(RQ_LOCAL, &rqstp->rq_flags);
>> -	else
>> -		clear_bit(RQ_LOCAL, &rqstp->rq_flags);
>> +	assign_bit(RQ_LOCAL, &rqstp->rq_flags,
>> +		   test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags));
>> 
>>  	/* Completing one message stops ->read_sock with whatever
>>  	 * follows still queued, and no path from here re-arms XPT_DATA.
>> -- 
>> 2.51.0
>
>-- 
>Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
>
>
