From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 7 - Release rpc response when dropping request.
Date: Tue, 17 Dec 2002 12:59:25 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18O713-0000oq-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18O71O-0003nk-00
	for <nfs@lists.sourceforge.net>; Mon, 16 Dec 2002 17:59:46 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.239] == wireless-239.wireless.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 17 Dec 2002 12:59:36 +1100
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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


Marcelo, 
 This is the first of 7 smallish nfsd related patches for 2.4.21-pre.
 Thanks, NeilBrown

If a kmalloc failure causes us to have to drop an nfs request,
the ->pc_release function currently isn't called, so
dentries can leak.  This fixes it.

 ----------- Diffstat output ------------
 ./net/sunrpc/svc.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff ./net/sunrpc/svc.c~current~ ./net/sunrpc/svc.c
--- ./net/sunrpc/svc.c~current~	2002-12-16 16:28:08.000000000 +1100
+++ ./net/sunrpc/svc.c	2002-12-16 16:28:09.000000000 +1100
@@ -333,8 +333,12 @@ svc_process(struct svc_serv *serv, struc
 		}
 	} else {
 		dprintk("svc: calling dispatcher\n");
-		if (!versp->vs_dispatch(rqstp, statp))
+		if (!versp->vs_dispatch(rqstp, statp)) {
+			/* Release reply info */
+			if (procp->pc_release)
+				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
 			goto dropit;
+		}
 	}
 
 	/* Check RPC status result */


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
