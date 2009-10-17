From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 1/3] nfsmount.conf: New variables that explicitly set default
 (Release 3)
Date: Sat, 17 Oct 2009 09:38:47 -0400
Message-ID: <4AD9C8E7.3090506@RedHat.com>
References: <4AD9C871.3000400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473AbZJQNi6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 17 Oct 2009 09:38:58 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9HDd3jM011991
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2009 09:39:03 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-234.rdu.redhat.com [10.11.10.234])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9HDd2kf017978
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2009 09:39:02 -0400
In-Reply-To: <4AD9C871.3000400-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit c41c16fca30b30796e66d997c1ad504d128f76b6
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Oct 17 09:16:18 2009 -0400

    Introducing the parsing of both 'defaultvers' and 'defaultproto'
    config variables which will be used to set the the default
    version and network protocol.
    
    A global variable will be set for each option with the
    corresponding value. The value will be used as the
    initial value in the server negation.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/include/conffile.h b/support/include/conffile.h
index 672020a..fe23ec2 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -75,4 +75,11 @@ static inline void upper2lower(char *str)
 	while ((c = tolower(*str)))
 		*str++ = c;
 }
+
+/*
+ * Default Mount options
+ */
+extern unsigned long config_default_vers;
+extern unsigned long config_default_proto;
+
 #endif				/* _CONFFILE_H_ */
diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index d3285f8..28b722c 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -20,13 +20,19 @@
 #include <config.h>
 #endif
 #include <sys/types.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
 
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
 #include <ctype.h>
+#include <errno.h>
 
 #include "xlog.h"
+#include "mount.h"
+#include "parse_opt.h"
+#include "network.h"
 #include "conffile.h"
 
 #define KBYTES(x)     ((x) * (1024))
@@ -197,6 +203,51 @@ int inline check_vers(char *mopt, char *field)
 	}
 	return 0;
 }
+
+unsigned long config_default_vers;
+unsigned long config_default_proto;
+/*
+ * Check to see if a default value is being set.
+ * If so, set the appropriate global value which will 
+ * be used as the initial value in the server negation.
+ */
+int inline default_value(char *mopt)
+{
+	struct mount_options *options = NULL;
+	int dftlen = strlen("default");
+	char *field;
+
+	if (strncasecmp(mopt, "default", dftlen) != 0)
+		return 0;
+
+	field = mopt + dftlen;
+	if (strncasecmp(field, "proto", strlen("proto")) == 0) {
+		if ((options = po_split(field)) != NULL) {
+			if (!nfs_nfs_protocol(options, &config_default_proto)) {
+				xlog_warn("Unable to set default protocol : %s", 
+					strerror(errno));
+			}
+		} else {
+			xlog_warn("Unable to alloc memory for default protocol");
+		}
+	} else if (strncasecmp(field, "vers", strlen("vers")) == 0) {
+		if ((options = po_split(field)) != NULL) {
+			if (!nfs_nfs_version(options, &config_default_vers)) {
+				xlog_warn("Unable to set default version: %s", 
+					strerror(errno));
+				
+			}
+		} else {
+			xlog_warn("Unable to alloc memory for default version");
+		}
+	} else 
+		xlog_warn("Invalid default setting: '%s'", mopt);
+
+	if (options)
+		po_destroy(options);
+
+	return 1;
+}
 /*
  * Parse the given section of the configuration 
  * file to if there are any mount options set.
@@ -320,15 +371,19 @@ char *conf_get_mntopts(char *spec, char *mount_point,
 		free_all();
 		return mount_opts;
 	}
+
 	if (mount_opts) {
 		strcpy(config_opts, mount_opts);
 		strcat(config_opts, ",");
 	}
 	SLIST_FOREACH(entry, &head, entries) {
+		if (default_value(entry->opt))
+			continue;
 		strcat(config_opts, entry->opt);
 		strcat(config_opts, ",");
 	}
-	*(strrchr(config_opts, ',')) = '\0';
+	if ((ptr = strrchr(config_opts, ',')) != NULL)
+		*ptr = '\0';
 
 	free_all();
 	if (mount_opts)
diff --git a/utils/mount/network.c b/utils/mount/network.c
index bd621be..1a05351 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1261,7 +1261,7 @@ nfs_nfs_version(struct mount_options *options, unsigned long *version)
  * Returns TRUE if @protocol contains a valid value for this option,
  * or FALSE if the option was specified with an invalid value.
  */
-static int
+int
 nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol)
 {
 	char *option;
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 402e0a5..7eb89b0 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -57,6 +57,8 @@ int clnt_ping(struct sockaddr_in *, const unsigned long,
 struct mount_options;
 
 int nfs_nfs_version(struct mount_options *options, unsigned long *version);
+int  nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol);
+
 int nfs_options2pmap(struct mount_options *,
 		      struct pmap *, struct pmap *);
 

