Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f41.google.com ([74.125.83.41]:39770 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756409AbaCDHiM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 02:38:12 -0500
Received: by mail-ee0-f41.google.com with SMTP id t10so2105593eei.14
        for <linux-nfs@vger.kernel.org>; Mon, 03 Mar 2014 23:38:11 -0800 (PST)
From: Noam Meltzer <noam@primarydata.com>
To: noam@primarydata.com, linux-nfs@vger.kernel.org,
        sssd-devel@lists.fedorahosted.org
Subject: [PATCH v2 2/5] NFSv4 client: (private) headers from libnfsidmap
Date: Tue,  4 Mar 2014 09:37:53 +0200
Message-Id: <1393918676-20865-3-git-send-email-noam@primarydata.com>
In-Reply-To: <1393918676-20865-1-git-send-email-noam@primarydata.com>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The private headers are needed in order to:
nfsidmap_internal.h:
* definition of struct trans_func
* prototype for logger function
cfg.h + queue.h:
* prototype(s) for accessing rpc.idmpad configuration file
---
 src/sss_client/nfs/nfsidmap_internal.h | 78 ++++++++++++++++++++++++++++++++++
 1 file changed, 78 insertions(+)
 create mode 100644 src/sss_client/nfs/nfsidmap_internal.h

diff --git a/src/sss_client/nfs/nfsidmap_internal.h b/src/sss_client/nfs/nfsidmap_internal.h
new file mode 100644
index 0000000..a598c10
--- /dev/null
+++ b/src/sss_client/nfs/nfsidmap_internal.h
@@ -0,0 +1,78 @@
+/*
+ *  nfsidmap_internal.h
+ *
+ *  nfs idmapping library, primarily for nfs4 client/server kernel idmapping
+ *  and for userland nfs4 idmapping by acl libraries.
+ *
+ *  Copyright (c) 2004 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson <andros@umich.edu>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+char *get_default_domain(void);
+struct conf_list *get_local_realms(void);
+
+typedef struct trans_func * (*libnfsidmap_plugin_init_t)(void);
+
+struct trans_func {
+	char *name;
+	int (*init)(void);
+	int (*princ_to_ids)(char *secname, char *princ, uid_t *uid, gid_t *gid, 
+		extra_mapping_params **ex);
+	int (*name_to_uid)(char *name, uid_t *uid);
+	int (*name_to_gid)(char *name, gid_t *gid);
+	int (*uid_to_name)(uid_t uid, char *domain, char *name, size_t len);
+	int (*gid_to_name)(gid_t gid, char *domain, char *name, size_t len);
+	int (*gss_princ_to_grouplist)(char *secname, char *princ, gid_t *groups,
+		int *ngroups, extra_mapping_params **ex);
+};
+
+struct mapping_plugin {
+	void *dl_handle;
+	struct trans_func *trans;
+};
+
+typedef enum {
+	IDTYPE_USER = 1,
+	IDTYPE_GROUP = 2
+} idtypes;
+
+extern int idmap_verbosity;
+extern nfs4_idmap_log_function_t idmap_log_func;
+/* Level zero always prints, others print depending on verbosity level */
+#define IDMAP_LOG(LVL, MSG) \
+	do { if (LVL <= idmap_verbosity) (*idmap_log_func)MSG; } while (0)
+
+
+/*
+ * from libnfsidmap's cfg.h (same license as above)
+ * Copyright (c) 1998, 1999, 2001 Niklas Hallqvist.  All rights reserved.
+ * Copyright (c) 2000, 2003 H�kan Olsson.  All rights reserved.
+ */
+extern char    *conf_get_str(char *, char *);
-- 
1.8.5.3

