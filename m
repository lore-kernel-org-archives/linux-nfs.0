Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84121C64EB4
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4F45320834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F45320834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725788AbeLCAcI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:32:08 -0500
Received: from mx2.suse.de ([195.135.220.15]:40780 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAcI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:32:08 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 648BBAD90;
        Mon,  3 Dec 2018 00:32:02 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 01/23] cred: add cred_fscmp() for comparing creds.
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703003.28598.12775774846678611265.stgit@noble>
In-Reply-To: <154379689752.28598.6750646657534626618.stgit@noble>
References: <154379689752.28598.6750646657534626618.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

NFS needs to compare to credentials, to see if they can
be treated the same w.r.t. filesystem access.  Sometimes
an ordering is needed when credentials are used as a key
to an rbtree.
NFS currently has its own private credential management from
before 'struct cred' existed.  To move it over to more consistent
use of 'struct cred' we need a comparison function.
This patch adds that function.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/cred.h |    1 +
 kernel/cred.c        |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 7eed6101c791..f1085767e1b3 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -169,6 +169,7 @@ extern int change_create_files_as(struct cred *, struct inode *);
 extern int set_security_override(struct cred *, u32);
 extern int set_security_override_from_ctx(struct cred *, const char *);
 extern int set_create_files_as(struct cred *, struct inode *);
+extern int cred_fscmp(const struct cred *, const struct cred *);
 extern void __init cred_init(void);
 
 /*
diff --git a/kernel/cred.c b/kernel/cred.c
index ecf03657e71c..0b3ac72bd717 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -19,6 +19,7 @@
 #include <linux/security.h>
 #include <linux/binfmts.h>
 #include <linux/cn_proc.h>
+#include <linux/uidgid.h>
 
 #if 0
 #define kdebug(FMT, ...)						\
@@ -564,6 +565,60 @@ void revert_creds(const struct cred *old)
 }
 EXPORT_SYMBOL(revert_creds);
 
+/**
+ * cred_fscmp - Compare two credentials with respect to filesystem access.
+ * @a: The first credential
+ * @b: The second credential
+ *
+ * cred_cmp() will return zero if both credentials have the same
+ * fsuid, fsgid, and supplementary groups.  That is, if they will both
+ * provide the same access to files based on mode/uid/gid.
+ * If the credentials are different, then either -1 or 1 will
+ * be returned depending on whether @a comes before or after @b
+ * respectively in an arbitrary, but stable, ordering of credentials.
+ *
+ * Return: -1, 0, or 1 depending on comparison
+ */
+int cred_fscmp(const struct cred *a, const struct cred *b)
+{
+	struct group_info *ga, *gb;
+	int g;
+
+	if (a == b)
+		return 0;
+	if (uid_lt(a->fsuid, b->fsuid))
+		return -1;
+	if (uid_gt(a->fsuid, b->fsuid))
+		return 1;
+
+	if (gid_lt(a->fsgid, b->fsgid))
+		return -1;
+	if (gid_gt(a->fsgid, b->fsgid))
+		return 1;
+
+	ga = a->group_info;
+	gb = b->group_info;
+	if (ga == gb)
+		return 0;
+	if (ga == NULL)
+		return -1;
+	if (gb == NULL)
+		return 1;
+	if (ga->ngroups < gb->ngroups)
+		return -1;
+	if (ga->ngroups > gb->ngroups)
+		return 1;
+
+	for (g = 0; g < ga->ngroups; g++) {
+		if (gid_lt(ga->gid[g], gb->gid[g]))
+			return -1;
+		if (gid_gt(ga->gid[g], gb->gid[g]))
+			return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(cred_fscmp);
+
 /*
  * initialise the credentials stuff
  */


