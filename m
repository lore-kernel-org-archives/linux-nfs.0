From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/4] nfsd: Minor cleanup of find_stateid
Date: Mon, 20 Oct 2008 16:26:32 -0400
Message-ID: <20081020202632.GA27702@fieldses.org>
References: <20081020061428.17722.68145.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41555 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036AbYJTU0j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 16:26:39 -0400
In-Reply-To: <20081020061428.17722.68145.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 20, 2008 at 11:44:28AM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Minor cleanup/rewrite of find_stateid. Compile tested.

Thanks, applied.--b.

> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  fs/nfsd/nfs4state.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff -ruNp linux-2.6.27.org/fs/nfsd/nfs4state.c linux-2.6.27.new/fs/nfsd/nfs4state.c
> --- linux-2.6.27.org/fs/nfsd/nfs4state.c	2008-10-20 10:47:23.000000000 +0530
> +++ linux-2.6.27.new/fs/nfsd/nfs4state.c	2008-10-20 10:48:29.000000000 +0530
> @@ -2421,13 +2421,13 @@ static struct list_head lockstateid_hash
>  static struct nfs4_stateid *
>  find_stateid(stateid_t *stid, int flags)
>  {
> -	struct nfs4_stateid *local = NULL;
> +	struct nfs4_stateid *local;
>  	u32 st_id = stid->si_stateownerid;
>  	u32 f_id = stid->si_fileid;
>  	unsigned int hashval;
>  
>  	dprintk("NFSD: find_stateid flags 0x%x\n",flags);
> -	if ((flags & LOCK_STATE) || (flags & RD_STATE) || (flags & WR_STATE)) {
> +	if (flags & (LOCK_STATE | RD_STATE | WR_STATE)) {
>  		hashval = stateid_hashval(st_id, f_id);
>  		list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
>  			if ((local->st_stateid.si_stateownerid == st_id) &&
> @@ -2435,7 +2435,8 @@ find_stateid(stateid_t *stid, int flags)
>  				return local;
>  		}
>  	} 
> -	if ((flags & OPEN_STATE) || (flags & RD_STATE) || (flags & WR_STATE)) {
> +
> +	if (flags & (OPEN_STATE | RD_STATE | WR_STATE)) {
>  		hashval = stateid_hashval(st_id, f_id);
>  		list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
>  			if ((local->st_stateid.si_stateownerid == st_id) &&
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
