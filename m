Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80A0E4A3F17
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 21:02:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792011754; cv=none; b=t0REN7xYhYnvJIW1EQ9JNyiOBUtOJdvmEgDM5oFY6GywU0WCGt/LHvRNQ0g+H5DG9B7Ja1HE6bAn8TYs/3oi064M2oYHlwuYYHlTjq3jI9q5rFfaxyJiRj700TH1qNHY7UYbW8e/1NC8j0Co1ZlndrXDzivRSk95pzxwnJ7uhZQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792011754; c=relaxed/simple;
	bh=TvG4W/3smH1SrnK+ubkpwEwbY36jix3e0NSx7nZ3+Is=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=sJ2ZXXTCIWG6NOYLI7Cklfoi4rusQm05Fy7EsVV5YNzy+JK3U5pMugrjVxDua7qk/7lKoCSv4/RdqHDcRKm6wve7x4e8n76ttlefuPmHy4ISua2p53vfpapov+DsrVKEYX4rWn/oSA+r9We35W2VJDUwaQC9fvCAebOuhaOcoQ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Gc1SSS7b; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Gc1SSS7b"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 915D71F000C4;
	Wed, 14 Oct 2026 21:02:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792011753;
	bh=JaQpHsaZfFhDlyGWaEp+LKDKCD6glj1JvFGpPP9mp8o=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Gc1SSS7bCaMvbUKRFLLN8PMBNGjlvEHngHvADV6t3TIEvZClZF4fs6xs7OJzgDutK
	 +I6e+8IktbFVLAB2MNjJrQjn8neC7uvi7YEP0Q+x1JypheC8pPTrPCclx+NU6vsQw7
	 Jp34aTZukDK3Pkw2W08dDOPPWYjNpxrwwx+DVT3hSuIkIbkwanX3cqmb1dKQmJrS0+
	 vPJH4goF2zV3sdfWXjl1FGe3AkGFv0cJGRRqMadh0CGf4hlAhffrOGvAwVTX43NXj+
	 AANBjHmKmvzomGyqvP4AeBdA7uN5FbUWwD2RbBsHFh3gHbAWRQZloiwamxvKdWSAhv
	 xvV+DycQsWTHQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id F29EBF40067;
	Wed, 14 Oct 2026 17:02:31 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 14 Oct 2026 17:02:31 -0400
X-ME-Sender: <xms:5-3PamCE1ISMU7dcqRnQmJwda6JlvPd_310rtmqJPd2jFY_3swCUJA>
    <xme:5-3ParVweaF0kFGsEL2S4r5SSXUNzMQ-5hRVJXwL_ag90dBMysASfEHcwfEJVSVSr
    MrkcHs3keH8afgLB3Sny_wWectFl96D7PgjkenywuhIlwEu39OruYU>
X-ME-Proxy-Cause: dmFkZTEwUguday2YbiRcB+yZiZclpacU3BNifeyW+rylXDmjYZLgJ1+KcRUeOVJvM3ukzw
    HRlJc4JakDPJbKPkTkJAYaBQ1ZCr37akHcae3W0g4uJ3zMswgDg2AEIAlXV6O4Shlvkw9Y
    Flj0QZZgspfpu3mFyZ2l1xhOaWPtHwETMgFE3nB6eg8zcsPEc8hoRcu+J2fxqWXU+pzCac
    zpYrYB9WIYT78hJpqOuBbsu2oa9oO0jgX5ywI9kRvxj53qkGOs1nzxrj6QVQoSvYxmynry
    /DUf83zo2HkXgQ5fq8zw2shvc4nq+RszcecDnnLOyDA187H0YP1TBMfF0ATASnx9t7zhKq
    kdprEq2RSBnAJzny+/R4KY5ZoczBCw2tiQrpOKZg+VIPDVwLNM9CsryAQMAKRcVwofPEjw
    NIIHa7d2QKO/idXecowXnWKLiU7hSXHmVq1qmp2tYBBeJXFWBe3DVWABvdh6e3o1J03oQy
    7qQWK9537gF5YBlfdIwrBgi/QB3UVa4AEFqAdtOXp25y2DaS7A18PZJQGBIvRyevWV9L03
    vlTv6dR6JzLwpo+v17UmYhQULVp+sHOYur+yrr6LLbk7cjx2MioDn0A029dN992Kx3CRb9
    cmNv+c7YgUfwBkSELYUERyDnALgD2/Cw5g4G2mi4UpK89jNE4NG8ce4J6AqA
X-ME-Proxy: <xmx:5-3Paj4xmumUr-Vpigvb0qf3S_L2Ry8Qu8SF6IkEsIHJTuV8vkJY7Q>
    <xmx:5-3PahB9C1OyleR7BtT61QLmJni5xEhas7HiArcNJGQYHDOnG5xvaQ>
    <xmx:5-3Pap-tmaL4sp_373_sErosmBSs7Ke7oJy_-Pj1QD_ixCPVCd9uqQ>
    <xmx:5-3PakFFapAAwuneqeJ3_4pqSc2WbPqW01MO1-PaLYuCmGuBVOevTg>
    <xmx:5-3PajQEVKpQUB0rGOqELBqTcqdavvOPlZt57-QsGfHwSZZKYF34VQSX>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CFF36782738; Wed, 14 Oct 2026 17:02:31 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AH8T3UFXz8G7
Date: Wed, 14 Oct 2026 17:02:11 -0400
From: "Chuck Lever" <cel@kernel.org>
To: daejun7.park@samsung.com
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Christoph Hellwig" <hch@lst.de>,
 "Benjamin Coddington" <bcodding@redhat.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <166857d6-bb91-4731-8a94-a6a7fbb722e4@slotpi15m67>
In-Reply-To: <20261014-nfsd-layout-recall-v2-4-764462bddfd1@samsung.com>
References: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
 <20261014-nfsd-layout-recall-v2-4-764462bddfd1@samsung.com>
Subject: Re: [PATCH v2 4/7] nfsd: run the fence script when a block layout lease break
 times out
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/14/26, Daejun Park wrote:
> @@ -1004,7 +1075,33 @@ static void nfsd4_layout_fence_worker(struct work_struct *work)
>  	clp = ls->ls_stid.sc_client;
>  	nn = net_generic(clp->net, nfsd_net_id);
>  	bdev = nf->nf_file->f_path.mnt->mnt_sb->s_bdev;
> -	if (nfsd4_layout_ops[ls->ls_layout_type]->fence_client(ls, nf)) {
> +	ops = nfsd4_layout_ops[ls->ls_layout_type];
> +	if (!ops->fence_client) {
> +		struct nfsd4_fence_script *fs = ls->ls_fence_script;
> +
> +		/*
> +		 * The layout type cannot fence. Run the fence script, as a
> +		 * failed recall does, and give the lease up once it is done.
> +		 */
> +		if (!fs) {
> +			fs = nfsd4_start_fence_script(ls, nf);
> +			ls->ls_fence_script = fs;
> +		}
> +		nfsd_file_put(nf);
> +		/* Pairs with nfsd4_fence_script_work() */
> +		if (fs && smp_load_acquire(&fs->done))
> +			goto dispose;
> +		spin_lock(&ls->ls_lock);
> +		if (ls->ls_fence_stopped) {
> +			spin_unlock(&ls->ls_lock);
> +			goto dispose;
> +		}
> +		mod_delayed_work(system_dfl_wq, &ls->ls_fence_work,
> +				 NFSD4_FENCE_SCRIPT_POLL);
> +		spin_unlock(&ls->ls_lock);
> +		return;
> +	}

When nfsd4_start_fence_script() returns NULL, fs stays NULL,
the done check is skipped, and the worker re-arms itself every
100 ms until an allocation succeeds. The fence_client failure
path right below backs off through ls_fence_delay and warns
once; this path does neither. A GFP_KERNEL allocation this
small rarely fails, so the practical exposure is tiny, but the
retry could reuse ls_fence_delay rather than the script poll
interval when fs is NULL.

Also, the fence script can run twice for one stateid. The
lease break times out first and this worker runs it. If
the client stays silent, the CB_LAYOUTRECALL later reaches its
two-lease-period cutoff and nfsd4_cb_layout_done() runs it
again through nfsd4_cb_layout_fail(), since that path checks
only whether layouts remain and never ls_fenced. For a dead
client both fire. nfsd4_cb_layout_done() could skip the fence
when ls_fenced is already set.

Related: nfsd4_cb_layout_fail() now builds the same address
string and s_id that nfsd4_start_fence_script() builds, and
hands them to the same helper. If the first became a call to
the second, the two fence triggers would share one argv
construction.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
