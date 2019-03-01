Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FCD3C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5325A2084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NIo5q/8O"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726002AbfCAT06 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:26:58 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:45887 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725905AbfCAT06 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:26:58 -0500
Received: by mail-yw1-f65.google.com with SMTP id r188so14784196ywb.12
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:26:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q5Cp7cxRMV82Uad41xxH5Eh8eZ8l/ZcvUMn8J96Y72A=;
        b=NIo5q/8OzuXE2j8Lfzi3fCEv+sAPRuyoj5461AD2RpOkskQrDFTJZ+M98Zn/+LBQFD
         vyOBmXEH+DAV4MeMVAk8BSO7JZOEMJKDJolNhTTxj0RxDLR+7x8vOVLt6G2J5euPQoJO
         DBQG2OsOLtX7urrPQYQEzzaBx5MPpIKFCRNr0wK7xUS8wJHx0bH4Y784NvA5tdD/iu32
         CrT425tMn1P6xZOcE2ORRdjYwBhbFtkjXnW/0iGhoKbNzVWO0o40YwNVCPfmB6bzgUpA
         Ogj8HzRwQt8OkyGnXf908uzxnm6uQd3q8TKSyqibHhJSRIgfnLQj0Bx3rq7u5/grJ/ru
         2kLg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=q5Cp7cxRMV82Uad41xxH5Eh8eZ8l/ZcvUMn8J96Y72A=;
        b=gDSD11tRyu+RNzCpaZo4d8nWTip+YuVVyJTgCzQ7quTBAUFYzDPOdY5X3d65bg62lH
         KjwxlLq/2JpLGX8Dln7UPQCXEkWzWXPfDBUZSEvnc/tECl8FWnBxEC3XNs+AHG519hdF
         CuIyYvgueR5pfPJFIGubPLrUcn7++5J1wqvVWmnNkLEgBmSVkciRBavpQ4V06QwZXFHd
         PFbnuTwj+47zqXdEFByoq0T3A36o06veEHLgs5SQ+55PoXWJA6socnsfgi1gRRrVXrPn
         MCHY+XhNBzG/bTXcJ1mHikNo/z+JHirw+YaDTz9RdgKvxeJD4PMOWNBfd2E42PJZphCs
         i6ZQ==
X-Gm-Message-State: APjAAAWpN2XBv+RY2rORwoOJSsI9mm032ijhhtJYWyk/WQ/DOShB7eNS
        XTzAGK1jlFXWBa/GeaoqeOJU5co=
X-Google-Smtp-Source: APXvYqx6usKP5nc5vsA6l7JQQOXdXdDNGNfMf+Wmi8JStj+BG0/119kOEibTPJ5DJFIlCVgDCushTQ==
X-Received: by 2002:a25:dd7:: with SMTP id 206mr5838956ybn.214.1551468416777;
        Fri, 01 Mar 2019 11:26:56 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.26.55
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:26:56 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 04/19] NFSv4/flexfiles: Abort I/O early if the layout segment was invalidated
Date:   Fri,  1 Mar 2019 14:24:40 -0500
Message-Id: <20190301192455.104943-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-4-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If a layout segment gets invalidated while a pNFS I/O operation
is queued for transmission, then we ideally want to abort
immediately. This is particularly the case when there is a large
number of I/O related RPCs queued in the RPC layer, and the layout
segment gets invalidated due to an ENOSPC error, or an EACCES (because
the client was fenced). We may end up forced to spam the MDS with a
lot of otherwise unnecessary LAYOUTERRORs after that I/O fails.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 17 +++++++++++++++++
 include/linux/sunrpc/sched.h           |  1 +
 net/sunrpc/xprt.c                      |  7 +++++++
 3 files changed, 25 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 244a03c22b31..a8e9bdd978e7 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1071,6 +1071,8 @@ static int ff_layout_async_handle_error_v4(struct rpc_task *task,
 		break;
 	case -NFS4ERR_RETRY_UNCACHED_REP:
 		break;
+	case -EAGAIN:
+		return -NFS4ERR_RESET_TO_PNFS;
 	/* Invalidate Layout errors */
 	case -NFS4ERR_PNFS_NO_LAYOUT:
 	case -ESTALE:           /* mapped NFS4ERR_STALE */
@@ -1131,6 +1133,7 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
 	case -EBADHANDLE:
 	case -ELOOP:
 	case -ENOSPC:
+	case -EAGAIN:
 		break;
 	case -EJUKEBOX:
 		nfs_inc_stats(lseg->pls_layout->plh_inode, NFSIOS_DELAY);
@@ -1369,6 +1372,16 @@ static void ff_layout_read_prepare_v4(struct rpc_task *task, void *data)
 	ff_layout_read_prepare_common(task, hdr);
 }
 
+static void
+ff_layout_io_prepare_transmit(struct rpc_task *task,
+		void *data)
+{
+	struct nfs_pgio_header *hdr = data;
+
+	if (!pnfs_is_valid_lseg(hdr->lseg))
+		rpc_exit(task, -EAGAIN);
+}
+
 static void ff_layout_read_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
@@ -1657,6 +1670,7 @@ static void ff_layout_commit_release(void *data)
 
 static const struct rpc_call_ops ff_layout_read_call_ops_v3 = {
 	.rpc_call_prepare = ff_layout_read_prepare_v3,
+	.rpc_call_prepare_transmit = ff_layout_io_prepare_transmit,
 	.rpc_call_done = ff_layout_read_call_done,
 	.rpc_count_stats = ff_layout_read_count_stats,
 	.rpc_release = ff_layout_read_release,
@@ -1664,6 +1678,7 @@ static const struct rpc_call_ops ff_layout_read_call_ops_v3 = {
 
 static const struct rpc_call_ops ff_layout_read_call_ops_v4 = {
 	.rpc_call_prepare = ff_layout_read_prepare_v4,
+	.rpc_call_prepare_transmit = ff_layout_io_prepare_transmit,
 	.rpc_call_done = ff_layout_read_call_done,
 	.rpc_count_stats = ff_layout_read_count_stats,
 	.rpc_release = ff_layout_read_release,
@@ -1671,6 +1686,7 @@ static const struct rpc_call_ops ff_layout_read_call_ops_v4 = {
 
 static const struct rpc_call_ops ff_layout_write_call_ops_v3 = {
 	.rpc_call_prepare = ff_layout_write_prepare_v3,
+	.rpc_call_prepare_transmit = ff_layout_io_prepare_transmit,
 	.rpc_call_done = ff_layout_write_call_done,
 	.rpc_count_stats = ff_layout_write_count_stats,
 	.rpc_release = ff_layout_write_release,
@@ -1678,6 +1694,7 @@ static const struct rpc_call_ops ff_layout_write_call_ops_v3 = {
 
 static const struct rpc_call_ops ff_layout_write_call_ops_v4 = {
 	.rpc_call_prepare = ff_layout_write_prepare_v4,
+	.rpc_call_prepare_transmit = ff_layout_io_prepare_transmit,
 	.rpc_call_done = ff_layout_write_call_done,
 	.rpc_count_stats = ff_layout_write_count_stats,
 	.rpc_release = ff_layout_write_release,
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 219aa3910a0c..52d41d0c1ae1 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -97,6 +97,7 @@ typedef void			(*rpc_action)(struct rpc_task *);
 
 struct rpc_call_ops {
 	void (*rpc_call_prepare)(struct rpc_task *, void *);
+	void (*rpc_call_prepare_transmit)(struct rpc_task *, void *);
 	void (*rpc_call_done)(struct rpc_task *, void *);
 	void (*rpc_count_stats)(struct rpc_task *, void *);
 	void (*rpc_release)(void *);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 1cf4e379be7b..e096c5a725df 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1330,6 +1330,13 @@ xprt_request_transmit(struct rpc_rqst *req, struct rpc_task *snd_task)
 			status = -EBADMSG;
 			goto out_dequeue;
 		}
+		if (task->tk_ops->rpc_call_prepare_transmit) {
+			task->tk_ops->rpc_call_prepare_transmit(task,
+					task->tk_calldata);
+			status = task->tk_status;
+			if (status < 0)
+				goto out_dequeue;
+		}
 	}
 
 	/*
-- 
2.20.1

