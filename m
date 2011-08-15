Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43965 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751351Ab1HOWaf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 18:30:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] nfsd4: return nfserr_symlink on v4 OPEN of non-regular file
Date: Mon, 15 Aug 2011 18:30:29 -0400
Message-Id: <1313447432-1537-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20110815222859.GD32181@fieldses.org>
References: <20110815222859.GD32181@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Without this, an attempt to open a device special file without first
stat'ing it will fail.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsfh.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 90c6aa6..cc8eb8d 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -69,6 +69,17 @@ nfsd_mode_check(struct svc_rqst *rqstp, umode_t mode, int type)
 			return nfserr_notdir;
 		else if ((mode & S_IFMT) == S_IFDIR)
 			return nfserr_isdir;
+		/*
+		 * err_symlink is our catch-all error in the v4 case; this
+		 * looks odd, but:
+		 *	- the comment next to ERR_SYMLINK in file is
+		 *	  "should be file/directory"
+		 *	- we happen to know this will cause the linux v4
+		 *	  client to do the right thing on attempts to open
+		 *	  something other than a regular file:
+		 */
+		else if (rqstp->rq_vers == 4)
+			return nfserr_symlink;
 		else
 			return nfserr_inval;
 	}
-- 
1.7.4.1

