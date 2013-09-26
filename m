Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:65351 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab3IZSka (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:30 -0400
Received: by mail-qc0-f177.google.com with SMTP id x12so1017037qcv.22
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:30 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 09/49] pnfsd: initial stub
Date: Thu, 26 Sep 2013 14:40:27 -0400
Message-Id: <1380220827-13092-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/Makefile    |  1 +
 fs/nfsd/nfs4pnfsd.c | 27 +++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)
 create mode 100644 fs/nfsd/nfs4pnfsd.c

diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index af32ef0..5ebe5df 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -12,3 +12,4 @@ nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o
+nfsd-$(CONFIG_PNFSD)	+= nfs4pnfsd.o
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
new file mode 100644
index 0000000..cb28207
--- /dev/null
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -0,0 +1,27 @@
+/******************************************************************************
+ *
+ * (c) 2007 Network Appliance, Inc.  All Rights Reserved.
+ * (c) 2009 NetApp.  All Rights Reserved.
+ *
+ * NetApp provides this source code under the GPL v2 License.
+ * The GPL v2 license is available at
+ * http://opensource.org/licenses/gpl-license.php.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
+ * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+ * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+ * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
+ * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *****************************************************************************/
+
+#include "pnfsd.h"
+
+#define NFSDDBG_FACILITY                NFSDDBG_PNFS
+
-- 
1.8.3.1

