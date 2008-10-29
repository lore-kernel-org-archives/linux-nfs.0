From: James Lentini <jlentini@netapp.com>
Subject: [PATCH] inherit clone nfs_sever's rsize and wsize from parent
Date: Wed, 29 Oct 2008 16:21:57 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0810291601390.27502@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36709 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbYJ2UWA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2008 16:22:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond,

I think this is a minor issue.

When a mount is cloned, the new nfs_server's rsize and wsize do not 
inherit their initial values from the parent mount. 
nfs_server_set_fsinfo() ends up setting the new nfs_server's rsize and 
wsize to the values returned in the FSINFO response. As a result, 
there is no way for a system administrator to configure the rsize and 
wsize of a cloned mount.

The patch below makes the cloned nfs_server inherit its initial rsize 
and wsize from its parent.

Signed-off-by: James Lentini <jlentini@netapp.com>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7547600..3a4c12c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -831,6 +831,8 @@ static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_serve
 	target->acdirmin = source->acdirmin;
 	target->acdirmax = source->acdirmax;
 	target->caps = source->caps;
+	target->rsize = source->rsize;
+	target->wsize = source->wsize;
 }
 
 /*
