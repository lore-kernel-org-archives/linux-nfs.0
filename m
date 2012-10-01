Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49157 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332Ab2JARgR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:36:17 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TIjui-0007mt-Sa
	for linux-nfs@vger.kernel.org; Mon, 01 Oct 2012 13:36:16 -0400
Date: Mon, 1 Oct 2012 13:36:16 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: don't pin clientids to pseudoflavors
Message-ID: <20121001173616.GB29803@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For 3.7.--b.

commit 4f01f198b0b3da95f17d96dd54431b02d98c65d3
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Aug 21 12:48:30 2012 -0400

    nfsd4: don't pin clientids to pseudoflavors
    
    I added cr_flavor to the data compared in same_creds without any
    justification, in d5497fc693a446ce9100fcf4117c3f795ddfd0d2 "nfsd4: move
    rq_flavor into svc_cred".
    
    Recent client changes then started making
    
    	mount -osec=krb5 server:/export /mnt/
    	echo "hello" >/mnt/TMP
    	umount /mnt/
    	mount -osec=krb5i server:/export /mnt/
    	echo "hello" >/mnt/TMP
    
    to fail due to a clid_inuse on the second open.
    
    Mounting sequentially like this with different flavors probably isn't
    that common outside artificial tests.  Also, the real bug here may be
    that the server isn't just destroying the former clientid in this case
    (because it isn't good enough at recognizing when the old state is
    gone).  But it prompted some discussion and a look back at the spec, and
    I think the check was probably wrong.  Fix and document.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5122e17..0f8d7e7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1223,10 +1223,26 @@ static bool groups_equal(struct group_info *g1, struct group_info *g2)
 	return true;
 }
 
+/*
+ * RFC 3530 language requires clid_inuse be returned when the
+ * "principal" associated with a requests differs from that previously
+ * used.  We use uid, gid's, and gss principal string as our best
+ * approximation.  We also don't want to allow non-gss use of a client
+ * established using gss: in theory cr_principal should catch that
+ * change, but in practice cr_principal can be null even in the gss case
+ * since gssd doesn't always pass down a principal string.
+ */
+static bool is_gss_cred(struct svc_cred *cr)
+{
+	/* Is cr_flavor one of the gss "pseudoflavors"?: */
+	return (cr->cr_flavor > RPC_AUTH_MAXFLAVOR);
+}
+
+
 static bool
 same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 {
-	if ((cr1->cr_flavor != cr2->cr_flavor)
+	if ((is_gss_cred(cr1) != is_gss_cred(cr2))
 		|| (cr1->cr_uid != cr2->cr_uid)
 		|| (cr1->cr_gid != cr2->cr_gid)
 		|| !groups_equal(cr1->cr_group_info, cr2->cr_group_info))
