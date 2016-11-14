Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:48869 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932297AbcKNUpO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Nov 2016 15:45:14 -0500
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: Re: [PATCH 1/5] NFSv4: Don't check file access when reclaiming state
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>
References: <1478814070-17140-1-git-send-email-trond.myklebust@primarydata.com>
 <1478814070-17140-2-git-send-email-trond.myklebust@primarydata.com>
Message-ID: <2db857a6-a5eb-9b62-93fa-4c4ad81f35e7@Netapp.com>
Date: Mon, 14 Nov 2016 15:44:59 -0500
MIME-Version: 1.0
In-Reply-To: <1478814070-17140-2-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 11/10/2016 04:41 PM, Trond Myklebust wrote:
> If we're reclaiming state after a reboot, or as part of returning a
> delegation, we don't need to check access modes again.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs4proc.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 6a1d650e0419..4eead738da8e 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1221,6 +1221,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
>  	atomic_inc(&sp->so_count);
>  	p->o_arg.open_flags = flags;
>  	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
> +	p->o_arg.claim = nfs4_map_atomic_open_claim(server, claim);
>  	p->o_arg.share_access = nfs4_map_atomic_open_share(server,
>  			fmode, flags);
>  	/* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
> @@ -1228,8 +1229,14 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
>  	if (!(flags & O_EXCL)) {
>  		/* ask server to check for all possible rights as results
>  		 * are cached */
> -		p->o_arg.access = NFS4_ACCESS_READ | NFS4_ACCESS_MODIFY |
> -				  NFS4_ACCESS_EXTEND | NFS4_ACCESS_EXECUTE;
> +		switch (p->o_arg.claim) {
> +		case NFS4_OPEN_CLAIM_NULL:
> +		case NFS4_OPEN_CLAIM_FH:
> +			p->o_arg.access = NFS4_ACCESS_READ |
> +				NFS4_ACCESS_MODIFY |
> +				NFS4_ACCESS_EXTEND |
> +				NFS4_ACCESS_EXECUTE;
> +		}

This adds these warnings when I compile:

fs/nfs/nfs4proc.c: In function 'nfs4_opendata_alloc':
fs/nfs/nfs4proc.c:1232:3: error: enumeration value 'NFS4_OPEN_CLAIM_PREVIOUS' not handled in switch [-Werror=switch]
   switch (p->o_arg.claim) {
   ^~~~~~
fs/nfs/nfs4proc.c:1232:3: error: enumeration value 'NFS4_OPEN_CLAIM_DELEGATE_CUR' not handled in switch [-Werror=switch]
fs/nfs/nfs4proc.c:1232:3: error: enumeration value 'NFS4_OPEN_CLAIM_DELEGATE_PREV' not handled in switch [-Werror=switch]
fs/nfs/nfs4proc.c:1232:3: error: enumeration value 'NFS4_OPEN_CLAIM_DELEG_CUR_FH' not handled in switch [-Werror=switch]
fs/nfs/nfs4proc.c:1232:3: error: enumeration value 'NFS4_OPEN_CLAIM_DELEG_PREV_FH' not handled in switch [-Werror=switch]

Thanks,
Anna


>  	}
>  	p->o_arg.clientid = server->nfs_client->cl_clientid;
>  	p->o_arg.id.create_time = ktime_to_ns(sp->so_seqid.create_time);
> @@ -1239,7 +1246,6 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
>  	p->o_arg.bitmask = nfs4_bitmask(server, label);
>  	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
>  	p->o_arg.label = nfs4_label_copy(p->a_label, label);
> -	p->o_arg.claim = nfs4_map_atomic_open_claim(server, claim);
>  	switch (p->o_arg.claim) {
>  	case NFS4_OPEN_CLAIM_NULL:
>  	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
> 

