Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB1AEC43334
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Jul 2022 18:27:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239607AbiGHS1F (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Jul 2022 14:27:05 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47324 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S239609AbiGHS0k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2022 14:26:40 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5B4D888F35;
        Fri,  8 Jul 2022 11:26:25 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 83807B82928;
        Fri,  8 Jul 2022 18:26:06 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C86E1C341C6;
        Fri,  8 Jul 2022 18:26:04 +0000 (UTC)
Subject: [PATCH v3 22/32] NFSD: nfsd_file_hash_remove can compute hashval
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc:     david@fromorbit.com, jlayton@redhat.com, tgraf@suug.ch
Date:   Fri, 08 Jul 2022 14:26:03 -0400
Message-ID: <165730476376.28142.6727024491872832707.stgit@klimt.1015granger.net>
In-Reply-To: <165730437087.28142.6731645688073512500.stgit@klimt.1015granger.net>
References: <165730437087.28142.6731645688073512500.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5.dev3+g9561319
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Remove an unnecessary use of nf_hashval.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/filecache.c |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 26d10e3c4e70..490e7d7da7d2 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -294,6 +294,18 @@ nfsd_file_do_unhash(struct nfsd_file *nf)
 	atomic_long_dec(&nfsd_filecache_count);
 }
 
+static void
+nfsd_file_hash_remove(struct nfsd_file *nf)
+{
+	struct inode *inode = nf->nf_inode;
+	unsigned int hashval = (unsigned int)hash_long(inode->i_ino,
+				NFSD_FILE_HASH_BITS);
+
+	spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
+	nfsd_file_do_unhash(nf);
+	spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
+}
+
 static bool
 nfsd_file_unhash(struct nfsd_file *nf)
 {
@@ -513,11 +525,8 @@ static void nfsd_file_gc_dispose_list(struct list_head *dispose)
 {
 	struct nfsd_file *nf;
 
-	list_for_each_entry(nf, dispose, nf_lru) {
-		spin_lock(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
-		nfsd_file_do_unhash(nf);
-		spin_unlock(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
-	}
+	list_for_each_entry(nf, dispose, nf_lru)
+		nfsd_file_hash_remove(nf);
 	nfsd_file_dispose_list_delayed(dispose);
 }
 


