From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 2 - Convert error code to nfserror code in nfsd_symlink
Date: Mon, 28 Jul 2003 16:56:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19h1vW-0002qX-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19h1vh-0006w9-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Jul 2003 23:56:22 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Mon, 28 Jul 2003 16:56:11 +1000
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


As Andreas Gruenbacher <agruen@suse.de> noticed, without this
as wrong error code can leak out.

(patch against 2.4.22-pre9)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2003-07-28 16:21:20.000000000 +1000
+++ ./fs/nfsd/vfs.c	2003-07-28 16:21:20.000000000 +1000
@@ -1151,7 +1151,9 @@ nfsd_symlink(struct svc_rqst *rqstp, str
 				iap->ia_mode = (iap->ia_mode&S_IALLUGO)
 					| S_IFLNK;
 				err = notify_change(dnew, iap);
-				if (!err && EX_ISSYNC(fhp->fh_export))
+				if (err)
+					err = nfserrno(err);
+				else if (EX_ISSYNC(fhp->fh_export))
 					write_inode_now(dentry->d_inode, 1);
 		       }
 		}


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
