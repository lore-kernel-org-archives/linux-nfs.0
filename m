From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 4 - pre-zero response for lockd _msg requests.
Date: Fri, 11 Oct 2002 10:00:21 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17znE5-0007cu-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17znEO-0000Rk-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 17:00:40 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 10:00:30 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

All the lockd *_msg requests are implemented by
calling the equivalent non- *_msg request and sending off
the response as a new message (*_res).

For the non- *_msg requests, the response buffer is
pre-zeroed by the RPC layer, but the *_msg handlers weren't
pre-zeroing the buffer, would could in some circumstances lead to
an Oops.

Now we pre-zero them all.

 ----------- Diffstat output ------------
 ./fs/lockd/svc4proc.c |    5 +++++
 ./fs/lockd/svcproc.c  |    5 +++++
 2 files changed, 10 insertions(+)

--- ./fs/lockd/svc4proc.c	2002/10/10 23:07:55	1.1
+++ ./fs/lockd/svc4proc.c	2002/10/10 23:08:01	1.2
@@ -244,6 +244,7 @@ nlm4svc_proc_test_msg(struct svc_rqst *r
 	u32		stat;
 
 	dprintk("lockd: TEST_MSG      called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlm4svc_proc_test(rqstp, argp, &res)) == 0)
 		stat = nlm4svc_callback(rqstp, NLMPROC_TEST_RES, &res);
@@ -258,6 +259,7 @@ nlm4svc_proc_lock_msg(struct svc_rqst *r
 	u32		stat;
 
 	dprintk("lockd: LOCK_MSG      called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlm4svc_proc_lock(rqstp, argp, &res)) == 0)
 		stat = nlm4svc_callback(rqstp, NLMPROC_LOCK_RES, &res);
@@ -272,6 +274,7 @@ nlm4svc_proc_cancel_msg(struct svc_rqst 
 	u32		stat;
 
 	dprintk("lockd: CANCEL_MSG    called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlm4svc_proc_cancel(rqstp, argp, &res)) == 0)
 		stat = nlm4svc_callback(rqstp, NLMPROC_CANCEL_RES, &res);
@@ -286,6 +289,7 @@ nlm4svc_proc_unlock_msg(struct svc_rqst 
 	u32		stat;
 
 	dprintk("lockd: UNLOCK_MSG    called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlm4svc_proc_unlock(rqstp, argp, &res)) == 0)
 		stat = nlm4svc_callback(rqstp, NLMPROC_UNLOCK_RES, &res);
@@ -300,6 +304,7 @@ nlm4svc_proc_granted_msg(struct svc_rqst
 	u32		stat;
 
 	dprintk("lockd: GRANTED_MSG   called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlm4svc_proc_granted(rqstp, argp, &res)) == 0)
 		stat = nlm4svc_callback(rqstp, NLMPROC_GRANTED_RES, &res);
--- ./fs/lockd/svcproc.c	2002/10/10 23:07:55	1.1
+++ ./fs/lockd/svcproc.c	2002/10/10 23:08:01	1.2
@@ -272,6 +272,7 @@ nlmsvc_proc_test_msg(struct svc_rqst *rq
 	u32		stat;
 
 	dprintk("lockd: TEST_MSG      called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlmsvc_proc_test(rqstp, argp, &res)) == 0)
 		stat = nlmsvc_callback(rqstp, NLMPROC_TEST_RES, &res);
@@ -286,6 +287,7 @@ nlmsvc_proc_lock_msg(struct svc_rqst *rq
 	u32		stat;
 
 	dprintk("lockd: LOCK_MSG      called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlmsvc_proc_lock(rqstp, argp, &res)) == 0)
 		stat = nlmsvc_callback(rqstp, NLMPROC_LOCK_RES, &res);
@@ -300,6 +302,7 @@ nlmsvc_proc_cancel_msg(struct svc_rqst *
 	u32		stat;
 
 	dprintk("lockd: CANCEL_MSG    called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlmsvc_proc_cancel(rqstp, argp, &res)) == 0)
 		stat = nlmsvc_callback(rqstp, NLMPROC_CANCEL_RES, &res);
@@ -314,6 +317,7 @@ nlmsvc_proc_unlock_msg(struct svc_rqst *
 	u32		stat;
 
 	dprintk("lockd: UNLOCK_MSG    called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlmsvc_proc_unlock(rqstp, argp, &res)) == 0)
 		stat = nlmsvc_callback(rqstp, NLMPROC_UNLOCK_RES, &res);
@@ -328,6 +332,7 @@ nlmsvc_proc_granted_msg(struct svc_rqst 
 	u32		stat;
 
 	dprintk("lockd: GRANTED_MSG   called\n");
+	memset(&res, 0, sizeof(res));
 
 	if ((stat = nlmsvc_proc_granted(rqstp, argp, &res)) == 0)
 		stat = nlmsvc_callback(rqstp, NLMPROC_GRANTED_RES, &res);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
