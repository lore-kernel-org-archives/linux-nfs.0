Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:35728 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819Ab3HTTfX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Aug 2013 15:35:23 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 12/16] NFSv4: Add tracepoints for debugging the idmapper
Date: Tue, 20 Aug 2013 15:35:08 -0400
Message-ID: <1377027312-45957-13-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377027312-45957-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1377027312-45957-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-10-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-11-git-send-email-Trond.Myklebust@netapp.com>
 <1377027312-45957-12-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add tracepoints to help debug uid/gid mappings to username/group.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c     |  5 +++++
 fs/nfs/nfs4trace.h | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index c2c4163..f16a872 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -49,6 +49,7 @@
 
 #include "internal.h"
 #include "netns.h"
+#include "nfs4trace.h"
 
 #define NFS_UINT_MAXLEN 11
 
@@ -849,6 +850,7 @@ int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_
 		if (!uid_valid(*uid))
 			ret = -ERANGE;
 	}
+	trace_nfs4_map_name_to_uid(name, namelen, id, ret);
 	return ret;
 }
 
@@ -865,6 +867,7 @@ int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size
 		if (!gid_valid(*gid))
 			ret = -ERANGE;
 	}
+	trace_nfs4_map_group_to_gid(name, namelen, id, ret);
 	return ret;
 }
 
@@ -879,6 +882,7 @@ int nfs_map_uid_to_name(const struct nfs_server *server, kuid_t uid, char *buf,
 		ret = nfs_idmap_lookup_name(id, "user", buf, buflen, idmap);
 	if (ret < 0)
 		ret = nfs_map_numeric_to_string(id, buf, buflen);
+	trace_nfs4_map_uid_to_name(buf, ret, id, ret);
 	return ret;
 }
 int nfs_map_gid_to_group(const struct nfs_server *server, kgid_t gid, char *buf, size_t buflen)
@@ -892,5 +896,6 @@ int nfs_map_gid_to_group(const struct nfs_server *server, kgid_t gid, char *buf,
 		ret = nfs_idmap_lookup_name(id, "group", buf, buflen, idmap);
 	if (ret < 0)
 		ret = nfs_map_numeric_to_string(id, buf, buflen);
+	trace_nfs4_map_gid_to_group(buf, ret, id, ret);
 	return ret;
 }
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 82428fb..f00fa87 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -637,6 +637,52 @@ DEFINE_NFS4_INODE_EVENT(nfs4_set_security_label);
 DEFINE_NFS4_INODE_EVENT(nfs4_recall_delegation);
 DEFINE_NFS4_INODE_EVENT(nfs4_delegreturn);
 
+DECLARE_EVENT_CLASS(nfs4_idmap_event,
+		TP_PROTO(
+			const char *name,
+			int len,
+			u32 id,
+			int error
+		),
+
+		TP_ARGS(name, len, id, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(u32, id)
+			__dynamic_array(char, name, len > 0 ? len + 1 : 1)
+		),
+
+		TP_fast_assign(
+			if (len < 0)
+				len = 0;
+			__entry->error = error < 0 ? error : 0;
+			__entry->id = id;
+			memcpy(__get_dynamic_array(name), name, len);
+			((char *)__get_dynamic_array(name))[len] = 0;
+		),
+
+		TP_printk(
+			"error=%d id=%u name=%s",
+			__entry->error,
+			__entry->id,
+			__get_str(name)
+		)
+);
+#define DEFINE_NFS4_IDMAP_EVENT(name) \
+	DEFINE_EVENT(nfs4_idmap_event, name, \
+			TP_PROTO( \
+				const char *name, \
+				int len, \
+				u32 id, \
+				int error \
+			), \
+			TP_ARGS(name, len, id, error))
+DEFINE_NFS4_IDMAP_EVENT(nfs4_map_name_to_uid);
+DEFINE_NFS4_IDMAP_EVENT(nfs4_map_group_to_gid);
+DEFINE_NFS4_IDMAP_EVENT(nfs4_map_uid_to_name);
+DEFINE_NFS4_IDMAP_EVENT(nfs4_map_gid_to_group);
+
 #endif /* _TRACE_NFS4_H */
 
 #undef TRACE_INCLUDE_PATH
-- 
1.8.3.1

