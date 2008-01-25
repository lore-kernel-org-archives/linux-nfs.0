From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 035/112] SUNRPC: Remove an unneeded implicit type cast when
	calling rpc_depopulate()
Date: Fri, 25 Jan 2008 11:37:33 -0500
Message-ID: <20080125163733.31887.76904.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14355 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112AbYAYQ7z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:55 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxseO010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:54 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The two arguments of rpc_depopulate() that pass in inode numbers should use
the same type as inode->i_ino: unsigned long.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpc_pipe.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 19b44e5..7e19716 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -523,8 +523,8 @@ rpc_get_inode(struct super_block *sb, int mode)
 /*
  * FIXME: This probably has races.
  */
-static void
-rpc_depopulate(struct dentry *parent, int start, int eof)
+static void rpc_depopulate(struct dentry *parent,
+			   unsigned long start, unsigned long eof)
 {
 	struct inode *dir = parent->d_inode;
 	struct list_head *pos, *next;
