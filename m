Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34942 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbHRUiN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2015 16:38:13 -0400
Received: by igbjg10 with SMTP id jg10so90026074igb.0
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2015 13:38:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1419021845-96747-2-git-send-email-trond.myklebust@primarydata.com>
References: <CAHQdGtTqO02BWwTOsXn2s641_KBdawBexG5+kGwmJKWaAmewtA@mail.gmail.com>
	<1419021845-96747-1-git-send-email-trond.myklebust@primarydata.com>
	<1419021845-96747-2-git-send-email-trond.myklebust@primarydata.com>
Date: Tue, 18 Aug 2015 16:38:13 -0400
Message-ID: <CAN-5tyFki0cgkUGj-_+9vTdpv0oWnLPjFLOVQ_AB-h_AfBwkwg@mail.gmail.com>
Subject: Re: [PATCH v3 2/2] NFSv4: Remove incorrect check in can_open_delegated()
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the patch that breaks recovery of opens upon server reboot.

I have a test that open a file and gets a write delegation and tried
to do a write. At this point, I reboot my server so that write fails
with bad_session and then stale_clientid. Upon completing the
exchange_id, create_session, and putrootfh, the client no longer sends
the open to be recovered and instead resends the failed write. It
would use all 0s stateid (this is 4.1) for the write and for the close
that follows it.

Reverting the patch fixes the problem.

On Fri, Dec 19, 2014 at 3:44 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> Remove an incorrect check for NFS_DELEGATION_NEED_RECLAIM in
> can_open_delegated(). We are allowed to cache opens even in
> a situation where we're doing reboot recovery.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8514b59a8c30..002c7dfedb08 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1119,8 +1119,6 @@ static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
>                 return 0;
>         if ((delegation->type & fmode) != fmode)
>                 return 0;
> -       if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
> -               return 0;
>         if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
>                 return 0;
>         nfs_mark_delegation_referenced(delegation);
> --
> 2.1.0
>
