From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
Subject: Re: nfs_file_flush() question
Date: Tue, 19 Aug 2008 15:17:31 -0500
Message-ID: <20080819201731.GA25036@yahoo-inc.com>
References: <1218992641.7999.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip4-fw.champ.corp.yahoo.com ([64.198.211.64]:45457 "EHLO
	enemycanmeet.champ.corp.yahoo.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759315AbYHSUUd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2008 16:20:33 -0400
In-Reply-To: <1218992641.7999.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 17, 2008 at 10:04:01AM -0700, Trond Myklebust wrote:
> On Sat, 2008-08-16 at 19:23 -0500, Quentin Barnes wrote:
> > I've been coming up to speed on the NFS protocol and its NFS client
> > support in Linux.  I've been comparing performance of NFS on RHEL4
> > and RHEL5 vs. FreeBSD 6.2.  (Okay, we're on an old base, but I don't
> > think it matters here for this question.)

Oops.  I goofed in my assumption.  There is a notable difference
between the older kernels and the newer kernels in this regards.

[...]
> > Is there a reason I'm missing that the revalidate and GETATTR are
> > required?
> 
> Yes: It is required for correct close-to-open cache consistency
> semantics.
> 
> If I don't know the correct mtime attribute of the file when I close it,

If I follow the code, you do know the mtime when closing the
file.  With V3, from the WRITE and COMMIT, you're given weak cache
consistency data containing the the updated mtimes, correct?

I'm still learning the NFS protocol, so I know I don't fully
understand when and how the WCC is utilized in the kernel, so I
probably have something wrong.

> then I can't compare it with the mtime of the file when I open it again.
> If so, close-to-open semantics forbid me from assuming that my cached
> data is still valid, and so I have to throw out the entire page cache
> contents for that file.

I watched a 2.6.24 kernel I had lying around.  It never does a
GETATTR anymore during closing a file.

The older kernels invalidated the attribute cache as part of
nfs_file_flush()'s write/commit step.  The newer kernels still leave
the attribute or data cache marked as valid post-write and commit.
(More below).

If the nocto mount flag is used, the only difference is the GETATTR
on open(2) is avoided.

On Mon, Aug 18, 2008 at 09:53:11AM -0700, Trond Myklebust wrote:
> On Mon, 2008-08-18 at 12:04 -0400, Chuck Lever wrote:
> > Does the Linux NFS client optimize away the GETATTR when it has sent
> > only a single WRITE and the server has returned post-op attributes?
> > Using a large wsize with a modern server implementation might make
> > this a fairly common scenario.
> 
> Yes: please see the code. We use a standard nfs_revalidate_inode() which
> will be optimised away if the inode metadata is known to be up to date.

That's what I found.  There was two pieces to that change.
The first was in nfs_file_flush() changing the call from
__nfs_revalidate_inode() to nfs_revalidate_inode() in 2.6.15 so the
always forced GETATTR could be optimized out when the attribute
cache was still valid and hadn't timed out.

But making the change to nfs_revalidate_inode() by itself only
helps in the case where the file was open O_RDWR and no write(2)
was done.  The code still needed to be updated to use the WCC data
at the right time.  In the older kernels when nfs_wb_all() ended up
calling nfs_update_inode() which was clearing the cache when it saw
the mtime change from the WRITE.  I tracked down why.  Newer kernels
(2.6.24 and later) had nfs_post_op_update_inode_force_wcc() call
added to nfs3_write_done() which updated the inode with the WCC data
from the WRITE so the later call to nfs_update_inode() didn't see
an unexpected mtime change flagging the attribute and data cache as
invalid.

At least that's my current understanding from reading through the
code for the last couple of days and comparing older and newer
kernels.  Please correct me where I'm wrong.

> Cheers
>   Trond

Quentin
