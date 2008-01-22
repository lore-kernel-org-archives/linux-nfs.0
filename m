From: Jan Engelhardt <jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>
Subject: [PATCH] [NFS]: constify function pointer tables
Date: Tue, 22 Jan 2008 20:48:31 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801222048130.5722@fbirervta.pbzchgretzou.qr>
References: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:33215 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbYAVTsc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2008 14:48:32 -0500
In-Reply-To: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jan Engelhardt <jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>
---
 fs/nfs/client.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a6f6254..b4832d9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1168,7 +1168,7 @@ static void *nfs_server_list_next(struct seq_file *p, void *v, loff_t *pos);
 static void nfs_server_list_stop(struct seq_file *p, void *v);
 static int nfs_server_list_show(struct seq_file *m, void *v);
 
-static struct seq_operations nfs_server_list_ops = {
+static const struct seq_operations nfs_server_list_ops = {
 	.start	= nfs_server_list_start,
 	.next	= nfs_server_list_next,
 	.stop	= nfs_server_list_stop,
@@ -1188,7 +1188,7 @@ static void *nfs_volume_list_next(struct seq_file *p, void *v, loff_t *pos);
 static void nfs_volume_list_stop(struct seq_file *p, void *v);
 static int nfs_volume_list_show(struct seq_file *m, void *v);
 
-static struct seq_operations nfs_volume_list_ops = {
+static const struct seq_operations nfs_volume_list_ops = {
 	.start	= nfs_volume_list_start,
 	.next	= nfs_volume_list_next,
 	.stop	= nfs_volume_list_stop,
-- 
1.5.3.4

