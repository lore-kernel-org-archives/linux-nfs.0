Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:36772 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200AbbKQLxS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:18 -0500
Received: by qkda6 with SMTP id a6so1673471qkd.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:17 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 01/38] nfsd: add new io class tracepoint
Date: Tue, 17 Nov 2015 06:52:23 -0500
Message-Id: <1447761180-4250-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add some new tracepoints in the nfsd read/write codepaths. The idea
is that this will give us the ability to measure how long each phase of
a read or write operation takes.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfsfh.h | 23 +++++++++++++++++++++++
 fs/nfsd/trace.h | 41 +++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/vfs.c   | 15 +++++++++++++++
 3 files changed, 79 insertions(+)

diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 2087bae17582..0770bcb543c8 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -7,6 +7,7 @@
 #ifndef _LINUX_NFSD_NFSFH_H
 #define _LINUX_NFSD_NFSFH_H
 
+#include <linux/crc32.h>
 #include <linux/sunrpc/svc.h>
 #include <uapi/linux/nfsd/nfsfh.h>
 
@@ -205,6 +206,28 @@ static inline bool fh_fsid_match(struct knfsd_fh *fh1, struct knfsd_fh *fh2)
 	return true;
 }
 
+#ifdef CONFIG_CRC32
+/**
+ * knfsd_fh_hash - calculate the crc32 hash for the filehandle
+ * @fh - pointer to filehandle
+ *
+ * returns a crc32 hash for the filehandle that is compatible with
+ * the one displayed by "wireshark".
+ */
+
+static inline u32
+knfsd_fh_hash(struct knfsd_fh *fh)
+{
+	return ~crc32_le(0xFFFFFFFF, (unsigned char *)&fh->fh_base, fh->fh_size);
+}
+#else
+static inline u32
+knfsd_fh_hash(struct knfsd_fh *fh)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_NFSD_V3
 /*
  * The wcc data stored in current_fh should be cleared
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 0befe762762b..3287041905da 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -8,6 +8,47 @@
 #define _NFSD_TRACE_H
 
 #include <linux/tracepoint.h>
+#include "nfsfh.h"
+
+DECLARE_EVENT_CLASS(nfsd_io_class,
+	TP_PROTO(struct svc_rqst *rqstp,
+		 struct svc_fh	*fhp,
+		 loff_t		offset,
+		 int		len),
+	TP_ARGS(rqstp, fhp, offset, len),
+	TP_STRUCT__entry(
+		__field(__be32, xid)
+		__field_struct(struct knfsd_fh, fh)
+		__field(loff_t, offset)
+		__field(int, len)
+	),
+	TP_fast_assign(
+		__entry->xid = rqstp->rq_xid,
+		fh_copy_shallow(&__entry->fh, &fhp->fh_handle);
+		__entry->offset = offset;
+		__entry->len = len;
+	),
+	TP_printk("xid=0x%x fh=0x%x offset=%lld len=%d",
+		  __be32_to_cpu(__entry->xid), knfsd_fh_hash(&__entry->fh),
+		  __entry->offset, __entry->len)
+)
+
+#define DEFINE_NFSD_IO_EVENT(name)		\
+DEFINE_EVENT(nfsd_io_class, name,		\
+	TP_PROTO(struct svc_rqst *rqstp,	\
+		 struct svc_fh	*fhp,		\
+		 loff_t		offset,		\
+		 int		len),		\
+	TP_ARGS(rqstp, fhp, offset, len))
+
+DEFINE_NFSD_IO_EVENT(read_start);
+DEFINE_NFSD_IO_EVENT(read_opened);
+DEFINE_NFSD_IO_EVENT(read_io_done);
+DEFINE_NFSD_IO_EVENT(read_done);
+DEFINE_NFSD_IO_EVENT(write_start);
+DEFINE_NFSD_IO_EVENT(write_opened);
+DEFINE_NFSD_IO_EVENT(write_io_done);
+DEFINE_NFSD_IO_EVENT(write_done);
 
 #include "state.h"
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 994d66fbb446..3257c59dc860 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -42,6 +42,7 @@
 
 #include "nfsd.h"
 #include "vfs.h"
+#include "trace.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_FILEOP
 
@@ -983,16 +984,23 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct raparms	*ra;
 	__be32 err;
 
+	trace_read_start(rqstp, fhp, offset, vlen);
 	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
 	if (err)
 		return err;
 
 	ra = nfsd_init_raparms(file);
+
+	trace_read_opened(rqstp, fhp, offset, vlen);
 	err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
+	trace_read_io_done(rqstp, fhp, offset, vlen);
+
 	if (ra)
 		nfsd_put_raparams(file, ra);
 	fput(file);
 
+	trace_read_done(rqstp, fhp, offset, vlen);
+
 	return err;
 }
 
@@ -1008,24 +1016,31 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 {
 	__be32			err = 0;
 
+	trace_write_start(rqstp, fhp, offset, vlen);
+
 	if (file) {
 		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
 				NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE);
 		if (err)
 			goto out;
+		trace_write_opened(rqstp, fhp, offset, vlen);
 		err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
 				stablep);
+		trace_write_io_done(rqstp, fhp, offset, vlen);
 	} else {
 		err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
 		if (err)
 			goto out;
 
+		trace_write_opened(rqstp, fhp, offset, vlen);
 		if (cnt)
 			err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen,
 					     cnt, stablep);
+		trace_write_io_done(rqstp, fhp, offset, vlen);
 		fput(file);
 	}
 out:
+	trace_write_done(rqstp, fhp, offset, vlen);
 	return err;
 }
 
-- 
2.4.3

