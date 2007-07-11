From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [RFC Patch 05/09] NFS/RDMA client - allow NFSv4/RDMA mounts
Date: Wed, 11 Jul 2007 17:07:41 -0400
Message-ID: <EXNANE0169aZbLAX3cf00000c64@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8jRZ-0002Au-PR
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:09:53 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I8jRd-0004eP-Am
	for nfs@lists.sourceforge.net; Wed, 11 Jul 2007 14:09:57 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l6BL9pGq022405
	for <nfs@lists.sourceforge.net>; Wed, 11 Jul 2007 14:09:51 -0700 (PDT)
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

NFS: Temporary fix for NFSv4 mounts over RPC-RDMA

The NFSv4 mount insists on an IPv4 server address. This prevents RDMA
mounts from succeeding, so allow the (temporary) RDMA nfsmount family.

Signed-off-by: Tom Talpey <talpey@netapp.com>

---

 super.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.22/fs/nfs/super.c
===================================================================
--- linux-2.6.22.orig/fs/nfs/super.c
+++ linux-2.6.22/fs/nfs/super.c
@@ -826,7 +826,7 @@ static int nfs4_get_sb(struct file_syste
        if (copy_from_user(&addr, data->host_addr, sizeof(addr)))
                return -EFAULT;
 
-       if (addr.sin_family != AF_INET ||
+       if ( (addr.sin_family != AF_INET && addr.sin_family != 0xff) ||
            addr.sin_addr.s_addr == INADDR_ANY
            ) {
                dprintk("%s: mount program didn't pass remote IP address!\n",


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
