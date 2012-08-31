Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:2691 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab2HaEd4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Aug 2012 00:33:56 -0400
Date: Thu, 30 Aug 2012 21:33:52 -0700
From: Nick Pasich <Nick@NickAndBarb.net>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: WARNING: at fs/inode.c:280 drop_nlink+0x31/0x33()
Message-ID: <20120831043352.GA23663@NickAndBarb.net>
References: <20120829162527.GA3635@NickAndBarb.net>
 <20120829151641.20cde4bc@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120829151641.20cde4bc@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 29, 2012 at 03:16:41PM -0700, Jeff Layton wrote:
> On Wed, 29 Aug 2012 09:25:27 -0700
> Nick Pasich <Nick@NickAndBarb.net> wrote:
> 
> > 
> > I'm using kernel 3.5.3 ... 
> > 
> > It happens on 3.5.1 and 3.5.2 also.
> > 
> > I know that Nick Bowler has already reported this...
> > 
> > I'm experiencing the same thing.
> > 
> > It happens when moving files from one directory to another
> > on the same partition (NFS). 
> > 
> >   --( Nick Pasich )--
> > 
> > 
> > #############################################################################
> > ##
> > ## Happens when PSTs are moved from one directory to another on the ISCSI ...
> > ##
> > #############################################################################
> > 
> > Aug 29 08:06:16 localhost kernel: ------------[ cut here ]------------
> > Aug 29 08:06:16 localhost kernel: WARNING: at fs/inode.c:280 drop_nlink+0x31/0x33()
> > Aug 29 08:06:16 localhost kernel: Hardware name: To Be Filled By O.E.M.
> > Aug 29 08:06:16 localhost kernel: Modules linked in: ecb md4 cifs w83627hf eeprom asb100 hwmon_vid hwmon nfsd exportfs ipv6 psmouse usb_storage io_edgeport usbserial sg r8169 mii evdev intel_agp uhci_hcd i2c_i801 i2c_core shpchp intel_gtt agpgart ehci_hcd microcode serio_raw
> > Aug 29 08:06:16 localhost kernel: Pid: 31477, comm: rm Tainted: G        W    3.5.3 #1
> > Aug 29 08:06:16 localhost kernel: Call Trace:
> > Aug 29 08:06:16 localhost kernel:  [<c10a53e2>] ? drop_nlink+0x31/0x33
> > Aug 29 08:06:16 localhost kernel:  [<c1025dd2>] ? warn_slowpath_common+0x7b/0x90
> > Aug 29 08:06:16 localhost kernel:  [<c10a53e2>] ? drop_nlink+0x31/0x33
> > Aug 29 08:06:16 localhost kernel:  [<c1025e02>] ? warn_slowpath_null+0x1b/0x1f
> > Aug 29 08:06:16 localhost kernel:  [<c10a53e2>] ? drop_nlink+0x31/0x33
> > Aug 29 08:06:16 localhost kernel:  [<f83dfa81>] ? cifs_unlink+0x134/0x63d [cifs]
> > Aug 29 08:06:16 localhost kernel:  [<c10a37d4>] ? dput+0x11/0x117
> > Aug 29 08:06:16 localhost kernel:  [<c10a87d4>] ? mntput_no_expire+0xf/0xf7
> > Aug 29 08:06:16 localhost kernel:  [<c109ca9b>] ? vfs_unlink+0x4e/0xb6
> > Aug 29 08:06:16 localhost kernel:  [<c109b333>] ? __lookup_hash+0x54/0xac
> > Aug 29 08:06:16 localhost kernel:  [<c109e8c2>] ? do_unlinkat+0x10a/0x12d
> > Aug 29 08:06:16 localhost kernel:  [<c10a0124>] ? sys_ioctl+0x34/0x57
> > Aug 29 08:06:16 localhost kernel:  [<c140a8ed>] ? syscall_call+0x7/0xb
> > Aug 29 08:06:16 localhost kernel: ---[ end trace 756b427e3bd671f9 ]---
> > 
> 
> (cc'ing linux-cifs ml)
> 
> This stack trace comes from cifs, not nfs.
> 
> Steve French has a patch queued in his tree to silence this warning
> that I believe he intends to send to Linus for 3.6. Perhaps we should
> consider backporting it for 3.5.z too?
> 
> -- 
> Jeff Layton <jlayton@redhat.com>

Jeff,

I applied this patch to Kernel 3.5.3 from Pavel and the 
the warning is gone with no problems.

Thanks,
 
--( Nick Pasich

##########################################################

>From df2d6b1fbf2401c5ee04f2ac143ea0954e3a87a6 Mon Sep 17 00:00:00 2001
From: Pavel Shilovsky <pshilovsky@samba.org>
Date: Fri, 13 Jul 2012 11:59:45 +0400
Subject: [PATCH] CIFS: Protect i_nlink from being negative

that can cause warning messages.

Signed-off-by: Pavel Shilovsky <pshilovsky@samba.org>
---
 fs/cifs/inode.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index 7354877..88afb1a 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1110,6 +1110,15 @@ undo_setattr:
		goto out_close;
 }
 
+/* copied from fs/nfs/dir.c with small changes */
+static void
+cifs_drop_nlink(struct inode *inode)
+{
+	spin_lock(&inode->i_lock);
+	if (inode->i_nlink > 0)
+		drop_nlink(inode);
+	spin_unlock(&inode->i_lock);
+}
 
 /*
  * If dentry->d_inode is null (usually meaning the cached dentry
@@ -1166,13 +1175,13 @@ retry_std_delete:
 psx_del_no_retry:
		if (!rc) {
				if (inode)
-			drop_nlink(inode);
+			cifs_drop_nlink(inode);
		} else if (rc == -ENOENT) {
				d_drop(dentry);
		} else if (rc == -ETXTBSY) {
				rc = cifs_rename_pending_delete(full_path, dentry, xid);
				if (rc == 0)
-			drop_nlink(inode);
+			cifs_drop_nlink(inode);
		} else if ((rc == -EACCES) && (dosattr == 0) && inode) {
				attrs = kzalloc(sizeof(*attrs), GFP_KERNEL);
				if (attrs == NULL) {
-- 
1.7.3.3

##########################################################

