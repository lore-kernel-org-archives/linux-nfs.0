From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: [PATCH 2.6.8] trivial sunrpc cleanup
Date: Wed, 15 Sep 2004 00:25:46 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040914222546.GA18250@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7LkF-0006ga-Lp
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 15:25:51 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C7LkE-0004fh-Kx
	for nfs@lists.sourceforge.net; Tue, 14 Sep 2004 15:25:51 -0700
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
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

Basically NFS_NGROUPS definitions are deleted at a few places,
introducing RPC_MAXGROUPS as a more appropriate replacement.
The patch also deletes a cast and SVC_CRED_NGROUPS (unused).

Signed-off-by: Frank van Maarseveen <frankvm@xs4all.nl>

diff -ru a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/msg_prot.h
--- a/include/linux/sunrpc/msg_prot.h	2004-05-10 04:32:54.000000000 +0200
+++ b/include/linux/sunrpc/msg_prot.h	2004-09-05 14:56:26.000000000 +0200
@@ -75,6 +75,7 @@
 #define RPC_PMAP_PORT		111
 
 #define RPC_MAXNETNAMELEN	256
+#define RPC_MAXGROUPS		16
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_MSGPROT_H_ */
diff -ru a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
--- a/include/linux/sunrpc/svcauth.h	2004-08-15 12:38:54.000000000 +0200
+++ b/include/linux/sunrpc/svcauth.h	2004-09-05 15:05:59.000000000 +0200
@@ -16,7 +16,6 @@
 #include <linux/sunrpc/cache.h>
 #include <linux/hash.h>
 
-#define SVC_CRED_NGROUPS	32
 struct svc_cred {
 	uid_t			cr_uid;
 	gid_t			cr_gid;
diff -ru a/net/sunrpc/auth.c b/net/sunrpc/auth.c
--- a/net/sunrpc/auth.c	2004-05-10 04:32:37.000000000 +0200
+++ b/net/sunrpc/auth.c	2004-09-06 00:28:06.000000000 +0200
@@ -249,7 +249,7 @@
 		}
 	}
 
-	return (struct rpc_cred *) cred;
+	return cred;
 }
 
 struct rpc_cred *
diff -ru a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
--- a/net/sunrpc/auth_gss/auth_gss.c	2004-08-15 12:38:57.000000000 +0200
+++ b/net/sunrpc/auth_gss/auth_gss.c	2004-09-05 15:13:56.000000000 +0200
@@ -63,8 +63,6 @@
 # define RPCDBG_FACILITY	RPCDBG_AUTH
 #endif
 
-#define NFS_NGROUPS	16
-
 #define GSS_CRED_EXPIRE		(60 * HZ)	/* XXX: reasonable? */
 #define GSS_CRED_SLACK		1024		/* XXX: unused */
 /* length of a krb5 verifier (48), plus data added before arguments when
diff -ru a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
--- a/net/sunrpc/auth_unix.c	2004-05-10 04:32:39.000000000 +0200
+++ b/net/sunrpc/auth_unix.c	2004-09-06 00:33:49.000000000 +0200
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
diff -ru a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
--- a/net/sunrpc/svcauth_unix.c	2004-08-15 12:38:57.000000000 +0200
+++ b/net/sunrpc/svcauth_unix.c	2004-09-05 15:15:17.000000000 +0200
@@ -447,7 +447,7 @@
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
