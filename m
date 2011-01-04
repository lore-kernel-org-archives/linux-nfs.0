Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50134 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751078Ab1ADXXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 18:23:35 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] nfsd4: move idmap and acl header files into fs/nfsd
Date: Tue,  4 Jan 2011 18:23:28 -0500
Message-Id: <1294183410-14688-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1294178391.5896.31.camel@heimdal.trondhjem.org>
References: <1294178391.5896.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These are internal nfsd interfaces.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/acl.h              |   61 +++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/idmap.h            |   64 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4acl.c          |    2 +-
 fs/nfsd/nfs4idmap.c        |    2 +-
 fs/nfsd/nfs4xdr.c          |    5 ++-
 fs/nfsd/nfsctl.c           |    2 +-
 fs/nfsd/vfs.c              |    4 +-
 include/linux/nfs4_acl.h   |   61 -----------------------------------------
 include/linux/nfsd_idmap.h |   64 --------------------------------------------
 9 files changed, 133 insertions(+), 132 deletions(-)
 create mode 100644 fs/nfsd/acl.h
 create mode 100644 fs/nfsd/idmap.h
 delete mode 100644 include/linux/nfs4_acl.h
 delete mode 100644 include/linux/nfsd_idmap.h

diff --git a/fs/nfsd/acl.h b/fs/nfsd/acl.h
new file mode 100644
index 0000000..c9c05a7
--- /dev/null
+++ b/fs/nfsd/acl.h
@@ -0,0 +1,61 @@
+/*
+ *  include/linux/nfs4_acl.c
+ *
+ *  Common NFSv4 ACL handling definitions.
+ *
+ *  Copyright (c) 2002 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Marius Aamodt Eriksen <marius@umich.edu>
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
+#ifndef LINUX_NFS4_ACL_H
+#define LINUX_NFS4_ACL_H
+
+#include <linux/posix_acl.h>
+
+/* Maximum ACL we'll accept from client; chosen (somewhat arbitrarily) to
+ * fit in a page: */
+#define NFS4_ACL_MAX 170
+
+struct nfs4_acl *nfs4_acl_new(int);
+int nfs4_acl_get_whotype(char *, u32);
+int nfs4_acl_write_who(int who, char *p);
+int nfs4_acl_permission(struct nfs4_acl *acl, uid_t owner, gid_t group,
+		                        uid_t who, u32 mask);
+
+#define NFS4_ACL_TYPE_DEFAULT	0x01
+#define NFS4_ACL_DIR		0x02
+#define NFS4_ACL_OWNER		0x04
+
+struct nfs4_acl *nfs4_acl_posix_to_nfsv4(struct posix_acl *,
+				struct posix_acl *, unsigned int flags);
+int nfs4_acl_nfsv4_to_posix(struct nfs4_acl *, struct posix_acl **,
+				struct posix_acl **, unsigned int flags);
+
+#endif /* LINUX_NFS4_ACL_H */
diff --git a/fs/nfsd/idmap.h b/fs/nfsd/idmap.h
new file mode 100644
index 0000000..d4a2ac1
--- /dev/null
+++ b/fs/nfsd/idmap.h
@@ -0,0 +1,64 @@
+/*
+ *  include/linux/nfsd_idmap.h
+ *
+ *  Mapping of UID to name and vice versa.
+ *
+ *  Copyright (c) 2002, 2003 The Regents of the University of
+ *  Michigan.  All rights reserved.
+> *
+ *  Marius Aamodt Eriksen <marius@umich.edu>
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
+#ifndef LINUX_NFSD_IDMAP_H
+#define LINUX_NFSD_IDMAP_H
+
+#include <linux/in.h>
+#include <linux/sunrpc/svc.h>
+
+/* XXX from linux/nfs_idmap.h */
+#define IDMAP_NAMESZ 128
+
+#ifdef CONFIG_NFSD_V4
+int nfsd_idmap_init(void);
+void nfsd_idmap_shutdown(void);
+#else
+static inline int nfsd_idmap_init(void)
+{
+	return 0;
+}
+static inline void nfsd_idmap_shutdown(void)
+{
+}
+#endif
+
+int nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, __u32 *);
+int nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, __u32 *);
+int nfsd_map_uid_to_name(struct svc_rqst *, __u32, char *);
+int nfsd_map_gid_to_name(struct svc_rqst *, __u32, char *);
+
+#endif /* LINUX_NFSD_IDMAP_H */
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index e480526..ad88f1c 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -36,7 +36,7 @@
 
 #include <linux/slab.h>
 #include <linux/nfs_fs.h>
-#include <linux/nfs4_acl.h>
+#include "acl.h"
 
 
 /* mode bit translations: */
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 844960f..cbd5997 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -33,10 +33,10 @@
  */
 
 #include <linux/module.h>
-#include <linux/nfsd_idmap.h>
 #include <linux/seq_file.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include "idmap.h"
 
 /*
  * Cache entry
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 364aae7..2a0814d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -44,13 +44,14 @@
 #include <linux/namei.h>
 #include <linux/statfs.h>
 #include <linux/utsname.h>
-#include <linux/nfsd_idmap.h>
-#include <linux/nfs4_acl.h>
 #include <linux/sunrpc/svcauth_gss.h>
 
+#include "idmap.h"
+#include "acl.h"
 #include "xdr4.h"
 #include "vfs.h"
 
+
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
 /*
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6840ec3..33b3e2b 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -8,12 +8,12 @@
 #include <linux/namei.h>
 #include <linux/ctype.h>
 
-#include <linux/nfsd_idmap.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/lockd/lockd.h>
 #include <linux/sunrpc/clnt.h>
 
+#include "idmap.h"
 #include "nfsd.h"
 #include "cache.h"
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6a3af2f..b991125 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -35,8 +35,8 @@
 #endif /* CONFIG_NFSD_V3 */
 
 #ifdef CONFIG_NFSD_V4
-#include <linux/nfs4_acl.h>
-#include <linux/nfsd_idmap.h>
+#include "acl.h"
+#include "idmap.h"
 #endif /* CONFIG_NFSD_V4 */
 
 #include "nfsd.h"
diff --git a/include/linux/nfs4_acl.h b/include/linux/nfs4_acl.h
deleted file mode 100644
index c9c05a7..0000000
--- a/include/linux/nfs4_acl.h
+++ /dev/null
@@ -1,61 +0,0 @@
-/*
- *  include/linux/nfs4_acl.c
- *
- *  Common NFSv4 ACL handling definitions.
- *
- *  Copyright (c) 2002 The Regents of the University of Michigan.
- *  All rights reserved.
- *
- *  Marius Aamodt Eriksen <marius@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef LINUX_NFS4_ACL_H
-#define LINUX_NFS4_ACL_H
-
-#include <linux/posix_acl.h>
-
-/* Maximum ACL we'll accept from client; chosen (somewhat arbitrarily) to
- * fit in a page: */
-#define NFS4_ACL_MAX 170
-
-struct nfs4_acl *nfs4_acl_new(int);
-int nfs4_acl_get_whotype(char *, u32);
-int nfs4_acl_write_who(int who, char *p);
-int nfs4_acl_permission(struct nfs4_acl *acl, uid_t owner, gid_t group,
-		                        uid_t who, u32 mask);
-
-#define NFS4_ACL_TYPE_DEFAULT	0x01
-#define NFS4_ACL_DIR		0x02
-#define NFS4_ACL_OWNER		0x04
-
-struct nfs4_acl *nfs4_acl_posix_to_nfsv4(struct posix_acl *,
-				struct posix_acl *, unsigned int flags);
-int nfs4_acl_nfsv4_to_posix(struct nfs4_acl *, struct posix_acl **,
-				struct posix_acl **, unsigned int flags);
-
-#endif /* LINUX_NFS4_ACL_H */
diff --git a/include/linux/nfsd_idmap.h b/include/linux/nfsd_idmap.h
deleted file mode 100644
index d4a2ac1..0000000
--- a/include/linux/nfsd_idmap.h
+++ /dev/null
@@ -1,64 +0,0 @@
-/*
- *  include/linux/nfsd_idmap.h
- *
- *  Mapping of UID to name and vice versa.
- *
- *  Copyright (c) 2002, 2003 The Regents of the University of
- *  Michigan.  All rights reserved.
-> *
- *  Marius Aamodt Eriksen <marius@umich.edu>
- *
- *  Redistribution and use in source and binary forms, with or without
- *  modification, are permitted provided that the following conditions
- *  are met:
- *
- *  1. Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *  2. Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in the
- *     documentation and/or other materials provided with the distribution.
- *  3. Neither the name of the University nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
- *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
- *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
- *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
- *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
- *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
- *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
- *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
- *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
- *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-#ifndef LINUX_NFSD_IDMAP_H
-#define LINUX_NFSD_IDMAP_H
-
-#include <linux/in.h>
-#include <linux/sunrpc/svc.h>
-
-/* XXX from linux/nfs_idmap.h */
-#define IDMAP_NAMESZ 128
-
-#ifdef CONFIG_NFSD_V4
-int nfsd_idmap_init(void);
-void nfsd_idmap_shutdown(void);
-#else
-static inline int nfsd_idmap_init(void)
-{
-	return 0;
-}
-static inline void nfsd_idmap_shutdown(void)
-{
-}
-#endif
-
-int nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, __u32 *);
-int nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, __u32 *);
-int nfsd_map_uid_to_name(struct svc_rqst *, __u32, char *);
-int nfsd_map_gid_to_name(struct svc_rqst *, __u32, char *);
-
-#endif /* LINUX_NFSD_IDMAP_H */
-- 
1.7.1

