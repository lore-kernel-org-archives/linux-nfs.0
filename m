From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: [PATCH 1/3 2.6.9-rc2] trivial sunrpc cleanup
Date: Thu, 16 Sep 2004 01:49:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040915234949.GA23903@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7jX6-0006uH-IG
	for nfs@lists.sourceforge.net; Wed, 15 Sep 2004 16:49:52 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C7jX5-0002ks-NF
	for nfs@lists.sourceforge.net; Wed, 15 Sep 2004 16:49:52 -0700
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

The 2.6.8 version would apply as well (2 line offset in one file)
but since the next patches are all against 2.6.9-rc2..

Signed-off-by: Frank van Maarseveen <frankvm@xs4all.nl>

diff -ru c/include/linux/sunrpc/msg_prot.h d/include/linux/sunrpc/msg_prot.h
--- c/include/linux/sunrpc/msg_prot.h	2004-05-10 04:32:54.000000000 +0200
+++ d/include/linux/sunrpc/msg_prot.h	2004-09-14 23:20:20.000000000 +0200
@@ -75,6 +75,7 @@
 #define RPC_PMAP_PORT		111
 
 #define RPC_MAXNETNAMELEN	256
+#define RPC_MAXGROUPS		16
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_MSGPROT_H_ */
diff -ru c/include/linux/sunrpc/svcauth.h d/include/linux/sunrpc/svcauth.h
--- c/include/linux/sunrpc/svcauth.h	2004-08-15 12:38:54.000000000 +0200
+++ d/include/linux/sunrpc/svcauth.h	2004-09-14 23:20:20.000000000 +0200
@@ -16,7 +16,6 @@
 #include <linux/sunrpc/cache.h>
 #include <linux/hash.h>
 
-#define SVC_CRED_NGROUPS	32
 struct svc_cred {
 	uid_t			cr_uid;
 	gid_t			cr_gid;
diff -ru c/net/sunrpc/auth.c d/net/sunrpc/auth.c
--- c/net/sunrpc/auth.c	2004-05-10 04:32:37.000000000 +0200
+++ d/net/sunrpc/auth.c	2004-09-14 23:20:20.000000000 +0200
@@ -249,7 +249,7 @@
 		}
 	}
 
-	return (struct rpc_cred *) cred;
+	return cred;
 }
 
 struct rpc_cred *
diff -ru c/net/sunrpc/auth_gss/auth_gss.c d/net/sunrpc/auth_gss/auth_gss.c
--- c/net/sunrpc/auth_gss/auth_gss.c	2004-09-14 23:03:19.000000000 +0200
+++ d/net/sunrpc/auth_gss/auth_gss.c	2004-09-14 23:20:20.000000000 +0200
@@ -63,8 +63,6 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
-#define NFS_NGROUPS	16
-
 #define GSS_CRED_EXPIRE		(60 * HZ)	/* XXX: reasonable? */
 #define GSS_CRED_SLACK		1024		/* XXX: unused */
 /* length of a krb5 verifier (48), plus data added before arguments when
diff -ru c/net/sunrpc/auth_unix.c d/net/sunrpc/auth_unix.c
--- c/net/sunrpc/auth_unix.c	2004-05-10 04:32:39.000000000 +0200
+++ d/net/sunrpc/auth_unix.c	2004-09-14 23:20:20.000000000 +0200
@@ -14,14 +14,12 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/auth.h>
 
-#define NFS_NGROUPS	16
-
 struct unx_cred {
 	struct rpc_cred		uc_base;
 	gid_t			uc_gid;
 	uid_t			uc_puid;		/* process uid */
 	gid_t			uc_pgid;		/* process gid */
-	gid_t			uc_gids[NFS_NGROUPS];
+	gid_t			uc_gids[RPC_MAXGROUPS];
 };
 #define uc_uid			uc_base.cr_uid
 #define uc_count		uc_base.cr_count
@@ -83,8 +81,8 @@
 		cred->uc_gids[0] = NOGROUP;
 	} else {
 		int groups = acred->group_info->ngroups;
-		if (groups > NFS_NGROUPS)
-			groups = NFS_NGROUPS;
+		if (groups > RPC_MAXGROUPS)
+			groups = RPC_MAXGROUPS;
 
 		cred->uc_uid = acred->uid;
 		cred->uc_gid = acred->gid;
@@ -92,8 +90,8 @@
 		cred->uc_pgid = current->gid;
 		for (i = 0; i < groups; i++)
 			cred->uc_gids[i] = GROUP_AT(acred->group_info, i);
-		if (i < NFS_NGROUPS)
-		  cred->uc_gids[i] = NOGROUP;
+		if (i < RPC_MAXGROUPS)
+			cred->uc_gids[i] = NOGROUP;
 	}
 	cred->uc_base.cr_ops = &unix_credops;
 
@@ -127,8 +125,8 @@
 			return 0;
 
 		groups = acred->group_info->ngroups;
-		if (groups > NFS_NGROUPS)
-			groups = NFS_NGROUPS;
+		if (groups > RPC_MAXGROUPS)
+			groups = RPC_MAXGROUPS;
 		for (i = 0; i < groups ; i++)
 			if (cred->uc_gids[i] != GROUP_AT(acred->group_info, i))
 				return 0;
@@ -169,7 +167,7 @@
 		*p++ = htonl((u32) cred->uc_gid);
 	}
 	hold = p++;
-	for (i = 0; i < 16 && cred->uc_gids[i] != (gid_t) NOGROUP; i++)
+	for (i = 0; i < RPC_MAXGROUPS && cred->uc_gids[i] != (gid_t) NOGROUP; i++)
 		*p++ = htonl((u32) cred->uc_gids[i]);
 	*hold = htonl(p - hold - 1);		/* gid array length */
 	*base = htonl((p - base - 1) << 2);	/* cred length */
diff -ru c/net/sunrpc/svcauth_unix.c d/net/sunrpc/svcauth_unix.c
--- c/net/sunrpc/svcauth_unix.c	2004-09-14 23:03:19.000000000 +0200
+++ d/net/sunrpc/svcauth_unix.c	2004-09-14 23:20:20.000000000 +0200
@@ -445,7 +445,7 @@
 	cred->cr_uid = ntohl(svc_getu32(argv));		/* uid */
 	cred->cr_gid = ntohl(svc_getu32(argv));		/* gid */
 	slen = ntohl(svc_getu32(argv));			/* gids length */
-	if (slen > 16 || (len -= (slen + 2)*4) < 0)
+	if (slen > RPC_MAXGROUPS || (len -= (slen + 2)*4) < 0)
 		goto badcred;
 	cred->cr_group_info = groups_alloc(slen);
 	if (cred->cr_group_info == NULL)

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
