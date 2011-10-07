Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753716Ab1JGRlS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Oct 2011 13:41:18 -0400
Message-ID: <4E8F39BB.1080207@netapp.com>
Date: Fri, 07 Oct 2011 13:41:15 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        viro@zeniv.linux.org.uk,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] VFS: Add "device" tag to /proc/self/mountstats
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsiostat was failing to find mounted filesystems on kernels after
2.6.38 because of changes to show_vfsstat() by commit
c7f404b40a3665d9f4e9a927cc5c1ee0479ed8f9.  This patch adds back the
"device" tag before the nfs server entry so scripts can parse the
mountstats file correctly.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
CC: stable@kernel.org [>=2.6.39]
---
 fs/namespace.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 22bfe82..1429114 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1109,6 +1109,7 @@ static int show_vfsstat(struct seq_file *m, void *v)
 
 	/* device */
 	if (mnt->mnt_sb->s_op->show_devname) {
+		seq_puts(m, "device ");
 		err = mnt->mnt_sb->s_op->show_devname(m, mnt);
 	} else {
 		if (mnt->mnt_devname) {
-- 
1.7.6.3
