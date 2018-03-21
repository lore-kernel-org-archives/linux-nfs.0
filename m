Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46364 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753570AbeCUVfF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Mar 2018 17:35:05 -0400
Date: Wed, 21 Mar 2018 17:35:05 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        kernel@pengutronix.de, patchwork-lst@pengutronix.de,
        agruenba@redhat.com
Subject: Re: [PATCH] nfsd: zero out umask if the client didn't provide one
Message-ID: <20180321213505.GI4288@fieldses.org>
References: <20180321195242.4250-1-l.stach@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180321195242.4250-1-l.stach@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 21, 2018 at 08:52:42PM +0100, Lucas Stach wrote:
> When the server is serving a mixed set of clients where some support the
> NFS 4.2 umask attribute and some don't, we need to make sure to reset the
> nfd thread umask to 0 when serving a client that isn't providing the umask,
> otherwise a stale umask from a previous request will be applied.
> 
> This was only done in the nfsd4_decode_open() callsite, but not in
> nfsd4_decode_create() leading to newly created directories ending up with
> wrong permissions in some cases. To avoid any such inconsistency in the
> future, reset the umask in nfsd4_decode_fattr() where we know if the
> client did provide a umask.

Thanks for catching this!  (Is it because you were seeing directories
created with incorrect permissions in production?)

If the next rpc handled by this thread doesn't include a file attribute,
or isn't an NFSv4 request (maybe it's NFSv3), then it won't hit this
code and will still use the non-zero umask.

I was thinking of initializing it in nfsd_setuser, or maybe on each pass
through the loop that processes each op of a compound in
nfsd4_proc_compound....  But I think that would clear umask too
often--it'd clear the umask before it was actually used.

Actually I don't think there's any correct time to clear the umask, the
problem is where we're setting it.

We decode the whole compound in one pass, then process each op of an
NFSv4 compound.  That means the last op containing a set of the umask
will determine the umask used for the whole compound.  That seems wrong.

I mean, in practice no real client sends compounds with multiple create
operations, so maybe this is all academic, but still I think the correct
thing to do is stop setting current->fs->umask in the xdr decoder and
instead pass the umask value in the compound op arguments and set it
later in the proc code.

--b.

> 
> Fixes: 47057abde515 (nfsd: add support for the umask attribute)
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
>  fs/nfsd/nfs4xdr.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index e502fd16246b..1eb33b34c51b 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -486,6 +486,8 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		dummy32 = be32_to_cpup(p++);
>  		*umask = dummy32 & S_IRWXUGO;
>  		iattr->ia_valid |= ATTR_MODE;
> +	} else if (umask) {
> +		*umask = 0;
>  	}
>  	if (len != expected_len)
>  		goto xdr_error;
> @@ -927,7 +929,6 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
>  	case NFS4_OPEN_NOCREATE:
>  		break;
>  	case NFS4_OPEN_CREATE:
> -		current->fs->umask = 0;
>  		READ_BUF(4);
>  		open->op_createmode = be32_to_cpup(p++);
>  		switch (open->op_createmode) {
> -- 
> 2.16.1
