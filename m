Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F175BC0044C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:13:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BB31C2086B
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:13:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB31C2086B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730610AbeKGNmc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 08:42:32 -0500
Received: from mx2.suse.de ([195.135.220.15]:56476 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726516AbeKGNmc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 08:42:32 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 29E9AB659;
        Wed,  7 Nov 2018 04:13:55 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Wed, 07 Nov 2018 15:12:30 +1100
Subject: [PATCH 04/23] cred: allow get_cred() and put_cred() to be given
 NULL.
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154156395086.24086.10808517305345523298.stgit@noble>
In-Reply-To: <154156285766.24086.14262073575778354276.stgit@noble>
References: <154156285766.24086.14262073575778354276.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

It is common practice for helpers like this to silently,
accept a NULL pointer.
get_rpccred() and put_rpccred() used by NFS act this way
and using the same interface will ease the conversion
for NFS, and simplify the resulting code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/cred.h |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 48979fcb95cf..4907c9df86b3 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -237,7 +237,7 @@ static inline struct cred *get_new_cred(struct cred *cred)
  * @cred: The credentials to reference
  *
  * Get a reference on the specified set of credentials.  The caller must
- * release the reference.
+ * release the reference.  If %NULL is passed, it is returned with no action.
  *
  * This is used to deal with a committed set of credentials.  Although the
  * pointer is const, this will temporarily discard the const and increment the
@@ -248,6 +248,8 @@ static inline struct cred *get_new_cred(struct cred *cred)
 static inline const struct cred *get_cred(const struct cred *cred)
 {
 	struct cred *nonconst_cred = (struct cred *) cred;
+	if (!cred)
+		return cred;
 	validate_creds(cred);
 	return get_new_cred(nonconst_cred);
 }
@@ -268,7 +270,7 @@ static inline const struct cred *get_cred_rcu(const struct cred *cred)
  * @cred: The credentials to release
  *
  * Release a reference to a set of credentials, deleting them when the last ref
- * is released.
+ * is released.  If %NULL is passed, nothing is done.
  *
  * This takes a const pointer to a set of credentials because the credentials
  * on task_struct are attached by const pointers to prevent accidental
@@ -278,9 +280,11 @@ static inline void put_cred(const struct cred *_cred)
 {
 	struct cred *cred = (struct cred *) _cred;
 
-	validate_creds(cred);
-	if (atomic_dec_and_test(&(cred)->usage))
-		__put_cred(cred);
+	if (cred) {
+		validate_creds(cred);
+		if (atomic_dec_and_test(&(cred)->usage))
+			__put_cred(cred);
+	}
 }
 
 /**


