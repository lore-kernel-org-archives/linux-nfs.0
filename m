From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: [PATCH 3/3 2.6.9-rc2] remove broken_suid mount option (last part)
Date: Thu, 16 Sep 2004 01:51:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040915235110.GC23903@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7jYP-00078l-2r
	for nfs@lists.sourceforge.net; Wed, 15 Sep 2004 16:51:13 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C7jYO-0005aD-Fg
	for nfs@lists.sourceforge.net; Wed, 15 Sep 2004 16:51:13 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This gave me some thinking. But it seems that without this patch the only
difference would be that processes with different real uid/gid would get
different credentials internally only. It would not make any difference
from what the server would see since we ultimately send fsuid/fsgid only
(and of course the grouplist).

Signed-off-by: Frank van Maarseveen <frankvm@xs4all.nl>

--- d2/net/sunrpc/auth_unix.c.orig	2004-09-15 21:54:27.000000000 +0200
+++ d2/net/sunrpc/auth_unix.c	2004-09-15 23:02:25.000000000 +0200
@@ -17,8 +17,6 @@
 struct unx_cred {
 	struct rpc_cred		uc_base;
 	gid_t			uc_gid;
-	uid_t			uc_puid;		/* process uid */
-	gid_t			uc_pgid;		/* process gid */
 	gid_t			uc_gids[RPC_MAXGROUPS];
 };
 #define uc_uid			uc_base.cr_uid
@@ -76,8 +74,8 @@
 	atomic_set(&cred->uc_count, 0);
 	cred->uc_flags = RPCAUTH_CRED_UPTODATE;
 	if (flags & RPC_TASK_ROOTCREDS) {
-		cred->uc_uid = cred->uc_puid = 0;
-		cred->uc_gid = cred->uc_pgid = 0;
+		cred->uc_uid = 0;
+		cred->uc_gid = 0;
 		cred->uc_gids[0] = NOGROUP;
 	} else {
 		int groups = acred->group_info->ngroups;
@@ -86,8 +84,6 @@
 
 		cred->uc_uid = acred->uid;
 		cred->uc_gid = acred->gid;
-		cred->uc_puid = current->uid;
-		cred->uc_pgid = current->gid;
 		for (i = 0; i < groups; i++)
 			cred->uc_gids[i] = GROUP_AT(acred->group_info, i);
 		if (i < RPC_MAXGROUPS)
@@ -119,9 +115,7 @@
 		int groups;
 
 		if (cred->uc_uid != acred->uid
-		 || cred->uc_gid != acred->gid
-		 || cred->uc_puid != current->uid
-		 || cred->uc_pgid != current->gid)
+		 || cred->uc_gid != acred->gid)
 			return 0;
 
 		groups = acred->group_info->ngroups;
@@ -132,8 +126,8 @@
 				return 0;
 		return 1;
 	}
-	return (cred->uc_uid == 0 && cred->uc_puid == 0
-	     && cred->uc_gid == 0 && cred->uc_pgid == 0
+	return (cred->uc_uid == 0
+	     && cred->uc_gid == 0
 	     && cred->uc_gids[0] == (gid_t) NOGROUP);
 }
 
-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
