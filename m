From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression [SOLVED]
Date: Wed, 12 Dec 2007 04:24:23 +0200
Message-ID: <200712120424.24029.maximlevitsky@gmail.com>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989@mail.gmail.com> <200712120401.57128.maximlevitsky@gmail.com> <20071211181559.fe21687a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_YZ0XHuruGgYZ4Pp"
Cc: bfields@fieldses.org, neilb@suse.de, rjw@sisk.pl,
	trond.myklebust@fys.uio.no, gnome42@gmail.com,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	den@openvz.org, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:12205 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbXLLCZB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 21:25:01 -0500
Received: by ug-out-1314.google.com with SMTP id z38so454186ugc.16
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2007 18:25:00 -0800 (PST)
In-Reply-To: <20071211181559.fe21687a.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Boundary-00=_YZ0XHuruGgYZ4Pp
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 12 December 2007 04:15:59 Andrew Morton wrote:
> On Wed, 12 Dec 2007 04:01:56 +0200 Maxim Levitsky <maximlevitsky@gmail.com> wrote:
> 
> > > 
> > > argh, this is getting bad.
> > > 
> > > Can you please test the below patch asap? Against 2.6.24-rc4 or latest-linus.
> > > 
> > > 
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > 
> > > Revert
> > > 
> > >     commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416
> > >     Author: Eric W. Biederman <ebiederm@xmission.com>
> > >     Date:   Sun Dec 2 00:33:17 2007 +1100
> > > 
> > 
> > Hi,
> > 
> > I finally solved this.
> > There is no need to revert 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416.
> > 
> > It was actually a deadly mixture of 3 bugs:
> > 
> > 1) Stale handles - Trond's patch fixes it, but I somehow missed it.
> 
> What is "Trond's patch" and where is it now?
Message-Id: <1197053179.7532.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
It is in beginning of that thread.
I attached it for reference.

> 
> > 2) Empty /proc/fs/nfsd (which causes nfs4 failures, and masks the bug #1, since with it the subfolders are just empty)
> > 	[PATCH 2.6.24-rc4] proc: Remove/Fix proc generic d_revalidate fixes it
> 
> That patch was merged into Linus's tree just prior to 2.6.24-rc5.
Yes I know, I was testing -rc4, but I put this patch in
> 
> > 3) And as I expected, a userspace bug, which believe me or not has exactly the same symptoms
> > like #2 (and doesn't depend on others)
> > 
> > It is a wrong boot script in BLFS that starts nfs daemons in wrong order.
> > So there are 3 bugs and each masks the former one :-) .
> > 
> > I revised boot script to use recommended order like in nfs-utils.
> > And finally everything works....
> > 
> 
> Well...  It's relatively common that insufficiently-robust userspace works
> OK under kernel N and then stops working under kernel N+1.  Even though the
> fault lies with userspace, we prefer that it continues to work.
> 
> But it doesn't sounds like that'll be a concern here.
Well, no.
This boot script doesn't work in 2.6.23 ether.
I just didn't use nfs4, and I thought that I don't understand how crossmnt/nohide work.
> 
> Thanks for the followup.
> 


Best regards,
	Maxim Levitsky

--Boundary-00=_YZ0XHuruGgYZ4Pp
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.24-001-fix_submounts.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.24-001-fix_submounts.dif"

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: 
Subject: NFS: Fix NFS mountpoint crossing...
Message-Id: <1197053179.7532.24.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

The check that was added to nfs_xdev_get_sb() to work around broken
servers, works fine for NFSv2, but causes mountpoint crossing on NFSv3 to
always return ESTALE.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2426e71..ea92920 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1475,7 +1475,7 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
-	if (mntroot->d_inode->i_op != &nfs_dir_inode_operations) {
+	if (mntroot->d_inode->i_op != server->nfs_client->rpc_ops->dir_inode_ops) {
 		dput(mntroot);
 		error = -ESTALE;
 		goto error_splat_super;

--Boundary-00=_YZ0XHuruGgYZ4Pp--
