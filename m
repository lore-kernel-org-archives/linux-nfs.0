Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34270 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935219AbdAEFIW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jan 2017 00:08:22 -0500
Received: by mail-pg0-f67.google.com with SMTP id b1so39434661pgc.1
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jan 2017 21:08:22 -0800 (PST)
Date: Thu, 5 Jan 2017 15:08:10 +1000
From: Nicholas Piggin <npiggin@gmail.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "Neil Brown" <neilb@suse.de>
Subject: Re: [PATCH 1/2] nfs: no PG_private waiters remain, remove waker
Message-ID: <20170105150810.0b82a9ec@roar.ozlabs.ibm.com>
In-Reply-To: <0562F017-2963-41E0-BE5B-62A07EC444CD@primarydata.com>
References: <20170103182234.30141-1-npiggin@gmail.com>
        <20170103182234.30141-2-npiggin@gmail.com>
        <0562F017-2963-41E0-BE5B-62A07EC444CD@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 4 Jan 2017 13:43:10 +0000
Trond Myklebust <trondmy@primarydata.com> wrote:

> Hi Nick,
> 
> > On Jan 3, 2017, at 13:22, Nicholas Piggin <npiggin@gmail.com> wrote:
> > 
> > Since commit 4f52b6bb ("NFS: Don't call COMMIT in ->releasepage()"),
> > no tasks wait on PagePrivate, so the wake introduced in commit 95905446
> > ("NFS: avoid deadlocks with loop-back mounted NFS filesystems.") can
> > be removed.
> > 
> > Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> > ---
> > fs/nfs/write.c | 2 --
> > 1 file changed, 2 deletions(-)
> > 
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index b00d53d13d47..006068526542 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -728,8 +728,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
> > 		if (likely(head->wb_page && !PageSwapCache(head->wb_page))) {
> > 			set_page_private(head->wb_page, 0);
> > 			ClearPagePrivate(head->wb_page);
> > -			smp_mb__after_atomic();
> > -			wake_up_page(head->wb_page, PG_private);
> > 			clear_bit(PG_MAPPED, &head->wb_flags);
> > 		}
> > 		nfsi->nrequests--;
> > -- 
> > 2.11.0
> >   
> 
> That looks fine to me. Do you want to push it through the linux-mm path or do you want me to take it?

Hi Trond,

Thanks. I don't see a problem with both patches going through your tree.
I think the patches to add this stuff went through your tree as well.
The removal of the export is really the only thing that makes patch 2
non-trivial, but considering it was added for NFS, I think it's safe to
remove.

Thanks,
Nick
