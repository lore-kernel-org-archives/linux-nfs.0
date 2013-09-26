Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f54.google.com ([209.85.128.54]:51892 "EHLO
	mail-qe0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab3IZSkO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:14 -0400
Received: by mail-qe0-f54.google.com with SMTP id cy11so1086705qeb.41
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:14 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Date: Thu, 26 Sep 2013 14:40:10 -0400
Message-Id: <1380220810-12909-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@umich.edu>

pnfsd data structures used internally and over the export API.

[extracted from pnfsd: Initial pNFS server implementation.]
[pnfsd: remove CONFIG_PNFSD from nfsd4_pnfs.h]
Signed-off-by: Andy Adamson <andros@netapp.com>
[moved {include/linux,fs}/nfsd/pnfsd.h]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/pnfsd.h                 | 37 +++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/nfsd4_pnfs.h | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 74 insertions(+)
 create mode 100644 fs/nfsd/pnfsd.h
 create mode 100644 include/linux/nfsd/nfsd4_pnfs.h

diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
new file mode 100644
index 0000000..65fb57e
--- /dev/null
+++ b/fs/nfsd/pnfsd.h
@@ -0,0 +1,37 @@
+/*
+ *  Copyright (c) 2005 The Regents of the University of Michigan.
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
+ *
+ */
+
+#ifndef LINUX_NFSD_PNFSD_H
+#define LINUX_NFSD_PNFSD_H
+
+#endif /* LINUX_NFSD_PNFSD_H */
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
new file mode 100644
index 0000000..9e7d95e
--- /dev/null
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -0,0 +1,37 @@
+/*
+ *  Copyright (c) 2006 The Regents of the University of Michigan.
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
+ *
+ */
+
+#ifndef _LINUX_NFSD_NFSD4_PNFS_H
+#define _LINUX_NFSD_NFSD4_PNFS_H
+
+#endif /* _LINUX_NFSD_NFSD4_PNFS_H */
-- 
1.8.3.1

