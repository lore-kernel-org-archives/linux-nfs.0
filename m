Return-Path: <SRS0=zkC/=D3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD493C4363A
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Oct 2020 18:39:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9083A21D7B
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Oct 2020 18:39:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1603219181;
	bh=y1GZHeyFiLzYGhfnTxlC1KUcazwO2ji8I77P8rOG2Qo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=FnlQp42wlKuqMDyPtOHrphCb0FWWGqkH3/+Lewwg6VUy8Pg9qzMHu9Nk7r57Hzs3F
	 B9riNbVpvZdObrDj8/OttBvaBUG2J3vLrFxIIGCcSE7j4hubw10j/fjhy70Ldi7LEV
	 23Ee49b4VPPHZILz+q5R8ugecSNaJBmFGGTJszCw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2437496AbgJTSjl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Oct 2020 14:39:41 -0400
Received: from mail.kernel.org ([198.145.29.99]:51846 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389212AbgJTSjk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Oct 2020 14:39:40 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A7B8922247;
        Tue, 20 Oct 2020 18:39:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1603219180;
        bh=y1GZHeyFiLzYGhfnTxlC1KUcazwO2ji8I77P8rOG2Qo=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=GH3yjRxHX5xXBwDCYn6O4FSWYK+zZb6e+TvYCJ1xrkRlIOhyo7pFi9Fqwgf3QTPd4
         Q3bfU4WlkZ6X0z4qZr8WKxdsKLbqcOCxvDJ8/AFPunjNBJRU3lWwFYgXYyFId1d8Mk
         BsTBK+ukEAAXLGcC+co5jmwk/cwvaGOox+u96LSE=
From:   trondmy@kernel.org
To:     Daire Byrne <daire@dneg.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/3] NFSv4: Observe the NFS_MOUNT_SOFTREVAL flag in _nfs4_proc_lookupp
Date:   Tue, 20 Oct 2020 14:37:18 -0400
Message-Id: <20201020183718.14618-4-trondmy@kernel.org>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20201020183718.14618-3-trondmy@kernel.org>
References: <279389889.68934777.1603124383614.JavaMail.zimbra@dneg.com>
 <20201020183718.14618-1-trondmy@kernel.org>
 <20201020183718.14618-2-trondmy@kernel.org>
 <20201020183718.14618-3-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

We need to respect the NFS_MOUNT_SOFTREVAL flag in _nfs4_proc_lookupp,
by timing out if the server is unavailable.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bdf33e18fc54..c306c97c1ed0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4376,6 +4376,10 @@ static int _nfs4_proc_lookupp(struct inode *inode,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	unsigned short task_flags = 0;
+
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_SOFTREVAL)
+		task_flags |= RPC_TASK_TIMEOUT;
 
 	args.bitmask = nfs4_bitmask(server, label);
 
@@ -4383,7 +4387,7 @@ static int _nfs4_proc_lookupp(struct inode *inode,
 
 	dprintk("NFS call  lookupp ino=0x%lx\n", inode->i_ino);
 	status = nfs4_call_sync(clnt, server, &msg, &args.seq_args,
-				&res.seq_res, 0);
+				&res.seq_res, task_flags);
 	dprintk("NFS reply lookupp: %d\n", status);
 	return status;
 }
-- 
2.26.2

