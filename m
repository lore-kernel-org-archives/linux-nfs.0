From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 1/3] nfsmount.conf: New variables that explicitly set default
 (Release 2)
Date: Mon, 12 Oct 2009 17:37:31 -0400
Message-ID: <4AD3A19B.70602@RedHat.com>
References: <4AD3A0BA.3080104@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933192AbZJLViL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2009 17:38:11 -0400
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n9CLbjV5017937
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2009 17:37:45 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-119.rdu.redhat.com [10.11.10.119])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id n9CLbiUI009599
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2009 17:37:44 -0400
In-Reply-To: <4AD3A0BA.3080104-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 7c9406cbfb7cf4d694890c6ddf7f4597b026cb7a
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Oct 12 16:48:21 2009 -0400

    Introducing the parsing of both 'defaultvers' and 'defaultproto'
    config variables which will be used to set the the default
    version and network protocol.
    
    A global variable is used to mark the fact these options
    are have be set.
    
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
index d3285f8..ff1bb5f 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -197,6 +197,30 @@ int inline check_vers(char *mopt, char *field)
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
+	int dftlen = strlen("default");
+	char *field;
+
+	if (strncasecmp(mopt, "default", dftlen) != 0)
+		return;
+
+	field = mopt + dftlen;
+	if (strncasecmp(field, "proto", strlen("proto")) == 0) {
+		config_default_opts |= DEFAULT_PROTO;
+		strcpy(mopt, field);
+	} else if (strncasecmp(field, "vers", strlen("vers")) == 0) {
+			config_default_opts |= DEFAULT_VERS;
+			strcpy(mopt, field);
+	}
+}
 /*
  * Parse the given section of the configuration 
  * file to if there are any mount options set.
@@ -325,6 +349,7 @@ char *conf_get_mntopts(char *spec, char *mount_point,
 		strcat(config_opts, ",");
 	}
 	SLIST_FOREACH(entry, &head, entries) {
+		set_default_bits(entry->opt);
 		strcat(config_opts, entry->opt);
 		strcat(config_opts, ",");
 	}

