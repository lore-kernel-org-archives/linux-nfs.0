Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:30631 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750816AbeAQCz4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jan 2018 21:55:56 -0500
From: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: nfsd: return RESOURCE not GARBAGE_ARGS on too many ops
Message-ID: <717a096b-96d6-87d2-9b7f-54bdd182e220@cn.fujitsu.com>
Date: Wed, 17 Jan 2018 10:55:52 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce

Would you consider the patch for merging ?

> commit fd9a5e1c4952
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Wed Nov 15 12:30:27 2017 -0500
> 
>     nfsd: return RESOURCE not GARBAGE_ARGS on too many ops
>     
>     A client that sends more than a hundred ops in a single compound
>     currently gets an rpc-level GARBAGE_ARGS error.
>     
>     It would be more helpful to return NFS4ERR_RESOURCE, since that gives
>     the client a better idea how to recover (for example by splitting up the
>     compound into smaller compounds).
>     
>     This is all a bit academic since we've never actually seen a reason for
>     clients to send such long compounds, but we may as well fix it.
>     
>     While we're there, just use NFSD4_MAX_OPS_PER_COMPOUND == 16, the
>     constant we already use in the 4.1 case, instead of hard-coding 100.
>     Chances anyone actually uses even 16 ops per compound are small enough
>     that I think there's a neglible risk or any regression.
>     
>     This fixes pynfs test COMP6.
>     
>     Reported-by: sunlianwen <sunlw.fnst@cn.fujitsu.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 008ea0b627d0..c9669d75c157 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1703,6 +1703,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
>          status = nfserr_minor_vers_mismatch;
>          if (nfsd_minorversion(args->minorversion, NFSD_TEST) <= 0)
>                  goto out;
> +       status = nfserr_resource;
> +       if (resp->opcnt > NFSD_MAX_OPS_PER_COMPOUND)
> +               goto out;
>  
>          status = nfs41_check_op_ordering(args);
>          if (status) {
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 2c61c6b8ae09..5dcd7cb45b2d 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1918,8 +1918,13 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  
>          if (argp->taglen > NFSD4_MAX_TAGLEN)
>                  goto xdr_error;
> -       if (argp->opcnt > 100)
> -               goto xdr_error;
> +       /*
> +        * NFS4ERR_RESOURCE is a more helpful error than GARBAGE_ARGS
> +        * here, so we return success at the xdr level so that
> +        * nfsd4_proc can handle this is an NFS-level error.
> +        */
> +       if (argp->opcnt > NFSD_MAX_OPS_PER_COMPOUND)
> +               return 0;
>  
>          if (argp->opcnt > ARRAY_SIZE(argp->iops)) {
>                  argp->ops = kzalloc(argp->opcnt * sizeof(*argp->ops), GFP_KERNEL);
> 
> 
> .

--
Lu Xinyu
--


