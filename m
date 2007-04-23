From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/7] NFS: Add functions to parse nfs4 mount options
	to	fs/nfs/super.c
Date: Mon, 23 Apr 2007 18:04:03 -0400
Message-ID: <20070423220403.24305.26227.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg6dp-0003PJ-NY
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:13 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hg6ds-0005kx-0P
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:16 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Add infrastructure required for parsing nfs4 mount options in the NFS
client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  320 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 320 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4eb0f92..9260364 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -46,6 +46,7 @@
 #include <linux/in6.h>
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
+#include <linux/parser.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -58,6 +59,47 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+struct nfs4_mount_args {
+	struct nfs4_mount_data nmd;
+	struct sockaddr_in addr;
+	char clientaddr[81];
+	int authflavor;
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
+	Opt_sec_none, Opt_sec_sys,
+	Opt_sec_krb5, Opt_sec_krb5i, Opt_sec_krb5p,
+	Opt_sec_lkey, Opt_sec_lkeyi, Opt_sec_lkeyp,
+	Opt_sec_spkm, Opt_sec_spkmi, Opt_sec_spkmp,
+
+	/* Mount options that take integer arguments */
+	Opt_port,
+	Opt_rsize, Opt_wsize,
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
+	Opt_addr, Opt_mounthost, Opt_clientaddr, Opt_context,
+
+	Opt_ignore, Opt_err,
+};
+
 static void nfs_umount_begin(struct vfsmount *, int);
 static int  nfs_statfs(struct dentry *, struct kstatfs *);
 static int  nfs_show_options(struct seq_file *, struct vfsmount *);
@@ -776,6 +818,284 @@ error_splat_super:
 
 #ifdef CONFIG_NFS_V4
 
+static match_table_t nfs4_tokens = {
+	{Opt_port, "port=%u"},
+	{Opt_rsize, "rsize=%u"},
+	{Opt_wsize, "wsize=%u"},
+	{Opt_timeo, "timeo=%u"},
+	{Opt_retrans, "retrans=%u"},
+	{Opt_acregmin, "acregmin=%u"},
+	{Opt_acregmax, "acregmax=%u"},
+	{Opt_acdirmin, "acdirmin=%u"},
+	{Opt_acdirmax, "acdirmax=%u"},
+	{Opt_actimeo, "actimeo=%u"},
+	{Opt_ignore, "retry=%u"},
+
+	{Opt_addr, "addr=%s"},
+	{Opt_clientaddr, "clientaddr=%s"},
+
+	{Opt_ignore, "bg"},
+	{Opt_ignore, "fg"},
+	{Opt_soft, "soft"},
+	{Opt_hard, "hard"},
+	{Opt_intr, "intr"},
+	{Opt_nointr, "nointr"},
+	{Opt_cto, "cto"},
+	{Opt_nocto, "nocto"},
+	{Opt_ac, "ac"},
+	{Opt_noac, "noac"},
+	{Opt_udp, "proto=udp"},
+	{Opt_tcp, "proto=tcp"},
+
+	{Opt_sec_sys, "sec=sys"},
+	{Opt_sec_krb5, "sec=krb5"},
+	{Opt_sec_krb5i, "sec=krb5i"},
+	{Opt_sec_krb5p, "sec=krb5p"},
+	{Opt_sec_lkey, "sec=lkey"},
+	{Opt_sec_lkeyi, "sec=lkeyi"},
+	{Opt_sec_lkeyp, "sec=lkeyp"},
+	{Opt_sec_spkm, "sec=spkm"},
+	{Opt_sec_spkmi, "sec=spkmi"},
+	{Opt_sec_spkmp, "sec=spkmp"},
+
+	{Opt_err, NULL},
+};
+
+static int nfs4_parse_options(char *raw, struct nfs4_mount_args *mnt)
+{
+	char *p;
+
+	if (!raw)
+		return 1;
+
+	while ((p = strsep (&raw, ",")) != NULL) {
+		substring_t args[MAX_OPT_ARGS];
+		unsigned int option;
+		int token;
+
+		if (!*p)
+			continue;
+		token = match_token(p, nfs4_tokens, args);
+
+		dprintk("NFS:   nfs4 mount option '%s': parsing token %d\n",
+			p, token);
+
+		switch (token) {
+		case Opt_soft:
+			mnt->nmd.flags |= NFS4_MOUNT_SOFT;
+			break;
+		case Opt_hard:
+			mnt->nmd.flags &= ~NFS4_MOUNT_SOFT;
+			break;
+		case Opt_intr:
+			mnt->nmd.flags |= NFS4_MOUNT_INTR;
+			break;
+		case Opt_nointr:
+			mnt->nmd.flags &= ~NFS4_MOUNT_INTR;
+			break;
+		case Opt_cto:
+			mnt->nmd.flags &= ~NFS4_MOUNT_NOCTO;
+			break;
+		case Opt_nocto:
+			mnt->nmd.flags |= NFS4_MOUNT_NOCTO;
+			break;
+		case Opt_ac:
+			mnt->nmd.flags &= ~NFS4_MOUNT_NOAC;
+			break;
+		case Opt_noac:
+			mnt->nmd.flags |= NFS4_MOUNT_NOAC;
+			break;
+		case Opt_udp:
+			mnt->nmd.proto = IPPROTO_UDP;
+			break;
+		case Opt_tcp:
+			mnt->nmd.proto = IPPROTO_TCP;
+			break;
+
+		case Opt_sec_sys:
+			mnt->nmd.auth_flavourlen = 0;
+				break;
+		case Opt_sec_krb5:
+			mnt->nmd.auth_flavourlen = 1;
+			*mnt->nmd.auth_flavours = RPC_AUTH_GSS_KRB5;
+			break;
+		case Opt_sec_krb5i:
+			mnt->nmd.auth_flavourlen = 1;
+			*mnt->nmd.auth_flavours = RPC_AUTH_GSS_KRB5I;
+			break;
+		case Opt_sec_krb5p:
+			mnt->nmd.auth_flavourlen = 1;
+			*mnt->nmd.auth_flavours = RPC_AUTH_GSS_KRB5P;
+			break;
+		case Opt_sec_lkey:
+			mnt->nmd.auth_flavourlen = 1;
+			*mnt->nmd.auth_flavours = RPC_AUTH_GSS_LKEY;
+			break;
+		case Opt_sec_lkeyi:
+			mnt->nmd.auth_flavourlen = 1;
+			*mnt->nmd.auth_flavours = RPC_AUTH_GSS_LKEYI;
+			break;
+		case Opt_sec_lkeyp:
+			mnt->nmd.auth_flavourlen = 1;
+			*mnt->nmd.auth_flavours = RPC_AUTH_GSS_LKEYP;
+			break;
+		case Opt_sec_spkm:
+			mnt->nmd.auth_flavourlen = 1;
+			*mnt->nmd.auth_flavours = RPC_AUTH_GSS_SPKM;
+			break;
+		case Opt_sec_spkmi:
+			mnt->nmd.auth_flavourlen = 1;
+			*mnt->nmd.auth_flavours = RPC_AUTH_GSS_SPKMI;
+			break;
+		case Opt_sec_spkmp:
+			mnt->nmd.auth_flavourlen = 1;
+			*mnt->nmd.auth_flavours = RPC_AUTH_GSS_SPKMP;
+			break;
+
+		case Opt_port:
+			if (match_int(args, &option))
+				return 0;
+			if (option > 65535)
+				return 0;
+			mnt->addr.sin_port = htonl(option);
+			break;
+		case Opt_rsize:
+			if (match_int(args, &mnt->nmd.rsize))
+				return 0;
+			break;
+		case Opt_wsize:
+			if (match_int(args, &mnt->nmd.wsize))
+				return 0;
+			break;
+		case Opt_timeo:
+			if (match_int(args, &mnt->nmd.timeo))
+				return 0;
+			break;
+		case Opt_retrans:
+			if (match_int(args, &mnt->nmd.retrans))
+				return 0;
+			break;
+		case Opt_acregmin:
+			if (match_int(args, &mnt->nmd.acregmin))
+				return 0;
+			break;
+		case Opt_acregmax:
+			if (match_int(args, &mnt->nmd.acregmax))
+				return 0;
+			break;
+		case Opt_acdirmin:
+			if (match_int(args, &mnt->nmd.acdirmin))
+				return 0;
+			break;
+		case Opt_acdirmax:
+			if (match_int(args, &mnt->nmd.acdirmax))
+				return 0;
+			break;
+		case Opt_actimeo:
+			if (match_int(args, &option))
+				return 0;
+			mnt->nmd.acregmin =
+			mnt->nmd.acregmax =
+			mnt->nmd.acdirmin =
+			mnt->nmd.acdirmax = option;
+			break;
+
+		case Opt_addr: {
+			char *string = match_strdup(args);
+			if (string == NULL)
+				goto out_addr_nomem;
+			mnt->addr.sin_family = AF_INET;
+			mnt->addr.sin_addr.s_addr = in_aton(string);
+			kfree(string);
+			break;
+		}
+		case Opt_clientaddr: {
+			unsigned int len = args[0].to - args[0].from;
+			if (len > 80)
+				goto out_clntaddr_long;
+			match_strcpy(mnt->clientaddr, args);
+			mnt->nmd.client_addr.data = mnt->clientaddr;
+			mnt->nmd.client_addr.len = len;
+			break;
+		}
+
+		case Opt_ignore:	/* options handled by user-space */
+			break;
+
+		default:
+			goto out_unknown;
+		}
+	}
+
+	return 1;
+
+out_addr_nomem:
+	printk(KERN_ERR "NFS4: not enough memory to copy addr\n");
+	return 0;
+
+out_clntaddr_long:
+	printk(KERN_ERR "NFS4: clientaddr too long\n");
+	return 0;
+
+out_unknown:
+	printk(KERN_WARNING "NFS4: unrecognized mount option: %s\n", p);
+	return 0;
+}
+
+/*
+ * Convert a string of nfs4 mount options into an nfs4_mount_data struct.
+ *
+ * User space handles the following behaviors:
+ *
+ * + DNS: mapping server host name to IP address ("addr=" option)
+ *
+ * + DNS: providing IP address of callback interface ("clientaddr=" option)
+ *
+ * + failure mode: how to behave if a mount request can't be handled
+ *   immediately ("fg/bg" option)
+ *
+ * + retry: how often to retry a mount request ("retry=" option)
+ *
+ */
+static struct nfs4_mount_data *nfs4_convert_mount_opts(const char *options)
+{
+	struct nfs4_mount_args *args;
+
+	dprintk("NFS: nfs4 mount opts='%s'\n", options);
+
+	args = kzalloc(sizeof(*args), GFP_KERNEL);
+	if (args == NULL)
+		return ERR_PTR(-ENOMEM);
+	args->nmd.version = 2;
+
+	args->nmd.rsize = NFS_MAX_FILE_IO_SIZE;
+	args->nmd.wsize = NFS_MAX_FILE_IO_SIZE;
+	args->nmd.proto = IPPROTO_TCP;
+	args->nmd.timeo = 600;		/* in tenths of a second */
+	args->nmd.retrans = 2;
+	args->nmd.acregmin = 3;
+	args->nmd.acregmax = 60;
+	args->nmd.acdirmin = 30;
+	args->nmd.acdirmax = 60;
+
+	args->nmd.auth_flavourlen = 0;
+	args->nmd.auth_flavours = &args->authflavor;
+
+	args->nmd.host_addrlen = sizeof(args->addr);
+	args->nmd.host_addr = (struct sockaddr *) &args->addr;
+
+	args->addr.sin_port = htonl(NFS_PORT);
+
+	if (nfs4_parse_options((char *) options, args) == 0)
+		goto out_err;
+
+	return &args->nmd;
+
+out_err:
+	kfree(args);
+	return ERR_PTR(-EINVAL);
+}
+
 /*
  * Finish setting up a cloned NFS4 superblock
  */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
