Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:32868 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbbLZRaZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 12:30:25 -0500
Received: by mail-oi0-f53.google.com with SMTP id y66so157904201oig.0
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 09:30:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <402981449664410@web10j.yandex.ru>
References: <402981449664410@web10j.yandex.ru>
Date: Sat, 26 Dec 2015 12:30:24 -0500
Message-ID: <CAHQdGtTLu7Hz3Cgw5qT3UX2yXBM+4=mDfpLG+7K6KBvCq5Jgxg@mail.gmail.com>
Subject: Re: NFSv4: Possible buffer overflow in security label decode.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Nazarov Sergey <s-nazarov@yandex.ru>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Sergey,

On Wed, Dec 9, 2015 at 7:33 AM, Nazarov Sergey <s-nazarov@yandex.ru> wrote:
> Hi!
> Buffer overflow possible in decode_attr_security_label, if given label buffer size is not enough to
> store data received from server. This adds additional check for buffer capacity:
> ---
>  fs/nfs/nfs4xdr.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 4e44412..6a6302b 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -4157,7 +4157,9 @@ static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
>                 if (unlikely(!p))
>                         goto out_overflow;
>                 if (len < NFS4_MAXLABELLEN) {
> -                       if (label) {
> +                       if (label && label->label) {
> +                               if (len > label->len)
> +                                       return -ERANGE;
>                                 memcpy(label->label, p, len);
>                                 label->len = len;
>                                 label->pi = pi;
> @@ -4165,9 +4167,11 @@ static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
>                                 status = NFS_ATTR_FATTR_V4_SECURITY_LABEL;
>                         }
>                         bitmap[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
> -               } else
> +               } else {
>                         printk(KERN_WARNING "%s: label too long (%u)!\n",
>                                         __func__, len);
> +                       return -EIO;
> +               }
>         }
>         if (label && label->label)
>                 dprintk("%s: label=%s, len=%d, PI=%d, LFS=%d\n", __func__,
> --

Looks good, but could you please add a Signed-off-by: line as per the
instructions in Documentation/SubmittingPatches?

Thanks!
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
