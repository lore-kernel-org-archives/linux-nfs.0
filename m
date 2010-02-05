Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:49099 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755738Ab0BETqM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2010 14:46:12 -0500
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH] mount.nfs: set the default family for lookups based on Defaultproto= setting (try #2)
Date: Fri,  5 Feb 2010 14:46:09 -0500
Message-Id: <1265399169-19445-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is the second iteration of this patch. The only difference here
is that this one has default_value call nfs_nfs_proto_family regardless
of whether IPV6_SUPPORTED is set.

When IPv6 is enabled, the Proto= config file option is treated as a
netid, and the address family for lookups is selected based on that
setting. The Defaultproto= option however still only affects the
protocol setting for the sockets (IPPROTO_*) and not the address family.

This patch makes it so that if someone sets the "Defaultproto=" option
in the nfsmount.conf, it's used to determine the default address family
for lookups as well as the protocol type.

This gives users a way to force a particular address family to be used
universally for mounts and brings the behavior of the Defaultproto=
option in line with the Proto= option.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/mount/configfile.c |    6 ++++++
 utils/mount/network.c    |   18 ++++++++----------
 2 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 6843098..8d751d3 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -221,6 +221,8 @@ int inline check_vers(char *mopt, char *field)
 
 unsigned long config_default_vers;
 unsigned long config_default_proto;
+extern sa_family_t config_default_family;
+
 /*
  * Check to see if a default value is being set.
  * If so, set the appropriate global value which will 
@@ -242,6 +244,10 @@ int inline default_value(char *mopt)
 				xlog_warn("Unable to set default protocol : %s", 
 					strerror(errno));
 			}
+			if (!nfs_nfs_proto_family(options, &config_default_family)) {
+				xlog_warn("Unable to set default family : %s", 
+					strerror(errno));
+			}
 		} else {
 			xlog_warn("Unable to alloc memory for default protocol");
 		}
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 92bba2d..0ab3bb1 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1331,6 +1331,12 @@ nfs_nfs_port(struct mount_options *options, unsigned long *port)
 	return 1;
 }
 
+#ifdef IPV6_SUPPORTED
+sa_family_t	config_default_family = AF_UNSPEC;
+#else
+sa_family_t	config_default_family = AF_INET;
+#endif
+
 /*
  * Returns TRUE and fills in @family if a valid NFS protocol option
  * is found, or FALSE if the option was specified with an invalid value.
@@ -1341,11 +1347,7 @@ int nfs_nfs_proto_family(struct mount_options *options,
 	unsigned long protocol;
 	char *option;
 
-#ifdef IPV6_SUPPORTED
-	*family = AF_UNSPEC;
-#else
-	*family = AF_INET;
-#endif
+	*family = config_default_family;
 
 	switch (po_rightmost(options, nfs_transport_opttbl)) {
 	case 0:	/* udp */
@@ -1488,11 +1490,7 @@ int nfs_mount_proto_family(struct mount_options *options,
 	unsigned long protocol;
 	char *option;
 
-#ifdef HAVE_LIBTIRPC
-	*family = AF_UNSPEC;
-#else
-	*family = AF_INET;
-#endif
+	*family = config_default_family;
 
 	option = po_get(options, "mountproto");
 	if (option != NULL)
-- 
1.6.6

