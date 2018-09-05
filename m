Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:59278 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727267AbeIFAE6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 20:04:58 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 0/7] Misc NFS + pNFS performance enhancements
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
Date: Wed, 5 Sep 2018 15:33:10 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <825DAB8C-9E0B-438D-9D36-7F1B188F86AD@oracle.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Sep 5, 2018, at 3:23 PM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> Fallout from a bunch of flame graphs...

Hey, are these in a public git repo I can pull from?


> Trond Myklebust (7):
>  pNFS: Don't zero out the array in nfs4_alloc_pages()
>  pNFS: Don't allocate more pages than we need to fit a layoutget
>    response
>  NFS: Convert lookups of the lock context to RCU
>  NFS: Simplify internal check for whether file is open for write
>  NFS: Convert lookups of the open context to RCU
>  NFSv4: Convert open state lookup to use RCU
>  NFSv4: Convert struct nfs4_state to use refcount_t
> 
> fs/nfs/delegation.c                    | 11 ++--
> fs/nfs/filelayout/filelayout.c         |  1 +
> fs/nfs/flexfilelayout/flexfilelayout.c |  1 +
> fs/nfs/inode.c                         | 70 +++++++++++---------------
> fs/nfs/nfs4_fs.h                       |  3 +-
> fs/nfs/nfs4proc.c                      | 38 ++++++++++----
> fs/nfs/nfs4state.c                     | 32 ++++++------
> fs/nfs/pnfs.c                          | 16 ++++--
> fs/nfs/pnfs.h                          |  1 +
> include/linux/nfs_fs.h                 |  2 +
> 10 files changed, 98 insertions(+), 77 deletions(-)
> 
> -- 
> 2.17.1
> 

--
Chuck Lever
