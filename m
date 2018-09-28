Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vs1-f67.google.com ([209.85.217.67]:33228 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726568AbeI2Cot (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Sep 2018 22:44:49 -0400
Received: by mail-vs1-f67.google.com with SMTP id w23-v6so4346986vsh.0
        for <linux-nfs@vger.kernel.org>; Fri, 28 Sep 2018 13:19:26 -0700 (PDT)
MIME-Version: 1.0
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <20180905192400.107485-2-trond.myklebust@hammerspace.com> <20180905192400.107485-3-trond.myklebust@hammerspace.com>
 <20180905192400.107485-4-trond.myklebust@hammerspace.com> <20180905192400.107485-5-trond.myklebust@hammerspace.com>
 <20180905192400.107485-6-trond.myklebust@hammerspace.com> <CAN-5tyG_qr7P8-2_yXAqDvQps0C06AQUuNuBBbYpUcWUsXEVYg@mail.gmail.com>
 <CAN-5tyGoywV9_cqv9jwHS7s58sX49baG4HXLn85ka-jHySxT0g@mail.gmail.com>
 <9dbc1442dd1e7bba1903a5ecf2855054ffcd0ee4.camel@gmail.com>
 <CAN-5tyH=YKiTb4ZWUeJgZg+TDJP9W2yP8acapKSs=km5RTU_6Q@mail.gmail.com>
 <cf7ee206ca825e243f671ccc3a0f3c332e144174.camel@hammerspace.com>
 <CAN-5tyGBufKA6Bn1AsB7yLviVGr5SHGyRc4z4hrKF-hScTrQXg@mail.gmail.com>
 <CAN-5tyGrjjGKG5KoDAgzLrnnzjGUqmf1iUD_AM=wbX8bD5Jk-g@mail.gmail.com> <983c9970070f98ac54526742e6c4de4b0ff7ad63.camel@hammerspace.com>
In-Reply-To: <983c9970070f98ac54526742e6c4de4b0ff7ad63.camel@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 28 Sep 2018 16:19:14 -0400
Message-ID: <CAN-5tyGt+J=irZQgByH_nXOtXkztsyjjzLwEfrXHs2UzOZXEHA@mail.gmail.com>
Subject: Re: [PATCH 5/7] NFS: Convert lookups of the open context to RCU
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 28, 2018 at 4:07 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> On Fri, 2018-09-28 at 15:55 -0400, Olga Kornievskaia wrote:
> > On Fri, Sep 28, 2018 at 3:10 PM Olga Kornievskaia <aglo@umich.edu>
> > wrote:
> > >
> > > On Fri, Sep 28, 2018 at 2:54 PM Trond Myklebust <
> > > trondmy@hammerspace.com> wrote:
> > > >
> > > > On Fri, 2018-09-28 at 14:31 -0400, Olga Kornievskaia wrote:
> > > > > On Fri, Sep 28, 2018 at 1:50 PM Trond Myklebust <
> > > > > trondmy@gmail.com>
> > > > > wrote:
> > > > > >
> > > > > > On Fri, 2018-09-28 at 12:54 -0400, Olga Kornievskaia wrote:
> > > > > > > Also shouldn't this be a bug fix for 4.19 and also go to
> > > > > > > stable?
> > > > > >
> > > > > > It wasn't really intended as a bugfix because I wasn't aware
> > > > > > that
> > > > > > there
> > > > > > was a bug to fix in the first place. I assume the
> > > > > > modification to
> > > > > > nfs4_state_find_open_context() to cause it to look for an
> > > > > > open
> > > > > > context
> > > > > > with a READ/WRITE open mode first is what fixes the bug. Is
> > > > > > that
> > > > > > the
> > > > > > case?
> > > > >
> > > > > I don't think so. nfs4_state_find_open_context() never gets
> > > > > calls
> > > > > during the run of this test case. This function is called
> > > > > during the
> > > > > reclaim on an open. In delegation recall the opens are not
> > > > > reclaimed,
> > > > > it is just reclaiming the locks.
> > > > >
> > > > > Actually, when I undo this piece of the patch, I can make it
> > > > > fail
> > > > > again.
> > > > >
> > > > > @@ -1027,10 +1027,7 @@ void
> > > > > nfs_inode_attach_open_context(struct
> > > > > nfs_open_context *ctx)
> > > > >         struct nfs_inode *nfsi = NFS_I(inode);
> > > > >
> > > > >         spin_lock(&inode->i_lock);
> > > > > -       if (ctx->mode & FMODE_WRITE)
> > > > > -               list_add(&ctx->list, &nfsi->open_files);
> > > > > -       else
> > > > > -               list_add_tail(&ctx->list, &nfsi->open_files);
> > > > > +       list_add_tail_rcu(&ctx->list, &nfsi->open_files);
> > > > >         spin_unlock(&inode->i_lock);
> > > > >  }
> > > > >  EXPORT_SYMBOL_GPL(nfs_inode_attach_open_context);
> > > > >
> > > > > It looks like the placement in the list matters? Any ideas why?
> > > >
> > > > Currently, the list is ordered so that writeable open contexts
> > > > are
> > > > always found first. The reason is that when traversing the list
> > > > during
> > > > server reboot recovery, we want to ensure that we reclaim any
> > > > write
> > > > delegations on the file first so that we can cache all subsequent
> > > > opens
> > > > and locks of that file.
> > > >
> > > > A delegation return requires us to recover all cached state, so
> > > > it must
> > > > reclaim both OPEN and LOCK state. It is not, however, expected to
> > > > depend on the open context list ordering, since there can be no
> > > > further
> > > > caching.
> > > > IOW: no, I don't see why your bug would depend on the list order
> > > > unless
> > > > some part of the recovery is actually failing.
> > >
> > > Ok thanks. Need to fix the lack of OPEN reclaim.
> >
> > Wait, why are we suppose to reclaim the open state when we have a
> > valid open stateid? We don't have any cached opens that server
> > doesn't
> > know about. RFC7530 says "if the file has other open reference", I
> > think the emphasis is on "other". I don't believe we need to be
> > sending anything besides the locks to the server. Then I'm back to
> > square one.
>
> Holding a delegation does not imply that we hold an open stateid. Under
> Linux, the open stateid gets closed as soon as the application closes
> the file.
>
> The delegation, on the other hand, is retained until either it is
> recalled, or we see that the file has not been used for 2 lease
> periods.

Ok I agree with all of it but I'm saying it doesn't need to be
reclaimed unconditionally or are you saying that's what the linux
client does? In this test case, the file hasn't been closed or
expired. I'm stating that the client has a valid open stateid and
should only be required to reclaim the locks (which with this patch it
does).

>
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
