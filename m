From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/25] NFS: Enable NFS client to generate CLIENTID
	strings	with IPv6 addresses
Date: Tue, 13 Nov 2007 13:31:21 -0500
Message-ID: <20071113183121.5087.71482.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Xz-0000NM-8f
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:39 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0Y5-0005YA-1x
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:31:45 -0800
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

We recently added methods to RPC transports that provide string versions of
the remote peer address information.  Convert the NFSv4 SETCLIENTID
procedure to use those methods instead of building the client ID out of
whole cloth.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/nfs/nfs4proc.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f03d9d5..ec58d1e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2912,14 +2912,18 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short po
 
 	for(;;) {
 		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
-				sizeof(setclientid.sc_name), "%s/%u.%u.%u.%u %s %u",
-				clp->cl_ipaddr, NIPQUAD(clp->cl_addr.sin_addr),
+				sizeof(setclientid.sc_name), "%s/%s %s %u",
+				clp->cl_ipaddr,
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_ADDR),
 				cred->cr_ops->cr_name,
 				clp->cl_id_uniquifier);
 		setclientid.sc_netid_len = scnprintf(setclientid.sc_netid,
-				sizeof(setclientid.sc_netid), "tcp");
+				sizeof(setclientid.sc_netid),
+				rpc_peeraddr2str(clp->cl_rpcclient,
+							RPC_DISPLAY_NETID));
 		setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
-				sizeof(setclientid.sc_uaddr), "%s.%d.%d",
+				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
 				clp->cl_ipaddr, port >> 8, port & 255);
 
 		status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
