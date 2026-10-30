Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.43.27
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793365662;
	b=junuoUf68ejhYqnA8qNuFGiYF/tlxspWN3wEr2XswrB7lSRLrvOh06j49vsTkb3BtfDG
	 9fc/5cxewRFiCOXQzaNUaar1V2ZWgdD7MUWNaUmC2Kepb69/bbQHfLWWuuvKDzGWSQmlt
	 iZ/s21FfBU9N1Ny3pIgmr4YO/A7Ml+fppZfRIClx7iMmDmcptRm61cqUytnkvKDLJM7vj
	 tOUfP8yFuniXXpQtej4n0ZPsAlcRAIcyrXmKIB9KmFyWtbgwAD+LlMw0kcdyG0Zc3NDlQ
	 LQOhuc99RdbBhF/cQMDvMl1xjoyLe+EIrM6RU9L6UuMDTKXPzeMzwgZRQdf1ry7083g==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793365662;
	h=DMARC-Filter:DKIM-Signature:Received:Received:
	 X-MS-Exchange-Authentication-Results:Received-SPF:Received:Received:
	 Received:From:To:CC:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy:X-EOPAttributedMessage:X-MS-PublicTrafficType:
	 X-MS-TrafficTypeDiagnostic:X-MS-Office365-Filtering-Correlation-Id:
	 X-MS-Exchange-SenderADCheck:X-MS-Exchange-AntiSpam-Relay:
	 X-Microsoft-Antispam:X-Microsoft-Antispam-Message-Info:
	 X-Forefront-Antispam-Report:
	 X-MS-Exchange-AntiSpam-MessageData-ChunkCount:
	 X-MS-Exchange-AntiSpam-MessageData-0:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-OriginalArrivalTime:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-Id:
	 X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp:
	 X-MS-Exchange-CrossTenant-AuthSource:X-MS-Exchange-CrossTenant-AuthAs:
	 X-MS-Exchange-CrossTenant-FromEntityHeader:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped;
	bh=ndTIG/JdXE75XLZ+cZ5rIZXXDnx/mFTgkIYLi9ECJ2U=;
	b=v6U0sVFdXjaGnpmKnszM06lZ3eYMRJf25tPJyzVr4aVXYOQr+4TgOEuhoj8S/YRK0Pnc
	 DnYcA169lI4AxmI2APTP/rlJ4mO1u0LHJJdSREomf2IQYNQJqdnfmtvgdNojmzC0oNF3e
	 MO/VZ087YCB7e3TJJd3P4qvU17K+zTWJ5dx7oijDp2eiw9AJKT/WM77jlzJWU/Mq2urA0
	 +4lWLOeuZczKF99C4b5njSzfweCb49pS4D05EZa8fYxtWRW4ZwGwuIwzmGLFnRzznpKNy
	 txBrrqmzw44C7zs+HsYwX7CV+l4hD7VMZOCc31v9T+cSrZbd5LwbCoOQcopOdX4eUsg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=nvidia.com;
	spf=fail smtp.mailfrom=nvidia.com;
	dkim=pass header.d=Nvidia.com header.i=@Nvidia.com header.a=rsa-sha256 header.s=selector2 header.b=mkk6EZ5X;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.43.27
Received: from SJ2PR03CU001.outbound.protection.outlook.com (mail-westusazon11012027.outbound.protection.outlook.com [52.101.43.27])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 70F99606A335;
	Fri, 30 Oct 2026 13:07:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 70F99606A335
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=Nvidia.com header.i=@Nvidia.com header.a=rsa-sha256 header.s=selector2 header.b=mkk6EZ5X
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=q9CSZ5V+xmwbrBiusYJZccNVdWrkfoQ+XZcCPmHEYsQBKjYhD/O5syy6dNFUsldSD4ZvfDCFxu1z6XcvOxAYI1R7hzYfhOLxlw7Oio+gPH5Vc7ufftpZdyXcpL4MU8vgn2RMLv1qCUxxxSLWFHKzriXIoEGdef1JcQYtJuJM5GFkPSuMDNlKtduZp+rIWCwTh06B0a+JBzZB1LbLDnGvz0/Q68FWMKHjoNKjW+5hW3WonE96Av5tq3TEVL4VhDXyhtf9sLeJ8ExgwtdqKepa4DHZ5y/1xiN795lVk0n+HorKaSWdmgnMr1aR/dujgPI4TSAHJEt6N3OwhP0c+tTEGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=ndTIG/JdXE75XLZ+cZ5rIZXXDnx/mFTgkIYLi9ECJ2U=;
 b=kl9+XPFi/dcNBrcvCE27B+S0wrvfPve3SStjdDwuNVBd7gbTlgFoH2ilQKDPv2L+s4dlA73q7OvNCN5jyqndehz1Z4lGfgAkLIVMZZSnl9cqRKGYrP+IvIwh5+zHkB4WrC2mFohkCRlT8m4/fyC56Ansa4HHkVYi8SxhwxPpvrwyMiohDMvZ2Y3VrjrW30tAoSrjV28qITNr0eNN4ixPJ+wDgKaoK45HnWuD4KNUX56S8N1pAn4Hgbr2TN9N1erHT+OgzaemLEshvhenFyF8CtLIfPRC9C5yEYKtaVLOAMSuXkxlvK1Xj3vJd/K91DslyDXOM4aJrh2bDX1cKBdYPA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 216.228.117.160) smtp.rcpttodomain=kernel.org smtp.mailfrom=nvidia.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=nvidia.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ndTIG/JdXE75XLZ+cZ5rIZXXDnx/mFTgkIYLi9ECJ2U=;
 b=mkk6EZ5Xu6r7vyMgOteDudd8yxkGLTCJz3UUzr9VMfgEYy04WAc+wU9tbeKGcMZiwgPORr13ZnYpc6CvPsJk09WDbrsJp4RNh/7zZEidJyhIqmWm5RJS+TM80Yn22EeTp+/LH5Zl6DENPLCneIXPCEGPqgVn+F/LYsQsKBbe2H4xuC3kEI/do0IUGw3KBmrQIe4cjlQDR8aoS7SLHzINHQJVIj/3VcTU5Y2lP3jBh6zEI5Xhc7y4wvmo9ZiUFoJc9dL35fM7eiOIey7cCBOGP222CyaH//BS6cUmH9Nvypz201K+wpY8zEJyt2c7dd1Z4+9Uqqml2aR4s6x5Z3si7g==
Received: from SJ0PR03CA0039.namprd03.prod.outlook.com (2603:10b6:a03:33e::14)
 by LV8PR12MB9335.namprd12.prod.outlook.com (2603:10b6:408:1fc::22) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.569.9; Fri, 30 Oct
 2026 13:07:34 +0000
Received: from MWH0EPF000C6188.namprd02.prod.outlook.com
 (2603:10b6:a03:33e:cafe::58) by SJ0PR03CA0039.outlook.office365.com
 (2603:10b6:a03:33e::14) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.546.22 via Frontend Transport; Fri,
 30 Oct 2026 13:07:33 +0000
X-MS-Exchange-Authentication-Results: mx.microsoft.com 1; spf=pass (sender IP
 is 216.228.117.160) smtp.mailfrom=nvidia.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=nvidia.com;
Received-SPF: Pass (protection.outlook.com: domain of nvidia.com designates
 216.228.117.160 as permitted sender) receiver=protection.outlook.com;
 client-ip=216.228.117.160; helo=mail.nvidia.com; pr=C
Received: from mail.nvidia.com (216.228.117.160) by
 MWH0EPF000C6188.mail.protection.outlook.com (10.167.249.120) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.569.4 via Frontend Transport; Fri, 30 Oct 2026 13:07:33 +0000
Received: from rnnvmail201.nvidia.com (10.129.68.8) by mail.nvidia.com
 (10.129.200.66) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.56; Fri, 30 Oct
 2026 06:07:12 -0700
Received: from 8e48b22-lcelt.nvidia.com (10.126.230.37) by
 rnnvmail201.nvidia.com (10.129.68.8) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.56; Fri, 30 Oct 2026 06:07:07 -0700
From: Kal Cutter Conley <kalcutterc@nvidia.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, "David S. Miller"
	<davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, Jakub Kicinski
	<kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman
	<horms@kernel.org>
CC: Kal Cutter Conley <kalcutterc@nvidia.com>, <linux-nfs@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH] sunrpc: fix lost wakeups when stopping service threads
Date: Fri, 30 Oct 2026 14:06:28 +0100
Message-ID: <20261030130629.103716-1-kalcutterc@nvidia.com>
X-Mailer: git-send-email 2.53.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: rnnvmail202.nvidia.com (10.129.68.7) To
 rnnvmail201.nvidia.com (10.129.68.8)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: MWH0EPF000C6188:EE_|LV8PR12MB9335:EE_
X-MS-Office365-Filtering-Correlation-Id: d6741194-06a0-49d2-70b0-08df3686c313
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|36860700016|82310400026|23010399003|7416014|376014|1800799024|10067099003|18002099003|921020|56012099006|11063799006|261028144727099003|261026140227099003|261022105027099003|261021121427099003|261009223027099003;
X-Microsoft-Antispam-Message-Info:
	tsaYsvfIZBM1ulWLZqpQxhqO4R/1Rm+6DS/XuAHoq+mTvhU+G9UOJbLRPdflc5aoHi1VrbtgfFHMgpt8bd9tp78r1DE7JQR8XuKkDyVMsxNdEUEfruynp3jGE+GHn4JFbfgCrDQws5CBQNqvKD4XiysupyaNrwk6ZgJhv30rXVq3HXxGajIPjA7IN6UvQuQry/4k5z85x9Fx9X611ODuQNpNlf7HFJh0Y7WP60hIWq7GXngy1F2q0llR+sEFUMC473g0N4eCjtb/K6RvI85P9Udx3XUMnNXC0WZHRH5gX9Vq6J3ozC/iYM9AxIEud8JL0/qq4wPr6hjwuRafI+RJ3tl0JSMY7CjBDskz0VfQZu+Guj5TWiiLDgVCNquwa8ZNSZUjxNJbzVAP03aaRJFO3x23ROY1MFmjwA/te2Eq52HTU6ew2zjJCDQwhBz13yDmWTK0IF8hoa67TzVsYjAUOByBaXlyeg7Elc1C4H59gWe39fe9ybc0gqSJ/jgXsbyuhz+m1YD69BKOxSubOlzbHtcSzkMDz7IJBX+B5f3CJva3Gx/bVbU3YN95M7+Z0qkBPj7GMbUkXNzrdS7U+hIOvgNVx0AQrB3hNy/H6D1uwf3EVDq0uBxpjmjX3xkOYheBNI32carDljwr0FuiXq0Q4GcrY+Rj0EfktxymQ8CzbOvWIST1kmaERjp5UHLnfv0esTjHEdNksLImlFEvDJYwO9ot3p2DNMcfBrQdO/JmTA2O8Vbg9SwTlnAXfD4PExQ1
X-Forefront-Antispam-Report:
	CIP:216.228.117.160;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:mail.nvidia.com;PTR:dc6edge1.nvidia.com;CAT:NONE;SFS:(13230040)(36860700016)(82310400026)(23010399003)(7416014)(376014)(1800799024)(10067099003)(18002099003)(921020)(56012099006)(11063799006)(261028144727099003)(261026140227099003)(261022105027099003)(261021121427099003)(261009223027099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	E8TXqJXasH4ybrtA4Pc0H+GPtxIO/xHOsSyMjbSqu+k3M8fUawUXPXYob/QmINYb+r+VavWycJxsH3+PIp7kAsaQm0jm94RA6UfubSFo0/gV+NX7yvzOkGXELGDYf/2w+seG819X0AQx4GYLap9W87PkVwU+xm1lcqMkFNeaxf7VX5IAwDCdkJIv/sA0ZiCArI08aQaABakaxeSjNChveA6zOEnwHnBWseZE8M/YWc9TbK+CLx7XehAFHRgByQA8sBglX+fiO3SID/f31lTU1u976ZcUV5ByzzLEnTUqu5YZRzqvL0Wz5hih7TCgVLPNyUQW4t6+F8U0fnp7bNpEocPw7n5rMNg3uZV2EyDYrgw4EA6hXniwxVj3JjUnIi1IR75uChFvSGsfubU6x8YoUvx1dyG/VAWXv4Gw5wjT7qJZ3N7XAy/j5sAIRDXNqL4R
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 30 Oct 2026 13:07:33.5268
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: d6741194-06a0-49d2-70b0-08df3686c313
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=43083d15-7273-40c1-b7db-39efd9ccc17a;Ip=[216.228.117.160];Helo=[mail.nvidia.com]
X-MS-Exchange-CrossTenant-AuthSource:
	MWH0EPF000C6188.namprd02.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: LV8PR12MB9335

Stopping NFS can leave rpc.nfsd 0 in an uninterruptible wait with
this stack:

  svc_stop_kthreads [sunrpc]
  svc_set_num_threads [sunrpc]
  nfsd_svc [nfsd]
  write_threads [nfsd]
  nfsctl_transaction_write [nfsd]

SP_NEED_VICTIM and SP_VICTIM_REMAINS remain set while all remaining
nfsd threads sleep in svc_recv() and none has RQ_VICTIM set.

The stop request is published with unordered set_bit() operations.
svc_pool_wake_idle_thread() checks the idle list and task state before
calling wake_up_process(). If it sees an empty list or TASK_RUNNING,
it skips the wakeup and its memory barrier. The requester can therefore
miss a sleeping worker while that worker misses the stop request.

Order work publication before both lockless checks, even when no
wakeup occurs. Pair with set_current_state() and llist_add() in
svc_thread_wait_for_work(), so the worker observes the pending work or
the requester observes the idle worker and wakes it.

Fixes: 60749cbe3d8a ("sunrpc: change sp_nrthreads from atomic_t to unsigned int.")
Signed-off-by: Kal Cutter Conley <kalcutterc@nvidia.com>
---
 net/sunrpc/svc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index af8d87c1de83..f3cc63acc5e1 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -29,6 +29,8 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/bc_xprt.h>
 
+#include <asm/barrier.h>
+
 #include <trace/events/sunrpc.h>
 
 #include "fail.h"
@@ -693,6 +695,13 @@ void svc_pool_wake_idle_thread(struct svc_pool *pool)
 	struct svc_rqst	*rqstp;
 	struct llist_node *ln;
 
+	/*
+	 * Order work publication before the idle-list and task-state checks,
+	 * even when wake_up_process() is skipped. Pairs with the barriers in
+	 * set_current_state() and llist_add() in svc_thread_wait_for_work().
+	 */
+	smp_mb();
+
 	rcu_read_lock();
 	ln = READ_ONCE(pool->sp_idle_threads.first);
 	if (ln) {

base-commit: b803428098f6fcd584db9f0499217b80e465bb34
-- 
2.53.0

