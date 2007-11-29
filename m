From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 07/29] NFS: Enable NFS client to generate CLIENTID
	strings	with IPv6 addresses
Date: Thu, 29 Nov 2007 14:40:29 -0500
Message-ID: <20071129194029.4170.65168.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpGD-0001Ur-Gd
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:21 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpGI-0002Ip-HJ
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:27 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

We recently added methods to RPC transports that provide string versions of
the remote peer address information.  Convert the NFSv4 SETCLIENTID
procedure to use those methods instead of building the client ID out of
whole cloth.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
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
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

