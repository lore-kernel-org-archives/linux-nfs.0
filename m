From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: fix failure to set eof in readdir in some situations
Date: Thu, 30 Oct 2008 17:31:25 -0400
Message-ID: <20081030213125.GC24156@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <David.Woodhouse@intel.com>,
	Al Viro <viro@zeniv.linux.org.uk>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58978 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642AbYJ3Vb1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Oct 2008 17:31:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Before 14f7dd632011bb89c035722edd6ea0d90ca6b078 "[PATCH] Copy XFS
readdir hack into nfsd code", readdir_cd->err was reset to eof before
each call to vfs_readdir; afterwards, it is set only once.  Similarly,
c002a6c7977320f95b5edede5ce4e0eeecf291ff "[PATCH] Optimise NFS readdir
hack slightly", can cause us to exit without nfserr_eof set.  Fix this.

This ensures the "eof" bit is set when needed in readdir replies.  (The
particular case I saw was an nfsv4 readdir of an empty directory, which
returned with no entries (the protocol requires "." and ".." to be
filtered out), but with eof unset.)

Cc: David Woodhouse <David.Woodhouse@intel.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

I'm queuing this up for 2.6.28.--b.

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0bc56f6..848a03e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1912,6 +1912,7 @@ static int nfsd_buffered_readdir(struct file *file, filldir_t func,
 			de = (struct buffered_dirent *)((char *)de + reclen);
 		}
 		offset = vfs_llseek(file, 0, SEEK_CUR);
+		cdp->err = nfserr_eof;
 		if (!buf.full)
 			break;
 	}
-- 
1.5.5.rc1

