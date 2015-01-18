Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:54410 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbbAROnd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Jan 2015 09:43:33 -0500
Received: by mail-vc0-f173.google.com with SMTP id kv19so8922044vcb.4
        for <linux-nfs@vger.kernel.org>; Sun, 18 Jan 2015 06:43:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1421584142-12505-1-git-send-email-junxiao.bi@oracle.com>
References: <1421584142-12505-1-git-send-email-junxiao.bi@oracle.com>
Date: Sun, 18 Jan 2015 09:43:32 -0500
Message-ID: <CAHQdGtTs6B93fi4TAL86f02cD7OE5zzWgk8tCa6ZOyKQ9Bd7Eg@mail.gmail.com>
Subject: Re: [PATCH] nfsd: fix memory corruption due to uninitialized variable
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 18, 2015 at 7:29 AM, Junxiao Bi <junxiao.bi@oracle.com> wrote:
>
> nfsd4_decode_open() doesn't initialize variable open->op_file and
> open->op_stp, they are initialized in nfsd4_process_open1(), but if
> any error happens before initializing them, nfsd4_open() will call
> into nfsd4_cleanup_open_state() and corrupt the memory.
>
> Since nfsd4_process_open1() will initialize these two variables and
> open->op_openowner, make them default to null at the beginning.
>
> Signed-off-by: Junxiao Bi <junxiao.bi@oracle.com>
> ---
>  fs/nfsd/nfs4state.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c06a1ba..6e74a91 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3547,6 +3547,10 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
>         struct nfs4_openowner *oo = NULL;
>         __be32 status;
>
> +       open->op_file = NULL;
> +       open->op_openowner = NULL;
> +       open->op_stp = NULL;
> +
>         if (STALE_CLIENTID(&open->op_clientid, nn))
>                 return nfserr_stale_clientid;
>         /*

Have you ever seen an instance of this corruption? I would have
thought that the kzalloc() in nfsd4_decode_compound() and/or the
earlier memset() in svc_process_common() would ensure that these
fields are always initialised to NULL.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
