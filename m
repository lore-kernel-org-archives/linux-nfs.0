Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:10357 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752315AbcISRNr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Sep 2016 13:13:47 -0400
Subject: Re: [PATCH v4 resend 0/2] pnfs: allow client to support servers that
 send multiple layout types
To: Jeff Layton <jlayton@redhat.com>, <trond.myklebust@primarydata.com>
References: <1473964849-3194-1-git-send-email-jlayton@redhat.com>
CC: <linux-nfs@vger.kernel.org>, <tigran.mkrtchyan@desy.de>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <abcb0fdd-b2da-0208-c57a-66c2c5ce83b9@Netapp.com>
Date: Mon, 19 Sep 2016 13:13:42 -0400
MIME-Version: 1.0
In-Reply-To: <1473964849-3194-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/15/2016 02:40 PM, Jeff Layton wrote:
> Resending as I noticed that Anna had merged the first of the two
> patches into her linux-next branch, but not the second one. Were
> there any further concerns with it?

Nope, no concerns.  I updated a few of the later patchsets in my branch before pushing everything out, so it must have gotten lost in the shuffle.  I've applied the patch again, so it should be there now.  Thanks for catching!

Sorry about the mistake, and thanks for catching it!
Anna

> 
> v4:
> - pass around fsinfo instead of separate array and length args
> 
> v3:
> - use sort() from lib/sort.c to sort the list
> 
> v2:
> - rework Tigran's patch to preserve existing selection behaviour
> - simplify layout driver selection by sorting the list
> 
> This is v4 of the patchset. The main change is the change to pass
> around the fsinfo instead of separate array pointer and length args.
> 
> Only lightly tested by mounting a server that sends both flexfiles and
> block layouts. The client successfully selected the block layout in most
> cases, but if I blacklist blocklayoutdriver then it selects flexfiles
> instead.
> 
> Jeff Layton (2):
>   pnfs: track multiple layout types in fsinfo structure
>   pnfs: add a new mechanism to select a layout driver according to an
>     ordered list
> 
>  fs/nfs/client.c         |  3 ++-
>  fs/nfs/nfs4proc.c       |  2 +-
>  fs/nfs/nfs4xdr.c        | 40 ++++++++++++++--------------
>  fs/nfs/pnfs.c           | 69 ++++++++++++++++++++++++++++++++++++++++---------
>  fs/nfs/pnfs.h           |  5 ++--
>  include/linux/nfs_xdr.h |  8 +++++-
>  6 files changed, 91 insertions(+), 36 deletions(-)
> 

