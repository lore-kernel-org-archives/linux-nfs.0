From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression [SOLVED]
Date: Tue, 11 Dec 2007 21:19:00 -0500
Message-ID: <1197425940.27061.1.camel@heimdal.trondhjem.org>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989@mail.gmail.com>
	 <200712101705.30428.maximlevitsky@gmail.com>
	 <20071210130305.d8983fdc.akpm@linux-foundation.org>
	 <200712120401.57128.maximlevitsky@gmail.com>
	 <20071211181559.fe21687a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-TlI4Fg2n/Pv+WrlBB4oh"
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, bfields@fieldses.org,
	neilb@suse.de, rjw@sisk.pl, gnome42@gmail.com,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	den@openvz.org, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:44652 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077AbXLLCTe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2007 21:19:34 -0500
In-Reply-To: <20071211181559.fe21687a.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-TlI4Fg2n/Pv+WrlBB4oh
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Tue, 2007-12-11 at 18:15 -0800, Andrew Morton wrote:
> > 1) Stale handles - Trond's patch fixes it, but I somehow missed it.
> 
> What is "Trond's patch" and where is it now?

He means the one this whole thread started with. See attachment...

Trond


--=-TlI4Fg2n/Pv+WrlBB4oh
Content-Disposition: inline
Content-Description: Attached message - Re: 2.6.24-rc3-git4 NFS crossmnt
	regression
Content-Type: message/rfc822

Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Shane <gnome42@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,  "J. Bruce Fields" <bfields@fieldses.org>, "Rafael J. Wysocki" <rjw@sisk.pl>
In-Reply-To: <fa4052ef0712071014l524951e2we4705d84c5005cf3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	 <20071207040219.e231cbc7.akpm@linux-foundation.org>
	 <fa4052ef0712071014l524951e2we4705d84c5005cf3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Type: multipart/mixed; boundary="=-IBupBxkFjx7YOD4mPYpk"
Message-Id: <1197053179.7532.23.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Mime-Version: 1.0
X-Mailer: Evolution 2.12.1 
Date: Fri, 07 Dec 2007 13:46:22 -0500
X-Evolution-Format: text/plain
X-Evolution-Account: 1149135252.7829.2-SyLVLa/KEI9HwK5hSS5vWB2eb7JE58TQ@public.gmane.org
X-Evolution-Transport: smtp://trondmy;auth=PLAIN-KA+CI/vQ5ZMXWF+eFR7m5Q@public.gmane.org/;use_ssl=always
X-Evolution-Fcc: imap://trondmy-7Aet2DzYtukXWF+eFR7m5Q@public.gmane.org/INBOX/Sent
X-Evolution-Source: imap://trondmy-7Aet2DzYtukXWF+eFR7m5Q@public.gmane.org/


--=-IBupBxkFjx7YOD4mPYpk
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Fri, 2007-12-07 at 13:14 -0500, Shane wrote:
> On Dec 7, 2007 7:02 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> ...
> > > 2.6.24-rc3-git1 is last known good kernel. The problem also exists
> > > with the latest snap 2.6.24-rc4-git4. NFS server is 2.6.23-rc9 and
> > > is unchanged.
> >
> > hm, there have been no nfs changes since 2.6.24-rc4.
> 
> Ok, but the problem seems to have appeared before 2.6.24-rc4.
> 
> > > It is easily reproducible here, hopefully for the person who
> > > knows how to debug it too :)
> > >
> >
> > I guess a full set of the commands which you typed to reproduce this would
> > help.
> 
> Server is 2.6.23-rc9 and is exporting:
> 
> /dirA/dirB
> 10.10.20.0/255.255.255.0(rw,async,no_root_squash,no_subtree_check,insecure,crossmnt)
> /dirA/dirB/dirC
> 10.10.20.0/255.255.255.0(rw,async,no_root_squash,no_subtree_check,insecure)
> /dirA/dirB/dirD
> 10.10.20.0/255.255.255.0(rw,async,no_root_squash,no_subtree_check,insecure)
> 
> The NFS client (Core2 SMP) 2.6.24-rc3-git4:
> 
> NFS-server:/dirA/dirB     /dirA/dirB    nfs
> auto,rsize=16384,wsize=16384,hard,intr,users,exec,nfsvers=3,tcp,nolock,actimeo=0
> 
> Then on the client when the new kernel has booted:
> 
> ls /dirA/dirB      --> normal listing
> ls /dirA/dirB/dirC   -->  Stale NFS file handle
> ls /dirA/dirB/dirD   -->  Stale NFS file handle
> 
> I will do a few more builds/boots and check -rc3-git2 and -rc3-git3.

This problem has already been reported. The fix (which I'm planning on
sending to Linus soon) is appended.

Cheers
  Trond

--=-IBupBxkFjx7YOD4mPYpk
Content-Disposition: inline; filename=linux-2.6.24-001-fix_submounts.dif
Content-Type: message/rfc822; name=linux-2.6.24-001-fix_submounts.dif

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

--=-IBupBxkFjx7YOD4mPYpk--

--=-TlI4Fg2n/Pv+WrlBB4oh--

