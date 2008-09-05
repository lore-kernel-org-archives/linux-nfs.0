From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Restore missing hunk in NFS mount option parser
Date: Fri, 05 Sep 2008 14:16:07 -0400
Message-ID: <20080905181339.17103.36231.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:31960 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbYIESR3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 14:17:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit f45663ce5fb30f76a3414ab3ac69f4dd320e760a was missing a hunk that
prevented the new "sloppy" mount option from having any effect.

Tested against 2.6.27-rc.  2.6.26 is not affected.

Thanks to Neil Brown for reporting this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5b2aa04..e3ac650 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1279,6 +1279,12 @@ static int nfs_parse_mount_options(char *raw,
 		}
 	}
 
+	if (errors > 0) {
+		dfprintk(MOUNT, "NFS: parsing encountered %d error%s\n",
+				errors, (errors == 1 ? "" : "s"));
+		if (!sloppy)
+			return 0;
+	}
 	return 1;
 
 out_nomem:

