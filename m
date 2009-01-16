From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 5/5] NFS: Systemtap script
Date: Fri, 16 Jan 2009 11:33:56 -0500
Message-ID: <4970B6F4.6080501@RedHat.com>
References: <4970B451.4080201@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: SystemTAP <systemtap@redhat.com>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4970B451.4080201@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

The systemtap scripts used to pull and parse the information
from the kernel.

Signed-off-by: Steve Dickson <steved@redhat.com>

--- /dev/null	2009-01-08 09:11:53.943261863 -0500
+++ linux/samples/nfs/nfs_mount.stp	2009-01-15 12:23:11.000000000 -0500
@@ -0,0 +1,160 @@
+%{
+#include <linux/mount.h>
+#include <linux/nfs_mount.h>
+%}
+
+function _fstype_name:string (_fstype:long) %{
+	struct file_system_type *fstype;
+	char *name;
+
+	fstype = (struct file_system_type *)(long)kread(&(THIS->_fstype));
+	name = (char *)(long)kread(&fstype->name);
+
+	snprintf(THIS->__retvalue, MAXSTRINGLEN, "name %s flags 0x%x",
+		name, fstype->fs_flags);
+
+	CATCH_DEREF_FAULT();
+%}
+function _vfsmnt_dump:string (_vfsmnt:long) %{
+	struct vfsmount *vfsmnt;
+	char *dev;
+
+	vfsmnt = (struct vfsmount *)(long)kread(&(THIS->_vfsmnt));
+	dev = (char *)(long)kread(&vfsmnt->mnt_devname);
+
+	snprintf(THIS->__retvalue, MAXSTRINGLEN, "dev %s flags=0x%x",
+		vfsmnt->mnt_devname, vfsmnt->mnt_flags);
+
+	CATCH_DEREF_FAULT();
+%}
+function _nfsmnt_dump:string (_nfsmnt:long) %{
+	struct nfs_mount_data *data;
+	unsigned char *bytes;
+
+	data = (struct nfs_mount_data *)(long)kread(&(THIS->_nfsmnt));
+	bytes = (unsigned char *)&data->addr.sin_addr.s_addr;
+
+	snprintf(THIS->__retvalue, MAXSTRINGLEN, 
+		"vers %d flags 0x%x flavor %d hostname %s(%d.%d.%d.%d)",
+		data->version, data->flags, data->pseudoflavor,
+		data->hostname, bytes[0], bytes[1], bytes[2], bytes[3]);
+
+	CATCH_DEREF_FAULT();
+%}
+
+probe kernel.mark("nfs_mount") {
+    printf("nfs_mount:entry: fstype (%s) flags %x dev %s\n",
+		_fstype_name($arg1), $arg2, kernel_string($arg3));
+    printf("\tdata: %s\n\tmnt: %s\n",
+		_nfsmnt_dump($arg4), _vfsmnt_dump($arg5));
+
+}
+probe  kernel.mark("nfs_mount_data_null") {
+    printf("nfs_mount: missing mount data: errno %d\n", $arg1);
+}
+probe  kernel.mark("nfs_mount_data_badvers") {
+
+	if ($arg1 <= 0) {
+    	printf("nfs_mount: invalid mount version: vers %d <= 0\n", $arg1);
+	} else  {
+    	printf("nfs_mount: invalid mount version: vers %d > %d\n",
+			$arg1, $arg2);
+	}
+}
+probe  kernel.mark("nfs_mount_data_invalvers") {
+	if ($arg1 == 3) {
+    	printf("nfs_mount: mount structure version %d does not support NFSv3\n", 			$arg1);
+	} else { 
+		printf("nfs_mount: mount structure version %d does not support strong security\n", arg1)
+	}
+}
+probe  kernel.mark("nfs_mount_data_noaddr") {
+    printf("nfs_mount: invalid server IP address:\n");
+}
+probe  kernel.mark("nfs_mount_data_badsize") {
+    printf("nfs_mount: invalid root filehandle: fhsize %s > maxsize %d\n",
+		arg1, arg2);
+}
+probe kernel.mark("nfs_mount_get_root") {
+	printf("nfs_get_root: sb %p server %p mntfh %p\n", $arg1, $arg2, $arg3);
+}
+probe kernel.mark("nfs_mount_getroot_fhget1") {
+	printf("nfs_get_root: !s_root: nfs_fhget failed: errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_mount_getroot_alloc1") {
+	printf("nfs_get_root: !s_root: d_alloc_root failed: errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_mount_getroot_fhget2") {
+	printf("nfs_get_root: nfs_fhget failed: errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_mount_getroot_alloc2") {
+	printf("nfs_get_root: d_alloc_root failed: errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_mount_init_clnt") {
+	printf("nfs_init_client: nfs_create_rpc_client failed: errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_create_rpc_client") {
+	printf("nfs_create_rpc_client: clp %p proto %d timeo %d retrans %d flavor %d", 
+		$arg1, $arg2, $arg3, $arg4, $arg5);
+}
+probe kernel.mark("nfs_create_rpc_client_proto") {
+	printf("nfs_create_rpc_client: xprt_create_proto failed: errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_create_rpc_client_client") {
+	printf("nfs_create_rpc_client: rpc_create_client failed: errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_mount_init_srv") {
+	printf("nfs_init_server: nfs_get_client failed: errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_mount_sget") {
+	printf("nfs_init_server: nfs_get_client failed: errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+
+probe kernel.mark("nfs_init_server_rpcclient") {
+	printf("nfs_init_server_rpcclient: server %p flavor %d\n",
+		$arg1, $arg2);
+}
+probe kernel.mark("nfs_init_server_rpcclient_clone") {
+	printf("nfs_init_server_rpcclient: rpc_clone_client failed errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_init_server_rpcclient_auth") {
+	printf("nfs_init_server_rpcclient: rpcauth_create failed errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_start_lockd") {
+	// struct nfs_server *server = $arg1;
+
+	printf("nfs_start_lockd: lockd_up_proto failed errno %d (%s)\n",
+		$arg2, errno_str($arg2));
+}
+probe kernel.mark("nfs_probe_fsinfo") {
+	printf("nfs_probe_fsinfo: server %p mntfh %p fattr %p\n",
+		$arg1, $arg2, $arg3);
+}
+probe kernel.mark("nfs_probe_fsinfo_setcaps") {
+	printf("nfs_probe_fsinfo: set_capabilities failed errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_probe_fsinfo_fsinfo") {
+	printf("nfs_probe_fsinfo: fsinfo failed errno %d (%s)\n",
+		$arg1, errno_str($arg1));
+}
+probe kernel.mark("nfs_create_server") {
+	// struct nfs_server *server = $arg1;
+	// struct nfs_fh *mntfh = $arg2;
+
+	printf("nfs_create_server: getattr failed errno %d (%s)\n",
+		$arg3, errno_str($arg3));
+} 
+probe begin { log("starting nfs_mount trace") }
+probe end { log("ending nfs_mount trace") }
