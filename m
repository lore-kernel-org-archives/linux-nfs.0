Return-Path: <SRS0=DK+G=SY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 011F3C282CE
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 16:34:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BD880214AE
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 16:34:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555950869;
	bh=0PkiT99TqIXGtWCzH1VP7uqeerenrH5VZ7io2KGU7AY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=b6oaCVZvahMhX8OjRxeTve7K0wXF05pTbsFFpMGLz6XYPEIb9hBIUJjLNRcLo3T8e
	 lblXSHlbwhv6uvn4/bJPGdImJQqQtNim5AuYrOGXlQw1A12qwdlRskwdNj8ZbGQEjF
	 T1h7OZLcc0ggrLCYVIns2wLdKbDpHfEKGDQAgLuc=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727463AbfDVQe3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Apr 2019 12:34:29 -0400
Received: from mail.kernel.org ([198.145.29.99]:48720 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727347AbfDVQe3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Apr 2019 12:34:29 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id AA3F221738;
        Mon, 22 Apr 2019 16:34:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1555950868;
        bh=0PkiT99TqIXGtWCzH1VP7uqeerenrH5VZ7io2KGU7AY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=IWXM6/aMV76bj9HPYCC2tINs5KDbhZBzZeFZfMlr8dTCStcCQoso4W/OAuS8Vc4mc
         Ry/3+XfBK4ZEPTbh55zDbLQmuYLlv6cuLd8YNJo45mahMLRkHySCApLgX994V086NC
         +0jRuqWhJ863VDAgrIP7wlkWx9jD17bhkxAsDyeU=
From:   Jeff Layton <jlayton@kernel.org>
To:     bfields@fieldses.org
Cc:     slawek1211@gmail.com, neilb@suse.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] nfsd: wake blocked file lock waiters before sending callback
Date:   Mon, 22 Apr 2019 12:34:24 -0400
Message-Id: <20190422163424.19402-3-jlayton@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190422163424.19402-1-jlayton@kernel.org>
References: <20190422163424.19402-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When a blocked NFS lock is "awoken" we send a callback to the server and
then wake any hosts waiting on it. If a client attempts to get a lock
and then drops off the net, we could end up waiting for a long time
until we end up waking locks blocked on that request.

Add a new "prepare" phase for CB_NOTIFY_LOCK callbacks, and have it
call locks_delete_block to wake any lock requests waiting on the
one for which we're sending the callback before it is sent.

URL: https://bugzilla.kernel.org/show_bug.cgi?id=203363
Fixes: 16306a61d3b7 ("fs/locks: always delete_block after waiting.")
Reported-by: Slawomir Pryczek <slawek1211@gmail.com>
Cc: Neil Brown <neilb@suse.com>
Cc: stable@vger.kernel.org
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e87e15df2044..f056b1d3fecd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -298,6 +298,14 @@ remove_blocked_locks(struct nfs4_lockowner *lo)
 	}
 }
 
+static void
+nfsd4_cb_notify_lock_prepare(struct nfsd4_callback *cb)
+{
+	struct nfsd4_blocked_lock	*nbl = container_of(cb,
+						struct nfsd4_blocked_lock, nbl_cb);
+	locks_delete_block(&nbl->nbl_lock);
+}
+
 static int
 nfsd4_cb_notify_lock_done(struct nfsd4_callback *cb, struct rpc_task *task)
 {
@@ -325,6 +333,7 @@ nfsd4_cb_notify_lock_release(struct nfsd4_callback *cb)
 }
 
 static const struct nfsd4_callback_ops nfsd4_cb_notify_lock_ops = {
+	.prepare	= nfsd4_cb_notify_lock_prepare,
 	.done		= nfsd4_cb_notify_lock_done,
 	.release	= nfsd4_cb_notify_lock_release,
 };
-- 
2.20.1

