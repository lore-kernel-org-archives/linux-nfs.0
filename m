Return-Path: <SRS0=dGNU=Y7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AAFAC5DF60
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Nov 2019 06:18:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E985821D6C
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Nov 2019 06:18:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726897AbfKGGSM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Nov 2019 01:18:12 -0500
Received: from smtprelay0145.hostedemail.com ([216.40.44.145]:58769 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725938AbfKGGSL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2019 01:18:11 -0500
X-Greylist: delayed 408 seconds by postgrey-1.27 at vger.kernel.org; Thu, 07 Nov 2019 01:18:11 EST
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave07.hostedemail.com (Postfix) with ESMTP id 962AC1802ED6D
        for <linux-nfs@vger.kernel.org>; Thu,  7 Nov 2019 06:11:24 +0000 (UTC)
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay02.hostedemail.com (Postfix) with ESMTP id 459952471;
        Thu,  7 Nov 2019 06:11:23 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: paint27_bfd63cc44947
X-Filterd-Recvd-Size: 4632
Received: from XPS-9350.home (unknown [47.151.135.224])
        (Authenticated sender: joe@perches.com)
        by omf17.hostedemail.com (Postfix) with ESMTPA;
        Thu,  7 Nov 2019 06:11:22 +0000 (UTC)
Message-ID: <1cc2ec36b5eedefc44826bb173a40528a4badca6.camel@perches.com>
Subject: [PATCH] NFS: Correct comment tyops -> typos
From:   Joe Perches <joe@perches.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Date:   Wed, 06 Nov 2019 22:11:09 -0800
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.34.1-2 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Just fix the typos checkpatch notices...

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/nfs/export.c                        | 2 +-
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
 fs/nfs/nfs4_fs.h                       | 2 +-
 fs/nfs/nfs4proc.c                      | 4 ++--
 fs/nfs/nfs4xdr.c                       | 2 +-
 fs/nfs/pnfs.c                          | 2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index deecb6..c54cc1d 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -18,7 +18,7 @@ enum {
 	FILEID_HIGH_OFF = 0,	/* inode fileid high */
 	FILEID_LOW_OFF,		/* inode fileid low */
 	FILE_I_TYPE_OFF,	/* inode type */
-	EMBED_FH_OFF		/* embeded server fh */
+	EMBED_FH_OFF		/* embedded server fh */
 };
 
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5657b7f..ca4cc6 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -123,7 +123,7 @@ static int decode_nfs_fh(struct xdr_stream *xdr, struct nfs_fh *fh)
  * I.e., kerberos is not supported to the DSes, so no pricipals.
  *
  * That means that one common function will suffice, but when
- * principals are added, this should be split to accomodate
+ * principals are added, this should be split to accommodate
  * calls to both nfs_map_name_to_uid() and nfs_map_group_to_gid().
  */
 static int
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 16b2e5..25eebd 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -345,7 +345,7 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 	if (sp4_mode == NFS_SP4_MACH_CRED_CLEANUP ||
 	    sp4_mode == NFS_SP4_MACH_CRED_PNFS_CLEANUP) {
 		/* Using machine creds for cleanup operations
-		 * is only relevent if the client credentials
+		 * is only relevant if the client credentials
 		 * might expire. So don't bother for
 		 * RPC_AUTH_UNIX.  If file was only exported to
 		 * sec=sys, the PUTFH would fail anyway.
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index caacf5..420b3f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7701,7 +7701,7 @@ int nfs4_proc_fsid_present(struct inode *inode, const struct cred *cred)
 }
 
 /*
- * If 'use_integrity' is true and the state managment nfs_client
+ * If 'use_integrity' is true and the state management nfs_client
  * cl_rpcclient is using krb5i/p, use the integrity protected cl_rpcclient
  * and the machine credential as per RFC3530bis and RFC5661 Security
  * Considerations sections. Otherwise, just use the user cred with the
@@ -9411,7 +9411,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 }
 
 /*
- * Use the state managment nfs_client cl_rpcclient, which uses krb5i (if
+ * Use the state management nfs_client cl_rpcclient, which uses krb5i (if
  * possible) as per RFC3530bis and RFC5661 Security Considerations sections
  */
 static int
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ab07db..4befb5a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4768,7 +4768,7 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
 }
 
 /*
- * The prefered block size for layout directed io
+ * The preferred block size for layout directed io
  */
 static int decode_attr_layout_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
 				      uint32_t *res)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bb80034..378a672 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1873,7 +1873,7 @@ static void _add_to_server_list(struct pnfs_layout_hdr *lo,
 }
 
 /*
- * Layout segment is retreived from the server if not cached.
+ * Layout segment is retrieved from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
  */
 struct pnfs_layout_segment *


