Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:34365 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbHRVHr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2015 17:07:47 -0400
Received: by obbfr1 with SMTP id fr1so151827488obb.1
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2015 14:07:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFki0cgkUGj-_+9vTdpv0oWnLPjFLOVQ_AB-h_AfBwkwg@mail.gmail.com>
References: <CAHQdGtTqO02BWwTOsXn2s641_KBdawBexG5+kGwmJKWaAmewtA@mail.gmail.com>
	<1419021845-96747-1-git-send-email-trond.myklebust@primarydata.com>
	<1419021845-96747-2-git-send-email-trond.myklebust@primarydata.com>
	<CAN-5tyFki0cgkUGj-_+9vTdpv0oWnLPjFLOVQ_AB-h_AfBwkwg@mail.gmail.com>
Date: Tue, 18 Aug 2015 14:07:46 -0700
Message-ID: <CAHQdGtS3d6+sqgGQpY822hc4AZM+zzihc=CGb43ihfDC6Bh1Qw@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] NFSv4: Remove incorrect check in can_open_delegated()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 18, 2015 at 1:38 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>
> This is the patch that breaks recovery of opens upon server reboot.
>
> I have a test that open a file and gets a write delegation and tried
> to do a write. At this point, I reboot my server so that write fails
> with bad_session and then stale_clientid. Upon completing the
> exchange_id, create_session, and putrootfh, the client no longer sends
> the open to be recovered and instead resends the failed write. It
> would use all 0s stateid (this is 4.1) for the write and for the close
> that follows it.

Why is the client not attempting to recover the open? That's a bug,
whether or not this patch is correct.

> On Fri, Dec 19, 2014 at 3:44 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> > Remove an incorrect check for NFS_DELEGATION_NEED_RECLAIM in
> > can_open_delegated(). We are allowed to cache opens even in
> > a situation where we're doing reboot recovery.
> >
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfs/nfs4proc.c | 2 --
> >  1 file changed, 2 deletions(-)
> >
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 8514b59a8c30..002c7dfedb08 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -1119,8 +1119,6 @@ static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
> >                 return 0;
> >         if ((delegation->type & fmode) != fmode)
> >                 return 0;
> > -       if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
> > -               return 0;
> >         if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
> >                 return 0;
> >         nfs_mark_delegation_referenced(delegation);
> > --
> > 2.1.0
> >
