From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 4] Make the initial RPC PING interruptible.
Date: Tue, 24 Oct 2006 12:48:57 +1000
Message-ID: <1061024024857.4748@suse.de>
References: <20061024122646.4426.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcCLg-0001oR-Mp
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 19:49:04 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcCLg-0001KP-8x
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 19:49:05 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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


If an RPC client is created with CREATE_INTR and not CREATE_NOPING,
then the ping should be interruptible.  With tcp the PING can take 30
seconds to time out and not being able to interrupt that can be
frustrating.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/clnt.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff .prev/net/sunrpc/clnt.c ./net/sunrpc/clnt.c
--- .prev/net/sunrpc/clnt.c	2006-10-24 09:41:49.000000000 +1000
+++ ./net/sunrpc/clnt.c	2006-10-24 09:43:48.000000000 +1000
@@ -221,7 +221,15 @@ struct rpc_clnt *rpc_create(struct rpc_c
 		return clnt;
 
 	if (!(args->flags & RPC_CLNT_CREATE_NOPING)) {
-		int err = rpc_ping(clnt, RPC_TASK_SOFT|RPC_TASK_NOINTR);
+		int tskflags = RPC_TASK_SOFT;
+		int err;
+		if ( ! (args->flags & RPC_CLNT_CREATE_INTR))
+			tskflags |= RPC_TASK_NOINTR;
+		/* Note: we keep task_soft even if RPC_CLNT_CREATE_HARDRTRY
+		 * is set.  The whole point of the PING is to check that the
+		 * server is there *now*
+		 */
+		err = rpc_ping(clnt, tskflags);
 		if (err != 0) {
 			rpc_shutdown_client(clnt);
 			return ERR_PTR(err);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
