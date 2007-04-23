From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] NFS: Add functions to parse nfs mount options
	to	fs/nfs/super.c
Date: Mon, 23 Apr 2007 18:04:29 -0400
Message-ID: <20070423220429.24305.99451.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg6eB-0003QY-T7
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:37 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hg6eE-0005od-04
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:38 -0700
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

Add infrastructure required for parsing nfs mount options in the NFS
client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  455 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 454 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index be3f349..5896973 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -61,6 +61,16 @@
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
+struct nfs_mount_args {
+	struct nfs_mount_data nmd;
+	unsigned int nfsprog;
+	unsigned use_mnthost;
+	struct sockaddr_in mnthost;
+	unsigned int mntprog;
+	unsigned int mntvers;
+	unsigned short mntport;
+};
+
 struct nfs4_mount_args {
 	struct nfs4_mount_data nmd;
 	struct sockaddr_in addr;
@@ -97,7 +107,7 @@ enum {
 	Opt_nfsprog, Opt_nfsvers,
 
 	/* Mount options that take string arguments */
-	Opt_addr, Opt_mounthost, Opt_clientaddr, Opt_context,
+	Opt_proto, Opt_addr, Opt_mounthost, Opt_clientaddr, Opt_context,
 
 	Opt_ignore, Opt_err,
 };
@@ -478,6 +488,449 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
 	shrink_submounts(vfsmnt, &nfs_automount_list);
 }
 
+
+static match_table_t nfs_tokens = {
+	{Opt_ignore, "bg"},
+	{Opt_ignore, "fg"},
+	{Opt_soft, "soft"},
+	{Opt_hard, "hard"},
+	{Opt_intr, "intr"},
+	{Opt_nointr, "nointr"},
+	{Opt_posix, "posix"},
+	{Opt_noposix, "noposix"},
+	{Opt_cto, "cto"},
+	{Opt_nocto, "nocto"},
+	{Opt_ac, "ac"},
+	{Opt_noac, "noac"},
+	{Opt_lock, "lock"},
+	{Opt_nolock, "nolock"},
+	{Opt_v2, "v2"},
+	{Opt_v3, "v3"},
+	{Opt_udp, "udp"},
+	{Opt_tcp, "tcp"},
+	{Opt_acl, "acl"},
+	{Opt_noacl, "noacl"},
+
+	{Opt_sec_none, "sec=none"},
+	{Opt_sec_none, "sec=null"},
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
+	{Opt_namelen, "namlen=%u"},
+	{Opt_mountport, "mountport=%u"},
+	{Opt_mountprog, "mountprog=%u"},
+	{Opt_mountvers, "mountvers=%u"},
+	{Opt_nfsprog, "nfsprog=%u"},
+	{Opt_nfsvers, "nfsvers=%u"},
+	{Opt_nfsvers, "vers=%u"},
+
+	{Opt_proto, "proto=%s"},
+	{Opt_addr, "addr=%s"},
+	{Opt_mounthost, "mounthost=%s"},
+	{Opt_context, "context=%s"},
+
+	{Opt_err, NULL},
+};
+
+static int nfs_parse_options(char *raw, struct nfs_mount_args *mnt)
+{
+	char *p;
+
+	if (!raw) {
+		dprintk("NFS: mount options string was NULL.\n");
+		return 1;
+	}
+
+	while ((p = strsep (&raw, ",")) != NULL) {
+		substring_t args[MAX_OPT_ARGS];
+		unsigned int option;
+		int token;
+
+		if (!*p)
+			continue;
+		token = match_token(p, nfs_tokens, args);
+
+		dprintk("NFS:   nfs mount option '%s': parsing token %d\n",
+			p, token);
+
+		switch (token) {
+		case Opt_soft:
+			mnt->nmd.flags |= NFS_MOUNT_SOFT;
+			break;
+		case Opt_hard:
+			mnt->nmd.flags &= ~NFS_MOUNT_SOFT;
+			break;
+		case Opt_intr:
+			mnt->nmd.flags |= NFS_MOUNT_INTR;
+			break;
+		case Opt_nointr:
+			mnt->nmd.flags &= ~NFS_MOUNT_INTR;
+			break;
+		case Opt_posix:
+			mnt->nmd.flags |= NFS_MOUNT_POSIX;
+			break;
+		case Opt_noposix:
+			mnt->nmd.flags &= ~NFS_MOUNT_POSIX;
+			break;
+		case Opt_cto:
+			mnt->nmd.flags &= ~NFS_MOUNT_NOCTO;
+			break;
+		case Opt_nocto:
+			mnt->nmd.flags |= NFS_MOUNT_NOCTO;
+			break;
+		case Opt_ac:
+			mnt->nmd.flags &= ~NFS_MOUNT_NOAC;
+			break;
+		case Opt_noac:
+			mnt->nmd.flags |= NFS_MOUNT_NOAC;
+			break;
+		case Opt_lock:
+			mnt->nmd.flags &= ~NFS_MOUNT_NONLM;
+			break;
+		case Opt_nolock:
+			mnt->nmd.flags |= NFS_MOUNT_NONLM;
+			break;
+		case Opt_v2:
+			mnt->nmd.flags &= ~NFS_MOUNT_VER3;
+			break;
+		case Opt_v3:
+			mnt->nmd.flags |= NFS_MOUNT_VER3;
+			break;
+		case Opt_udp:
+			mnt->nmd.flags &= ~NFS_MOUNT_TCP;
+			break;
+		case Opt_tcp:
+			mnt->nmd.flags |= NFS_MOUNT_TCP;
+			break;
+		case Opt_acl:
+			mnt->nmd.flags &= ~NFS_MOUNT_NOACL;
+			break;
+		case Opt_noacl:
+			mnt->nmd.flags |= NFS_MOUNT_NOACL;
+			break;
+
+		case Opt_sec_none:
+			mnt->nmd.flags &= ~NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_NULL;
+			break;
+		case Opt_sec_sys:
+			mnt->nmd.flags &= ~NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_UNIX;
+			break;
+		case Opt_sec_krb5:
+			mnt->nmd.flags |= NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_GSS_KRB5;
+			break;
+		case Opt_sec_krb5i:
+			mnt->nmd.flags |= NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_GSS_KRB5I;
+			break;
+		case Opt_sec_krb5p:
+			mnt->nmd.flags |= NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_GSS_KRB5P;
+			break;
+		case Opt_sec_lkey:
+			mnt->nmd.flags |= NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_GSS_LKEY;
+			break;
+		case Opt_sec_lkeyi:
+			mnt->nmd.flags |= NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_GSS_LKEYI;
+			break;
+		case Opt_sec_lkeyp:
+			mnt->nmd.flags |= NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_GSS_LKEYP;
+			break;
+		case Opt_sec_spkm:
+			mnt->nmd.flags |= NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_GSS_SPKM;
+			break;
+		case Opt_sec_spkmi:
+			mnt->nmd.flags |= NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_GSS_SPKMI;
+			break;
+		case Opt_sec_spkmp:
+			mnt->nmd.flags |= NFS_MOUNT_SECFLAVOUR;
+			mnt->nmd.pseudoflavor = RPC_AUTH_GSS_SPKMP;
+			break;
+
+		case Opt_port:
+			if (match_int(args, &option))
+				return 0;
+			if (option > 65535)
+				return 0;
+			mnt->nmd.addr.sin_port = htonl(option);
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
+		case Opt_namelen:
+			if (match_int(args, &mnt->nmd.namlen))
+				return 0;
+			break;
+		case Opt_mountport:
+			if (match_int(args, &option))
+				return 0;
+			if (option > 65535)
+				return 0;
+			mnt->mnthost.sin_port = htonl(option);
+			break;
+		case Opt_mountprog:
+			if (match_int(args, &option))
+				return 0;
+			mnt->mntprog = option;
+			break;
+		case Opt_mountvers:
+			if (match_int(args, &option))
+				return 0;
+			mnt->mntvers = option;
+			break;
+		case Opt_nfsprog:
+			if (match_int(args, &option))
+				return 0;
+			mnt->nfsprog = option;
+			break;
+		case Opt_nfsvers:
+			if (match_int(args, &option))
+				return 0;
+			switch (option) {
+			case 2:
+				mnt->nmd.flags &= ~NFS_MOUNT_VER3;
+				break;
+			case 3:
+				mnt->nmd.flags |= NFS_MOUNT_VER3;
+				break;
+			default:
+				goto out_unrec_vers;
+			}
+			break;
+
+		case Opt_proto: {
+			char *string = match_strdup(args);
+			if (string == NULL)
+				goto out_addr_nomem;
+			if (strcmp(string, "udp") == 0) {
+				mnt->nmd.flags &= ~NFS_MOUNT_TCP;
+				kfree(string);
+				break;
+			}
+			if (strcmp(string, "tcp") == 0) {
+				mnt->nmd.flags |= NFS_MOUNT_TCP;
+				kfree(string);
+				break;
+			}
+			goto out_unrec_xprt;
+		}
+		case Opt_addr: {
+			char *string = match_strdup(args);
+			if (string == NULL)
+				goto out_addr_nomem;
+			mnt->nmd.addr.sin_family = AF_INET;
+			mnt->nmd.addr.sin_addr.s_addr = in_aton(string);
+			kfree(string);
+			break;
+		}
+		case Opt_mounthost: {
+			char *string = match_strdup(args);
+			if (string == NULL)
+				goto out_addr_nomem;
+			mnt->mnthost.sin_family = AF_INET;
+			mnt->mnthost.sin_addr.s_addr = in_aton(string);
+			kfree(string);
+			mnt->use_mnthost = 1;
+			break;
+		}
+		case Opt_context:
+			/* copy context into nfs_mount_data */
+			break;
+
+		case Opt_ignore:
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
+	printk(KERN_ERR "NFS: not enough memory to copy addr\n");
+	return 0;
+
+out_unrec_vers:
+	printk(KERN_ERR "NFS: unrecognized NFS version number\n");
+	return 0;
+
+out_unrec_xprt:
+	printk(KERN_ERR "NFS: unrecognized transport protocol\n");
+	return 0;
+
+out_unknown:
+	printk(KERN_WARNING "NFS: unknown mount option: %s\n", p);
+	return 0;
+}
+
+/*
+ * Use the remote server's MOUNT service to request the NFS file handle
+ * corresponding to the provided path.
+ */
+static int nfs_try_mount(struct nfs_mount_data *nmd, char *path)
+{
+	struct nfs_mount_args *args;
+	int status, version, protocol;
+	struct sockaddr_in sin;
+	struct nfs_fh fh;
+
+	args = container_of(nmd, struct nfs_mount_args, nmd);
+	if (args->mntvers == 0) {
+		version = (args->nmd.flags & NFS_MOUNT_VER3) ?
+					NFS_MNT3_VERSION : NFS_MNT_VERSION;
+	} else
+		version = args->mntvers;
+	protocol = (args->nmd.flags & NFS_MOUNT_TCP) ?
+				IPPROTO_TCP : IPPROTO_UDP;
+
+	sin.sin_family = AF_INET;
+	if (args->use_mnthost == 0)
+		sin.sin_addr.s_addr = args->nmd.addr.sin_addr.s_addr;
+	else
+		sin.sin_addr.s_addr = args->mnthost.sin_addr.s_addr;
+	if (args->mntport == 0) {
+		status = rpcb_getport_sync(&sin, args->mntprog, version, protocol);
+		if (status < 0)
+			goto out_err;
+		sin.sin_port = htons(status);
+	} else
+		sin.sin_port = htons(args->mntport);
+
+	sin.sin_addr.s_addr = args->nmd.addr.sin_addr.s_addr;
+	status = nfs_mount(&sin, path, &fh, version, protocol);
+	if (status < 0)
+		goto out_err;
+
+	args->nmd.root.size = fh.size;
+	memcpy(args->nmd.root.data, fh.data, fh.size);
+	return status;
+
+out_err:
+	printk(KERN_ERR "NFS: server returned error %d while mounting %s\n",
+	       -status, path);
+	return status;
+}
+
+/*
+ * Convert a string of nfs mount options into an nfs_mount_data struct.
+ *
+ * User space handles the following behaviors:
+ *
+ * + DNS: mapping server host name to IP address ("addr=" option)
+ *
+ * + failure mode: how to behave if a mount request can't be handled
+ *   immediately ("fg/bg" option)
+ *
+ * + retry: how often to retry a mount request ("retry=" option)
+ *
+ * + breaking back: trying UDP after TCP, and v2 after v3
+ *
+ * XXX: as far as I can tell, changing the NFS program is not really supported
+ *      in the NFS client.
+ *
+ */
+static struct nfs_mount_data *nfs_convert_mount_opts(const char *options)
+{
+	struct nfs_mount_args *args;
+
+	dprintk("NFS: nfs mount opts='%s'\n", options);
+
+	args = kzalloc(sizeof(*args), GFP_KERNEL);
+	if (args == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	args->nmd.version = 7;
+
+	args->nmd.flags = (NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
+	args->nmd.rsize = NFS_MAX_FILE_IO_SIZE;
+	args->nmd.wsize = NFS_MAX_FILE_IO_SIZE;
+	args->nmd.timeo = 600;		/* in tenths of a second */
+	args->nmd.retrans = 2;
+	args->nmd.acregmin = 3;
+	args->nmd.acregmax = 60;
+	args->nmd.acdirmin = 30;
+	args->nmd.acdirmax = 60;
+
+	args->nfsprog = NFS_PROGRAM;
+	args->use_mnthost = 0;
+	args->mntprog = NFS_MNT_PROGRAM;
+	args->mntvers = 0;
+	args->mntport = 0;
+
+	if (nfs_parse_options((char *) options, args) == 0)
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
  * Sanity-check a server address provided by the mount command
  */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
