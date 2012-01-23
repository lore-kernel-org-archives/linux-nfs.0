Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f53.google.com ([209.85.216.53]:36010 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803Ab2AWUBp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:01:45 -0500
Received: by mail-qw0-f53.google.com with SMTP id g24so1996217qab.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:01:44 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 4/6] nfsd: add a header describing upcall to nfsdcld
Date: Mon, 23 Jan 2012 15:01:05 -0500
Message-Id: <1327348867-699-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327348867-699-1-git-send-email-jlayton@redhat.com>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The daemon takes a versioned binary struct. Hopefully this should allow
us to revise the struct later if it becomes necessary.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/nfsd/cld.h |   58 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 58 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/nfsd/cld.h

diff --git a/include/linux/nfsd/cld.h b/include/linux/nfsd/cld.h
new file mode 100644
index 0000000..b144a70
--- /dev/null
+++ b/include/linux/nfsd/cld.h
@@ -0,0 +1,58 @@
+/*
+ * fs/nfsd/cld.h - upcall description for nfsdcld communication
+ *
+ * Copyright (c) 2011 Red Hat, Inc.
+ * Author(s): Jeff Layton <jlayton@redhat.com>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef _NFSD_CLD_H
+#define _NFSD_CLD_H
+
+/* latest upcall version available */
+#define CLD_UPCALL_VERSION 1
+
+/* defined by RFC3530 */
+#define NFS4_OPAQUE_LIMIT 1024
+
+enum cld_command {
+	Cld_Init,		/* called when nfsd starts */
+	Cld_Create,		/* create a record for this cm_id */
+	Cld_Allow,		/* is this cm_id allowed? */
+	Cld_GraceDone,		/* grace period is complete */
+};
+
+/* representation of long-form NFSv4 client ID */
+struct cld_name {
+	uint16_t	cn_len;				/* length of cm_id */
+	unsigned char	cn_id[NFS4_OPAQUE_LIMIT];	/* client-provided */
+} __attribute__((packed));
+
+/* message struct for communication with userspace */
+struct cld_msg {
+	uint8_t		cm_vers;		/* upcall version */
+	uint8_t		cm_cmd;			/* upcall command */
+	int16_t		cm_status;		/* return code */
+	uint32_t	cm_xid;			/* transaction id */
+	union {
+		int64_t		cm_gracetime;	/* grace period start time */
+		int64_t		cm_index;	/* clientid index */
+		uint32_t	cm_generation;	/* boot generation index */
+		struct cld_name	cm_name;
+	} __attribute__((packed)) cm_u;
+} __attribute__((packed));
+
+#endif /* !_NFSD_CLD_H */
-- 
1.7.7.5

