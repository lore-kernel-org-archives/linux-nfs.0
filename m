From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: make NFS work with 64KB page-size
Date: Wed, 18 Jun 2003 15:56:31 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16112.60959.588900.824473@napali.hpl.hp.com>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	davidm@napali.hpl.hp.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from palrel13.hp.com ([156.153.255.238])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Slsa-0005Wl-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 15:58:12 -0700
To: neilb@cse.unsw.edu.au
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

NFS currently bugs out on kernels with a page size of 64KB.  The
reason is a mismatch between RPCSVC_MAXPAGES and a calculation in
svc_init_buffer().  I'm not entirely certain which calculation is the
right one, but if I understand the code correctly, RPCSVC_MAXPAGES is
right and svc_init_buffer() is wrong.  The patch below fixes the
latter.

If the patch looks right, could you make sure it finds its way into
Linus' tree?

Thanks,

	--david

===== net/sunrpc/svc.c 1.20 vs edited =====
--- 1.20/net/sunrpc/svc.c	Fri Feb  7 12:25:20 2003
+++ edited/net/sunrpc/svc.c	Wed Jun 18 15:02:19 2003
@@ -111,7 +111,7 @@
 static int
 svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 {
-	int pages = 2 + (size+ PAGE_SIZE -1) / PAGE_SIZE;
+	int pages = 1 + (size+ PAGE_SIZE -1) / PAGE_SIZE;
 	int arghi;
 	
 	rqstp->rq_argused = 0;


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
