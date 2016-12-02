Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44474 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752733AbcLBPu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Dec 2016 10:50:28 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/3] Readdirplus performance improvements for 4.10
Date: Fri, 02 Dec 2016 10:42:35 -0500
Message-ID: <1951E713-DF48-474E-BE6A-BA40F3C74B46@redhat.com>
In-Reply-To: <20161202142135.11515-1-trond.myklebust@primarydata.com>
References: <20161202142135.11515-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2 Dec 2016, at 9:21, Trond Myklebust wrote:

> Fix up the regression introduced by commit 311324ad1713, and then
> improve the READDIRPLUS hinting.
>
> Trond Myklebust (3):
>   NFS: Fix a performance regression in readdir
>   NFS: Be more targeted about readdirplus use when doing
>     lookup/revalidation
>   NFS: Allow getattr to also report readdirplus cache hits
>
>  fs/nfs/dir.c      | 46 +++++++++++++++++++++-------------------------
>  fs/nfs/inode.c    | 21 +++++++++++++++++----
>  fs/nfs/internal.h |  1 +
>  3 files changed, 39 insertions(+), 29 deletions(-)

My testing shows that these three patches restore and/or retain these 
three
NFS readdir optimizations:

1.  Detect ls -l, so that we continue to use READDIRPLUS after the first 
batch
     of entries are returned by nfs_readdir(). This avoids a GETATTR 
storm.
     311324ad1713 NFS: Be more aggressive in using readdirplus for ‘ls 
-l’
     situations

2.  Don’t use READDIRPLUS unnecessarily.
     d69ee9b85541 NFS: Adapt readdirplus to application usage patterns
     http://www.spinics.net/lists/linux-nfs/msg19996.html

3.  Don’t invalidate the page cache every time the directory is 
modified if we
     are in the middle of a listing. At least wait until the attributes 
time out.
     07b5ce8ef2d8 NFS: Make nfs_readdir revalidate less often

Feel free to add

Reviewed-and-Tested-by: Benjamin Coddington <bcodding@redhat.com>

.. and thanks very much!

Ben
