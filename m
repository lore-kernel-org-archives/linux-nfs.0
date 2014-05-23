Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:34139 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbaEWNzE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 09:55:04 -0400
Received: by mail-vc0-f182.google.com with SMTP id la4so6289505vcb.13
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 06:55:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1400851379-34474-1-git-send-email-andros@netapp.com>
References: <1400851379-34474-1-git-send-email-andros@netapp.com>
Date: Fri, 23 May 2014 09:55:03 -0400
Message-ID: <CAHQdGtR8A=O75V-oQnU8w9iTeFFrTMuFCTJgC_uGn6iZmOjeKA@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv4: Use error handler on failed GETATTR with
 successful OPEN
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Adamson William Andros <andros@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 23, 2014 at 9:22 AM,  <andros@netapp.com> wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Place the call to resend the failed GETATTR under the error handler so that
> when appropriate, the GETATTR is retried more than once.
>
> The server can fail the GETATTR op in the OPEN compound with a recoverable
> error such as NFS4ERR_DELAY. In the case of an O_EXCL open, the server has
> created the file, so a retrans of the OPEN call will fail with NFS4ERR_EXIST.
>

Why would the client retransmit the open in this case? We don't use
the return value from the getattr call, so the callers of
_nfs4_proc_open() will never see the NFS4ERR_DELAY.


> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 397be39..be1b305 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2027,7 +2027,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
>                         return status;
>         }
>         if (!(o_res->f_attr->valid & NFS_ATTR_FATTR))
> -               _nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
> +               nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
>         return 0;
>  }
>
> --
> 1.8.3.1
>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
