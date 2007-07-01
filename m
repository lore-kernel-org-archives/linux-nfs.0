From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/21] NFS: Add enums and match tables for mount
	option parsing
Date: Sun, 01 Jul 2007 12:13:44 -0400
Message-ID: <20070701161343.2786.21041.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I52ig-00007z-B3
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:19 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I52ii-0007Rg-Dd
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:20 -0700
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

This generic infrastructure works for both NFS and NFSv4 mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  537 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 537 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2b5e681..3f24d63 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -45,6 +45,7 @@
 #include <linux/inet.h>
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
+#include <linux/parser.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -57,6 +58,167 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+
+struct nfs_parsed_mount_data {
+	int			flags;
+	int			rsize, wsize;
+	int			timeo, retrans;
+	int			acregmin, acregmax,
+				acdirmin, acdirmax;
+	int			namlen;
+	unsigned int		bsize;
+	unsigned int		auth_flavor_len;
+	rpc_authflavor_t	auth_flavors[1];
+	char			*client_address;
+
+	struct {
+		struct sockaddr_in	address;
+		unsigned int		program;
+		unsigned int		version;
+		unsigned short		port;
+		int			protocol;
+	} mount_server;
+
+	struct {
+		struct sockaddr_in	address;
+		char			*hostname;
+		char			*export_path;
+		unsigned int		program;
+		int			protocol;
+	} nfs_server;
+};
+
+enum {
+	/* Mount options that take no arguments */
+	Opt_soft, Opt_hard,
+	Opt_intr, Opt_nointr,
+	Opt_posix, Opt_noposix,
+	Opt_cto, Opt_nocto,
+	Opt_ac, Opt_noac,
+	Opt_lock, Opt_nolock,
+	Opt_v2, Opt_v3,
+	Opt_udp, Opt_tcp,
+	Opt_acl, Opt_noacl,
+	Opt_rdirplus, Opt_nordirplus,
+	Opt_shared, Opt_unshared,
+
+	/* Mount options that take integer arguments */
+	Opt_port,
+	Opt_rsize, Opt_wsize, Opt_bsize,
+	Opt_timeo, Opt_retrans,
+	Opt_acregmin, Opt_acregmax,
+	Opt_acdirmin, Opt_acdirmax,
+	Opt_actimeo,
+	Opt_namelen,
+	Opt_mountport,
+	Opt_mountprog, Opt_mountvers,
+	Opt_nfsprog, Opt_nfsvers,
+
+	/* Mount options that take string arguments */
+	Opt_sec, Opt_proto, Opt_mountproto,
+	Opt_addr, Opt_mounthost, Opt_clientaddr,
+
+	/* Mount options that are ignored */
+	Opt_userspace, Opt_deprecated,
+
+	Opt_err
+};
+
+static match_table_t nfs_mount_option_tokens = {
+	{ Opt_userspace, "bg" },
+	{ Opt_userspace, "fg" },
+	{ Opt_soft, "soft" },
+	{ Opt_hard, "hard" },
+	{ Opt_intr, "intr" },
+	{ Opt_nointr, "nointr" },
+	{ Opt_posix, "posix" },
+	{ Opt_noposix, "noposix" },
+	{ Opt_cto, "cto" },
+	{ Opt_nocto, "nocto" },
+	{ Opt_ac, "ac" },
+	{ Opt_noac, "noac" },
+	{ Opt_lock, "lock" },
+	{ Opt_nolock, "nolock" },
+	{ Opt_v2, "v2" },
+	{ Opt_v3, "v3" },
+	{ Opt_udp, "udp" },
+	{ Opt_tcp, "tcp" },
+	{ Opt_acl, "acl" },
+	{ Opt_noacl, "noacl" },
+	{ Opt_rdirplus, "rdirplus" },
+	{ Opt_nordirplus, "nordirplus" },
+	{ Opt_shared, "shared" },
+	{ Opt_unshared, "unshared" },
+
+	{ Opt_port, "port=%u" },
+	{ Opt_rsize, "rsize=%u" },
+	{ Opt_wsize, "wsize=%u" },
+	{ Opt_bsize, "bsize=%u" },
+	{ Opt_timeo, "timeo=%u" },
+	{ Opt_retrans, "retrans=%u" },
+	{ Opt_acregmin, "acregmin=%u" },
+	{ Opt_acregmax, "acregmax=%u" },
+	{ Opt_acdirmin, "acdirmin=%u" },
+	{ Opt_acdirmax, "acdirmax=%u" },
+	{ Opt_actimeo, "actimeo=%u" },
+	{ Opt_userspace, "retry=%u" },
+	{ Opt_namelen, "namlen=%u" },
+	{ Opt_mountport, "mountport=%u" },
+	{ Opt_mountprog, "mountprog=%u" },
+	{ Opt_mountvers, "mountvers=%u" },
+	{ Opt_nfsprog, "nfsprog=%u" },
+	{ Opt_nfsvers, "nfsvers=%u" },
+	{ Opt_nfsvers, "vers=%u" },
+
+	{ Opt_sec, "sec=%s" },
+	{ Opt_proto, "proto=%s" },
+	{ Opt_mountproto, "mountproto=%s" },
+	{ Opt_addr, "addr=%s" },
+	{ Opt_clientaddr, "clientaddr=%s" },
+	{ Opt_mounthost, "mounthost=%s" },
+
+	{ Opt_err, NULL }
+};
+
+enum {
+	Opt_xprt_udp, Opt_xprt_tcp,
+
+	Opt_xprt_err
+};
+
+static match_table_t nfs_xprt_protocol_tokens = {
+	{ Opt_xprt_udp, "udp" },
+	{ Opt_xprt_tcp, "tcp" },
+
+	{ Opt_xprt_err, NULL }
+};
+
+enum {
+	Opt_sec_none, Opt_sec_sys,
+	Opt_sec_krb5, Opt_sec_krb5i, Opt_sec_krb5p,
+	Opt_sec_lkey, Opt_sec_lkeyi, Opt_sec_lkeyp,
+	Opt_sec_spkm, Opt_sec_spkmi, Opt_sec_spkmp,
+
+	Opt_sec_err
+};
+
+static match_table_t nfs_secflavor_tokens = {
+	{ Opt_sec_none, "none" },
+	{ Opt_sec_none, "null" },
+	{ Opt_sec_sys, "sys" },
+
+	{ Opt_sec_krb5, "krb5" },
+	{ Opt_sec_krb5i, "krb5i" },
+	{ Opt_sec_krb5p, "krb5p" },
+
+	{ Opt_sec_lkey, "lkey" },
+	{ Opt_sec_lkeyi, "lkeyi" },
+	{ Opt_sec_lkeyp, "lkeyp" },
+
+	{ Opt_sec_err, NULL }
+};
+
+
 static void nfs_umount_begin(struct vfsmount *, int);
 static int  nfs_statfs(struct dentry *, struct kstatfs *);
 static int  nfs_show_options(struct seq_file *, struct vfsmount *);
@@ -465,6 +627,381 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 }
 
 /*
+ * Error-check and convert a string of mount options from user space into
+ * a data structure
+ */
+static int nfs_parse_mount_options(char *raw,
+				   struct nfs_parsed_mount_data *mnt)
+{
+	char *p, *string;
+
+	if (!raw) {
+		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
+		return 1;
+	}
+	dfprintk(MOUNT, "NFS: nfs mount opts='%s'\n", raw);
+
+	while ((p = strsep(&raw, ",")) != NULL) {
+		substring_t args[MAX_OPT_ARGS];
+		int option, token;
+
+		if (!*p)
+			continue;
+
+		dfprintk(MOUNT, "NFS:   parsing nfs mount option '%s'\n", p);
+
+		token = match_token(p, nfs_mount_option_tokens, args);
+		switch (token) {
+		case Opt_soft:
+			mnt->flags |= NFS_MOUNT_SOFT;
+			break;
+		case Opt_hard:
+			mnt->flags &= ~NFS_MOUNT_SOFT;
+			break;
+		case Opt_intr:
+			mnt->flags |= NFS_MOUNT_INTR;
+			break;
+		case Opt_nointr:
+			mnt->flags &= ~NFS_MOUNT_INTR;
+			break;
+		case Opt_posix:
+			mnt->flags |= NFS_MOUNT_POSIX;
+			break;
+		case Opt_noposix:
+			mnt->flags &= ~NFS_MOUNT_POSIX;
+			break;
+		case Opt_cto:
+			mnt->flags &= ~NFS_MOUNT_NOCTO;
+			break;
+		case Opt_nocto:
+			mnt->flags |= NFS_MOUNT_NOCTO;
+			break;
+		case Opt_ac:
+			mnt->flags &= ~NFS_MOUNT_NOAC;
+			break;
+		case Opt_noac:
+			mnt->flags |= NFS_MOUNT_NOAC;
+			break;
+		case Opt_lock:
+			mnt->flags &= ~NFS_MOUNT_NONLM;
+			break;
+		case Opt_nolock:
+			mnt->flags |= NFS_MOUNT_NONLM;
+			break;
+		case Opt_v2:
+			mnt->flags &= ~NFS_MOUNT_VER3;
+			break;
+		case Opt_v3:
+			mnt->flags |= NFS_MOUNT_VER3;
+			break;
+		case Opt_udp:
+			mnt->flags &= ~NFS_MOUNT_TCP;
+			mnt->nfs_server.protocol = IPPROTO_UDP;
+			mnt->timeo = 7;
+			mnt->retrans = 5;
+			break;
+		case Opt_tcp:
+			mnt->flags |= NFS_MOUNT_TCP;
+			mnt->nfs_server.protocol = IPPROTO_TCP;
+			mnt->timeo = 600;
+			mnt->retrans = 2;
+			break;
+		case Opt_acl:
+			mnt->flags &= ~NFS_MOUNT_NOACL;
+			break;
+		case Opt_noacl:
+			mnt->flags |= NFS_MOUNT_NOACL;
+			break;
+		case Opt_rdirplus:
+			mnt->flags &= ~NFS_MOUNT_NORDIRPLUS;
+			break;
+		case Opt_nordirplus:
+			mnt->flags |= NFS_MOUNT_NORDIRPLUS;
+			break;
+		case Opt_shared:
+			mnt->flags &= ~NFS_MOUNT_UNSHARED;
+			break;
+		case Opt_unshared:
+			mnt->flags |= NFS_MOUNT_UNSHARED;
+			break;
+
+		case Opt_port:
+			if (match_int(args, &option))
+				return 0;
+			if (option < 0 || option > 65535)
+				return 0;
+			mnt->nfs_server.address.sin_port = htonl(option);
+			break;
+		case Opt_rsize:
+			if (match_int(args, &mnt->rsize))
+				return 0;
+			break;
+		case Opt_wsize:
+			if (match_int(args, &mnt->wsize))
+				return 0;
+			break;
+		case Opt_bsize:
+			if (match_int(args, &option))
+				return 0;
+			if (option < 0)
+				return 0;
+			mnt->bsize = option;
+			break;
+		case Opt_timeo:
+			if (match_int(args, &mnt->timeo))
+				return 0;
+			break;
+		case Opt_retrans:
+			if (match_int(args, &mnt->retrans))
+				return 0;
+			break;
+		case Opt_acregmin:
+			if (match_int(args, &mnt->acregmin))
+				return 0;
+			break;
+		case Opt_acregmax:
+			if (match_int(args, &mnt->acregmax))
+				return 0;
+			break;
+		case Opt_acdirmin:
+			if (match_int(args, &mnt->acdirmin))
+				return 0;
+			break;
+		case Opt_acdirmax:
+			if (match_int(args, &mnt->acdirmax))
+				return 0;
+			break;
+		case Opt_actimeo:
+			if (match_int(args, &option))
+				return 0;
+			if (option < 0)
+				return 0;
+			mnt->acregmin =
+			mnt->acregmax =
+			mnt->acdirmin =
+			mnt->acdirmax = option;
+			break;
+		case Opt_namelen:
+			if (match_int(args, &mnt->namlen))
+				return 0;
+			break;
+		case Opt_mountport:
+			if (match_int(args, &option))
+				return 0;
+			if (option < 0 || option > 65535)
+				return 0;
+			mnt->mount_server.port = option;
+			break;
+		case Opt_mountprog:
+			if (match_int(args, &option))
+				return 0;
+			if (option < 0)
+				return 0;
+			mnt->mount_server.program = option;
+			break;
+		case Opt_mountvers:
+			if (match_int(args, &option))
+				return 0;
+			if (option < 0)
+				return 0;
+			mnt->mount_server.version = option;
+			break;
+		case Opt_nfsprog:
+			if (match_int(args, &option))
+				return 0;
+			if (option < 0)
+				return 0;
+			mnt->nfs_server.program = option;
+			break;
+		case Opt_nfsvers:
+			if (match_int(args, &option))
+				return 0;
+			switch (option) {
+			case 2:
+				mnt->flags &= ~NFS_MOUNT_VER3;
+				break;
+			case 3:
+				mnt->flags |= NFS_MOUNT_VER3;
+				break;
+			default:
+				goto out_unrec_vers;
+			}
+			break;
+
+		case Opt_sec:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			token = match_token(string, nfs_secflavor_tokens, args);
+			kfree(string);
+
+			/*
+ 			 * The flags setting is for v2/v3.  The flavor_len
+ 			 * setting is for v4.  v2/v3 also need to know the
+ 			 * difference between NULL and UNIX.
+ 			 */
+			switch (token) {
+			case Opt_sec_none:
+				mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 0;
+				mnt->auth_flavors[0] = RPC_AUTH_NULL;
+				break;
+			case Opt_sec_sys:
+				mnt->flags &= ~NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 0;
+				mnt->auth_flavors[0] = RPC_AUTH_UNIX;
+				break;
+			case Opt_sec_krb5:
+				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 1;
+				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5;
+				break;
+			case Opt_sec_krb5i:
+				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 1;
+				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5I;
+				break;
+			case Opt_sec_krb5p:
+				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 1;
+				mnt->auth_flavors[0] = RPC_AUTH_GSS_KRB5P;
+				break;
+			case Opt_sec_lkey:
+				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 1;
+				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEY;
+				break;
+			case Opt_sec_lkeyi:
+				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 1;
+				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYI;
+				break;
+			case Opt_sec_lkeyp:
+				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 1;
+				mnt->auth_flavors[0] = RPC_AUTH_GSS_LKEYP;
+				break;
+			case Opt_sec_spkm:
+				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 1;
+				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKM;
+				break;
+			case Opt_sec_spkmi:
+				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 1;
+				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMI;
+				break;
+			case Opt_sec_spkmp:
+				mnt->flags |= NFS_MOUNT_SECFLAVOUR;
+				mnt->auth_flavor_len = 1;
+				mnt->auth_flavors[0] = RPC_AUTH_GSS_SPKMP;
+				break;
+			default:
+				goto out_unrec_sec;
+			}
+			break;
+		case Opt_proto:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			token = match_token(string,
+					    nfs_xprt_protocol_tokens, args);
+			kfree(string);
+
+			switch (token) {
+			case Opt_udp:
+				mnt->flags &= ~NFS_MOUNT_TCP;
+				mnt->nfs_server.protocol = IPPROTO_UDP;
+				mnt->timeo = 7;
+				mnt->retrans = 5;
+				break;
+			case Opt_tcp:
+				mnt->flags |= NFS_MOUNT_TCP;
+				mnt->nfs_server.protocol = IPPROTO_TCP;
+				mnt->timeo = 600;
+				mnt->retrans = 2;
+				break;
+			default:
+				goto out_unrec_xprt;
+			}
+			break;
+		case Opt_mountproto:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			token = match_token(string,
+					    nfs_xprt_protocol_tokens, args);
+			kfree(string);
+
+			switch (token) {
+			case Opt_udp:
+				mnt->mount_server.protocol = IPPROTO_UDP;
+				break;
+			case Opt_tcp:
+				mnt->mount_server.protocol = IPPROTO_TCP;
+				break;
+			default:
+				goto out_unrec_xprt;
+			}
+			break;
+		case Opt_addr:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			mnt->nfs_server.address.sin_family = AF_INET;
+			mnt->nfs_server.address.sin_addr.s_addr =
+							in_aton(string);
+			kfree(string);
+			break;
+		case Opt_clientaddr:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			mnt->client_address = string;
+			break;
+		case Opt_mounthost:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			mnt->mount_server.address.sin_family = AF_INET;
+			mnt->mount_server.address.sin_addr.s_addr =
+							in_aton(string);
+			kfree(string);
+			break;
+
+		case Opt_userspace:
+		case Opt_deprecated:
+			break;
+
+		default:
+			goto out_unknown;
+		}
+	}
+
+	return 1;
+
+out_nomem:
+	printk(KERN_INFO "NFS: not enough memory to parse option\n");
+	return 0;
+
+out_unrec_vers:
+	printk(KERN_INFO "NFS: unrecognized NFS version number\n");
+	return 0;
+
+out_unrec_xprt:
+	printk(KERN_INFO "NFS: unrecognized transport protocol\n");
+	return 0;
+
+out_unrec_sec:
+	printk(KERN_INFO "NFS: unrecognized security flavor\n");
+	return 0;
+
+out_unknown:
+	printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
+	return 0;
+}
+
+/*
  * Validate the NFS2/NFS3 mount data
  * - fills in the mount root filehandle
  */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
