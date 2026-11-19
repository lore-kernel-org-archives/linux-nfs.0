Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795109063;
	b=3PhZbio8G8tLCqdUXzEyl5w5fBUhynR8yXtZlphdWlRviYhMry0Tk0eRM+wikfJgRNPG
	 4eSpiPLfh4t0ecf5A2dU0It8+6hJhzxIGEjITt8NyiUGOk7z/9iFsz5nFGSeHz57ErOaZ
	 vQ1rzai93vL9Zw8lgwhvT+ebtk2V5YkkgerA2ubS4lBx0OOfd9TWx9UO6cfO8qxKng2xT
	 KSz39/PoGZnJo0YTMnfNbSUp3PXt51rtYhXiy6uxz8n8WNb5t/p6x83l4xpgw+5UJZNHD
	 m5yCVd1tTz2IEphfF2HtfhNUuJRFhf9FsTkWjYhlSgyq0VhAKibWjoMUV+6NWxqg20w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795109063;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=GvYmXdIJjpD4fC/vhrs8FSXJoxdTGJbay1F4HP97M9g=;
	b=NBAMQ87+KVws84wHUsn6pdoUfZOuCtd1MQQUL20d6now3kTS2RZ6ymsf1tSPCrn9hCi8
	 dlggQnG357eXmPe5TTqATnKytlAaU2Rovh0l2uY/L938Y/4FQ5jhCr8bCIXy0cs48mb7/
	 u03GWxCIXim7h73K6F9ygYs+5cMvNU7gorJoHJWePp5XZxccDjzJkt4Lkmrti0y3SmmV7
	 SnyV7e+nYh/kcfhSWrSWRApAhMiTfY44IxyOuPCYuSUOvV9RNY0iZt344vPd2afsCBHna
	 1UCRbfQr35oKnPw9daVsZV1Ke78w0kPQpngz1m1g98MOcZPXIoY+WRNRdSoXaph7CyQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=NWLVjTYS;
	arc=none smtp.remote-ip=209.85.210.50
Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8E9160A2604
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:24:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C8E9160A2604
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=NWLVjTYS
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-862b76e3c8cso8328a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 09:24:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795109061; x=1795713861; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=GvYmXdIJjpD4fC/vhrs8FSXJoxdTGJbay1F4HP97M9g=;
        b=NWLVjTYSMzc5zONKsRN1jgmpY4rLtFtPbElQFaHbEZZCL7Wq8uFswmnE9pR0g/Urxf
         cB36lmI/euThEZSBWbBmV8SCCIDkocLlOE/PItFYND86vk3ZCTvpMNcoYpbbTyw86wTH
         21CNY6l3xtxFexUxURboKY1oQ299FWR5r404VvxzZnHoKxb8QqqUiqID9CB1nnqWZLaf
         LxqsAWzhPHW3hEdgbAcPo+6ZdweVjMPdrvJ+dGrK3PQOzPnBRiO2wJJg1R++gCpdiV0H
         /pULPASQNebh5ShY8QRxZeXc7tGEmGiN1A8Qtk0/GqWbz70pmadbWYfv5WsRaGhNyBoY
         ty3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795109061; x=1795713861;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=GvYmXdIJjpD4fC/vhrs8FSXJoxdTGJbay1F4HP97M9g=;
        b=QJ6QKeh8clzBxprGlaZvFTK2BiqYFZtTVOgVeoWdOM1yFrOYnJbimDoHJfJ5EwGmSL
         Kdffu/zhEdez1nIRy+fB+02lHLUJPKcPY3kgObfn6qVrAbbXV5EsPI3yRszmoW5x99ck
         0zrvimff3okmXSA8RFWlOxqBgHn9DK4FZ+tBxBi2uUU7KvIoJ/vqv14YwLVlUutV1BS9
         vzuy/ALpiEt3rNw4LdvBzet3spds4Mmaf4Uz0KPXC0U0yNMQYC+A7VvHR/M8ugz2JKx+
         uRvDQ7bWIbMByw0NZzB5vBW6w+O5l0jYczFYBdmO84O6+rro9h+VI0ruFV3qruCJppDh
         dcFA==
X-Gm-Message-State: APuU4Z8rysvdss05uEWGzc2dFIlBaKxdXb98Z2IOhXHDxN4EI3xSJlMK
	J7pxZRwbJd127dszkBWU8EQViyxUJRU43vsY5KC+2oFa27hdMFo6ZekAZ5h5rFDVPtoycWyTcHx
	ysWJG
X-Gm-Gg: AYBFou22t+e8TuS+u3MDf/Q8VFq6Vb0P2EIua3JaBG6xZ+hoLk/zJ4vo7WYccDqkxKT
	DstfYS7ZHDXahD5l5oY069zLKmqYp8ddCCN/HZQPzVawSs7Ev9Ln81fFc4f80dvYU+bnCieVjNi
	3VEof8ttJtqSfBUfBfh/j6ViY1b2OAVCqgBFlK/P0YvIc03VMNX6GXCYVbWZlu7o8xUjYlXVQmq
	5TSUfUidjW9UVdjXbPQy2HLpXRuYyVQUqqkRKypUhEixrwqdOXHev40sHc29ttYEy1vguqupBvF
	hCaRfTfJclAUNnP6HIWWy1KU1ko1quXf1YLn4yle3y6IfuqPhIbmnhYf9Hzd94O4qj1wrKM5zfl
	JsEjdD+tDUQ7Vyn6VXgLloWAPPh6w7nwjQrTEIGgcK44BzrL1bUt2pHDg1QBB8sxJt1Gb/omGVO
	pztkmNP23HGvaMEI4s+VtCwdpGkqBCvilNn5gYMDrmpp3IFTmItEQVi59hQ650QZglmoY4EEBAC
	dINWDJBDgqK+cBqoiEoLPU7Zc32y89ADhXvulbIoyM98AraIwVeSjtzbHZWootTFEpV3L3wHcgs
	QfX8file54RaOq3a5aMYhUnpEEek932jbN01vn7yJ0srPL4vFaFYaQRYfxly4+5udV/ip7Cegz7
	g
X-Received: by 2002:a05:6830:92a:b0:862:8382:e0ba with SMTP id 46e09a7af769-86315490d73mr922134a34.9.1795109061507;
        Thu, 19 Nov 2026 09:24:21 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-863168f6d33sm96641a34.18.2026.11.19.09.24.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 09:24:20 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: don't delay or restart an rpc_task that LOCALIO never ran
Date: Thu, 19 Nov 2026 12:24:18 -0500
Message-ID: <9c46fda0f2cd6d3843b198dac304b4722514b8e3.1795108831.git.bcodding@hammerspace.com>
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

From: Benjamin Coddington <bcodding@hammerspace.com>

LOCALIO completes a flexfiles read, write or commit without running its
rpc_task, and maps a local -ENOMEM, -EAGAIN, -ETIMEDOUT or -ERESTARTSYS
to NFS4ERR_DELAY in op_status.  The flexfiles error handlers answer
NFS4ERR_DELAY (NFSERR_JUKEBOX for v3) with rpc_delay(), and on a task
that was never activated rpc_sleep_check_activated() warns and calls
rpc_put_task_async(), taking tk_count below zero.

For a commit, ff_layout_commit_done_cb() also asks for a restart, but
LOCALIO has no way to restart a commit.  The request is dropped and the
commit is released with tk_status cleared; its pages are written again
only because the commit's zeroed verifier doesn't match theirs.

Skip rpc_delay() for a task that was never activated.  Whatever restart
the handlers ask for is still run by nfs_local_pgio_release().  For a
local commit, resend the writes instead of restarting, as is done when
a commit to a data server has to be reset.

Fixes: 38074de35b01 ("NFSv4/flexfiles: Fix handling of NFS level errors in I/O")
Cc: stable@vger.kernel.org # v6.16+
Reported-by: Sashiko <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/bug/linux-4421953e-5de7-428b-b77c-4ed6c87cd0f0
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5c289737366f..5a9a9c487647 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1355,6 +1355,13 @@ static void ff_layout_reset_read(struct nfs_pgio_header *hdr)
 	}
 }
 
+/* LOCALIO completes I/O without ever running the rpc_task */
+static void ff_layout_rpc_delay(struct rpc_task *task, unsigned long delay)
+{
+	if (RPC_IS_ACTIVATED(task))
+		rpc_delay(task, delay);
+}
+
 static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 					   u32 op_status,
 					   struct nfs4_state *state,
@@ -1392,7 +1399,7 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 		nfs_inc_stats(lseg->pls_layout->plh_inode, NFSIOS_DELAY);
 		fallthrough;
 	case NFS4ERR_GRACE:
-		rpc_delay(task, FF_LAYOUT_POLL_RETRY_MAX);
+		ff_layout_rpc_delay(task, FF_LAYOUT_POLL_RETRY_MAX);
 		goto out_retry;
 	case NFS4ERR_RETRY_UNCACHED_REP:
 		goto out_retry;
@@ -1536,7 +1543,7 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
 out_retry:
 	task->tk_status = 0;
 	rpc_restart_call_prepare(task);
-	rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
+	ff_layout_rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
 	return -EAGAIN;
 }
 
@@ -1971,6 +1978,11 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 		pnfs_generic_prepare_to_resend_writes(data);
 		return -EAGAIN;
 	case -EAGAIN:
+		/* A LOCALIO commit can't be restarted */
+		if (!RPC_IS_ACTIVATED(task)) {
+			pnfs_generic_prepare_to_resend_writes(data);
+			return -EAGAIN;
+		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	case -NFS4ERR_FATAL_IOERROR:
-- 
2.53.0

