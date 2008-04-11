From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS Client mounts hang when exported directory do not exist
Date: Fri, 11 Apr 2008 11:12:12 -0400
Message-ID: <47FF7FCC.2050403@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fedora Kernel Mailing list <fedora-kernel-list@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <fedora-kernel-list-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-kernel-list>,
	<mailto:fedora-kernel-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-kernel-list>
List-Post: <mailto:fedora-kernel-list@redhat.com>
List-Help: <mailto:fedora-kernel-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-kernel-list>,
	<mailto:fedora-kernel-list-request@redhat.com?subject=subscribe>
Sender: fedora-kernel-list-bounces@redhat.com
Errors-To: fedora-kernel-list-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

This patch fixes a regression that was introduced by the string based mounts. 

nfs_mount() statically returns -EACCES for every error returned
by the remote mounted. This is incorrect because -EACCES is
an non-fatal error to the mount.nfs command. This error causes
mount.nfs to retry the mount even in the case when the exported
directory does not exist. 

This patch maps the errors returned by the remote mountd into
valid errno values, exactly how it was done pre-string based 
mounts. By returning the correct errno enables mount.nfs 
to do the right thing.  

Signed-off-by: Steve Dickson <steved@redhat.com>
---

diff -up linux/fs/nfs/mount_clnt.c.orig linux/fs/nfs/mount_clnt.c
--- linux/fs/nfs/mount_clnt.c.orig	2008-04-09 08:32:43.000000000 -0400
+++ linux/fs/nfs/mount_clnt.c	2008-04-11 11:01:39.000000000 -0400
@@ -21,6 +21,49 @@
 
 static struct rpc_program	mnt_program;
 
+static struct {
+	enum nfs_stat stat;
+	int errnum;
+} mnt_errtbl[] = {
+	{ NFS_OK,		0		},
+	{ NFSERR_PERM,		EPERM		},
+	{ NFSERR_NOENT,		ENOENT		},
+	{ NFSERR_IO,		EIO		},
+	{ NFSERR_NXIO,		ENXIO		},
+	{ NFSERR_ACCES,		EACCES		},
+	{ NFSERR_EXIST,		EEXIST		},
+	{ NFSERR_NODEV,		ENODEV		},
+	{ NFSERR_NOTDIR,	ENOTDIR		},
+	{ NFSERR_ISDIR,		EISDIR		},
+#ifdef NFSERR_INVAL
+	{ NFSERR_INVAL,		EINVAL		},	/* that Sun forgot */
+#endif
+	{ NFSERR_FBIG,		EFBIG		},
+	{ NFSERR_NOSPC,		ENOSPC		},
+	{ NFSERR_ROFS,		EROFS		},
+	{ NFSERR_NAMETOOLONG,	ENAMETOOLONG	},
+	{ NFSERR_NOTEMPTY,	ENOTEMPTY	},
+	{ NFSERR_DQUOT,		EDQUOT		},
+	{ NFSERR_STALE,		ESTALE		},
+#ifdef EWFLUSH
+	{ NFSERR_WFLUSH,	EWFLUSH		},
+#endif
+	/* Throw in some NFSv3 values for even more fun (HP returns these) */
+	{ 71,			EREMOTE		},
+};
+static int mnt_errtbl_sz = sizeof(mnt_errtbl)/sizeof(mnt_errtbl[0]);
+
+static inline int mnt_err_map(int stat)
+{
+	int i;
+
+	for (i = 0; i < mnt_errtbl_sz; i++) {
+		if (mnt_errtbl[i].stat == stat)
+			return -mnt_errtbl[i].errnum;
+	}
+	return -EACCES;
+}
+
 struct mnt_fhstatus {
 	u32 status;
 	struct nfs_fh *fh;
@@ -98,7 +141,7 @@ out_call_err:
 
 out_mnt_err:
 	dprintk("NFS: MNT server returned result %d\n", result.status);
-	status = -EACCES;
+	status = mnt_err_map(result.status);
 	goto out;
 }
