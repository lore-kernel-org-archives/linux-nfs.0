Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657Ab1LOSn2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 13:43:28 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIhSC2007972
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:43:28 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id pBFIhQq8021450
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:43:27 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/5] nfsd: add a header describing upcall to nfsdcld
Date: Thu, 15 Dec 2011 13:43:25 -0500
Message-Id: <1323974606-16477-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323974606-16477-1-git-send-email-jlayton@redhat.com>
References: <1323974606-16477-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The daemon takes a versioned binary struct. Hopefully this should allow
us to revise the struct later if it becomes necessary.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/nfsd/cld.h |   57 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 57 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/nfsd/cld.h

diff --git a/include/linux/nfsd/cld.h b/include/linux/nfsd/cld.h
new file mode 100644
index 0000000..d64a7e7
--- /dev/null
+++ b/include/linux/nfsd/cld.h
@@ -0,0 +1,57 @@
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
+#define CLD_MAX_UPCALL_VERSION 1
+
+/* defined by RFC3530 */
+#define NFS4_OPAQUE_LIMIT 1024
+
+enum cld_command {
+	Cld_Create,		/* create a record for this cm_id */
+	Cld_Expire,		/* remove record for this cm_id */
+	Cld_Allow,		/* is this cm_id allowed? */
+	Cld_GraceDone,		/* grace period is complete */
+	Cld_NrToReclaim,	/* how many client records need reclaim? */
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
+	uint32_t	cm_xid;			/* transaction id */
+	int16_t		cm_status;		/* return code */
+	union {
+		int64_t		cm_gracetime;	/* grace period start time */
+		struct cld_name	cm_name;
+	} __attribute__((packed)) cm_u;
+} __attribute__((packed));
+
+#endif /* !_NFSD_CLD_H */
-- 
1.7.1

