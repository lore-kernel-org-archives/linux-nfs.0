Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54755 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932903Ab3GVSxh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 14:53:37 -0400
Date: Mon, 22 Jul 2013 14:53:36 -0400
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC 0/5] NFS Server Side Copy
Message-ID: <20130722185336.GC10109@fieldses.org>
References: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 19, 2013 at 05:03:45PM -0400, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> These patches build on Zach Brown's copyfile patches to add server side
> copy to both the NFS client and the NFS server.
> 
> The first patch improves on the copyfile syscall to make it usable on my
> machine and also includes notes on other potential problems that I've
> found.  The remaining patches first implement a sync copy, then expand to
> async.
> 
> My testing was done on a server exporting an ext4 filesystem exporting an
> ext4 filesystem.  I compared copying using the cp command to copying with
> the copyfile system call.

Were these tests using the full series of patches?  (So, using the
asynchronous mechanism?)

--b.

> 
> 
> File size:  512 MB
> cp: 4.244 seconds
> copyfile: 0.961 seconds
> 
> File size: 1024 MB
> cp: 9.091 seconds
> copyfile: 1.919 seconds
> 
> File size: 1536 MB
> cp: 15.291 seconds
> copyfile: 6.016 seconds
> 
> 
> Repeating these tests on a btrfs exported filesystem supporting the copyfile
> system call drops the time for copyfile to about 0.01 seconds.
> 
> Feel free to send me any questions, comments or other thoughts!
> 
> - Bryan
> 
> Bryan Schumaker (5):
>   Improve on the copyfile systemcall
>   NFSD: Implement the COPY call
>   NFS: Add COPY nfs operation
>   NFSD: Defer copying
>   NFS: Change copy to support async servers
> 
>  fs/copy_range.c          |  10 +++-
>  fs/nfs/callback.h        |  13 ++++
>  fs/nfs/callback_proc.c   |   9 +++
>  fs/nfs/callback_xdr.c    |  54 ++++++++++++++++-
>  fs/nfs/inode.c           |   2 +
>  fs/nfs/nfs4_fs.h         |   7 +++
>  fs/nfs/nfs4file.c        | 101 +++++++++++++++++++++++++++++++
>  fs/nfs/nfs4proc.c        |  16 +++++
>  fs/nfs/nfs4xdr.c         | 150 +++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4callback.c   | 136 ++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4proc.c       | 104 ++++++++++++++++++++++++++++++--
>  fs/nfsd/nfs4state.c      |  15 ++++-
>  fs/nfsd/nfs4xdr.c        | 121 +++++++++++++++++++++++++++++++++++++-
>  fs/nfsd/state.h          |  23 +++++++-
>  fs/nfsd/vfs.c            |   9 +++
>  fs/nfsd/vfs.h            |   1 +
>  fs/nfsd/xdr4.h           |  24 ++++++++
>  fs/nfsd/xdr4cb.h         |   9 +++
>  include/linux/nfs4.h     |  14 ++++-
>  include/linux/nfs_xdr.h  |  33 +++++++++++
>  include/linux/syscalls.h |   1 +
>  21 files changed, 836 insertions(+), 16 deletions(-)
> 
> -- 
> 1.8.3.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
