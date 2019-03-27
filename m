Return-Path: <SRS0=BAWL=R6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 545C2C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Mar 2019 19:11:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2561A2064A
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Mar 2019 19:11:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389001AbfC0TLW convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Mar 2019 15:11:22 -0400
Received: from 193-32-235-38.hosts.ezit.hu ([193.32.235.38]:35208 "EHLO
        zentai.name" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S2388428AbfC0TLV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Mar 2019 15:11:21 -0400
X-Greylist: delayed 454 seconds by postgrey-1.27 at vger.kernel.org; Wed, 27 Mar 2019 15:11:20 EDT
From:   Armin Zentai <armin@zentai.name>
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: 8BIT
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: [PATCH] Add EMFILE to nfsd errors
Message-Id: <23B588B3-C119-4036-B60B-7872A52129F4@zentai.name>
Date:   Wed, 27 Mar 2019 20:03:43 +0100
To:     linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patch adds the EMFILE to nfsd errors for better error output.

I've encountered a hard-to-debug situation, when I used a fuse under an NFS export, because of a 'too many open files' error.

Before the patch nfsd warns with this message:
'nfsd4_process_open2 failed to open newly-created file! status=5'  (5: EIO)

After the patch:
'nfsd4_process_open2 failed to open newly-created file! status=24' (24: EMFILE)

Also the client returns with EREMOTEIO instead of EIO, which indicates a server error from the NFS client side.

Signed-off-by: Armin ZENTAI <armin@zentai.name>
---
 fs/nfsd/nfsd.h           | 1 +
 fs/nfsd/nfsproc.c        | 1 +
 include/uapi/linux/nfs.h | 1 +
 3 files changed, 3 insertions(+)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 066899929863..19a269d75fb5 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -217,6 +217,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_cb_path_down	cpu_to_be32(NFSERR_CB_PATH_DOWN)
 #define	nfserr_locked		cpu_to_be32(NFSERR_LOCKED)
 #define	nfserr_wrongsec		cpu_to_be32(NFSERR_WRONGSEC)
+#define nfserr_emfile  		cpu_to_be32(NFSERR_EMFILE)
 #define nfserr_badiomode		cpu_to_be32(NFS4ERR_BADIOMODE)
 #define nfserr_badlayout		cpu_to_be32(NFS4ERR_BADLAYOUT)
 #define nfserr_bad_session_digest	cpu_to_be32(NFS4ERR_BAD_SESSION_DIGEST)
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 0d20fd161225..ff9e883c7829 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -810,6 +810,7 @@ nfserrno (int errno)
 		{ nfserr_serverfault, -ENFILE },
 		{ nfserr_io, -EUCLEAN },
 		{ nfserr_perm, -ENOKEY },
+		{ nfserr_emfile, -EMFILE },
 	};
 	int	i;

diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
index 946cb62d64b0..dcb0ea33f2db 100644
--- a/include/uapi/linux/nfs.h
+++ b/include/uapi/linux/nfs.h
@@ -57,6 +57,7 @@
 	NFSERR_NOTDIR = 20,		/* v2 v3 v4 */
 	NFSERR_ISDIR = 21,		/* v2 v3 v4 */
 	NFSERR_INVAL = 22,		/* v2 v3 v4 */
+	NFSERR_EMFILE = 24,		/* v2 v3 v4 */
 	NFSERR_FBIG = 27,		/* v2 v3 v4 */
 	NFSERR_NOSPC = 28,		/* v2 v3 v4 */
 	NFSERR_ROFS = 30,		/* v2 v3 v4 */
--
2.11.0

