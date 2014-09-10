Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:50052 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaIJNEe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 09:04:34 -0400
Received: by mail-qa0-f48.google.com with SMTP id v10so1831752qac.35
        for <linux-nfs@vger.kernel.org>; Wed, 10 Sep 2014 06:04:34 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: add __acquires and __releases annotations to seqfile start/stop routines
Date: Wed, 10 Sep 2014 09:04:27 -0400
Message-Id: <1410354267-24409-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To make sparse happy...

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfs/client.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1c5ff6d58385..39589b4f1966 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1252,6 +1252,7 @@ static int nfs_server_list_open(struct inode *inode, struct file *file)
  * set up the iterator to start reading from the server list and return the first item
  */
 static void *nfs_server_list_start(struct seq_file *m, loff_t *_pos)
+				__acquires(&nn->nfs_client_lock)
 {
 	struct nfs_net *nn = net_generic(seq_file_net(m), nfs_net_id);
 
@@ -1274,6 +1275,7 @@ static void *nfs_server_list_next(struct seq_file *p, void *v, loff_t *pos)
  * clean up after reading from the transports list
  */
 static void nfs_server_list_stop(struct seq_file *p, void *v)
+				__releases(&nn->nfs_client_lock)
 {
 	struct nfs_net *nn = net_generic(seq_file_net(p), nfs_net_id);
 
@@ -1326,6 +1328,7 @@ static int nfs_volume_list_open(struct inode *inode, struct file *file)
  * set up the iterator to start reading from the volume list and return the first item
  */
 static void *nfs_volume_list_start(struct seq_file *m, loff_t *_pos)
+				__acquires(&nn->nfs_client_lock)
 {
 	struct nfs_net *nn = net_generic(seq_file_net(m), nfs_net_id);
 
@@ -1348,6 +1351,7 @@ static void *nfs_volume_list_next(struct seq_file *p, void *v, loff_t *pos)
  * clean up after reading from the transports list
  */
 static void nfs_volume_list_stop(struct seq_file *p, void *v)
+				__releases(&nn->nfs_client_lock)
 {
 	struct nfs_net *nn = net_generic(seq_file_net(p), nfs_net_id);
 
-- 
1.9.3

