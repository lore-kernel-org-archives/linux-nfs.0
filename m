From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 6/10] lockd: pass cookie in nlmsvc_testlock
Date: Wed,  6 Dec 2006 00:34:16 -0500
Message-ID: <b24eab1e47a44c1855d47d54b2858a7e5c2d4653.1165380893.git.bfields__37567.6069445491$1165383326$gmane$org@citi.umich.edu>
References: <11653832602203-git-send-email-bfields@fieldses.org>
	<1165383260627-git-send-email-bfields@fieldses.org>
	<11653832603105-git-send-email-bfields@fieldses.org>
	<11653832601058-git-send-email-bfields@fieldses.org>
	<11653832601635-git-send-email-bfields@fieldses.org>
	<1165383260424-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrpQH-0006XV-FB
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:25 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GrpQH-0006d3-Ur
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 21:34:26 -0800
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <1165383260424-git-send-email-bfields@fieldses.org>
Message-Id: <b24eab1e47a44c1855d47d54b2858a7e5c2d4653.1165380893.git.bfields@citi.umich.edu>
In-Reply-To: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
To: me <bfields@umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Marc Eshel <eshel@almaden.ibm.com>

Change NLM internal interface to pass more information for test lock; we
need this to make sure the cookie information is pushed down to the place
where we do request deferral, which is handled for testlock by the
following patch.

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc4proc.c         |    2 +-
 fs/lockd/svclock.c          |    5 +++--
 fs/lockd/svcproc.c          |    2 +-
 include/linux/lockd/lockd.h |    4 ++--
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 0ce5c81..eb5994e 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -99,7 +99,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
-	resp->status = nlmsvc_testlock(file, &argp->lock, &resp->lock);
+	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie);
 
 	dprintk("lockd: TEST4          status %d\n", ntohl(resp->status));
 	nlm_release_host(host);
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 90aa4a5..e342046 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -549,8 +549,9 @@ out:
  * Test for presence of a conflicting lock.
  */
 __be32
-nlmsvc_testlock(struct nlm_file *file, struct nlm_lock *lock,
-				       struct nlm_lock *conflock)
+nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
+		struct nlm_lock *lock, struct nlm_lock *conflock,
+		struct nlm_cookie *cookie)
 {
 	dprintk("lockd: nlmsvc_testlock(%s/%ld, ty=%d, %Ld-%Ld)\n",
 				file->f_file->f_dentry->d_inode->i_sb->s_id,
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 32e99a6..d4257a5 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -127,7 +127,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
-	resp->status = cast_status(nlmsvc_testlock(file, &argp->lock, &resp->lock));
+	resp->status = cast_status(nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie));
 
 	dprintk("lockd: TEST          status %d vers %d\n",
 		ntohl(resp->status), rqstp->rq_vers);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ac865f8..863bc23 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -197,8 +197,8 @@ typedef int	  (*nlm_host_match_fn_t)(struct nlm_host *cur, struct nlm_host *ref)
 __be32		  nlmsvc_lock(struct svc_rqst *, struct nlm_file *,
 					struct nlm_lock *, int, struct nlm_cookie *);
 __be32		  nlmsvc_unlock(struct nlm_file *, struct nlm_lock *);
-__be32		  nlmsvc_testlock(struct nlm_file *, struct nlm_lock *,
-					struct nlm_lock *);
+__be32		  nlmsvc_testlock(struct svc_rqst *, struct nlm_file *,
+			struct nlm_lock *, struct nlm_lock *, struct nlm_cookie *);
 __be32		  nlmsvc_cancel_blocked(struct nlm_file *, struct nlm_lock *);
 unsigned long	  nlmsvc_retry_blocked(void);
 void		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
-- 
1.4.4.1


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
