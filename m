Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:64448 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964863AbaFQVhV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 17:37:21 -0400
Received: by mail-vc0-f182.google.com with SMTP id il7so7172310vcb.27
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2014 14:37:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140617210439.GC4510@tonberry.usersys.redhat.com>
References: <1402683488-23725-1-git-send-email-smayhew@redhat.com>
	<1402683488-23725-2-git-send-email-smayhew@redhat.com>
	<CAABAsM5kJFJK_-VwL4bB4ZUvpdx4pFEYqXKN1S7KqdF6=Xc76g@mail.gmail.com>
	<20140617210439.GC4510@tonberry.usersys.redhat.com>
Date: Tue, 17 Jun 2014 17:37:20 -0400
Message-ID: <CAHQdGtS=jTwzh+Q7WHy5Bg=vqXXsJvLK+O3-r55bq58DXNiZrQ@mail.gmail.com>
Subject: Re: [PATCH RFC] nfs: ensure cached data is correct before using delegation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 17, 2014 at 5:04 PM, Scott Mayhew <smayhew@redhat.com> wrote:
>
> No, I don't think it's right to ignore NFS_INO_INVALID_DATA, and
> originally I was testing a fix similar to this:
>
> ---8<---
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 3ee5af4..98ff061 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -934,12 +934,14 @@ static bool nfs_write_pageuptodate(struct page *page, struct inode *inode)
>
>         if (nfs_have_delegated_attributes(inode))
>                 goto out;
> -       if (nfsi->cache_validity & (NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE))
> +       if (nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
>                 return false;
>         smp_rmb();
>         if (test_bit(NFS_INO_INVALIDATING, &nfsi->flags))
>                 return false;
>  out:
> +       if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
> +               return false;
>         return PageUptodate(page) != 0;
>  }
> ---8<---
>
>
> However,
>
> 1) it wasn't really keeping with the spirit of commit 8d197a56 (NFS:
> Always trust the PageUptodate flag when we have a delegation), and
>
> 2) one of my test programs (used to test commit c7559663 (NFS: Allow
> nfs_updatepage to extend a write under additional circumstances)))
> started performing poorly again, doing tons of sub page-sized writes
> intead of a handful of wsize'd writes.
>
> I did some more digging and I think I see 2 areas that could be
> improved.
>
> The first would be to clear NFS_INO_INVALID_DATA if we've just
> truncated the inode to 0 bytes -- after all, if we've just unmapped
> all the pages from the inode's address space then isn't our data
> consisitent?:

Hi Scott,

What say we rather just don't set/clear NFS_INO_INVALID_DATA if
mapping->nrpages == 0? That should catch the above case, plus a couple
of other potential false positives.

> The second thing I noticed is that we're constantly invalidating our
> cache due to the change attribute changing on the server.  But if we
> have a write delegation then the change attribute changing must be the
> result of *our* changes, in which case we should be able to just silently
> update the change attribute on our side without invalidating our caches:

Ack. That's a bug in the current code.

Cheers
  Trond


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
