From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 20/20] knfsd: create listener via portlist write
Date: Tue, 10 Jul 2007 00:35:02 -0500
Message-ID: <20070710053502.28979.32613.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88NM-00078q-E8
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:35:04 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88NP-00051V-Na
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:35:08 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 552027C79E
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:35:02 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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


Update the write handler for the portlist file to allow creating new 
listening endpoints on a transport. The general form of the string is:

<transport_name><space><port number>

For example:

tcp 2049

This is intended to support the creation of a listening endpoint for
RDMA transports without adding #ifdef code to the nfssvc.c file.
The "built-in" transports UDP/TCP were left in the nfssvc initialization
code to avoid having to change rpc.nfsd, etc...

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfsctl.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 71c686d..b72514d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -555,6 +555,22 @@ static ssize_t write_ports(struct file *
 		kfree(toclose);
 		return len;
 	}
+	/* This implements the ability to add a transport by writing
+	 * it's transport name to the portlist file
+	 */
+	if (isalnum(buf[0])) {
+		int err;
+		char transport[16];
+		int port;
+		sscanf(buf, "%15s %4d", transport, &port);
+		err = nfsd_create_serv();
+		if (!err)
+			err = svc_create_svcsock(nfsd_serv,
+						 transport, port,
+						 SVC_SOCK_ANONYMOUS);
+		return err < 0 ? err : 0;
+	}
+	
 	return -EINVAL;
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
