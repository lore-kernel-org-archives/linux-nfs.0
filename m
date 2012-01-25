Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:38613 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752347Ab2AYO57 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 09:57:59 -0500
From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
To: linux-nfs@vger.kernel.org
Cc: akpm@linux-foundation.org, mingo@redhat.com, neilb@suse.de,
        stuart.menefy@st.com
Subject: [RFC:PATCH 3.1.0] do_mount: Add mount retry option for nfs root mount.
Date: Wed, 25 Jan 2012 14:50:03 +0000
Message-Id: <1327503003-21722-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds mountretry kernel parameter for nfs root mount.
mount retry indicates the number of times nfs root mount attempts to be
made before giving up. If this option is not specified, the default
value of 3 retries is used.

One noticable change for us from moving from 2.6.32 to 3.x kernel was
nfs root mount was failing all the time, because we use external PHY.
PHY takes about 2-4 seconds get into a Link ready state after ipconfig.
However as nfsroot mount is attempted in this halfway, which finally
fails.
Important thing to notice here is in 2.6.32 nfs mount usally spent more
than 4 seconds Looking up port of RPC, hence we got lucky to get
nfsroot mount working all the time.

Without this patch a rootdelay has to be added to kernel boot
parameters.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
Hello All,

Recently we have upgraded kernel from 2.6.32 to 3.x, and One noticable change 
in this process was nfs-root was failing all the time on our boards.
The reason being we are using external PHY, which takes about 2-4 seconds to 
get into Link UP state. In the mean time nfsroot mount attempted by kernel fails 
and results in Kernel panic "VFS: Unable to mount root fs via NFS, trying floppy."

In 2.6.32 nfs mount usally spent more than 4 seconds Looking up port of RPC, 
hence we got lucky.

To get nfs-root working on 3.x kernel we have to add rootdelay to the 
kernel parameters. If the kernel had attempted an other try to mount 
nfs root, it would have succeded.

This will be a common problem across all the boards with external phy's, so 
I was thinking of solving the problem with nfs mount retries option.

I would like to seek your inputs on this patch, and are there any other 
methods of solving this issue without rootdelay option?

Comments?

Thanks,
srini


 Documentation/kernel-parameters.txt |    4 ++++
 init/do_mounts.c                    |   25 +++++++++++++++++++++----
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index e00ec14..20a876e 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1824,6 +1824,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			This can be set from sysctl after boot.
 			See Documentation/sysctl/vm.txt for details.
 
+	mountretry=   	Is the number of times nfs root mount retries attempts
+			are made before giving up. If this option is not
+			specified, the default value of 3 is used.
+
 	ohci1394_dma=early	[HW] enable debugging via the ohci1394 driver.
 			See Documentation/debugging-via-ohci1394.txt for more
 			info.
diff --git a/init/do_mounts.c b/init/do_mounts.c
index c0851a8..03b8c05 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -258,6 +258,19 @@ __setup("rootflags=", root_data_setup);
 __setup("rootfstype=", fs_names_setup);
 __setup("rootdelay=", root_delay_setup);
 
+
+#ifdef CONFIG_ROOT_NFS
+#define DEF_NFS_MOUNT_RETRIES		3
+static unsigned int __initdata mount_retry = DEF_NFS_MOUNT_RETRIES;
+static int __init mount_retry_setup(char *str)
+{
+	mount_retry = kstrtoul(str, 0, NULL);
+	return 1;
+}
+
+__setup("mountretry=", mount_retry_setup);
+#endif
+
 static void __init get_fs_names(char *page)
 {
 	char *s = page;
@@ -363,12 +376,16 @@ out:
 static int __init mount_nfs_root(void)
 {
 	char *root_dev, *root_data;
-
+	unsigned int retries = mount_retry;
 	if (nfs_root_data(&root_dev, &root_data) != 0)
 		return 0;
-	if (do_mount_root(root_dev, "nfs", root_mountflags, root_data) != 0)
-		return 0;
-	return 1;
+
+	while (retries--) {
+		if (do_mount_root(root_dev,
+				"nfs", root_mountflags, root_data) == 0)
+			return 1;
+	}
+	return 0;
 }
 #endif
 
-- 
1.6.3.3

