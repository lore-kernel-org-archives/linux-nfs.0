From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/4] nfs: ensure that sillyrenames run to completion
 (try #3)
Date: Fri, 17 Sep 2010 17:43:19 -0400
Message-ID: <1284759799.16091.0.camel@heimdal.trondhjem.org>
References: <1284647045-18286-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41146 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753034Ab0IQVnp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 17:43:45 -0400
In-Reply-To: <1284647045-18286-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-09-16 at 10:24 -0400, Jeff Layton wrote:
> Hi Trond,
> 
> A few changes to this set since I sent the last one. Notably:
> 
> - I merged some of the patches to ensure that we're not adding interfaces
>   that are unused in a particular patch and to minimize "churn" by multiple
>   patches changing the same code
> 
> - The fattr structs are allocated now as part of the nfs_renamedata. That
>   eliminates the need to dynamically allocate them and allows rename_setup
>   to be a void return function
> 
> - nfs_cancel_async_unlink now drops the d_lock before calling
>   nfs_free_unlinkdata
> 
> Also, some other less notable bugs were fixed. I'd like to see this in
> 2.6.37 if possible.
> 
> Original intro email follows:
> 
> --------------------------------[snip]--------------------------------
> 
> We had a bug report recently where someone was complaining about
> silly-renamed files being left around:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=511901
> 
> ...they attached a reproducer to the bug which involves a pthreads-based
> program killing a child thread that's unlinking and closing a file.
> 
> The unlink triggers a sillyrename (since the file is still open). The
> parent kills the child thread and if timed just right, the child thread
> will be killed after the RENAME call is issued but before the reply is
> processed. The file will end up renamed on the server, but the client
> won't be aware of it and won't unlink it during dentry_iput.
> 
> This patchset is intended to prevent this from happening by having
> nfs_sillyrename use an asynchronous rename call and simply wait for the
> call to complete in TASK_KILLABLE sleep before proceeding. If the task
> is killed while the rename RPC is on the wire, it'll still run to
> completion even though the thread that initiated it was killed off.
> 
> To facilitate this, the set first changes all of the existing rename
> calls to use standardized argument and response containers. The
> nfs_sillyrename call is then moved to unlink.c (where the rest of the
> sillyrename code lives), and then is converted to use an asynchronous
> RPC call to handle the rename.
> 
> I've tested this by running the reproducer in the above bug report in a
> loop for several hours and never ended up with a leftover .nfs* file.
> 
> Jeff Layton (4):
>   nfs: standardize the rename args container
>   nfs: standardize the rename response container
>   nfs: move nfs_sillyrename to unlink.c
>   nfs: make sillyrename an async operation
> 
>  fs/nfs/dir.c            |   70 -------------
>  fs/nfs/nfs2xdr.c        |    8 +-
>  fs/nfs/nfs3proc.c       |   51 +++++++---
>  fs/nfs/nfs3xdr.c        |   16 ++--
>  fs/nfs/nfs4proc.c       |   34 ++++++-
>  fs/nfs/nfs4xdr.c        |    4 +-
>  fs/nfs/proc.c           |   29 ++++-
>  fs/nfs/unlink.c         |  263 ++++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/nfs_fs.h  |    2 +-
>  include/linux/nfs_xdr.h |   64 ++++--------
>  10 files changed, 391 insertions(+), 150 deletions(-)
> 

Thanks! I've queued this up in the nfs-for-2.6.37 branch.

Cheers
  Trond
