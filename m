Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757559Ab1GAWrQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2011 18:47:16 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p61MlG8h002509
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jul 2011 18:47:16 -0400
Received: from localhost6.localdomain6 (vpn1-7-70.ams2.redhat.com [10.36.7.70])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p61MlEiB002660
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 1 Jul 2011 18:47:15 -0400
Received: from localhost6.localdomain6 (alice [127.0.0.1])
	by localhost6.localdomain6 (8.14.4/8.14.4) with ESMTP id p61MlCUo012424
	for <linux-nfs@vger.kernel.org>; Sat, 2 Jul 2011 00:47:13 +0200
From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] sunrpc: add MODULE_ALIAS to match the filesystem name
To: linux-nfs@vger.kernel.org
Date: Sat, 02 Jul 2011 00:47:12 +0200
Message-ID: <20110701224712.12393.10369.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

sunrpc implements the rpc_pipefs filesystem type.
Add the alias to have the module requested automatically by the kernel
when the filesystem is mounted.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---

 net/sunrpc/rpc_pipe.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 72bc536..c1d1996 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1084,3 +1084,6 @@ void unregister_rpc_pipefs(void)
 	kmem_cache_destroy(rpc_inode_cachep);
 	unregister_filesystem(&rpc_pipe_fs_type);
 }
+
+/* Make 'mount -t rpc_pipefs ...' autoload this module. */
+MODULE_ALIAS("rpc_pipefs");

