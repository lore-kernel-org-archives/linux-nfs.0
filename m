From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 59/85] nfs41: New include/linux/sunrpc/bc_xprt.h
Date: Mon, 10 Nov 2008 22:28:46 +0200
Message-ID: <1226348926-9199-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60004 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbYKJU2w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:28:52 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Contains prototype for backchannel helper routines.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/bc_xprt.h |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/sunrpc/bc_xprt.h

diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
new file mode 100644
index 0000000..8ad9337
--- /dev/null
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -0,0 +1,40 @@
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
+#endif /* CONFIG_NFS_V4_1 */
+#endif /* _LINUX_SUNRPC_BC_XPRT_H */
+
-- 
1.6.0.2

