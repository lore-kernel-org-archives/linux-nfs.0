Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2816 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242Ab0IWJBj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Sep 2010 05:01:39 -0400
Message-ID: <4C9B176E.4090808@parallels.com>
Date: Thu, 23 Sep 2010 13:01:34 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH nfsd-next] nfsd: Export get_task_comm for nfsd
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The git://linux-nfs.org/~bfields/linux.git nfsd-next branch doesn't
compile when nfsd is a module with the following error:

   ERROR: "get_task_comm" [fs/nfsd/nfsd.ko] undefined!

The get_task_comm is used in nfsctl_transaction_read's printk.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/exec.c b/fs/exec.c
index 828dd24..1d22c4b 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -957,6 +957,7 @@ char *get_task_comm(char *buf, struct task_struct *tsk)
 	task_unlock(tsk);
 	return buf;
 }
+EXPORT_SYMBOL_GPL(get_task_comm);
 
 void set_task_comm(struct task_struct *tsk, char *buf)
 {
