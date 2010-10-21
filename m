Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36052 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164Ab0JUQsD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:48:03 -0400
Date: Thu, 21 Oct 2010 12:48:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 2.6.37 nfsd changes
Message-ID: <20101021164759.GB9537@fieldses.org>
References: <20101021162306.GA9537@fieldses.org>
 <20101021163234.GA23584@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101021163234.GA23584@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 21, 2010 at 12:32:34PM -0400, Christoph Hellwig wrote:
> > Pavel Emelyanov (37):
> >       nfsd: Export get_task_comm for nfsd
> 
> NAK.  As mentioned in the reply to the patch series nfsd should
> just use current->comm.

Ugh, sorry: I did fix up the code, but I forgot the subject line; it was
committed as follows.

--b.

commit 049ef27b224ecc33958465fef83d5e4e8a056115
Author: Pavel Emelyanov <xemul@parallels.com>
Date:   Thu Sep 23 18:26:58 2010 +0400

    nfsd: Export get_task_comm for nfsd
    
    The git://linux-nfs.org/~bfields/linux.git nfsd-next branch doesn't
    compile when nfsd is a module with the following error:
    
       ERROR: "get_task_comm" [fs/nfsd/nfsd.ko] undefined!
    
    Replace the get_task_comm call with direct comm access, which is
    safe for current.
    
    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b278e44..7b2fa1d 100644
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
