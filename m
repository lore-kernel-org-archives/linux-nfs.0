From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/2] nfsd: minor fs/nfsd/auth.h cleanup
Date: Thu, 15 Nov 2007 17:53:52 -0500
Message-ID: <1195167232-30238-2-git-send-email-bfields@citi.umich.edu>
References: <1195167232-30238-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <1195167232-30238-1-git-send-email-bfields@citi.umich.edu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

While we're here, let's remove the redundant (and now wrong) pathname in
the comment, and the #ifdef __KERNEL__'s.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/auth.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/auth.h b/fs/nfsd/auth.h
index 0fb9f72..78b3c0e 100644
--- a/fs/nfsd/auth.h
+++ b/fs/nfsd/auth.h
@@ -1,6 +1,4 @@
 /*
- * include/linux/nfsd/auth.h
- *
  * nfsd-specific authentication stuff.
  * uid/gid mapping not yet implemented.
  *
@@ -10,8 +8,6 @@
 #ifndef LINUX_NFSD_AUTH_H
 #define LINUX_NFSD_AUTH_H
 
-#ifdef __KERNEL__
-
 #define nfsd_luid(rq, uid)	((u32)(uid))
 #define nfsd_lgid(rq, gid)	((u32)(gid))
 #define nfsd_ruid(rq, uid)	((u32)(uid))
@@ -23,5 +19,4 @@
  */
 int nfsd_setuser(struct svc_rqst *, struct svc_export *);
 
-#endif /* __KERNEL__ */
 #endif /* LINUX_NFSD_AUTH_H */
-- 
1.5.3.5.561.g140d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
