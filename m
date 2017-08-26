Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45780 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750737AbdHZSGM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Aug 2017 14:06:12 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 0/3] Eliminate delegation self-conflicts
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1503697958-6122-1-git-send-email-bfields@redhat.com>
Date: Sat, 26 Aug 2017 14:06:05 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <1BD0901E-8339-4993-A012-9F8402BF16EF@oracle.com>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 25, 2017, at 5:52 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> 
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> This is my attempt to fix the NFS server so we don't unnecessarily
> recall delegations when the operation breaking the delegation comes from
> the same client that holds the delegation.
> 
> To do that we need some way to pass the identity of the breaker down
> through the VFS.
> 
> I didn't feel like adding another argument to all the VFS functions that
> this might need to be passed down through.  But all of those functions
> already take a struct inode **delegated inode, so instead I turned that
> into a single-member struct deleg_ctrl *, which I then added a second
> member to.
> 
> I dunno, welcome any more straightforward ways of doing this if anyone
> has suggestions.
> 
> My first attempt was to do this by instead checking for conflicts in the
> caller (nfsd) and then passing down one just one bit telling the lease
> code conflicts had already been checked so it didn't need to.  But
> that's much too early to check for conflicts, since the caller doesn't
> have the necessary inode locks yet.
> 
> I'm still missing testing.  Regression tests pass, but I haven't
> actually confirmed that the self-conflicts are gone!  Off to go hack on
> pynfs....

FWIW, I observe a lot of delegation recall activity when running
the git regression tests on an NFSv4.x mount. This is a single
client.

Unpack a recent release of the git tarball.

$ cd src/git
$ make clean
$ make
$ make test

Easily scriptable, and you can "cd t/" and run individual
regression tests if you like.


> --b.
> 
> J. Bruce Fields (3):
>  fs: cleanup to hide some details of delegation logic
>  fs: hide another detail of delegation logic
>  nfsd: clients don't need to break their own delegations
> 
> Documentation/filesystems/Locking |  2 ++
> fs/attr.c                         | 10 +++---
> fs/locks.c                        |  7 +++-
> fs/namei.c                        | 70 ++++++++++++++++++---------------------
> fs/nfsd/nfs4state.c               | 40 ++++++++++++++++++++++
> fs/nfsd/vfs.c                     | 26 ++++++++++++---
> fs/open.c                         | 24 ++++++--------
> fs/utimes.c                       | 12 +++----
> include/linux/fs.h                | 61 +++++++++++++++++++++-------------
> 9 files changed, 159 insertions(+), 93 deletions(-)
> 
> -- 
> 2.13.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



