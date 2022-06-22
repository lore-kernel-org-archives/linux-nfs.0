Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 811E4CCA481
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jun 2022 14:16:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1358185AbiFVOQj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jun 2022 10:16:39 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37512 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1358251AbiFVOP6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2022 10:15:58 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 838703B3C1;
        Wed, 22 Jun 2022 07:15:34 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 46F4DB81F69;
        Wed, 22 Jun 2022 14:15:33 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B83E3C3411B;
        Wed, 22 Jun 2022 14:15:31 +0000 (UTC)
Subject: [PATCH RFC 25/30] NFSD: Clean up "open file" case in
 nfsd_file_acquire()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc:     david@fromorbit.com, tgraf@suug.ch, jlayton@redhat.com
Date:   Wed, 22 Jun 2022 10:15:30 -0400
Message-ID: <165590733080.75778.16386422015870544314.stgit@manet.1015granger.net>
In-Reply-To: <165590626293.75778.9843437418112335153.stgit@manet.1015granger.net>
References: <165590626293.75778.9843437418112335153.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Refactor a little to prepare for changes to nfsd_file_find_locked().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/filecache.c |   27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index ae813e6f645f..8b8d765a0df0 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -1003,23 +1003,22 @@ nfsd_do_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	rcu_read_lock();
 	nf = nfsd_file_find_locked(inode, may_flags, hashval, net);
 	rcu_read_unlock();
-	if (nf)
-		goto wait_for_construction;
+	if (nf == NULL) {
+		new = nfsd_file_alloc(inode, may_flags, net);
+		if (!new) {
+			status = nfserr_jukebox;
+			goto out_status;
+		}
 
-	new = nfsd_file_alloc(inode, may_flags, net);
-	if (!new) {
-		status = nfserr_jukebox;
-		goto out_status;
-	}
+		spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
+		nf = nfsd_file_find_locked(inode, may_flags, hashval, net);
+		if (nf == NULL)
+			goto open_file;
+		spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
 
-	spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
-	nf = nfsd_file_find_locked(inode, may_flags, hashval, net);
-	if (nf == NULL)
-		goto open_file;
-	spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
-	nfsd_file_slab_free(&new->nf_rcu);
+		nfsd_file_slab_free(&new->nf_rcu);
+	}
 
-wait_for_construction:
 	wait_on_bit(&nf->nf_flags, NFSD_FILE_PENDING, TASK_UNINTERRUPTIBLE);
 
 	/* Did construction of this file fail? */


