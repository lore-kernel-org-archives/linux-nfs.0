Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50931 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282Ab2FKPKy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 11:10:54 -0400
Received: by bkcji2 with SMTP id ji2so3627731bkc.19
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jun 2012 08:10:52 -0700 (PDT)
Message-ID: <4FD60A78.8060604@tonian.com>
Date: Mon, 11 Jun 2012 18:10:48 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] Something very wrong with layout_recall of RETURN_FILE
References: <4FC6B29C.3030803@panasas.com>
In-Reply-To: <4FC6B29C.3030803@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-31 02:51, Boaz Harrosh wrote:
> 
> In patch:
> 	pnfsd: layout recall layout state
> 
> the cl_has_file_layout() is no longer inspecting the layout structures added per file
> but is inspecting if file has layout_state.
> 
> So it is counting layout_states and not layouts
> 
> This is bad because the addition of the layout_states on the file is done before the
> call to the filesystem so if the FS does a recall, the nfsd is confused thinking
> it already has a layout and issues a recall. Instead of returning -ENOENT, ie list
> is empty. The client then truly returns nomaching_layout and when the lo_return(s) are
> emulated the system gets stuck is some reference miss-match. (UML so no crash trace)

This should be fixed regardless so that exofs is more tolerant to "phantom"
layout returns.

> 
> Now lets say that the state should be set before the call to the FS. Then I don't
> see where the state is removed in the case of an ERROR return from FS->layout_get.
> Meaning cl_has_file_layout() will always think it has some count.

This is a bug and there is actually no reason to insert the layout state
before the call to layout_get.

> 
> Also When a layout is returned it is the layout list that is inspected and freed,
> so how is the cl_has_file_layout() emptied ?

Not sure I understand your question but the layout state is unhashed
in destroy_layout_state

> 
> In any way. I do not agree that it is the state that is needed to be searched
> in cl_has_file_layout() but it is layouts that are needed, otherwise the all
> layout <---> recall very delicate dance is totally broken.
> 
> What was the meaning of the Poet?

This wasn't the original intent for cl_has_file_layout.

I agree the requirement changed when we added the cookie magic
and the reliance of exofs on the layout recall process to be
precise about detecting the no layout case.  So on one hand
the process needs to be more robust and on the other we can
lookup the exact region as you suggest below.

Then, we should be able to get rid of the layout states list altogether.
(practically reverting "pnfsd: layout recall layout state")

Benny

> 
> I reverted the cl_has_file_layout() to historical processing and am debugging
> Will probably now get the state processing wrong.
> 
> Also cl_has_file_layout() returns true for any layout on a file, but we must
> inspect IO_MODE and LSEG for a partial-match, as well.
> 
> The below works for me. State also looks good
> (lightly tested, bug above is fixed, Have not tried multiple clients shared
>  same-stripe writes)
> 
> Thanks
> Boaz
> 
> ------
> git diff --stat -p -M fs/nfsd/nfs4pnfsd.c
>  fs/nfsd/nfs4pnfsd.c | 29 ++++++++++++++++-------------
>  1 file changed, 16 insertions(+), 13 deletions(-)
> ------
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index f90f3a7..b421437 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -1179,24 +1179,27 @@ out:
>  }
>  
>  static bool
> -cl_has_file_layout(struct nfs4_client *clp, struct nfs4_file *fp, stateid_t *lsid)
> +cl_has_file_layout(struct nfs4_client *clp, struct nfs4_file *fp,
> +		   stateid_t *lsid, struct nfsd4_pnfs_cb_layout *cbl)
>  {
> -	struct nfs4_layout_state *ls;
> +	struct nfs4_layout *lo;
> +	bool ret = false;
>  
>  	spin_lock(&layout_lock);
> -	list_for_each_entry (ls, &fp->fi_layout_states, ls_perfile)
> -		if (same_clid(&ls->ls_stid.sc_stateid.si_opaque.so_clid,
> -			      &clp->cl_clientid)) {
> +	list_for_each_entry (lo, &fp->fi_layouts, lo_perfile) {
> +		if (same_clid(&lo->lo_client->cl_clientid, &clp->cl_clientid) &&
> +		    lo_seg_overlapping(&cbl->cbl_seg, &lo->lo_seg) &&
> +		    (cbl->cbl_seg.iomode & lo->lo_seg.iomode))
>  			goto found;
> -		}
> -	spin_unlock(&layout_lock);
> -	return false;
> -
> +	}
> +	goto unlock;
>  found:
> -	update_layout_stateid_locked(ls, lsid);
> +	/* Im going to send a recall on this latout update state */
> +	update_layout_stateid_locked(lo->lo_state, lsid);
> +	ret = true;
> +unlock:
>  	spin_unlock(&layout_lock);
> -
> -	return true;
> +	return ret;
>  }
>  
>  static int
> @@ -1228,7 +1231,7 @@ cl_has_layout(struct nfs4_client *clp, struct nfsd4_pnfs_cb_layout *cbl,
>  {
>  	switch (cbl->cbl_recall_type) {
>  	case RETURN_FILE:
> -		return cl_has_file_layout(clp, lrfile, lsid);
> +		return cl_has_file_layout(clp, lrfile, lsid, cbl);
>  	case RETURN_FSID:
>  		return cl_has_fsid_layout(clp, &cbl->cbl_fsid);
>  	default:
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
