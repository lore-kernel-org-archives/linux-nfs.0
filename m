Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60806 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751661AbdIMK1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 13 Sep 2017 06:27:08 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: NeilBrown <neilb@suse.com>, Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Jorgen Hansen <jhansen@vmware.com>
Subject: [PATCH nfs-utils v3 02/14] nfs-utils: add vsock.h
Date: Wed, 13 Sep 2017 11:26:38 +0100
Message-Id: <20170913102650.10377-3-stefanha@redhat.com>
In-Reply-To: <20170913102650.10377-1-stefanha@redhat.com>
References: <20170913102650.10377-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AF_VSOCK has been in Linux since 2013 but nfs-utils should compile
cleanly on systems that lack this feature or have incomplete header
files (see vsock.h file in this patch for details).

This patch allows code to #include "vsock.h" to use AF_VSOCK and struct
sockaddr_vm without #ifdefs.

Cc: Jorgen Hansen <jhansen@vmware.com>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
--
Jorgen: The header file in linux.git is GPLv2-only licensed.  nfs-utils
is GPLv2-or-later.  The only authors of the Linux header file are
@vmware.com.  Could you please post a GPLv2-or-later version of this
file?  Thanks!
---
 support/include/vsock.h | 59 +++++++++++++++++++++++++++++++++++++++++++++++++
 configure.ac            |  3 +++
 2 files changed, 62 insertions(+)
 create mode 100644 support/include/vsock.h

diff --git a/support/include/vsock.h b/support/include/vsock.h
new file mode 100644
index 0000000..8d1bb79
--- /dev/null
+++ b/support/include/vsock.h
@@ -0,0 +1,59 @@
+/*
+ * AF_VSOCK constants and struct definitions
+ *
+ * Copyright (C) 2007-2013 VMware, Inc. All rights reserved.
+ * Copyright (C) 2017 Red Hat, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation version 2 and no later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+
+#ifndef _VSOCK_H
+#define _VSOCK_H
+
+/*
+ * This header includes the vsock system headers.  Distros have been known to
+ * ship with:
+ * 1. vsock-capable kernels but no AF_VSOCK constant
+ * 2. AF_VSOCK but no <linux/vm_sockets.h>
+ *
+ * Define constants and structs ourselves, if necessary.  This avoids #ifdefs
+ * in many places throughout the code.  If the kernel really does not support
+ * AF_VSOCK then socket(2) returns an EAFNOSUPPORT errno.
+ */
+
+#include <sys/socket.h>
+
+#ifndef AF_VSOCK
+#define AF_VSOCK 40
+#endif
+
+#ifdef HAVE_LINUX_VM_SOCKETS_H
+#include <linux/vm_sockets.h>
+#else /* !HAVE_LINUX_VM_SOCKETS_H */
+
+#define VMADDR_CID_ANY (-1U)
+
+struct sockaddr_vm
+{
+	sa_family_t svm_family;
+	unsigned short svm_reserved1;
+	unsigned int svm_port;
+	unsigned int svm_cid;
+	unsigned char svm_zero[sizeof(struct sockaddr) -
+			       sizeof(sa_family_t) -
+			       sizeof(unsigned short) -
+			       sizeof(unsigned int) - sizeof(unsigned int)];
+};
+
+#define IOCTL_VM_SOCKETS_GET_LOCAL_CID _IO(7, 0xb9)
+
+#endif /* !HAVE_LINUX_VM_SOCKETS_H */
+
+#endif /* !_VSOCK_H */
diff --git a/configure.ac b/configure.ac
index 1ca1603..7d82d37 100644
--- a/configure.ac
+++ b/configure.ac
@@ -410,6 +410,9 @@ fi
 dnl Check for IPv6 support
 AC_IPV6
 
+dnl Check for AF_VSOCK support
+AC_CHECK_HEADERS([linux/vm_sockets.h], , , [#include <sys/socket.h>])
+
 dnl *************************************************************
 dnl Check for headers
 dnl *************************************************************
-- 
2.13.5

