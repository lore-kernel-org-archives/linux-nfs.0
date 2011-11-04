Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27755 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932878Ab1KDREy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 13:04:54 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH 2/2] nfs: when attempting to open a directory, fall back on normal lookup (try #4)
Date: Fri, 4 Nov 2011 10:04:52 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA9337@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <1320413608-17032-2-git-send-email-jlayton@redhat.com>
References: <1320413608-17032-1-git-send-email-jlayton@redhat.com> <1320413608-17032-2-git-send-email-jlayton@redhat.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Jeff Layton [mailto:jlayton@redhat.com]
> Sent: Friday, November 04, 2011 9:33 AM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: [PATCH 2/2] nfs: when attempting to open a directory, fall
back on
> normal lookup (try #4)
> 
> commit d953126 changed how nfs_atomic_lookup handles an -EISDIR return
> from an OPEN call. Prior to that patch, that caused the client to fall
back to
> doing a normal lookup. When that patch went in, the code began
returning
> that error to userspace. The d_revalidate codepath however never had
the
> corresponding change, so it was still possible to end up with a NULL
ctx-
> >state pointer after that.
> 
> That patch caused a regression. When we attempt to open a directory
that
> does not have a cached dentry, that open now errors out with EISDIR.
If you
> attempt the same open with a cached dentry, it will succeed.
> 
> Fix this by reverting the change in nfs_atomic_lookup and allowing
attempts
> to open directories to fall back to a normal lookup
> 
> Also, add a NFSv4-specific f_ops->open routine that just returns
-ENOTDIR.
> This should never be called if things are working properly, but if it
ever is,
> then the dprintk may help in debugging.
> 
> To facilitate this, a new file_operations field is also added to the
nfs_rpc_ops
> struct.
> 
> Cc: stable@kernel.org

Just one last request: can you reverse the order of the patches so that
this one becomes 1/2? That would lose the dependency on the first patch,
making the 'Cc: stable' bit more palatable.

BTW: it is now 'stable@vger.kernel.org'...

Also note that I'm quite ready to send these 2 patches as a post-rc1
bugfix. Doing so shouldn't be a problem for Linus, since this is a
regression w.r.t. older NFSv4 behaviour.

Cheers
  Trond


