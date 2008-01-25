From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 107/112] nfs4: allow nfsv4 acls on non-regular-files
Date: Fri, 25 Jan 2008 11:38:02 -0500
Message-ID: <20080125163802.31887.93796.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14387 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756184AbYAYRAO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:14 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09UC010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:11 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The rfc doesn't give any reason it shouldn't be possible to set an
attribute on a non-regular file.  And if the server supports it, then it
shouldn't be up to us to prevent it.

Thanks to Erez for the report and Trond for further analysis.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Tested-by: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 92bfbcb..ffe5584 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3621,10 +3621,6 @@ int nfs4_setxattr(struct dentry *dentry, const char *key, const void *buf,
 	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
 		return -EOPNOTSUPP;
 
-	if (!S_ISREG(inode->i_mode) &&
-	    (!S_ISDIR(inode->i_mode) || inode->i_mode & S_ISVTX))
-		return -EPERM;
-
 	return nfs4_proc_set_acl(inode, buf, buflen);
 }
 
