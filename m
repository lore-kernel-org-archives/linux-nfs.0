From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 08/39] nfs41: New include/linux/sunrpc/bc_xprt.h
Date: Fri,  1 May 2009 02:20:19 +0300
Message-ID: <1241133619-556-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:3366 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754325AbZD3XUd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:20:33 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Contains prototype for backchannel helper routines.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: xprt_setup_backchannel v4.0 only inline]
    Fix compile error when CONFIG_NFS_V4_1 is not set.
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/bc_xprt.h |   44 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 44 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/sunrpc/bc_xprt.h

diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
new file mode 100644
index 0000000..1c1746a
--- /dev/null
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -0,0 +1,44 @@
+/******************************************************************************
+
+(c) 2008 Network Appliance, Inc.  All Rights Reserved.
+
+Network Appliance provides this source code under the GPL v2 License.
+The GPL v2 license is available at
+http://opensource.org/licenses/gpl-license.php.
+
+THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
+CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
+PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+******************************************************************************/
+
+/*
+ * Functions to create and manage the backchannel
+ */
+
+#ifndef _LINUX_SUNRPC_BC_XPRT_H
+#define _LINUX_SUNRPC_BC_XPRT_H
+
+#include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/xprt.h>
+
+#ifdef CONFIG_NFS_V4_1
+struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt);
+void xprt_free_bc_request(struct rpc_rqst *req);
+int xprt_setup_backchannel(struct rpc_xprt *, unsigned int min_reqs);
+void xprt_destroy_backchannel(struct rpc_xprt *, int max_reqs);
+#else /* CONFIG_NFS_V4_1 */
+static inline int xprt_setup_backchannel(struct rpc_xprt *xprt,
+					 unsigned int min_reqs)
+{ return 0; }
+#endif /* CONFIG_NFS_V4_1 */
+#endif /* _LINUX_SUNRPC_BC_XPRT_H */
+
-- 
1.6.2.1

