Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54110 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751465AbeAZVhO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 Jan 2018 16:37:14 -0500
Date: Fri, 26 Jan 2018 16:37:14 -0500
To: Olga Kornievskaia <kolga@netapp.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v6 07/10] NFSD create new stateid for async copy
Message-ID: <20180126213714.GB7770@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com>
 <20171024174752.74910-8-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171024174752.74910-8-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 24, 2017 at 01:47:49PM -0400, Olga Kornievskaia wrote:
> +/*
> + * Create a unique stateid_t to represent each COPY. Hang the copy
> + * stateids off the OPEN/LOCK/DELEG stateid from the client open
> + * the source file.
> + */
> +struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn,
> +					       struct nfs4_stid *p_stid)
> +{
> +	struct nfs4_cp_state *cps;
> +	int new_id;
> +
> +	cps = kzalloc(sizeof(struct nfs4_cp_state), GFP_KERNEL);
> +	if (!cps)
> +		return NULL;
> +	idr_preload(GFP_KERNEL);
> +	spin_lock(&nn->s2s_cp_lock);
> +	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, cps, 0, 0, GFP_NOWAIT);
> +	spin_unlock(&nn->s2s_cp_lock);
> +	idr_preload_end();
> +	if (new_id < 0)
> +		goto out_free;
> +	cps->cp_stateid.si_opaque.so_id = new_id;
> +	cps->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
> +	cps->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
> +	cps->cp_p_stid = p_stid;
> +	INIT_LIST_HEAD(&cps->cp_list);

The INIT_LIST_HEAD is redundant here, it'll just be overridden by the
list_add below.

> +	list_add(&cps->cp_list, &p_stid->sc_cp_list);

p_stid is a preexisting stateid that's visible to other nfsd threads
too, right?  So in theory another COPY using the same parent stateid
could be running concurrently with this one?

Maybe you could just use p_stid->sc_lock  for this.

Ditto for any other manipulations of that list.

--b.
