Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34921 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933653AbbDIJmW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2015 05:42:22 -0400
Received: by qkhg7 with SMTP id g7so117596296qkh.2
        for <linux-nfs@vger.kernel.org>; Thu, 09 Apr 2015 02:42:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1428495850-7136-1-git-send-email-tao.peng@primarydata.com>
References: <1428495850-7136-1-git-send-email-tao.peng@primarydata.com>
From: Peng Tao <tao.peng@primarydata.com>
Date: Thu, 9 Apr 2015 17:42:01 +0800
Message-ID: <CAKVebiU57DG0G0cY8+xKbHC+Bbopdp+QAu53U_wQnzrAO+F_VQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: fix DIO good bytes calculation
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>, stable@vger.kernel.org,
        Jean Spector <jean@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 8, 2015 at 8:24 PM, Peng Tao <tao.peng@primarydata.com> wrote:
> When adding completed bytes, we should just use hdr->good_bytes.
> Otherwise if we send multiple requests for one direct IO (due to
> rsize/wsize limitation), we'll count completed bytes incorrectly.
>
> This fixes 5fadeb47("nfs: count DIO good bytes correctly with mirroring").
>
> Reported-by: Jean Spector <jean@primarydata.com>
> Cc: <stable@vger.kernel.org> # v3.19+
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/direct.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index e907c8c..645109e 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -132,10 +132,8 @@ nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
>         WARN_ON_ONCE(hdr->pgio_mirror_idx >= dreq->mirror_count);
>
>         count = dreq->mirrors[hdr->pgio_mirror_idx].count;
> -       if (count + dreq->io_start < hdr->io_start + hdr->good_bytes) {
> -               count = hdr->io_start + hdr->good_bytes - dreq->io_start;
> -               dreq->mirrors[hdr->pgio_mirror_idx].count = count;
> -       }
> +       if (count + dreq->io_start < hdr->io_start + hdr->good_bytes)
> +               dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
oh, speaking too soon. This would actually fail concurrent DIO writers
if split requests complete randomly. Please don't merge it! I'll send
a updated version. sorry for the noise!

Thanks,
Tao
