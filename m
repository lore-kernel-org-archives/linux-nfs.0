Received: from AM0PR02CU008.outbound.protection.outlook.com (mail-westeuropeazon11013036.outbound.protection.outlook.com [52.101.72.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B1393B71CF;
	Sun, 20 Sep 2026 02:29:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.72.36
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789871404; cv=fail; b=PyxBZnlGJ4ArM0OLmGDdgi4/uJNyjob04p1Wd29IKSdtAba8RrJjOSULLYUO/N08ecZgE9JeUapxxlo/52o4MmzQfOkBzcrrS392HSe+HkNFNX6QjmoQF61jgTlvLKyY3Y9ggR458uyDCONRiy2QJXKjGtfXQ9nzczU9PPC1uS8=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789871404; c=relaxed/simple;
	bh=zb4YhiyRtY2pXif0FgHVOFtLifgFYdZBy/mFTFnUXUA=;
	h=From:To:Cc:Subject:Date:Message-ID:Content-Type:MIME-Version; b=TmgXR3PkKuec5Z0L3LnuSpjCoQbksr4sDK2unlbLMtjf9KFvYlO4eqxWnBQC4LX2GNbrF2QHL8Dxe2toZCTRgwfOcxjIgn2ZtbMGNTS8r0C5AgBHDBBZtLXGcmrko4by0MFpk9UGJhnOG9PB/ECspthmuqI3iFJ33oLJlUaiBgE=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.nxp.com; spf=pass smtp.mailfrom=oss.nxp.com; dkim=pass (2048-bit key) header.d=NXP1.onmicrosoft.com header.i=@NXP1.onmicrosoft.com header.b=hsv5CAbS; arc=fail smtp.client-ip=52.101.72.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.nxp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.nxp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=NXP1.onmicrosoft.com header.i=@NXP1.onmicrosoft.com header.b="hsv5CAbS"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=S1JDWlP58Hz+M9dHkPqt9akfcTeX3FBXzLnAfDs0vPh2uQRPpn4JNc8Bh+HBLBA3wDqNLHlwfNssA1DZhjgOk6YsZiazZTjB/1lDxDgbfxWArslTkEzTj2pNPVnblDBBt3S4j8qmfVaR0IreDQoTLAMzbqHgxjI+tZWR7mXE5ydpP5nwPKqu2Jca7PjpZJCewOQjrsOENdrZNrYv/XLkgVa4o9VdWGjJsVxoLP4W9qAR1Hw+u/5XU87s9NrLUFdY0Tkx8CPVnB3pWRkRdcb6wZN1pfQcvS1N1AP0TF+yidctACyx3uThN/FhCH1mqcqFR8df6WHE/ll9OpbyewZ+Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=N2zcFPzQX3Kp2uhnI/AffjH5oQFdc3vSGPuMZ8ClPxA=;
 b=vHl0g5KjYAx/JqC6Bk9r0aElDPlUaOB5HwGsFZlqJoBbbWJEuGJ4GB3Q9ksQflo+sNODphyLlmJkO6F7XM8tpz7VjDTCj0r+8UI+PzY/6d4x5rtOPAX3Xnqc1BpullDuQ7NYEGYiXd0wiSQezII3EQd+Wew3MW7LRNggQxizbKi9iH/DRv0IZ2xStynQdktpRga/tMyibzsp/Ae5OiZs6Kuzflk7CpmiVYG7uPZTVdDTzmcRGAqQHwbyh36vAdL8NTIf/gP8ROlOOtLXt60Os6JNL65UTRgr1ywnFyVhRZhcZ4w7DJxhyYUFH2XQyJSk1e6r0Op61A3p8rzF0pzZgg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=oss.nxp.com; dmarc=pass action=none header.from=oss.nxp.com;
 dkim=pass header.d=oss.nxp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=NXP1.onmicrosoft.com;
 s=selector1-NXP1-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=N2zcFPzQX3Kp2uhnI/AffjH5oQFdc3vSGPuMZ8ClPxA=;
 b=hsv5CAbSuHN0LPJanO5BSoRSyUbzimhPG+EZuipkXHKLvgB5/OOSO0LCdbO4x01OP/gBBtLsCy0NxV6EEf5eM5Oid+ewxxt1dOGnUx7GW+iYCTYu9N+HmB65XbyqV1JyAQdL0jWee5hMFfHVp5cpnEMSmGeUP8ac5GT57R4VkOdRoJ9hQR2aOxQ4r8N2ETdlHQblsWrPD4m+YA/2cY3WPHtb42AG44/AQpMgamWpmuiGkxgpGWNMURVuipl37cKMhAB0/exeHUMjDCyOnMkvT1CFcc5sXOwIPnJYXhOSe8g3lLJh3r/7GqHIgaM+TQx9kKivWlpGnLcG4CRFXCWBAQ==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=oss.nxp.com;
Received: from AM8PR04MB7874.eurprd04.prod.outlook.com (2603:10a6:20b:24d::9)
 by PAXPR04MB9596.eurprd04.prod.outlook.com (2603:10a6:102:23e::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.428.13; Sun, 20 Sep
 2026 02:29:45 +0000
Received: from AM8PR04MB7874.eurprd04.prod.outlook.com
 ([fe80::ac38:1699:6f18:c5d9]) by AM8PR04MB7874.eurprd04.prod.outlook.com
 ([fe80::ac38:1699:6f18:c5d9%6]) with mapi id 15.21.0428.014; Sun, 20 Sep 2026
 02:29:45 +0000
From: "Peng Fan (OSS)" <peng.fan@oss.nxp.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	Peng Fan <peng.fan@nxp.com>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH] SUNRPC: use assign_bit() where applicable
Date: Sun, 20 Sep 2026 10:27:13 +0800
Message-ID: <20260920022714.3145751-1-peng.fan@oss.nxp.com>
X-Mailer: git-send-email 2.51.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: SI3PR01CA0011.apcprd01.prod.exchangelabs.com
 (2603:1096:4:296::6) To AM8PR04MB7874.eurprd04.prod.outlook.com
 (2603:10a6:20b:24d::9)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: AM8PR04MB7874:EE_|PAXPR04MB9596:EE_
X-MS-Office365-Filtering-Correlation-Id: 79fc9aaf-a5c9-4814-e1c5-08df16bf08c5
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|7416014|1800799024|23010399003|19092799006|366016|921020|18002099003|56012099006|11063799006|10067099003;
X-Microsoft-Antispam-Message-Info:
	JvNOtGgEXXjbRLfpj9S1GG2HtlzSgfBuA9rz8GuIRHMeGiwbcYPTVRK9mS/uc6X2KQE2baz8MogyEJqaR33wOnjQL6Qu238hXlooAl2lGyuIRgg+bR/BUlEpKcnpsU5ZRfqmyPlA3QNd9YQsAtoBmtd0/aFv1iA8vypMV1RRPl/CUiVzkMe2PVEWc+SrE4NUM1QakfWXkuDGGmgNngSHAgiPZWjR4S0M7r96mVGY/8PsVsslWz4qdKPUlYGLjLIJ63TC3SdbzgepAdx2bnMZ47PVpA1LBB03Wojd9dGdrMOySnEaRhngfjK5a45btf7FMv+cdRoon1oHkBMsWxjcH+0In8gXMmYHWFYv5o6O/s4XpFB/N2ZscUnqAovutQilKZdjSx6O30np+iExtc7BS1qbk8YB1uiUuGsKiEOCQKHzbORVmcDogGiYSoXs9w6QlJRrCrbarvQdruvJUbZ4XBA8vjqB+w57U+oESc4VV2hGyMQStgg5cjsfAK3TV2b4NQLVaX4rleM5/gFOHaxMN9Mf99emLOaslSrAQP6leAevXcn37VucIfjr8HK/DJShSfrWKGQxo/oJxD+ql8mqQ4qL5C1MrO6wWaTXP8hsnXOtMyxqEmyzuVPgqA7NJEz9XjEblqf4x3X+BxbmBcQeURfum8QAciZrRecATdV6O9agmLarJKfDztD3ym9oTaivvSRb1phwe0lf4cNKUbjetA==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:AM8PR04MB7874.eurprd04.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(7416014)(1800799024)(23010399003)(19092799006)(366016)(921020)(18002099003)(56012099006)(11063799006)(10067099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?PaTGgWoU/aMZeHaHY4Mac32R5y7hzW/eR+X9NGHdPcwopnmGmmVM+eNyHAv0?=
 =?us-ascii?Q?BfViCvUti1xanMsj53UZPFwI5wm/J6Mddv7ex8OKLr2N4aw+aSnRvWccK5FF?=
 =?us-ascii?Q?o01On5GLUTLQfvIxfvPrCTGbNiqNGuMmjYCMlKpGvMzt3XlcMUhEhVp+XUMU?=
 =?us-ascii?Q?k5oxdlCI+YxdJhAnh+f2qlb/8ZAmWCTg1lYrEYmW6g1OBxFChYbFYmfAa3M3?=
 =?us-ascii?Q?8XMmE8lXtssA04R2EcqpRjHhGvewpzIRuarxXfPnlG9zZBvflLqe59Ovy1T7?=
 =?us-ascii?Q?FiDF7m+Jn/A6LHEu6WJ0K7zZPGqNJPxnYFVIpG2Ia9IENf8Wfc2BXNoUFlrg?=
 =?us-ascii?Q?r4f2qpvjabcSFfvMaUbGHILrQGcOWvgHCSAPcJihuI+6gkLlPGzVFaUYs2YE?=
 =?us-ascii?Q?AFdaJ6IzQqpN2NzWt0bqq43j5UBoUaqiu2wgSapuIAoAo+nIQjr3kfaMCuGx?=
 =?us-ascii?Q?CDG4KCuvLuwc+8NOcYzTKs66p4SyYraPmrR4uy+NM3cyaz2T8LqqdTjQ+KZA?=
 =?us-ascii?Q?Ll+yXXjw/LQ+vQHEYRZy0YhPf+Ss4+26Eq5EViG8IwoAg3+j07RHjG/ON4M8?=
 =?us-ascii?Q?KuY+ddWOPqfW7mcG1CZb7MUvsb6VXrAyRlAc2afVxoFSql4F0IYPVcoL+x7i?=
 =?us-ascii?Q?3VsJh7NdQW+/Os0PrsIsaMMMOXM8jOyX8S3e3P/+6bnNS+hs9w4S8zGA3UI0?=
 =?us-ascii?Q?exYmNO43Dngsilyi9vpMU0hwDxSoTtj6wCJUac0iWv9SRcnhTSj4Q3EK3qyj?=
 =?us-ascii?Q?0GmKhE4pVYDyOvxdAY6nfxp7xS9ljc2QpyF3Wv9Y+CK8iS3lGYTCNL6c9y1X?=
 =?us-ascii?Q?D14ck67WbXL8YdABnXN/eVler/CYrf5uRhufnYpzW6PCynPxZRbd64kOqcB7?=
 =?us-ascii?Q?cOhuDMvspAJXGuEwLndfa0LgG5QrogWCjdjedIhMqrWpqsePQhcrwVV60k7I?=
 =?us-ascii?Q?JuOY3vPuGZlHK6rWFjWof3ANVAtSFmlr2IQ8DixpNK58T4zoIZQmiCBYHSjR?=
 =?us-ascii?Q?VPvsf712qqPG5yapb9iAPmZ6KpBKDtDsBRxKP4orGccpkI5cVoCTnvSVu1AV?=
 =?us-ascii?Q?Frs3qHOhr0d/1BOc1i9xUaD5ZoBqGXYZOQjw7J/XHZt82Za7LpcDcAbIQmno?=
 =?us-ascii?Q?FwiDaKlOF+y5n/xUyUQV+lOMKDJnpFdTFTv2T3c6joFgD4Fgt6lZgGcjvCT2?=
 =?us-ascii?Q?TrUh8za5uAmv5Q+oa7Z85KF7BXQCRa4gEuOqGC3Fc7jegc+Johv1Y03Qk0CB?=
 =?us-ascii?Q?B/Luaw23TOTotr//B3Q03C1CWRSTc+1s/8xuV4lYLWoLvf1FwN+DjbFAe0OE?=
 =?us-ascii?Q?H/DQHpSpssaeljAa3FDtU/CSOg2fW573qRKw9lulstmiaaJWORgEZytmIs8Z?=
 =?us-ascii?Q?tXZxs0QsC/hE3BnlOg1vfQFuZboID3DwUPKN+ftOJvcerU6MdxLWN+1Zz/Eg?=
 =?us-ascii?Q?rlgOWehAn0NGQbWCYLwxel54cpBFeWSVzAEBBubPyBNYM6lJkkc9BDyZYEpS?=
 =?us-ascii?Q?uimCpNMyPvRKsuFUXYjqeV3ENZYDq5M8d+7doGRf3WVIrm/yEzhiWW2kXje2?=
 =?us-ascii?Q?aAOooRUrUngSiqLHWkLGPE/RbKWYl/wZhKiai+Yb1Rxn6fiLiHAIerTmjDsX?=
 =?us-ascii?Q?73Z74UZdYgcHIW6bfM89vT8RmzSYzA4LwkSa82JhXt1MHCjbXvk6HR+5ktVD?=
 =?us-ascii?Q?/xLP5qJvDP9tJUCjcQfV0M+Ag2kfgfqW8OPzELXZ1tqjTp4ebgGDPIqEQa92?=
 =?us-ascii?Q?0FrOEDUwY6OT6dRViaqzzd11V6NNs4Bcc8MXdIqdevLPNUSHARhf?=
X-OriginatorOrg: oss.nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 79fc9aaf-a5c9-4814-e1c5-08df16bf08c5
X-MS-Exchange-CrossTenant-AuthSource: AM8PR04MB7874.eurprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 20 Sep 2026 02:29:45.2700
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: mCjPh/QJqNXtJU4kITAK5JraNuME2eUjYKNL9d2yiTn4bpabJUsY9mPOH4WLbWNgbBpVPdjA/vKpaVZwrjmVMGQiZLvmn33JDSv96v+RB4t5ZzUBLW7iBoU9VIF77C0/
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PAXPR04MB9596

From: Peng Fan <peng.fan@nxp.com>

Convert open-coded if/else with set_bit/clear_bit the assign_bit API.

Done with Coccinelle semantic patch:
    // set_bit -> clear_bit => assign_bit

    @@
    expression cond, bit, addr;
    @@

    -if (cond)
    -        set_bit(bit, addr);
    -else
    -        clear_bit(bit, addr);
    +assign_bit(bit, addr, cond);

    @@
    expression cond, bit, addr;
    @@

    -if (cond)
    -        clear_bit(bit, addr);
    -else
    -        set_bit(bit, addr);
    +assign_bit(bit, addr, !cond);

Signed-off-by: Peng Fan <peng.fan@nxp.com>
---
 net/sunrpc/svcsock.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ef7ac080fcd3..d7fa0d1de3ef 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -352,10 +352,8 @@ static void svc_sock_setbufsize(struct svc_sock *svsk, unsigned int nreqs)
 
 static void svc_sock_secure_port(struct svc_rqst *rqstp)
 {
-	if (svc_port_is_privileged(svc_addr(rqstp)))
-		set_bit(RQ_SECURE, &rqstp->rq_flags);
-	else
-		clear_bit(RQ_SECURE, &rqstp->rq_flags);
+	assign_bit(RQ_SECURE, &rqstp->rq_flags,
+		   svc_port_is_privileged(svc_addr(rqstp)));
 }
 
 /*
@@ -941,10 +939,8 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 		slen = offsetof(struct sockaddr, sa_data);
 	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
 
-	if (sock_is_loopback(newsock->sk))
-		set_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
-	else
-		clear_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
+	assign_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags,
+		   sock_is_loopback(newsock->sk));
 	if (serv->sv_stats)
 		serv->sv_stats->nettcpconn++;
 
@@ -1290,10 +1286,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
-	if (test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags))
-		set_bit(RQ_LOCAL, &rqstp->rq_flags);
-	else
-		clear_bit(RQ_LOCAL, &rqstp->rq_flags);
+	assign_bit(RQ_LOCAL, &rqstp->rq_flags,
+		   test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags));
 
 	/* Completing one message stops ->read_sock with whatever
 	 * follows still queued, and no path from here re-arms XPT_DATA.
-- 
2.51.0

