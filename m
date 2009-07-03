From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: NFSD: Don't hold unrefcounted creds over call to nfsd_setuser()
Date: Fri, 3 Jul 2009 11:47:57 -0400
Message-ID: <20090703154757.GG31538@fieldses.org>
References: <20090703142250.GB31538@fieldses.org> <20090702203937.GA10504@fieldses.org> <20090702133532.28297.89635.stgit@warthog.procyon.org.uk> <575.1246570293@redhat.com> <20090702230955.GB12376@fieldses.org> <31545.1246632086@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>, steved@redhat.com,
	rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 174-143-236-118.static.slicehost.net ([174.143.236.118]:44945
	"EHLO fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756649AbZGCPsA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2009 11:48:00 -0400
In-Reply-To: <31545.1246632086@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patch is appropriate for 2.6.31 (and stable), and is also
available from

  git://linux-nfs.org/~bfields/linux.git for-2.6.31

--b.

commit 033a666ccb842ab4134fcd0c861d5ba9f5d6bf3a
Author: David Howells <dhowells@redhat.com>
Date:   Thu Jul 2 14:35:32 2009 +0100

    NFSD: Don't hold unrefcounted creds over call to nfsd_setuser()
    
    nfsd_open() gets an unrefcounted pointer to the current process's effective
    credentials at the top of the function, then calls nfsd_setuser() via
    fh_verify() - which may replace and destroy the current process's effective
    credentials - and then passes the unrefcounted pointer to dentry_open() - but
    the credentials may have been destroyed by this point.
    
    Instead, the value from current_cred() should be passed directly to
    dentry_open() as one of its arguments, rather than being cached in a variable.
    
    Possibly fh_verify() should return the creds to use.
    
    This is a regression introduced by
    745ca2475a6ac596e3d8d37c2759c0fbe2586227 "CRED: Pass credentials through
    dentry_open()".
    
    Signed-off-by: David Howells <dhowells@redhat.com>
    Tested-and-Verified-By: Steve Dickson <steved@redhat.com>
    Cc: stable@kernel.org
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 4145083..23341c1 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -678,7 +678,6 @@ __be32
 nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 			int access, struct file **filp)
 {
-	const struct cred *cred = current_cred();
 	struct dentry	*dentry;
 	struct inode	*inode;
 	int		flags = O_RDONLY|O_LARGEFILE;
@@ -733,7 +732,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 		vfs_dq_init(inode);
 	}
 	*filp = dentry_open(dget(dentry), mntget(fhp->fh_export->ex_path.mnt),
-			    flags, cred);
+			    flags, current_cred());
 	if (IS_ERR(*filp))
 		host_err = PTR_ERR(*filp);
 	else
