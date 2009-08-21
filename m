From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] nfs/cache_lib: fix sunrpc struct build error
Date: Fri, 21 Aug 2009 09:57:56 -0700
Message-ID: <20090821095756.390c102e.randy.dunlap@oracle.com>
References: <200908210222.n7L2Musb015815@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: akpm <akpm@linux-foundation.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:31699 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932477AbZHUQ4r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 12:56:47 -0400
In-Reply-To: <200908210222.n7L2Musb015815-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Add header file for struct delayed_work:

In file included from fs/nfs/cache_lib.c:14:
include/linux/sunrpc/rpc_pipe_fs.h:35: error: field 'queue_timeout' has incomplete type

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 ++
 1 file changed, 2 insertions(+)

--- mmotm-2009-0820-1918.orig/include/linux/sunrpc/rpc_pipe_fs.h
+++ mmotm-2009-0820-1918/include/linux/sunrpc/rpc_pipe_fs.h
@@ -3,6 +3,8 @@
 
 #ifdef __KERNEL__
 
+#include <linux/workqueue.h>
+
 struct rpc_pipe_msg {
 	struct list_head list;
 	void *data;



---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
