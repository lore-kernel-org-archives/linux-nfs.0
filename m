From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: NFSv2 won't work in case of error
Date: Fri, 01 Nov 2002 17:09:33 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021101.170933.15272489.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187WzT-0005Yg-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Nov 2002 00:17:15 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Hello,

I've fixed a problem that NFSv2 won't work when NFSv2 procedure
handler (proc->pc_func) returns error.

I guess there may be better way to fix it than this patch.


--- fs/nfsd/nfssvc.c.ORGv2	Fri Nov  1 16:05:44 2030
+++ fs/nfsd/nfssvc.c	Fri Nov  1 17:01:59 2030
@@ -309,6 +309,8 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 			*statp = rpc_system_err;
 			return 1;
 		}
+	} else {
+		xdr_ressize_check(rqstp, (u32*)(rqstp->rq_res.head[0].iov_base+rqstp->rq_res.head[0].iov_len));
 	}
 
 	/* Store reply in cache. */


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
