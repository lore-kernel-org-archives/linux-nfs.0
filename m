Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35291 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdAQOeI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2017 09:34:08 -0500
Received: by mail-it0-f67.google.com with SMTP id 203so15705695ith.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2017 06:34:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1459541983-21301-1-git-send-email-kolga@netapp.com>
References: <1459541983-21301-1-git-send-email-kolga@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 17 Jan 2017 09:33:59 -0500
Message-ID: <CAN-5tyG6-TPbBxmMYpLPv6_duwAYRm1V_QtRSWepT6un5EtNAg@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFSv3: Ignore wcc before ctime attribute
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I'd like bring up this issue again as I was asked again that linux
nfsv3 client experiences poor performance when it receives
out-of-order write rpcs. If a general change to ignore "before" ctime
is not acceptable, what about something that is configurable via a
sysctl perhaps?

On Fri, Apr 1, 2016 at 4:19 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> Commit 7c2dad99d60c86ec686b3bfdcb787c450a7ea89f
> "Don't let the ctime override attribute barriers" introduced a problem
> of invalidating the cache when receiving in-order WRITE replies. Because
> ctime is no longer checked then attributes are not updated appropriately
> and then leads to mismatch of received "before" with what's stored.
>
> Given that sending the wcc attributes is not mandatory (and linux
> server doesn't), we can ignore the received "before" ctime. It fixes
> the current problem and also help when we receive out-of-order WRITEs.
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs3xdr.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index 267126d..feca07f 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -732,14 +732,12 @@ static int decode_wcc_attr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
>                 goto out_overflow;
>
>         fattr->valid |= NFS_ATTR_FATTR_PRESIZE
> -               | NFS_ATTR_FATTR_PRECHANGE
>                 | NFS_ATTR_FATTR_PREMTIME
>                 | NFS_ATTR_FATTR_PRECTIME;
>
>         p = xdr_decode_size3(p, &fattr->pre_size);
>         p = xdr_decode_nfstime3(p, &fattr->pre_mtime);
>         xdr_decode_nfstime3(p, &fattr->pre_ctime);
> -       fattr->pre_change_attr = nfs_timespec_to_change_attr(&fattr->pre_ctime);
>
>         return 0;
>  out_overflow:
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
