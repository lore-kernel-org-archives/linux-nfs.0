From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 6/6] NFS: Allow sloppy mount option parsing
Date: Wed, 30 Apr 2008 12:00:18 -0400
Message-ID: <20080430160018.32402.79021.stgit@manray.1015granger.net>
References: <20080430154011.32402.42101.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:59334 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757725AbYD3QAY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2008 12:00:24 -0400
Received: by an-out-0708.google.com with SMTP id d40so120817and.103
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2008 09:00:24 -0700 (PDT)
In-Reply-To: <20080430154011.32402.42101.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the kernel's NFS mount option parser will fail a mount if it sees
options it doesn't recognize.  This is to prevent data corruption in cases
where a required mount option such as "noac" is misspelled.

This is a problem in heterogeneous automounter environments, however.
The same automounter maps can be used by several different operating
systems, and NFS clients are expected to ignore mount options from other
operating systems that they don't recognize.

To address this, add a new NFS mount option that forces the in-kernel NFS
mount option parser to ignore unrecognized options and bad option values.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  236 ++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 150 insertions(+), 86 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e2cadd9..81afbcb 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -74,6 +74,7 @@ enum {
 	Opt_acl, Opt_noacl,
 	Opt_rdirplus, Opt_nordirplus,
 	Opt_sharecache, Opt_nosharecache,
+	Opt_sloppy,
 
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -125,6 +126,7 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_nordirplus, "nordirplus" },
 	{ Opt_sharecache, "sharecache" },
 	{ Opt_nosharecache, "nosharecache" },
+	{ Opt_sloppy, "sloppy" },
 
 	{ Opt_port, "port=%u" },
 	{ Opt_rsize, "rsize=%u" },
@@ -703,6 +705,40 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 }
 
 /*
+ * Look for the "sloppy" option.  We must copy the mount option
+ * string because strsep() replaces each ',' with a '\0'.
+ *
+ * Returns 1 if "sloppy" option is present, zero if not, or a
+ * negative errno value if a failure occurred.
+ */
+static int nfs_parse_sloppy_option(char *raw)
+{
+	char *p, *options;
+	int result = 0;
+
+	options = kstrdup(raw, GFP_KERNEL);
+	if (options == NULL)
+		return -ENOMEM;
+
+	while ((p = strsep(&options, ",")) != NULL) {
+		substring_t args[MAX_OPT_ARGS];
+		int token;
+
+		if (!*p)
+			continue;
+
+		token = match_token(p, nfs_mount_option_tokens, args);
+		if (token == Opt_sloppy) {
+			result = 1;
+			break;
+		}
+	}
+
+	kfree(options);
+	return result;
+}
+
+/*
  * Parse string addresses passed in via a mount option,
  * and construct a sockaddr based on the result.
  *
@@ -750,12 +786,17 @@ static int nfs_parse_mount_options(char *raw,
 	char *p, *string, *secdata;
 	int timeo = 0, retrans = 0;
 	unsigned short mount_protocol = 0;
-	int rc;
+	int rc, sloppy;
 
 	if (!raw) {
 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
 		return 1;
 	}
+
+	sloppy = nfs_parse_sloppy_option(raw);
+	if (sloppy == -ENOMEM)
+		goto out_nomem;
+
 	dfprintk(MOUNT, "NFS: nfs mount opts='%s'\n", raw);
 
 	secdata = alloc_secdata();
@@ -785,40 +826,40 @@ static int nfs_parse_mount_options(char *raw,
 		switch (token) {
 		case Opt_soft:
 			mnt->flags |= NFS_MOUNT_SOFT;
-			break;
+			continue;
 		case Opt_hard:
 			mnt->flags &= ~NFS_MOUNT_SOFT;
-			break;
+			continue;
 		case Opt_posix:
 			mnt->flags |= NFS_MOUNT_POSIX;
-			break;
+			continue;
 		case Opt_noposix:
 			mnt->flags &= ~NFS_MOUNT_POSIX;
-			break;
+			continue;
 		case Opt_cto:
 			mnt->flags &= ~NFS_MOUNT_NOCTO;
-			break;
+			continue;
 		case Opt_nocto:
 			mnt->flags |= NFS_MOUNT_NOCTO;
-			break;
+			continue;
 		case Opt_ac:
 			mnt->flags &= ~NFS_MOUNT_NOAC;
-			break;
+			continue;
 		case Opt_noac:
 			mnt->flags |= NFS_MOUNT_NOAC;
-			break;
+			continue;
 		case Opt_lock:
 			mnt->flags &= ~NFS_MOUNT_NONLM;
-			break;
+			continue;
 		case Opt_nolock:
 			mnt->flags |= NFS_MOUNT_NONLM;
-			break;
+			continue;
 		case Opt_v2:
 			mnt->flags &= ~NFS_MOUNT_VER3;
-			break;
+			continue;
 		case Opt_v3:
 			mnt->flags |= NFS_MOUNT_VER3;
-			break;
+			continue;
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
@@ -828,7 +869,7 @@ static int nfs_parse_mount_options(char *raw,
 				timeo = NFS_DEF_UDP_TIMEO;
 			if (retrans == 0)
 				retrans = NFS_DEF_UDP_RETRANS;
-			break;
+			continue;
 		case Opt_tcp:
 			mnt->flags |= NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
@@ -838,7 +879,7 @@ static int nfs_parse_mount_options(char *raw,
 				timeo = NFS_DEF_TCP_TIMEO;
 			if (retrans == 0)
 				retrans = NFS_DEF_TCP_RETRANS;
-			break;
+			continue;
 		case Opt_rdma:
 			mnt->flags |= NFS_MOUNT_TCP; /* for side protocols */
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
@@ -846,118 +887,121 @@ static int nfs_parse_mount_options(char *raw,
 				timeo = NFS_DEF_TCP_TIMEO;
 			if (retrans == 0)
 				retrans = NFS_DEF_TCP_RETRANS;
-			break;
+			continue;
 		case Opt_acl:
 			mnt->flags &= ~NFS_MOUNT_NOACL;
-			break;
+			continue;
 		case Opt_noacl:
 			mnt->flags |= NFS_MOUNT_NOACL;
-			break;
+			continue;
 		case Opt_rdirplus:
 			mnt->flags &= ~NFS_MOUNT_NORDIRPLUS;
-			break;
+			continue;
 		case Opt_nordirplus:
 			mnt->flags |= NFS_MOUNT_NORDIRPLUS;
-			break;
+			continue;
 		case Opt_sharecache:
 			mnt->flags &= ~NFS_MOUNT_UNSHARED;
-			break;
+			continue;
 		case Opt_nosharecache:
 			mnt->flags |= NFS_MOUNT_UNSHARED;
-			break;
+			continue;
+		case Opt_sloppy:
+			continue;
 
 		case Opt_port:
 			if (match_int(args, &option))
-				return 0;
+				break;
 			if (option < 0 || option > 65535)
-				return 0;
+				break;
 			mnt->nfs_server.port = option;
-			break;
+			continue;
 		case Opt_rsize:
 			if (match_int(args, &mnt->rsize))
-				return 0;
-			break;
+				break;
+			continue;
 		case Opt_wsize:
 			if (match_int(args, &mnt->wsize))
-				return 0;
-			break;
+				break;
+			continue;
 		case Opt_bsize:
 			if (match_int(args, &option))
-				return 0;
+				break;
 			if (option < 0)
-				return 0;
+				break;
 			mnt->bsize = option;
-			break;
+			continue;
 		case Opt_timeo:
 			if (match_int(args, &option))
-				return 0;
+				break;
 			if (option <= 0)
-				return 0;
+				break;
 			timeo = option;
-			break;
+			continue;
 		case Opt_retrans:
 			if (match_int(args, &option))
-				return 0;
+				break;
 			if (option <= 0)
-				return 0;
+				break;
 			retrans = option;
-			break;
+			continue;
 		case Opt_acregmin:
 			if (match_int(args, &mnt->acregmin))
-				return 0;
-			break;
+				break;
+			continue;
 		case Opt_acregmax:
 			if (match_int(args, &mnt->acregmax))
-				return 0;
-			break;
+				break;
+			continue;
 		case Opt_acdirmin:
 			if (match_int(args, &mnt->acdirmin))
-				return 0;
-			break;
+				break;
+			continue;
 		case Opt_acdirmax:
 			if (match_int(args, &mnt->acdirmax))
-				return 0;
-			break;
+				break;
+			continue;
 		case Opt_actimeo:
 			if (match_int(args, &option))
-				return 0;
+				break;
 			if (option < 0)
-				return 0;
+				break;
 			mnt->acregmin =
 			mnt->acregmax =
 			mnt->acdirmin =
 			mnt->acdirmax = option;
-			break;
+			continue;
 		case Opt_namelen:
 			if (match_int(args, &mnt->namlen))
-				return 0;
-			break;
+				break;
+			continue;
 		case Opt_mountport:
 			if (match_int(args, &option))
-				return 0;
+				break;
 			if (option < 0 || option > 65535)
-				return 0;
+				break;
 			mnt->mount_server.port = option;
-			break;
+			continue;
 		case Opt_mountvers:
 			if (match_int(args, &option))
-				return 0;
+				break;
 			if (option < 0)
-				return 0;
+				break;
 			mnt->mount_server.version = option;
-			break;
+			continue;
 		case Opt_nfsvers:
 			if (match_int(args, &option))
-				return 0;
+				break;
 			switch (option) {
 			case 2:
 				mnt->flags &= ~NFS_MOUNT_VER3;
-				break;
+				continue;
 			case 3:
 				mnt->flags |= NFS_MOUNT_VER3;
-				break;
+				continue;
 			default:
-				goto out_unrec_vers;
+				if (!sloppy)
+					goto out_unrec_vers;
 			}
 			break;
 
@@ -978,59 +1022,60 @@ static int nfs_parse_mount_options(char *raw,
 				mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 0;
 				mnt->auth_flavors[0] = RPC_AUTH_NULL;
-				break;
+				continue;
 			case Opt_sec_sys:
 				mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 0;
 				mnt->auth_flavors[0] = RPC_AUTH_UNIX;
-				break;
+				continue;
 			case Opt_sec_krb5:
 				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 1;
 				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5;
-				break;
+				continue;
 			case Opt_sec_krb5i:
 				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 1;
 				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5I;
-				break;
+				continue;
 			case Opt_sec_krb5p:
 				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 1;
 				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5P;
-				break;
+				continue;
 			case Opt_sec_lkey:
 				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 1;
 				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEY;
-				break;
+				continue;
 			case Opt_sec_lkeyi:
 				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 1;
 				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYI;
-				break;
+				continue;
 			case Opt_sec_lkeyp:
 				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 1;
 				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYP;
-				break;
+				continue;
 			case Opt_sec_spkm:
 				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 1;
 				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKM;
-				break;
+				continue;
 			case Opt_sec_spkmi:
 				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 1;
 				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMI;
-				break;
+				continue;
 			case Opt_sec_spkmp:
 				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
 				mnt->auth_flavor_len = 1;
 				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMP;
-				break;
+				continue;
 			default:
-				goto out_unrec_sec;
+				if (!sloppy)
+					goto out_unrec_sec;
 			}
 			break;
 		case Opt_proto:
@@ -1051,7 +1096,7 @@ static int nfs_parse_mount_options(char *raw,
 					timeo = NFS_DEF_UDP_TIMEO;
 				if (retrans == 0)
 					retrans = NFS_DEF_UDP_RETRANS;
-				break;
+				continue;
 			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
@@ -1061,7 +1106,7 @@ static int nfs_parse_mount_options(char *raw,
 					timeo = NFS_DEF_TCP_TIMEO;
 				if (retrans == 0)
 					retrans = NFS_DEF_TCP_RETRANS;
-				break;
+				continue;
 			case Opt_xprt_rdma:
 				/* vector side protocols to TCP */
 				mnt->flags |= NFS_MOUNT_TCP;
@@ -1070,9 +1115,10 @@ static int nfs_parse_mount_options(char *raw,
 					timeo = NFS_DEF_TCP_TIMEO;
 				if (retrans == 0)
 					retrans = NFS_DEF_TCP_RETRANS;
-				break;
+				continue;
 			default:
-				goto out_unrec_xprt;
+				if (!sloppy)
+					goto out_unrec_xprt;
 			}
 			break;
 		case Opt_mountproto:
@@ -1086,13 +1132,14 @@ static int nfs_parse_mount_options(char *raw,
 			switch (token) {
 			case Opt_xprt_udp:
 				mount_protocol = XPRT_TRANSPORT_UDP;
-				break;
+				continue;
 			case Opt_xprt_tcp:
 				mount_protocol = XPRT_TRANSPORT_TCP;
-				break;
+				continue;
 			case Opt_xprt_rdma: /* not used for side protocols */
 			default:
-				goto out_unrec_xprt;
+				if (!sloppy)
+					goto out_unrec_xprt;
 			}
 			break;
 		case Opt_addr:
@@ -1103,21 +1150,21 @@ static int nfs_parse_mount_options(char *raw,
 						 &mnt->nfs_server.address,
 						 &mnt->nfs_server.addrlen);
 			kfree(string);
-			break;
+			continue;
 		case Opt_clientaddr:
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
 			kfree(mnt->client_address);
 			mnt->client_address = string;
-			break;
+			continue;
 		case Opt_mounthost:
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
 			kfree(mnt->mount_server.hostname);
 			mnt->mount_server.hostname = string;
-			break;
+			continue;
 		case Opt_mountaddr:
 			string = match_strdup(args);
 			if (string == NULL)
@@ -1126,16 +1173,27 @@ static int nfs_parse_mount_options(char *raw,
 						 &mnt->mount_server.address,
 						 &mnt->mount_server.addrlen);
 			kfree(string);
-			break;
+			continue;
 
 		case Opt_userspace:
 		case Opt_deprecated:
-			dfprintk(MOUNT, "NFS:   ignoring nfs mount option '%s'\n", p);
-			break;
+			dfprintk(MOUNT, "NFS:   ignoring mount option '%s'\n",
+					p);
+			continue;
 
 		default:
+			dfprintk(MOUNT, "NFS:   unrecognized "
+					"mount option '%s'\n", p);
+			if (sloppy)
+				continue;
 			goto out_unknown;
 		}
+
+		dfprintk(MOUNT, "NFS:   incorrect value in "
+				"keyword=value mount option\n");
+		if (sloppy)
+			continue;
+		goto out_bad_value;
 	}
 
 	nfs_set_port((struct sockaddr *)&mnt->nfs_server.address,
@@ -1154,10 +1212,12 @@ static int nfs_parse_mount_options(char *raw,
 out_nomem:
 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
 	return 0;
+
 out_security_failure:
 	free_secdata(secdata);
 	printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
 	return 0;
+
 out_unrec_vers:
 	printk(KERN_INFO "NFS: unrecognized NFS version number\n");
 	return 0;
@@ -1170,6 +1230,10 @@ out_unrec_sec:
 	printk(KERN_INFO "NFS: unrecognized security flavor\n");
 	return 0;
 
+out_bad_value:
+	printk(KERN_INFO "NFS: incorrect value in keyword=value option\n");
+	return 0;
+
 out_unknown:
 	printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
 	return 0;

