From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Restore missing hunk in NFS mount option parser
Date: Mon, 08 Sep 2008 11:58:13 -0400
Message-ID: <20080908155812.4817.77312.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11242 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbYIHP7B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2008 11:59:01 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Automounter maps can contain mount options valid for other NFS
implementations but not for Linux.  The Linux automounter uses the
mount command's "-s" command line option ("s" for "sloppy") so that
mount requests containing such options are not rejected.

Commit f45663ce5fb30f76a3414ab3ac69f4dd320e760a attempted to address a
known regression with text-based NFS mount option parsing.  Unrecognized
mount options would cause mount requests to fail, even if the "-s"
option was used on the mount command line.

Unfortunately, this commit was not complete as submitted.  It adds a
new mount option, "sloppy".  But it is missing a hunk, so it now allows
NFS mounts with unrecognized mount options, even if the "sloppy" option
is not present.  This could be a problem if a required critical mount
option such as "sync" is misspelled, for example, and is considered a
regression from 2.6.26.

This patch restores the missing hunk.  Now, the default behavior of
text-based NFS mount options is as before: any unrecognized mount option
will cause the mount to fail.

Please include this in 2.6.27-rc.

Thanks to Neil Brown for reporting this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: J. Bruce Fields <bfields@citi.umich.edu>
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

