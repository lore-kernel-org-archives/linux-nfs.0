Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34404 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663Ab1CNWWf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2011 18:22:35 -0400
Date: Mon, 14 Mar 2011 18:22:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: roel <roel.kluin@gmail.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] nfsd: wrong index used in inner loop
Message-ID: <20110314222229.GJ25442@fieldses.org>
References: <4D76A06A.4090405@gmail.com>
 <20110309004955.GD15814@fieldses.org>
 <4D79A183.8090306@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D79A183.8090306@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 11, 2011 at 12:13:55PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > On Tue, Mar 08, 2011 at 10:32:26PM +0100, roel wrote:
> >> Index i was already used in the outer loop
> >>
> >> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> >> ---
> >>  fs/nfsd/nfs4xdr.c |    4 ++--
> >>  1 files changed, 2 insertions(+), 2 deletions(-)
> >>
> >> Not 100% sure this one is needed but it looks suspicious.
> > 
> > Looks bad to me, thanks.
> > 
> > nfsd4_decode_create_session should probably really be broken up a little
> > bit; if it wasn't so long this would have been more obvious.
> > 
> > I'll see if I can slip this into 2.6.38 with a couple other last-minute
> > patches....  Otherwise, it'll be in 2.6.39.
> > 
> > --b.
> > 
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index 1275b86..615f0a9 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -1142,7 +1142,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
> >>  
> >>  	u32 dummy;
> >>  	char *machine_name;
> >> -	int i;
> >> +	int i, j;
> >>  	int nr_secflavs;
> >>  
> >>  	READ_BUF(16);
> >> @@ -1215,7 +1215,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
> >>  			READ_BUF(4);
> >>  			READ32(dummy);
> >>  			READ_BUF(dummy * 4);
> >> -			for (i = 0; i < dummy; ++i)
> >> +			for (j = 0; j < dummy; ++j)
> >>  				READ32(dummy);
> 
>   We must not use dummy for index here.
>   After the first index, READ32(dummy) will change dummy!!!!

Actually, wait, this is kind of silly.  I don't see why we couldn't just
skip the loop and do

	p += dummy;

Also, your new test is still failing with a BAD_XDR error.  Well, maybe
the test should fail--we don't really implement this yet anyway--but it
should at least be getting past the xdr decoding.  So something else is
still wrong.

--b.

> 
>   The following patch fix this problem.
> 
> --
> thanks,
> Mi Jinlong
> ============================================================
> 
> We must not use dummy for index.
> After the first index, READ32(dummy) will change dummy!!!!
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4xdr.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 615f0a9..8dd70d0 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1140,7 +1140,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  {
>  	DECODE_HEAD;
>  
> -	u32 dummy;
> +	u32 dummy, tmp;
>  	char *machine_name;
>  	int i, j;
>  	int nr_secflavs;
> @@ -1216,7 +1216,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
>  			READ32(dummy);
>  			READ_BUF(dummy * 4);
>  			for (j = 0; j < dummy; ++j)
> -				READ32(dummy);
> +				READ32(tmp);
>  			break;
>  		case RPC_AUTH_GSS:
>  			dprintk("RPC_AUTH_GSS callback secflavor "
> -- 
> 1.7.4.1
> 
> 
