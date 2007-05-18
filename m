From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 6/15] knfsd: nfs3svc_decode_writeargs assumes data	follows
	header
Date: Fri, 18 May 2007 12:45:24 -0500
Message-ID: <1179510324.23385.119.camel@trinity.ogc.int>
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
	id 1Hp6W7-0000tb-BI
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:45:27 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp6W9-0006kh-SO
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 10:45:30 -0700
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


The nfs3svc_decode_writeargs routine assumes that the data for an 
NFS write comes inline with the header when it verifies the message. 
Since the data for the write does not appear immediately following the 
header when RDMA is the transport, this check had to be modified.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfs3xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 7e4bb0a..0f08c4b 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -400,7 +400,7 @@ nfs3svc_decode_writeargs(struct svc_rqst
 	rqstp->rq_vec[v].iov_len = len;
 	args->vlen = v+1;
 
-	return args->count == args->len && rqstp->rq_vec[0].iov_len > 0;
+	return args->count == args->len && rqstp->rq_arg.len > hdr;
 }
 
 int


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
