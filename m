Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:49097 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761044Ab2D0S5F convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 14:57:05 -0400
Received: by vbbff1 with SMTP id ff1so784629vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 27 Apr 2012 11:57:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335552105-27597-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1335552105-27597-1-git-send-email-Trond.Myklebust@netapp.com>
Date: Fri, 27 Apr 2012 14:57:04 -0400
Message-ID: <CADnza47YPMhRV0KPTcDfrHEqQdRQNoNXu1CMb0pujujbBXnBGA@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix a use-before-initialised warning in
 fs/nfs/write.c and fs/nfs/pnfs.c
From: Fred Isaman <iisaman@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACK

Fred


On Fri, Apr 27, 2012 at 2:41 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> If the allocation of nfs_write_header fails, the list of nfs_pages that
> needs to be cleaned up is still on desc->pg_list...
>
> Reported-by: Bryan Schumaker <bjschuma@netapp.com>
> Cc: Fred Isaman <iisaman@netapp.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/pnfs.c  |    2 +-
>  fs/nfs/write.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 4da05e4..39cbac5 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1308,7 +1308,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>
>        whdr = nfs_writehdr_alloc();
>        if (!whdr) {
> -               desc->pg_completion_ops->error_cleanup(&hdr->pages);
> +               desc->pg_completion_ops->error_cleanup(&desc->pg_list);
>                put_lseg(desc->pg_lseg);
>                desc->pg_lseg = NULL;
>                return -ENOMEM;
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index fec214b..3636191 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1164,7 +1164,7 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
>
>        whdr = nfs_writehdr_alloc();
>        if (!whdr) {
> -               desc->pg_completion_ops->error_cleanup(&hdr->pages);
> +               desc->pg_completion_ops->error_cleanup(&desc->pg_list);
>                return -ENOMEM;
>        }
>        hdr = &whdr->header;
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
