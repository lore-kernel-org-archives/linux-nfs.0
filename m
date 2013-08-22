Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c11o142.mxlogic.net ([208.65.144.75]:59796 "EHLO
	p02c11o142.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516Ab3HVOVf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Aug 2013 10:21:35 -0400
From: Peter Staubach <pstaubach@exagrid.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 22 Aug 2013 10:12:41 -0400
Subject: RE: [PATCH 1/6] NFSv3: Deal with a sparse warning in
 nfs3_proc_create
Message-ID: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC0CC0174A00@IT-1874.Isys.com>
References: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It seems a shame to byte swap something which doesn't really need to be byte swapped.  It is pretty much just an opaque value that the server stores and then checks during possible retransmits.  I suppose that it is cheap enough to do, not so many times per second.

	Thanx...

		ps


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Trond Myklebust
Sent: Wednesday, August 21, 2013 8:26 PM
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] NFSv3: Deal with a sparse warning in nfs3_proc_create

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c index f5c84c3..1db588a 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -336,8 +336,8 @@ nfs3_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	data->arg.create.createmode = NFS3_CREATE_UNCHECKED;
 	if (flags & O_EXCL) {
 		data->arg.create.createmode  = NFS3_CREATE_EXCLUSIVE;
-		data->arg.create.verifier[0] = jiffies;
-		data->arg.create.verifier[1] = current->pid;
+		data->arg.create.verifier[0] = cpu_to_be32(jiffies);
+		data->arg.create.verifier[1] = cpu_to_be32(current->pid);
 	}
 
 	sattr->ia_mode &= ~current_umask();
--
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
