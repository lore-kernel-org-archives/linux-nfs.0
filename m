Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:34712 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbcADPOT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 10:14:19 -0500
Received: by mail-qg0-f51.google.com with SMTP id 6so177616796qgy.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 07:14:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1451325918-33544-6-git-send-email-trond.myklebust@primarydata.com>
References: <1451325918-33544-1-git-send-email-trond.myklebust@primarydata.com>
 <1451325918-33544-2-git-send-email-trond.myklebust@primarydata.com>
 <1451325918-33544-3-git-send-email-trond.myklebust@primarydata.com>
 <1451325918-33544-4-git-send-email-trond.myklebust@primarydata.com>
 <1451325918-33544-5-git-send-email-trond.myklebust@primarydata.com> <1451325918-33544-6-git-send-email-trond.myklebust@primarydata.com>
From: Peng Tao <bergwolf@primarydata.com>
Date: Mon, 4 Jan 2016 23:13:59 +0800
Message-ID: <CAKVebiUoY1a9_fkyC1TTZegYXMEbigYL-Ww0HWJBowC1w78LXQ@mail.gmail.com>
Subject: Re: [PATCH v2 6/6] NFSv4.1/pNFS: Don't return NFS4ERR_DELAY
 unnecessarily in CB_LAYOUTRECALL
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 29, 2015 at 2:05 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> If the client is promising to return the layout ASAP, then there is no
> need to return DELAY and have the server retry. Instead default to the
> normal procedure described in RFC5661.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/callback_proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 1b24ad07d4f5..724a9b756ab0 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -214,7 +214,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>                 pnfs_mark_matching_lsegs_return(lo,
>                                 &free_me_list,
>                                 &args->cbl_range);
> -               rv = NFS4ERR_DELAY;
> +               rv = NFS4_OK;
It is possible that we've cleared all outstanding layout segments of
the file and returns NFS4_OK to CB_LAYOUTRECALL. Then server would be
expecting LAYOUTRETURN while client will not send one. IMO we'd better
re-check list_empty(&lo->plh_segs) to decide what to return here.

Cheers,
Tao
