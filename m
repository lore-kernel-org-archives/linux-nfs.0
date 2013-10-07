Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f181.google.com ([209.85.215.181]:55319 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293Ab3JGPDg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Oct 2013 11:03:36 -0400
Received: by mail-ea0-f181.google.com with SMTP id d10so3262321eaj.26
        for <linux-nfs@vger.kernel.org>; Mon, 07 Oct 2013 08:03:35 -0700 (PDT)
Message-ID: <5252CD43.6000101@primarydata.com>
Date: Mon, 07 Oct 2013 18:03:31 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] SQUASHME: pnfsd: nfs4_find_create_layout_stateid
References: <5251140B.4000203@primarydata.com> <1381045468-30670-1-git-send-email-bhalevy@primarydata.com> <20131006152916.GA8801@infradead.org>
In-Reply-To: <20131006152916.GA8801@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-06 18:29, Christoph Hellwig wrote:
>> + * If the layout state was found in cache, grab a reference count on it;
>> + * otherwise, allocate a new layout state if "do_alloc" is set.
> 
> There is no do_alloc parameter to the function.
> 

Yup. Silly copy+paste...

>> + *
>> + * Called with the state_lock held
>> + * Returns zero and the layout state in *lsp, or error.
>> + */
>> +static __be32
>> +nfs4_find_create_layout_stateid(struct nfs4_client *clp, struct nfs4_file *fp,
>> +				stateid_t *stateid, unsigned char typemask,
>> +				struct nfs4_layout_state **lsp)
>> +{
>> +	struct nfs4_layout_state *ls = NULL;
>> +	__be32 status = 0;
>> +	struct nfs4_stid *stid;
>> +
>> +	dprintk("--> %s clp %p fp %p operation stateid=" STATEID_FMT "\n",
>> +		__func__, clp, fp, STATEID_VAL(stateid));
>> +
>> +	nfs4_assert_state_locked();
>> +	status = nfsd4_lookup_stateid(stateid, typemask, &stid, true,
>> +				      net_generic(clp->net, nfsd_net_id));
>> +	if (status)
>> +		goto out;
>> +
>> +	/* Is this the first use of this layout ? */
>> +	if (stid->sc_type != NFS4_LAYOUT_STID) {
>> +		ls = alloc_init_layout_state(clp, fp, stateid);
>> +		if (!ls) {
>> +			status = nfserr_jukebox;
>> +			goto out;
>> +		}
>> +	} else {
>> +		ls = container_of(stid, struct nfs4_layout_state, ls_stid);
>> +
>> +		/* BAD STATEID */
>> +		if (stateid->si_generation > ls->ls_stid.sc_stateid.si_generation) {
>> +			status = nfserr_bad_stateid;
>> +			goto out;
>> +		}
>> +		get_layout_state(ls);
>> +	}
>> +	status = 0;
>> +
>> +	dprintk("%s: layout stateid=" STATEID_FMT " ref=%d\n", __func__,
>> +		STATEID_VAL(&ls->ls_stid.sc_stateid), atomic_read(&ls->ls_ref.refcount));
>> +
>> +	*lsp = ls;
>> +out:
>> +	dprintk("<-- %s status %d\n", __func__, htonl(status));
>> +
>> +	return status;
>> +}
> 
> Shouldn't there be a corresponding removal of the alloc code from
> nfs4_process_layout_stateid?

Yes, the corresponding code in nfs4_process_layout_stateid
can and should be removed.

I'll resend a new version of this patch.

Thanks!

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
