Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f182.google.com ([209.85.210.182]:56789 "EHLO
	mail-ia0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918Ab3CHTre (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:47:34 -0500
Received: by mail-ia0-f182.google.com with SMTP id b35so83211iac.41
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:47:34 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/11] gssd: gethostname(3) returns zero or -1, not an errno
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:47:32 -0500
Message-ID: <20130308194731.5656.51395.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to "man gethostname," gssd is handling the return value of
gethostname(3) incorrectly.  It looks like other gethostname(3) call
sites in nfs-utils are already correct.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/krb5_util.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 6c37094..215c0a4 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -802,8 +802,8 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 		goto out;
 
 	/* Get full local hostname */
-	retval = gethostname(myhostname, sizeof(myhostname));
-	if (retval) {
+	if (gethostname(myhostname, sizeof(myhostname)) == -1) {
+		retval = errno;
 		k5err = gssd_k5_err_msg(context, retval);
 		printerr(1, "%s while getting local hostname\n", k5err);
 		goto out;

