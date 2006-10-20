From: Neil Brown <neilb@suse.de>
Subject: Regression: NFS locking hangs when statd not running.
Date: Fri, 20 Oct 2006 20:23:13 +1000
Message-ID: <17720.41873.549441.330938@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Takashi Iwai <tiwai@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GarX8-0003X2-BC
	for nfs@lists.sourceforge.net; Fri, 20 Oct 2006 03:23:22 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GarX7-00078I-NP
	for nfs@lists.sourceforge.net; Fri, 20 Oct 2006 03:23:23 -0700
To: nfs@lists.sourceforge.net
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


Hi Chunk et.al.

 There seems to be a regression in 2.6.19-rc which I'm blaming 
 on you  :-)
 I should haste to say that I think you fixed something in the RPC
 layer and this as exposed a new problem.  I'm hoping that you can
 tell me if my analysis can patch make sense.

 In call_bind_status (net/sunrpc/clnt.c) there is code to handle the
 case where portmap has reported that the program/version is
 unavailable (via -EACCES).
 It requests a 3 second delay followed by a retry.  This can be expected
 to recur until a major timeout.

 In 2.6.18, this code is never exercised.  I'm not sure of exactly
 why, but when the portmap sub-task aborts, the whole task aborts.
 In 2.6.19-rc, this case is exercised.  I assume you fixed something
 so that the whole task doesn't get aborted.

 The problem is that there is a case where we don't want the retry.

 In 2.6.18, if statd isn't running, then a lock attempt returns ENOLCK
 immediately, which I think is good.
 In 2.6.19-rc, in the same situation, a lock attempt waits for a major
 timeout (30 seconds for TCP mounts) and is not interruptible for this
 whole time (even with '-o intr' mounts).

 So: what to do?  Should we retry requests when portmap says "no such
 service".

 I think that for requests to a remote service - lockd or nfsd - we do
 want to retry.  The server might be rebooting and so "no such
 service" should be treated much like "no reply".
 
 However for local services - statd - I don't think the timeout is
 desired.   So I would like to propose the following patch.  It
 introduces a new flag 'local' that gets set for statd requests and
 causes the call_bind_status to abort rather than retry after a
 timeout. 
 It also sets RPC_CLNT_CREATE_NOPING as I couldn't see an obvious way
 to pass 'local' through to the ping request.  Maybe this aspect of
 the patch can be improved.

 This also raises another issues.  The 'soft' and 'intr' flags aren't
 really passed around very much.  An 'intr' mount still makes 'nointr'
 requests to statd, and an 'intr,hard' rpc request will make a
 'nointr,soft' request to portmap for binding.  This doesn't seem
 right though I'm not certain if there are bad consequences.
 Have you thought about this issue?  Would you like to convince me
 that the current situation is fine?

Thanks for listening,
Comments on the patch appreciated.
NeilBrown

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/mon.c              |    4 +++-
 ./include/linux/sunrpc/clnt.h |    2 ++
 ./net/sunrpc/clnt.c           |    4 ++++
 3 files changed, 9 insertions(+), 1 deletion(-)

diff .prev/fs/lockd/mon.c ./fs/lockd/mon.c
--- .prev/fs/lockd/mon.c	2006-10-20 16:30:56.000000000 +1000
+++ ./fs/lockd/mon.c	2006-10-20 18:45:49.000000000 +1000
@@ -138,7 +138,9 @@ nsm_create(void)
 		.program	= &nsm_program,
 		.version	= SM_VERSION,
 		.authflavor	= RPC_AUTH_NULL,
-		.flags		= (RPC_CLNT_CREATE_ONESHOT),
+		.flags		= (RPC_CLNT_CREATE_ONESHOT|
+				   RPC_CLNT_CREATE_NOPING|
+				   RPC_CLNT_CREATE_LOCAL),
 	};
 
 	return rpc_create(&args);

diff .prev/include/linux/sunrpc/clnt.h ./include/linux/sunrpc/clnt.h
--- .prev/include/linux/sunrpc/clnt.h	2006-10-20 16:24:50.000000000 +1000
+++ ./include/linux/sunrpc/clnt.h	2006-10-20 18:41:24.000000000 +1000
@@ -42,6 +42,7 @@ struct rpc_clnt {
 				cl_intr     : 1,/* interruptible */
 				cl_autobind : 1,/* use getport() */
 				cl_oneshot  : 1,/* dispose after use */
+				cl_local    : 1, /* don't retry if not registered */
 				cl_dead     : 1;/* abandoned */
 
 	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
@@ -110,6 +111,7 @@ struct rpc_create_args {
 #define RPC_CLNT_CREATE_ONESHOT		(1UL << 3)
 #define RPC_CLNT_CREATE_NONPRIVPORT	(1UL << 4)
 #define RPC_CLNT_CREATE_NOPING		(1UL << 5)
+#define RPC_CLNT_CREATE_LOCAL		(1UL << 6)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,

diff .prev/net/sunrpc/clnt.c ./net/sunrpc/clnt.c
--- .prev/net/sunrpc/clnt.c	2006-10-20 15:21:14.000000000 +1000
+++ ./net/sunrpc/clnt.c	2006-10-20 18:42:07.000000000 +1000
@@ -238,6 +238,8 @@ struct rpc_clnt *rpc_create(struct rpc_c
 		clnt->cl_autobind = 1;
 	if (args->flags & RPC_CLNT_CREATE_ONESHOT)
 		clnt->cl_oneshot = 1;
+	if (args->flags & RPC_CLNT_CREATE_LOCAL)
+		clnt->cl_local = 1;
 
 	return clnt;
 }
@@ -860,6 +862,8 @@ call_bind_status(struct rpc_task *task)
 	case -EACCES:
 		dprintk("RPC: %4d remote rpcbind: RPC program/version unavailable\n",
 				task->tk_pid);
+		if (task->tk_client->cl_local)
+			break;
 		rpc_delay(task, 3*HZ);
 		goto retry_timeout;
 	case -ETIMEDOUT:

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
