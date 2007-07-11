From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC Patch 04/09] NFS/RDMA client - transport switch protocol
 wildcarding
Date: Wed, 11 Jul 2007 17:07:37 -0400
Message-ID: <EXNANE01ATcFZ4RgPRC00000c63@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8jRI-0002AV-OD
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:09:36 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8jRM-0007An-93
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:09:40 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l6BL9YMp022330
	for <nfs@lists.sourceforge.net>; Wed, 11 Jul 2007 14:09:34 -0700 (PDT)
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

SUNRPC: allow transport switch registrations to wildcard their protocol

Some RPC transports don't have any notion of "protocol", such as RDMA.
This patch allows a zero protocol to be a wildcard when creating new
transport endpoints.

Signed-off-by: Tom Talpey <talpey@netapp.com>

---

 net/sunrpc/xprt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.22/net/sunrpc/xprt.c
===================================================================
--- linux-2.6.22.orig/net/sunrpc/xprt.c
+++ linux-2.6.22/net/sunrpc/xprt.c
@@ -990,7 +990,7 @@ struct rpc_xprt *xprt_create_transport(i
        spin_lock(&xprt_list_lock);
        list_for_each_entry(t, &xprt_list, list) {
                if ((t->family == ap->sa_family) &&
-                   (t->protocol == proto)) {
+                   (t->protocol == 0 || t->protocol == proto)) {
                        spin_unlock(&xprt_list_lock);
                        goto found;
                }


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
