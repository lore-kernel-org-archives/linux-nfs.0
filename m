Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.61.36
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793708522;
	b=r6pfcsfKlbVCrvha4BbmGPNY8OIY7cs3cbE72w56P9PVfQafsGBm1dc8MefvypyX4iFP
	 BOHEBHQnVB99kU8ymgZ36PspuDRnxPoST9kX75s5BrT6qgaYIswH1ouPG8Ss56iPxJtlZ
	 I9Jtf0qudYsxZUQDKiZkJMrWg3qnoE7pIOfUAXVRU9YTKE8/RVVXb3sdFVQ6EvVros8uk
	 MquvCSDhYU3Ye8FUvWwTFFpcjGt2p8s1q/ug8hXuDzWEXvj90+QQgwVMdo0eICCzDhFsS
	 t+0CalXb6j8ZxJBG5jMqGR2v1pInbeoY6EOyQLGi83GRVT3eV0N6IxvkECpEoYvRpiA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793708522;
	h=DMARC-Filter:DKIM-Signature:Received:Received:
	 X-MS-Exchange-Authentication-Results:Received-SPF:Received:Received:
	 Received:From:To:CC:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding:Content-Type:
	 X-Originating-IP:X-ClientProxiedBy:X-EOPAttributedMessage:
	 X-MS-PublicTrafficType:X-MS-TrafficTypeDiagnostic:
	 X-MS-Office365-Filtering-Correlation-Id:X-MS-Exchange-SenderADCheck:
	 X-MS-Exchange-AntiSpam-Relay:X-Microsoft-Antispam:
	 X-Microsoft-Antispam-Message-Info:X-Forefront-Antispam-Report:
	 X-MS-Exchange-AntiSpam-MessageData-ChunkCount:
	 X-MS-Exchange-AntiSpam-MessageData-0:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-OriginalArrivalTime:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-Id:
	 X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp:
	 X-MS-Exchange-CrossTenant-AuthSource:X-MS-Exchange-CrossTenant-AuthAs:
	 X-MS-Exchange-CrossTenant-FromEntityHeader:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped;
	bh=t2tofVoe8B8mUbr/wtrIQF+84z4ck8y3u5VEqeaIanQ=;
	b=30O+mzdPNo+5PHbqO6aCvVySQw7wyTFvWwceLjOamJcuIFqpsfdAeIzARK4CCqDgrepe
	 tbsE/Tbl4HgKlMr3yYBXR74AlBw3LZpuBE4Xgnt1wXkKFpt0O7DvsNq/NvTbLg6EcFZjw
	 B3koCf42NPC9EEtzswrWTe41Ouvd5xcdmu5Pg/yuF1Qz2KqbFC8qB+5XREAvmkRpDF3Hn
	 BAa/+Ma/cAMJvmJ1FvCYiWbZ9qwV0mL1bEOHwn3zCYqMEWOR+GnHn7yXCPaPBO6xIVYVc
	 FVZTm7u7wApXBZjx2H25NeH+R9cTgGB13bE5GeUJmfsZ6QGzagsJ9d3uw2J1D6eAdWw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=nvidia.com;
	spf=fail smtp.mailfrom=nvidia.com;
	dkim=pass header.d=Nvidia.com header.i=@Nvidia.com header.a=rsa-sha256 header.s=selector2 header.b=pTbzzDb8;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.61.36
Received: from DM1PR04CU001.outbound.protection.outlook.com (mail-centralusazon11010036.outbound.protection.outlook.com [52.101.61.36])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 780C2606A32C;
	Tue,  3 Nov 2026 12:22:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 780C2606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=Nvidia.com header.i=@Nvidia.com header.a=rsa-sha256 header.s=selector2 header.b=pTbzzDb8
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=qCHv8sWM0wDnxV7vKviYFoOqbCVftGbCcxeqjOIaTaSYvuRBa7Pn7Z/lSBEB2HjDZg1D6ho6eLUl02iR/+SbqCiL5FalCrApE0GNkfugl31wZ+6RqtBLfjrMfKFKVApjd1BwimUg1NNSGpLDplbeq+5jTiQmD0fSccVEXvtzOuL12sCHPWPvUOJvQ5LiShp5t4EoAh7efmcXoOO2XEhQCRU+a2XEwTT3Mrk2DEDHfkH4je6z6nP5SOYjVCr4hRTy8gUcFil5hgxEHvcBU10p8vrF6HECjO3eWGZvKUDmIV4L2OwbVptx5otkG3+oZ9YoUXrSyXbCYFivIuvwNWFCCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=t2tofVoe8B8mUbr/wtrIQF+84z4ck8y3u5VEqeaIanQ=;
 b=ca5wtCbUFLcyWxaIEMHBskuQLdu3FQPMafUyJ4hZtov47K8CelBY0Q/On7l1ENA+/8UFPAe+EkuH8uoXX2khAO2+3akT7E9WgMT2regy2ucD/16Uc7HlFgpgoikSlNuVSf7Drh0tvcqZFE743gZ+dFG97ICSrvyDF+AVldiNu92v23EDeUOltVZFHJlGVrh/A6wSp87zKnYC1HTG4CZKQ5BfdJYsfPJ3c3fgUPwFz9cO7Xa+wZWPQr+QJeCpq7U1fBNL+2nMZq+9n2Q1gKeZNBgQSia04OvjqbMAtIqtFsJPdMrmvxiGdgT0YtfPSQFudevSJ5hY536W+JF3rZVf4Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 216.228.117.161) smtp.rcpttodomain=kernel.org smtp.mailfrom=nvidia.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=nvidia.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=t2tofVoe8B8mUbr/wtrIQF+84z4ck8y3u5VEqeaIanQ=;
 b=pTbzzDb8FBY7qvThErENhhDWN71bsr6E60diYOTwl6XyW3SW/r0RmRs19jLZeUI0Y2yS5JCLKyUTv5qFBjhkVaJEe/NvpaORS5+BUzHA1i6pF4DmCjJD5qLXrFbJOInHuAKSsTwYvtduZd+YdY6Q8oNpbtQZSiY3uYAdHykyNftgrGJo7xTazxLcOhTzZWqN7E6GJ0QgQfLRinz1MgX3kOtakbaJqqr4qZhM2/pzVo868JpNC4lm0DkzOM2plibxj/KzwJ9GkaFFNEiFi6UPNRLZsUsRiMuqsgGSCPCVaGuH0EP34j5I161DTlhGbJZJvWhW/o9Smj9XVuC3Ua1buA==
Received: from SJ0PR05CA0180.namprd05.prod.outlook.com (2603:10b6:a03:339::35)
 by SA1PR12MB7248.namprd12.prod.outlook.com (2603:10b6:806:2be::12) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.592.8; Tue, 3 Nov 2026
 12:19:48 +0000
Received: from SJ1PEPF000026C6.namprd04.prod.outlook.com
 (2603:10b6:a03:339:cafe::27) by SJ0PR05CA0180.outlook.office365.com
 (2603:10b6:a03:339::35) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.592.8 via Frontend Transport; Tue, 3
 Nov 2026 12:19:48 +0000
X-MS-Exchange-Authentication-Results: mx.microsoft.com 1; spf=pass (sender IP
 is 216.228.117.161) smtp.mailfrom=nvidia.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=nvidia.com;
Received-SPF: Pass (protection.outlook.com: domain of nvidia.com designates
 216.228.117.161 as permitted sender) receiver=protection.outlook.com;
 client-ip=216.228.117.161; helo=mail.nvidia.com; pr=C
Received: from mail.nvidia.com (216.228.117.161) by
 SJ1PEPF000026C6.mail.protection.outlook.com (10.167.244.103) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.592.5 via Frontend Transport; Tue, 3 Nov 2026 12:19:48 +0000
Received: from rnnvmail201.nvidia.com (10.129.68.8) by mail.nvidia.com
 (10.129.200.67) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.56; Tue, 3 Nov
 2026 04:19:33 -0800
Received: from 8e48b22-lcelt.nvidia.com (10.126.231.37) by
 rnnvmail201.nvidia.com (10.129.68.8) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.56; Tue, 3 Nov 2026 04:19:29 -0800
From: Kal Cutter Conley <kalcutterc@nvidia.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, "David S. Miller"
	<davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, Jakub Kicinski
	<kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon Horman
	<horms@kernel.org>
CC: Kal Cutter Conley <kalcutterc@nvidia.com>, <linux-nfs@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH v3] sunrpc: fix lost wakeups when stopping service threads
Date: Tue, 3 Nov 2026 13:19:14 +0100
Message-ID: <20261103121915.25298-1-kalcutterc@nvidia.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261030130629.103716-1-kalcutterc@nvidia.com>
References: <20261030130629.103716-1-kalcutterc@nvidia.com>
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
X-ClientProxiedBy: rnnvmail201.nvidia.com (10.129.68.8) To
 rnnvmail201.nvidia.com (10.129.68.8)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: SJ1PEPF000026C6:EE_|SA1PR12MB7248:EE_
X-MS-Office365-Filtering-Correlation-Id: 376f1c83-5a7a-4790-a47c-08df39a4c12e
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|36860700016|82310400026|23010399003|7416014|376014|1800799024|10067099003|22082099003|18002099003|13003099007|921020|56012099006|11063799006|261022075727099003|261102123227099003|261102130727099003|261028144727099003|261026121527099003|261021121427099003|261026140227099003|261022105027099003|261009223027099003;
X-Microsoft-Antispam-Message-Info:
	D8yDjFv0ZK/ZPe3mfJ7jIqe2HBeLmi32c53v+G4H7x0HAQlJoJaQWc8ARjYUDzWS95saJCupHdITdKppsNi33ko4sV/JG8Syz7RSr4Zx8thb7mNq9fIxfTTBzqE4Z04038jUsuK6tgk1G/DzvRS1zApwbM4NoFFW3xekvoDeZzUd5UIsgcT4epcquutXq5e3YO2A5UIVAGKsMvLC7s/Te+NUq8qPzSQk+MX5bas3XkdDlur86AulXAcV9ecqX3LIr7v3plHJExjqWWOtQyV+7m898FEoPPywnhBLrgmTEcPQS0oIzBX++Ek7ZqEz11P9SEKWgZIYdfBubIJumBokTeokZrHsbL59v1LXjUSVfBcWAH7ayU3yAQp3h2iQqtEPicG5z6sTxB3E1YSM28LQFyYxytD8nI5p9Rw+3N5KXD0Sp+8Os9Ichrwj8pgLPkZLOgXWCwR0vBI+V86HTaM1odnfPXQrGdj2TvbFLRWqiwBkziNDULwffd6qig/dtXUYSgsTr8yhiq+uLfTjNH+ZgjAHVphBvswiroO9J2Qjl3dwaMrLBW6iSYsRj0Od9/+oJhZYVL0M4AlN/4/xyZdcWhSkKaFIzgWNte5YOnjPhj6PXkeXrPX9zCC4XDx1NtEWgGLiv9j+QyrN5+Z6NW+c6L/US66FaZAGZnplGXTWXv4hrfg5yZC92gz1lDoH4EQedF4mv0eBvoGEVl3yzq0J0Y7dHe+L9u+gCnZJnJ3OrBI2Ox40NPuEPVw8HFpyxVY/
X-Forefront-Antispam-Report:
	CIP:216.228.117.161;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:mail.nvidia.com;PTR:dc6edge2.nvidia.com;CAT:NONE;SFS:(13230040)(36860700016)(82310400026)(23010399003)(7416014)(376014)(1800799024)(10067099003)(22082099003)(18002099003)(13003099007)(921020)(56012099006)(11063799006)(261022075727099003)(261102123227099003)(261102130727099003)(261028144727099003)(261026121527099003)(261021121427099003)(261026140227099003)(261022105027099003)(261009223027099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	bez5dUwHojQjtWKqRbUlyoP6L/m7NjE1dnaVPgBZYRjXQuKXXd/ZOC2kNFpC5K14eNvQz/5LY0bm16UkB4RS+W7xYIJNRn8U6+qfX9yahYHGKHGkAMYHHn1cxt47gbgD+8BRkVsqxFYqQo9FF8EzMn5cHOJMPHqEbdkBbiIN1loZrvNV4p6ok+JyJospIfjBCQjEprjaUD2umDFliUTF6OHgMRgbxV1kS2bY+Yj8use0EiF8me0GzZFNL2NQxkcif6iOJK8ZhzDE1IUaN7bFS80ygKNYL65dsaOJguDmbCCeIwtogQnf3M3CBHASarpkTHzGf+r4vqqyfWqArFjPG8r8M6wR2RC4CQewMa307WRriQa9ntQpAR+qxInd6mhObNclOvkvSSe1DneXD06CNaYCNFgkCWDcPWaAvPQzcus/J4kklGaxGLQiPo2XlEUL
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 03 Nov 2026 12:19:48.7054
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 376f1c83-5a7a-4790-a47c-08df39a4c12e
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=43083d15-7273-40c1-b7db-39efd9ccc17a;Ip=[216.228.117.161];Helo=[mail.nvidia.com]
X-MS-Exchange-CrossTenant-AuthSource:
	SJ1PEPF000026C6.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR12MB7248

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

Use smp_mb__after_atomic() after the flag updates in
svc_stop_kthreads() and svc_wake_up() to order work publication before
both lockless checks, even when no wakeup occurs. Pair with
set_current_state() and llist_add() in svc_thread_wait_for_work(), so
the worker observes the pending work or the requester observes the
idle worker and wakes it.

Fixes: 60749cbe3d8a ("sunrpc: change sp_nrthreads from atomic_t to unsigned int.")
Signed-off-by: Kal Cutter Conley <kalcutterc@nvidia.com>
---
Changes in v3:
- Drop the redundant <asm/barrier.h> include from svc.c.

Changes in v2:
- Move the barrier into svc_stop_kthreads() and svc_wake_up(), using
  smp_mb__after_atomic(). This avoids adding a redundant barrier on the
  transport enqueue path.

v1: https://lore.kernel.org/r/20261030130629.103716-1-kalcutterc@nvidia.com

 net/sunrpc/svc.c      | 5 +++++
 net/sunrpc/svc_xprt.c | 5 +++++
 2 files changed, 10 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index af8d87c1de83..6100603e0a34 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -784,6 +784,11 @@ svc_stop_kthreads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
 	do {
 		set_bit(SP_VICTIM_REMAINS, &pool->sp_flags);
 		set_bit(SP_NEED_VICTIM, &pool->sp_flags);
+		/*
+		 * Order flag updates before the idle list and task state checks.
+		 * Pairs with the barriers in svc_thread_wait_for_work().
+		 */
+		smp_mb__after_atomic();
 		svc_pool_wake_idle_thread(pool);
 		wait_on_bit(&pool->sp_flags, SP_VICTIM_REMAINS, TASK_IDLE);
 		nrservs++;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 076c624fe675..868e3da57b6c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -632,6 +632,11 @@ void svc_wake_up(struct svc_serv *serv)
 	struct svc_pool *pool = &serv->sv_pools[0];
 
 	set_bit(SP_TASK_PENDING, &pool->sp_flags);
+	/*
+	 * Order flag updates before the idle list and task state checks.
+	 * Pairs with the barriers in svc_thread_wait_for_work().
+	 */
+	smp_mb__after_atomic();
 	svc_pool_wake_idle_thread(pool);
 }
 EXPORT_SYMBOL_GPL(svc_wake_up);

base-commit: 2d3259f652bb0f1d137ccabecac6763da05064ec
-- 
2.53.0

