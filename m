Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.windriver.com ([147.11.146.13]:44980 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760965Ab2COPw7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Mar 2012 11:52:59 -0400
Message-ID: <4F621059.7040106@windriver.com>
Date: Thu, 15 Mar 2012 11:52:57 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS related randconfig failure on powerpc ('nfs_debug' undeclared)
References: <CAP=VYLoNpAU7YAvy+3KrqpBErbJtE9i4_3uCyv-QaMgHiD6evw@mail.gmail.com> <1331778292.9623.22.camel@lade.trondhjem.org>
In-Reply-To: <1331778292.9623.22.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12-03-14 10:24 PM, Myklebust, Trond wrote:
> On Wed, 2012-03-14 at 19:25 -0400, Paul Gortmaker wrote:
>> Just a heads up that linux-next builds found this;
>>
>> fs/nfs/nfs4xdr.c:3443:27: error: 'nfs_debug' undeclared (first use in
>> this function)
>> make[3]: *** [fs/nfs/nfs4xdr.o] Error 1
>> make[2]: *** [fs/nfs] Error 2
>> make[1]: *** [fs] Error 2
>> make: *** [sub-make] Error 2
>>
>> Full build log at:
>>
>> http://kisskb.ellerman.id.au/kisskb/buildresult/5871973/
>>
>> Paul.
> 
> Hi Paul,
> 
> Does the following fix work for you?

Yes. (compile tested, that is).

Thanks,
Paul.

> 
> Thanks!
>   Trond
> 8<------------------------------------------------------
> From 95a13f7b33be87d85d8e6652126a3f4d64d164db Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Wed, 14 Mar 2012 21:55:01 -0400
> Subject: [PATCH] NFS: Fix a compile error when !defined NFS_DEBUG
> 
> We should use the 'ifdebug' wrapper rather than trying to inline
> tests of nfs_debug, so that the code compiles correctly when we
> don't define NFS_DEBUG.
> 
> Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs4xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index f7e064d..c74fdb1 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -3440,7 +3440,7 @@ static int decode_pathname(struct xdr_stream *xdr, struct nfs4_pathname *path)
>  		status = decode_opaque_inline(xdr, &component->len, &component->data);
>  		if (unlikely(status != 0))
>  			goto out_eio;
> -		if (unlikely(nfs_debug & NFSDBG_XDR))
> +		ifdebug (XDR)
>  			pr_cont("%s%.*s ",
>  				(path->ncomponents != n ? "/ " : ""),
>  				component->len, component->data);
