From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: RFC: nlmclnt_grant() address check vs. callback address
	binding
Date: Mon, 2 Jul 2007 17:49:18 +0200
Message-ID: <20070702154918.GA543@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5O9R-0006xj-IK
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 08:49:21 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5O9S-0002e5-Jc
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 08:49:25 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Occasionally an NFS server needs to create an RPC transport for client
callbacks, e.g. when granting a blocked lock request. When a server
has multiple IP addresses (multihomed/multiple NICs or on a single
interface) then the client may be called back from a different address
because the server is free to select one: xs_udp_connect_worker() and
xs_tcp_connect_worker() call xs_bindresvport() only when a reserved port
is requested and xs_bindresvport() implicitly uses INADDR_ANY.

Currently this breaks locking when the server has more than one IP address
reachable from the client because nlmclnt_grant() on the client rejects
GRANT_MSG when the source IP address doesn't match the destination
address in the original request. This is happening in a real-world
situation where NFS servers have been virtualized using different IP
addresses on a single machine.

Basically there are two ways to fix this:
1.	server callbacks should bind to a local address, not INADDR_ANY.
2.	clients should accept callbacks from a different server address.

At first I thought fixing the server is the right thing to do because
the server behavior is arguably incorrect. Not easy but certainly doable
(I'd do it if it has a chance of being accepted). It might also help
NATting NFS traffic in some cases. However:

-	I'm not sure if an address check such as in nlmclnt_grant()
	is actually buying us anything.
-	clients requiring a correct callback src address might not
	work with other NFS server implementations and/or (future?)
	concepts for clustering/load balancing.
-	Multiple IP addresses may be a workaround for reserved port
	shortage.

As it currently stands, mounting from a secondary server IP address is
broken w.r.t. locking when both client and server run linux.

Any opinion about (1) and (2)? maybe we should do both?

Currently I use (2) as a workaround:

--- a/fs/lockd/clntlock.c	2007-02-27 22:55:27.000000000 +0100
+++ b/fs/lockd/clntlock.c	2007-07-02 17:36:29.000000000 +0200
@@ -124,8 +124,15 @@ __be32 nlmclnt_grant(const struct sockad
 		 */
 		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
 			continue;
-		if (!nlm_cmp_addr(&block->b_host->h_addr, addr))
-			continue;
+		/*
+		 * The granted message may come from a different IP address
+		 * when the server has more than one. Warn when debug is on.
+		 */
+		if (!nlm_cmp_addr(&block->b_host->h_addr, addr)) {
+			dprintk("nlmclnt_grant: "NIPQUAD_FMT" != "NIPQUAD_FMT"\n",
+				NIPQUAD(block->b_host->h_addr.sin_addr.s_addr),
+				NIPQUAD(addr->sin_addr.s_addr));
+		}
 		if (nfs_compare_fh(NFS_FH(fl_blocked->fl_file->f_path.dentry->d_inode) ,fh) != 0)
 			continue;
 		/* Alright, we found a lock. Set the return status

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
