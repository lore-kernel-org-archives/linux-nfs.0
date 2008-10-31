From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd fixes for 2.6.28
Date: Fri, 31 Oct 2008 18:35:59 -0400
Message-ID: <20081031223559.GA14270@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Neil Brown <neilb@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41267 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096AbYJaWgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2008 18:36:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull two small fixes for post-2.6.28 nfsd regressions from the
for-2.6.28 branch at

  git://linux-nfs.org/~bfields/linux.git for-2.6.28

--b.

Chuck Lever (1):
      NLM: Set address family before calling nlm_host_rebooted()

J. Bruce Fields (1):
      nfsd: fix failure to set eof in readdir in some situations

 fs/lockd/svc4proc.c |    1 +
 fs/lockd/svcproc.c  |    1 +
 fs/nfsd/vfs.c       |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

commit d7dc61d0a70371b1c6557ea8ffbc60fff94c8168
Author: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Date:   Thu Oct 23 00:50:35 2008 -0400

    NLM: Set address family before calling nlm_host_rebooted()
    
    The nlm_host_rebooted() function uses nlm_cmp_addr() to find an
    nsm_handle that matches the rebooted peer.  In order for this to work,
    the passed-in address must have a proper address family.
    
    This fixes a post-2.6.28 regression introduced by commit 781b61a6, which
    added AF_INET6 support to nlm_cmp_addr().  Before that commit,
    nlm_cmp_addr() didn't care about the address family; it compared only
    the sin_addr.s_addr field for equality.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 014f6ce..4dfdcbc 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -434,6 +434,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 	 * reclaim all locks we hold on this server.
 	 */
 	memset(&saddr, 0, sizeof(saddr));
+	saddr.sin_family = AF_INET;
 	saddr.sin_addr.s_addr = argp->addr;
 	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 548b0bb..3ca89e2 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -466,6 +466,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 	 * reclaim all locks we hold on this server.
 	 */
 	memset(&saddr, 0, sizeof(saddr));
+	saddr.sin_family = AF_INET;
 	saddr.sin_addr.s_addr = argp->addr;
 	nlm_host_rebooted(&saddr, argp->mon, argp->len, argp->state);
 

commit 8d7c4203c681a3ec359eccff4e53bc8c0ccf403b
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Oct 30 13:48:33 2008 -0400

    nfsd: fix failure to set eof in readdir in some situations
    
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
