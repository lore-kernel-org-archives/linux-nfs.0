Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.48.13
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793660085;
	b=W9NRcHz3ubgQ+QrxRHI4Hj7MkYTeie80H2B1RgHjzoh/v2wo4GnmWwDDg+KlJ0jEke6l
	 efGwRiQelpP7w2t5al752loqF+iPtndmvjF2PwOPS9t4dhmhum/c77qPy9mHhSi+K0VYO
	 Z8KZE1WoBvj1AQXStv0VOG3fKqf09X7l0V1YEFUbBR6/aeh3IVPdE/IEpRXo7pEyar9uj
	 0EYzjzuzRwMdxMeIPYBL06E91dUbawL7fht36Fle3GvhvTysAfUNxklgXmLwc9xE2OZOd
	 GEcXlr3dzejeXO2Or5rZFKooI1lgUo5OBT98JmxDdSvQsOwqPuAjMcaCvmK6vu91hOw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793660085;
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
	bh=dcW73MqQCJwIJ4CJb942CpXqqltTU8ZuaRm5NKisi0A=;
	b=M4jq+WKW1hOSCvurMyEoBtWlMvRD5xH0tkHJiab7NI8Cl8JEFfaky2oVDJa7CMYEV0zm
	 k/6XxZzDRXf+pKzcsFZ8CBhyQpkhI8hBl+g7n0XNUPzucuim8j3e+UU3rc+cC3ZtInxqB
	 DFrqGbqR4+IUua2eVcddPi/gUNgAuunGSMS9QIk7Q//z4b4IwdiAOHQ9FnyZg6hazb0hw
	 ka3FZQ4zLUOjm152ZnpVllVhaSGCPsHFtFvV/HGqBVqL8Ytt8NYBSj71FreddxOYEVTuQ
	 PW3PuiUR6NkxfImPLHRaaZoIc8bSBcFfKaGLwNjGprbtdo3vX/3Up4goZN+9cYYNbug==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=nvidia.com;
	spf=fail smtp.mailfrom=nvidia.com;
	dkim=pass header.d=Nvidia.com header.i=@Nvidia.com header.a=rsa-sha256 header.s=selector2 header.b=KqLv3EAH;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.48.13
Received: from MW6PR02CU001.outbound.protection.outlook.com (mail-westus2azon11012013.outbound.protection.outlook.com [52.101.48.13])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 703A8606D80D;
	Mon,  2 Nov 2026 22:54:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 703A8606D80D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=Nvidia.com header.i=@Nvidia.com header.a=rsa-sha256 header.s=selector2 header.b=KqLv3EAH
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=yIOAFLIEmH88HhSV23YgwsxgbnSbactDuCP/BRwmWIEeg7hAEq+JIkYKz0DrfnC9QEYq/aIQIn6zME6pt9eeO2sV6+FN5mz+wG/hKJJKShxeUFuSQaXea3sKbeL/O+u3Da8DW33aVuRT/4sBS0TCvOniR0F0moSJoOq19ET2zun7aWR+DmvRS1vQcGQLa5Czm3ODkr7YaELa5rWBm6/SrtI7HT1mRrPBkcjN0x5xW9SqDWX6vuY7c8U9hDpno1V57Ff+2pjXMkoTfCvHnSSbq0EpNMBnN33nEDr8AKiMTyqQOmCzO8dioxbVbf/y3Xxfl0dYWshROQG/0DJlTxYqEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=dcW73MqQCJwIJ4CJb942CpXqqltTU8ZuaRm5NKisi0A=;
 b=Fd5z7FJV3irrmNoabQ4fLfGvhmCLQ50LChUvgO+fD0bNnUzKwrOlr0YR+LeKL/VXWPMsR5wRSMr/KwGvR9q/pp/jdLNDCqftS7v5e0bqXFo5jfL4C9eJnqbX5CytgAkIr6XKrQwBdVcoR4co9RYE5QNx972i3b8+sRF3pzkPGQ8Aj8skJiYcBv26YhTBXjMFlt3F6iWcMuVp/Dv40dyVgOM+luGoi2kNZOqVTVuhAij0WuQ4rNEATNGlqiCtCl3JxMeihgdgJ9UR75j1NH1RIs5YS1z437DPseSiJzEIFAzgTDNoqj3da3oQVeABM6uavJWjxYPPRORv/MakWO2P5Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 216.228.117.161) smtp.rcpttodomain=kernel.org smtp.mailfrom=nvidia.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=nvidia.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dcW73MqQCJwIJ4CJb942CpXqqltTU8ZuaRm5NKisi0A=;
 b=KqLv3EAH0C0Z8hahI9S4NmPCSOhuEB/24jG9Wffzfed9vlHTnJOyqU78hM5jyh9ToG0D6d2EgitNy77Yy95de0hxxsZDGVzMt/C3fB+yY4cPLSolGgCqlmwo7XxLmXt/fyj+xxjmbBxrIVw01HYLDkBcdkmvqf8uDbhtcCs6pi3F/IkCgxaNwUeBq5AVh8t9o7Fu9R9o7qS59H+CtNcUAAF/97fre4U2Q0RvfgLihC+FWucpL8dlq8ng05YnFl6puGJaEGFZTcEjn+VMEPrY518p5wkpa3fQPYOpIIWNyhhJ2pLLXctdXTs2XMA2XbQsca0ntN3f9caHKj053vkJAg==
Received: from SJ0PR03CA0367.namprd03.prod.outlook.com (2603:10b6:a03:3a1::12)
 by CY1PR12MB9558.namprd12.prod.outlook.com (2603:10b6:930:fe::13) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.569.12; Mon, 2 Nov
 2026 22:54:41 +0000
Received: from MW2PEPF00014679.namprd04.prod.outlook.com
 (2603:10b6:a03:3a1:cafe::4c) by SJ0PR03CA0367.outlook.office365.com
 (2603:10b6:a03:3a1::12) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.569.12 via Frontend Transport; Mon, 2
 Nov 2026 22:54:41 +0000
X-MS-Exchange-Authentication-Results: mx.microsoft.com 1; spf=pass (sender IP
 is 216.228.117.161) smtp.mailfrom=nvidia.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=nvidia.com;
Received-SPF: Pass (protection.outlook.com: domain of nvidia.com designates
 216.228.117.161 as permitted sender) receiver=protection.outlook.com;
 client-ip=216.228.117.161; helo=mail.nvidia.com; pr=C
Received: from mail.nvidia.com (216.228.117.161) by
 MW2PEPF00014679.mail.protection.outlook.com (10.167.249.186) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.592.5 via Frontend Transport; Mon, 2 Nov 2026 22:54:40 +0000
Received: from rnnvmail201.nvidia.com (10.129.68.8) by mail.nvidia.com
 (10.129.200.67) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.56; Mon, 2 Nov
 2026 14:54:19 -0800
Received: from 8e48b22-lcelt.nvidia.com (10.126.230.37) by
 rnnvmail201.nvidia.com (10.129.68.8) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.56; Mon, 2 Nov 2026 14:54:15 -0800
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
Subject: [PATCH v2] sunrpc: fix lost wakeups when stopping service threads
Date: Mon, 2 Nov 2026 23:53:58 +0100
Message-ID: <20261102225358.414367-1-kalcutterc@nvidia.com>
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
X-ClientProxiedBy: rnnvmail203.nvidia.com (10.129.68.9) To
 rnnvmail201.nvidia.com (10.129.68.8)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: MW2PEPF00014679:EE_|CY1PR12MB9558:EE_
X-MS-Office365-Filtering-Correlation-Id: 70b3791b-39c3-4464-87e9-08df39344779
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|7416014|82310400026|36860700016|1800799024|376014|23010399003|18002099003|22082099003|10067099003|56012099006|261102123227099003|261102130727099003|13003099007|261009223027099003|921020|261022105027099003|261028144727099003|261021121427099003|261022075727099003|11063799006|261026140227099003|261026121527099003;
X-Microsoft-Antispam-Message-Info:
	1XdCuQRU2sUgayKOcqpKZThg8nsw9ZiujSD91hGxgfhEz91mqs04zwCtoDAuRehoRpuEq2qSx7f2ZKhZ2U/XB8zP17A6K48xfEIOnMu9jRJ+WsThQ18HzLf6OYaK1//DvAjYrhBZ323WQ7waPa6tVsBo1Jej/d6D//U7984wc3Se9/DPqmNzCWB+JB5IK6x1AfgT2X6P4FsZz8lgPHmEQNGDFTlKAov4W+g0Ab5a75VC2XmoIwUEPdJZFjT7jbkIBboNDw8wnXTUYRIzPuhlEEoFt8noQyfauuaQUyX6WdDqYcPV6NlEtrDJFRN7b7JEIdE06RIZEyn4tampE9NgJBMF1iYB5DWDXlItc33Mw6A7qwa4fGtZYnSo2LnqGsKBFwV+raQ+eD0WYdu0zuhBGWmdcb29QfpRdxJ98/lkTwC09zywb3wCs+JF0lrfxgBh4DAKSebGPME2TfA2kEg58XTsa+232FDoqzFf8swQV6fNTj9V94qKEil2powYjqmtRuJUVg5/I2yCH+jShz4E3z2IVf/7V5Hc4ZlvgtjpGnoU35TbH37Yr55peaCdMXdoUTSOZXBTPkO8/fic8DQ9UK2QfgHLAOe7OBFMLUBjfgGrVbob+jvRVZ7OzH1JupbGb2+CM52azz0mtdm0ANTInzW4Gr6VMJx7LS61OuSJhT29p6/UA9e2i2iO/cs//BlBNvtvmfCDPAFAHnX5dv1iFGxdq2ZH5x+sNO23Veeuvcytff/BRNSAvc8EUu+UcXIZ
X-Forefront-Antispam-Report:
	CIP:216.228.117.161;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:mail.nvidia.com;PTR:dc6edge2.nvidia.com;CAT:NONE;SFS:(13230040)(7416014)(82310400026)(36860700016)(1800799024)(376014)(23010399003)(18002099003)(22082099003)(10067099003)(56012099006)(261102123227099003)(261102130727099003)(13003099007)(261009223027099003)(921020)(261022105027099003)(261028144727099003)(261021121427099003)(261022075727099003)(11063799006)(261026140227099003)(261026121527099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	OGxGvS+BHgBm+PowF+ZqmnkhrH5corGMZVWpNSMxRN8ISUPBOijywGoXbJ16/bMT9jVFUJa97zMbRDFSsaekF0u2YohDkoXCo9f1kP/y9+/86M2mhiNETbqNq8R0yE1wAHWZo3Q22Q5qhEkGUI0VJiX7ZgjWwoJfAquWPd10buDKmNacjM7VshTWmACxgzv3wDu6a1lCARiyNGPNR83AiqCFvAdMtNuB2x6tvVL0osWq9EeoF2Sa142LNo13DjSUJCx+hm5AMA/fsE7WdfF1iJIU+xy83bPuBgjE/ksMPW/f6YmM54qfAN2KIdGsjeG7PP88/4lVqXzWsL9rvfb8jCpMrbJRwuSI9WFhqMqqIj0MasCrcRwXm2pLTGjacv6qUPQNrG01ZYOocP5tca8AqpI+fz3jqvuCm/fs7lGj2fUFBQbGoaOkBA5UgK9ooYJ/
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Nov 2026 22:54:40.9199
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 70b3791b-39c3-4464-87e9-08df39344779
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=43083d15-7273-40c1-b7db-39efd9ccc17a;Ip=[216.228.117.161];Helo=[mail.nvidia.com]
X-MS-Exchange-CrossTenant-AuthSource:
	MW2PEPF00014679.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY1PR12MB9558

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
Changes in v2:
- Move the barrier into svc_stop_kthreads() and svc_wake_up(), using
  smp_mb__after_atomic(). This avoids adding a redundant barrier on the
  transport enqueue path.

v1: https://lore.kernel.org/r/20261030130629.103716-1-kalcutterc@nvidia.com

 net/sunrpc/svc.c      | 7 +++++++
 net/sunrpc/svc_xprt.c | 5 +++++
 2 files changed, 12 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index af8d87c1de83..76232774646c 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -29,6 +29,8 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/bc_xprt.h>
 
+#include <asm/barrier.h>
+
 #include <trace/events/sunrpc.h>
 
 #include "fail.h"
@@ -784,6 +786,11 @@ svc_stop_kthreads(struct svc_serv *serv, struct svc_pool *pool, int nrservs)
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

