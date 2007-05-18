From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 7/15] knfsd: create RDMA transport in nfssvc
Date: Fri, 18 May 2007 12:45:31 -0500
Message-ID: <1179510331.23385.120.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp6WE-0000tw-0N
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:45:34 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp6WG-0006m6-Lp
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:45:36 -0700
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

Adds a call to the svc_makesock routine to create the RDMA transport. 
I think this should somehow be linked to the transport switch and the 
port mapper. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfssvc.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d7759ce..4a7982e 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -254,6 +254,17 @@ #ifdef CONFIG_NFSD_TCP
 	if (error < 0)
 		return error;
 #endif
+#ifdef CONFIG_NFSD_RDMA
+	/* KLUDGE: The rpc.nfsd utility passes down the
+	 * port number when it opens the nfsd file. We are
+	 * going to ignore it here and force the RDMA port number
+	 * to 2050. This will allow the TCP transport to coexist
+	 * with the RDMA transport.
+	 */
+	error = svc_makesock(nfsd_serv, IPPROTO_MAX, 2050 /* port */, 0);
+	if (error < 0)
+		return error;
+#endif
 	return 0;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
