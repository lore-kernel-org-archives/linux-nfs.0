Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:47415 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555Ab0IWO1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Sep 2010 10:27:08 -0400
Message-ID: <4C9B63B2.4030907@parallels.com>
Date: Thu, 23 Sep 2010 18:26:58 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfsd-next] nfsd: Export get_task_comm for nfsd
References: <4C9B176E.4090808@parallels.com> <20100923140550.GA10137@infradead.org>
In-Reply-To: <20100923140550.GA10137@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> Why doesn't it simply use current->comm as countless other users?

Yep, this is indeed better...

The git://linux-nfs.org/~bfields/linux.git nfsd-next branch doesn't
compile when nfsd is a module with the following error:

   ERROR: "get_task_comm" [fs/nfsd/nfsd.ko] undefined!

Replace the get_task_comm call with direct comm access, which is
safe for current.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 83c82ed..b6e192d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -129,12 +129,10 @@ static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size
 {
 	static int warned;
 	if (file->f_dentry->d_name.name[0] == '.' && !warned) {
-		char name[sizeof(current->comm)];
 		printk(KERN_INFO
 		       "Warning: \"%s\" uses deprecated NFSD interface: %s."
 		       "  This will be removed in 2.6.40\n",
-		       get_task_comm(name, current),
-		       file->f_dentry->d_name.name);
+		       current->comm, file->f_dentry->d_name.name);
 		warned = 1;
 	}
 	if (! file->private_data) {
