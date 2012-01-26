Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:56604 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751431Ab2AZOzY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 09:55:24 -0500
From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
To: linux-nfs@vger.kernel.org
Cc: akpm@linux-foundation.org, mingo@redhat.com, neilb@suse.de,
        stuart.menefy@st.com, chuck.lever@oracle.com, bharrosh@panasas.com,
        rees@umich.edu
Subject: [PATCH 3.3.0-rc1 2/2] do_mounts: Add mount retry option for nfs root mount retry.
Date: Thu, 26 Jan 2012 14:47:55 +0000
Message-Id: <1327589275-16948-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds mountretry kernel parameter for nfs root mount.
mount retry indicates the number of times nfs root mount attempts to be
made before giving up. If this option is not specified, the default
value of 5 retries is used.

User should be allowed to configure nfs mount retries, because if he
either want to timeout quickly and try the succession root-mounts or If
he wish to keep kernel trying very harder till nfs-root mount is
successful.

Without this patch kernel has to wait for a constant big delay before
attempting to mount succession root-mount. And this patch also gives
user more flexibility with nfs-root mount retries.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
Hello All, 

With hardcoded nfs-mount retry value(NFSROOT_RETRY_MAX), user and kernel 
have very little choice other than waiting for kernel to finish all the 
retries before attempting to make succession root-mounts.
So my patch makes mount retry an kernel parameter.
This gives user more flexibility to  decide to either nfs-timeout quickly 
and try succession root-mounts or  try more harder and wait forever to get 
the network up.

Comments?

Thanks,
srini

 Documentation/kernel-parameters.txt |    6 ++++++
 init/do_mounts.c                    |   19 +++++++++++++++----
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index e00ec14..999c3ae 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1824,6 +1824,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			This can be set from sysctl after boot.
 			See Documentation/sysctl/vm.txt for details.
 
+	mountretry=	Is the number of times nfs root mount retries attempts
+			are made before giving up. If this option is not
+			specified, the default value of 5 is used. Each retry
+			is attempted with a (1<<current_retry - 1) seconds
+			delay with a max of 31 seconds delay.
+
 	ohci1394_dma=early	[HW] enable debugging via the ohci1394 driver.
 			See Documentation/debugging-via-ohci1394.txt for more
 			info.
diff --git a/init/do_mounts.c b/init/do_mounts.c
index b8214ce..5c43715 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -258,6 +258,19 @@ __setup("rootflags=", root_data_setup);
 __setup("rootfstype=", fs_names_setup);
 __setup("rootdelay=", root_delay_setup);
 
+#ifdef CONFIG_ROOT_NFS
+#define NFSROOT_DEF_RETRY		5
+
+static unsigned int __initdata mount_retry = NFSROOT_DEF_RETRY;
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
@@ -363,7 +376,6 @@ out:
 
 #define NFSROOT_TIMEOUT_MIN	1
 #define NFSROOT_TIMEOUT_MAX	32
-#define NFSROOT_RETRY_MAX	5
 
 static int __init mount_nfs_root(void)
 {
@@ -381,13 +393,12 @@ static int __init mount_nfs_root(void)
 	 * to fall back to other boot methods.
 	 */
 	timeout = NFSROOT_TIMEOUT_MIN;
-	for (try = 1; ; try++) {
+	try = mount_retry;
+	while (try--) {
 		err = do_mount_root(root_dev, "nfs",
 					root_mountflags, root_data);
 		if (err == 0)
 			return 1;
-		if (try > NFSROOT_RETRY_MAX)
-			break;
 
 		/* Wait, in case the server refused us immediately */
 		ssleep(timeout - 1);
-- 
1.6.3.3

