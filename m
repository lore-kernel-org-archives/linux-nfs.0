Return-Path: <SRS0=Y3U+=SW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5856C282DD
	for <linux-nfs@archiver.kernel.org>; Sat, 20 Apr 2019 10:15:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7B4852087F
	for <linux-nfs@archiver.kernel.org>; Sat, 20 Apr 2019 10:15:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555755351;
	bh=Sqynm2vSbQ1pAh/3FcXrwFTMrJUwFTkrxoodJHFBfA0=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=KgDV1C1kXlXj0p5Jk/wgwC0cCE5DPtlbDS3U1h5Jw3zPyHb1/N4ZRV1edJgnWEFnq
	 wGK+FaGrZ34uaIKdO5MCfoSFHL6WLg1sIRUJmxlKkdXPLP9v8ivCI5a2srNox5gLOd
	 ZHTcJXI7ELKlV1kW2M+ew8AAgjm18+qOJqCq7zgk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726082AbfDTKPu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 20 Apr 2019 06:15:50 -0400
Received: from mail.kernel.org ([198.145.29.99]:36092 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725920AbfDTKPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Apr 2019 06:15:50 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 649D32087B;
        Sat, 20 Apr 2019 10:15:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1555755349;
        bh=Sqynm2vSbQ1pAh/3FcXrwFTMrJUwFTkrxoodJHFBfA0=;
        h=From:To:Cc:Subject:Date:From;
        b=TFlYii+F3H67zOX8b/mENa/XRCx1SjMI2/gLtscPnA5l6T0dG8aC/E+FJLvMeNLHo
         pu2zlPSdszk+MBMfWQrfUpKGCP7CPqfyk7F1rXRIr6kNYp2tE2gKYyIWvCkVPE45iX
         LngnHXERmf/R52j7gg2ENj+yjuOh07AifhxH1J00=
From:   Jeff Layton <jlayton@kernel.org>
To:     bfields@fieldses.org
Cc:     slawek1211@gmail.com, neilb@suse.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: wake waiters blocked on file_lock before deleting it
Date:   Sat, 20 Apr 2019 06:15:48 -0400
Message-Id: <20190420101548.8552-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After a blocked nfsd file_lock request is deleted, knfsd will send a
callback to the client and then free the request. Commit 16306a61d3b7
("fs/locks: always delete_block after waiting.") changed it such that
locks_delete_block is always called on a request after it is awoken,
but that patch missed fixing up blocked nfsd request handling.

Call locks_delete_block on the block to wake up any locks still blocked
on the nfsd lock request before sending the callback.

URL: https://bugzilla.kernel.org/show_bug.cgi?id=203363
Fixes: 16306a61d3b7 ("fs/locks: always delete_block after waiting.")
Reported-by: Slawomir Pryczek <slawek1211@gmail.com>
Cc: Neil Brown <neilb@suse.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6a45fb00c5fc..1960e8fd9ad1 100644
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

