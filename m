From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfsmount.conf: New variables that explicitly set default
Date: Fri, 09 Oct 2009 14:16:45 -0400
Message-ID: <4ACF7E0D.6060202@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56066 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752648AbZJISRV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 14:17:21 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n99IGt3t013386
	for <linux-nfs@vger.kernel.org>; Fri, 9 Oct 2009 14:16:55 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-151.rdu.redhat.com [10.11.10.151])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n99IGsSM012719
	for <linux-nfs@vger.kernel.org>; Fri, 9 Oct 2009 14:16:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch introduces two new mount configuration variables used
to set the default protocol version and network transport.

Currently when the nfsvers or proto is set in the nfsmount.conf
file the mount will fail if the server does not support 
the given version or  transport. No negation with the server occurs.

With default values, they define where the server negation should start.
So the 'default_nfsvers=' and default_proto=' will now define where the
server negation will start. Meaning just because they are set to a 
certain value does not meant that will be the final value used in
mount. 

comments?

steved.

commit a0e50cbe0e24abe0226ef240bd547e5e9e67de3f
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Oct 9 13:54:52 2009 -0400

    Introduces a new type of configuration file variable
    that will explicitly set the default protocol version
    and network transport. These variables will set where
    the negotiation with the server will start.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/include/conffile.h b/support/include/conffile.h
index 672020a..da8e836 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -75,4 +75,12 @@ static inline void upper2lower(char *str)
 	while ((c = tolower(*str)))
 		*str++ = c;
 }
+
+/*
+ * Default Mount options
+ */
+#define DEFAULT_PROTO 0x1
+#define DEFAULT_VERS  0x2
+extern int config_default_opts;
+
 #endif				/* _CONFFILE_H_ */
diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index d3285f8..c336670 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -185,7 +185,7 @@ void free_all(void)
 		free(entry);
 	}
 }
-static char *versions[] = {"v2", "v3", "v4", "vers", "nfsvers", NULL};
+char *versions[] = {"v2", "v3", "v4", "vers", "nfsvers", NULL};
 int inline check_vers(char *mopt, char *field)
 {
 	int i;
@@ -197,6 +197,34 @@ int inline check_vers(char *mopt, char *field)
 	}
 	return 0;
 }
+
+/*
+ * See if there are any default values being set.
+ * If so mark the bit and turn the option into a 
+ * valid option.
+ */
+int config_default_opts;
+void inline set_default_bits(char *mopt)
+{
+	int i;
+	char *field;
+
+	if (strncasecmp(mopt, "default_", strlen("default_")) != 0)
+		return;
+
+	field = strchr(mopt, '_');
+	field++; /* skip pass '_' */
+	if (strncasecmp(field, "proto", strlen("proto")) == 0) {
+		config_default_opts |= DEFAULT_PROTO;
+		strcpy(mopt, field);
+	} else for (i=0; versions[i]; i++) {
+		if (strncasecmp(field, versions[i], strlen(versions[i])) == 0) {
+			config_default_opts |= DEFAULT_VERS;
+			strcpy(mopt, field);
+			break;
+		}
+	}
+}
 /*
  * Parse the given section of the configuration 
  * file to if there are any mount options set.
@@ -325,6 +353,7 @@ char *conf_get_mntopts(char *spec, char *mount_point,
 		strcat(config_opts, ",");
 	}
 	SLIST_FOREACH(entry, &head, entries) {
+		set_default_bits(entry->opt);
 		strcat(config_opts, entry->opt);
 		strcat(config_opts, ",");
 	}
diff --git a/utils/mount/nfsmount.conf b/utils/mount/nfsmount.conf
index 991838f..af76d49 100644
--- a/utils/mount/nfsmount.conf
+++ b/utils/mount/nfsmount.conf
@@ -28,10 +28,24 @@
 # This statically named section defines global mount 
 # options that can be applied on all NFS mount.
 #
-# Protocol Version [2,3]
-# Nfsvers=3
+# Protocol Version [2,3,4]
+# This defines the default protocol version which will
+# be used to start the negotiation with the server.
+# Default_nfsvers=4
+#
+# Setting this option makes it mandatory the server supports the
+# given version. The mount will fail if the given version is 
+# not support by the server. 
+# Nfsvers=4
 #
 # Network Transport [udp,tcp,rdma] (Note: values are case sensitive)
+# This defines the default network transport which will
+# be used to start the negotiation with the server.
+# Default_Proto=tcp
+#
+# Setting this option makes it mandatory the server supports the
+# given transport. The mount will fail if the given transport
+# is not supported by the server.
 # Proto=tcp
 #
 # The number of times a request will be retired before 
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 069bdc1..b203414 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -92,6 +92,13 @@ struct nfsmount_info {
 				child;		/* forked bg child? */
 };
 
+#ifdef MOUNT_CONFIG
+#include "conffile.h"
+int inline config_defaults(struct nfsmount_info *mi);
+#else
+int inline config_defaults(struct nfsmount_info *mi) {return 0;}
+#endif
+
 /*
  * Obtain a retry timeout value based on the value of the "retry=" option.
  *
@@ -610,10 +617,22 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 	case 2:
 	case 3:
 		result = nfs_try_mount_v3v2(mi);
+		if (result)
+			break;
+
+		if (config_defaults(mi))
+			result = nfs_try_mount_v3v2(mi);
 		break;
+
 	case 4:
 		result = nfs_try_mount_v4(mi);
+		if (result)
+			break;
+
+		if (config_defaults(mi))
+			result = nfs_try_mount_v3v2(mi);
 		break;
+
 	default:
 		errno = EIO;
 	}
@@ -819,3 +838,38 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	free(mi.hostname);
 	return retval;
 }
+
+#ifdef MOUNT_CONFIG
+/*
+ * If the mount fails due to a ENOSUPPORT type of error
+ * and a default options were set in the configuration file
+ * try the mount again without that default options set.
+ */
+int config_defaults(struct nfsmount_info *mi)
+{
+	int i;
+	extern char *versions[];
+
+	if (!config_default_opts)
+		return 0;
+
+	switch(mi->version) {
+	case 4:
+		if (errno != EPROTONOSUPPORT)
+			return 0;
+		break;
+	case 3:
+		if (errno != ESPIPE)
+			return 0;
+		break;
+	}
+	if (config_default_opts && DEFAULT_VERS) {
+		for (i=0; versions[i]; i++) 
+			po_remove_all(mi->options, versions[i]);
+	}
+	if (config_default_opts && DEFAULT_PROTO)
+		po_remove_all(mi->options, "proto");
+
+	return 1;
+}
+#endif

 

