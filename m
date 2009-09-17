From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] sunrpc/rpc_pipe: fix kernel-doc notation
Date: Thu, 17 Sep 2009 15:27:30 -0700
Message-ID: <20090917152730.6db68254.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:33838 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751931AbZIQW1d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2009 18:27:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix kernel-doc notation (& warnings) in sunrpc/rpc_pipe.c.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-2.6.31-git6.orig/net/sunrpc/rpc_pipe.c
+++ linux-2.6.31-git6/net/sunrpc/rpc_pipe.c
@@ -860,7 +860,8 @@ static void rpc_clntdir_depopulate(struc
 
 /**
  * rpc_create_client_dir - Create a new rpc_client directory in rpc_pipefs
- * @path: path from the rpc_pipefs root to the new directory
+ * @dentry: dentry from the rpc_pipefs root to the new directory
+ * @name: &struct qstr for the name
  * @rpc_client: rpc client to associate with this directory
  *
  * This creates a directory at the given @path associated with



---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
