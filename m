Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34968 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028AbbHSEiP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 00:38:15 -0400
Received: by oiew67 with SMTP id w67so94729004oie.2
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2015 21:38:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1439959019-16805-1-git-send-email-trond.myklebust@primarydata.com>
References: <1439959019-16805-1-git-send-email-trond.myklebust@primarydata.com>
Date: Tue, 18 Aug 2015 21:38:14 -0700
Message-ID: <CAHQdGtS4bFB0er8a2Ymepuc73SDeReDKxPdGkOT4UPNv6rNTow@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1/pnfs: Fix a close/delegreturn hang when
 return-on-close is set
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 18, 2015 at 9:36 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> The helper pnfs_roc() has already verified that we have no delegations,
> and no further open files, hence no outstanding I/O and it has marked
> all the return-on-close lsegs as being invalid.
> Furthermore, it sets the NFS_LAYOUT_RETURN bit, thus serialising the
> close/delegreturn with all future layoutget calls on this inode.
>
> The checks in pnfs_roc_drain() for valid layout segments are therefore
> redundant: those cannot exist until another layoutget completes.
> The other check for whether or not NFS_LAYOUT_RETURN is set, actually
> causes a hang, since we already know that we hold that flag.
>
> To fix, we therefore strip out all the functionality in pnfs_roc_drain()
> except the retrieval of the barrier state, and then rename the function
> accordingly.
>
> Reported-by: Christoph Hellwig <hch@infradead.org>
> Fixes: 5c4a79fb2b1c ("Don't prevent layoutgets when doing return-on-close")
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 12 ++++--------
>  fs/nfs/pnfs.c     | 24 +-----------------------
>  fs/nfs/pnfs.h     |  7 +++----
>  3 files changed, 8 insertions(+), 35 deletions(-)

Hi Christoph,

Can you please check if this patch fixes the hang you're seeing?

Cheers,
  Trond
