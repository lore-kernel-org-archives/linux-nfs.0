From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFSv4: handle lack of clientaddr in option string gracefully
Date: Wed, 18 Jul 2007 11:28:43 -0400
Message-ID: <20070718112843.08644184.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

If a NFSv4 mount is attempted  with string based options, and the
option string doesn't contain a clientaddr= option, the kernel will
currently oops. Check for this situation and return a proper error.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a2b1af8..ff06b95 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1683,6 +1683,9 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
 
 		dprintk("MNTPATH: %s\n", *mntpath);
 
+		if (args.client_address == NULL)
+			goto out_no_client_address;
+
 		*ip_addr = args.client_address;
 
 		break;
@@ -1703,6 +1706,10 @@ out_inval_auth:
 out_no_address:
 	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
 	return -EINVAL;
+
+out_no_client_address:
+	dfprintk(MOUNT, "NFS4: mount program didn't pass callback address\n");
+	return -EINVAL;
 }
 
 /*
