Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f172.google.com ([209.85.220.172]:45104 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbACVUr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jan 2015 16:20:47 -0500
Received: by mail-vc0-f172.google.com with SMTP id hq11so7624695vcb.31
        for <linux-nfs@vger.kernel.org>; Sat, 03 Jan 2015 13:20:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150103193753.3418.77888.stgit@manet.1015granger.net>
References: <20150103193753.3418.77888.stgit@manet.1015granger.net>
Date: Sat, 3 Jan 2015 16:20:46 -0500
Message-ID: <CAHQdGtSVgdkDVJcraHRnsmmubLuP=RUjtyV2Zbihva5qf+z+yw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Ignore transport protocol when detecting server trunking
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 3, 2015 at 2:45 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Detect server trunking across transport protocols. Otherwise, an
> RDMA mount and a TCP mount of the same server will end up with
> separate nfs_clients using the same clientid4.
>
> Reported-by: Dai Ngo <dai.ngo@oracle.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Re: yesterday's discussion of "[PATCH] NFSv4.1: Fix client id
> trunking on Linux". This patch seems to address the behavior I
> mentioned.
>
>  fs/nfs/nfs4client.c |    6 ------
>  1 file changed, 6 deletions(-)
>
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index c0fe338..c7bc38e 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -540,9 +540,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
>                 if (pos->rpc_ops != new->rpc_ops)
>                         continue;
>
> -               if (pos->cl_proto != new->cl_proto)
> -                       continue;
> -
>                 if (pos->cl_minorversion != new->cl_minorversion)
>                         continue;
>
> @@ -675,9 +672,6 @@ int nfs41_walk_client_list(struct nfs_client *new,
>                 if (pos->rpc_ops != new->rpc_ops)
>                         continue;
>
> -               if (pos->cl_proto != new->cl_proto)
> -                       continue;
> -
>                 if (pos->cl_minorversion != new->cl_minorversion)
>                         continue;
>
>

Yep. Sorry, I only noticed this after I'd written my own version. I'll
replace mine with this one.


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
