Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD317470E9F;
	Wed, 22 Jul 2026 19:10:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784747449; cv=none; b=F/+7Yl7r4mrZaBxk14awtANQok/ayhNhkObJ/7NOlfYlAwOG5P46dl2Rr475CsAiShI23ixVoNcWeoS5L3qy67dChpWYpabKF1DLMWVh9vZEAJ26cSmArurOVzlBPSq2wtIn4LeCtR+w1981S2i/mqtUSpacSaAqVlXjSCvrm78=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784747449; c=relaxed/simple;
	bh=HK13T7s/X5pO1JvcC+yyz0YWcf/WDGWQi0PjvjTjEoU=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=JYvR5x+AP5HCROJOKWCmgNydW81ivPLSYXvqIY4yqY5RN3VRqFoQT33LHyFfZw0UsaOkgN0cH72rrJV4Q2BeOgeNaCA6Jw1yUJRrWlb9BPXAxS8uB8KFQUPM4G6v17dtuLFeSVtQKpznscWjcJbOqpBPdNblM3uEJp8Lf1Pnw5k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Dqgq8Zk8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Dqgq8Zk8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 452DF1F000E9;
	Wed, 22 Jul 2026 19:10:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784747447;
	bh=Adl7eZBiPu6wv6mDVEoGxlGcf1hd8vK4l716/KcmcQw=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=Dqgq8Zk8CJeu1olxDfmauAf/VM8tCwCyd5nnu3O3Wqu4zz/IRoRsaI/bAAyUDtuxV
	 sTdTTdjNv386J6AbXqx3hUGfDgZWZmvXHp5ZThWEWfqsjTbs2agXucaUftG7CmVApm
	 2K9M6xjI1T7nTEN1zhEiQS1rYltwRXbBPtCDiLNbw1mkQZED5YSdiSK3l8IBvZhTXX
	 VPQs65j+ydx24ytUcm8+AwK5+5E0a5Sscvf/+X+XrFgg81KYtxjR2Z39wH0DgBd0U0
	 y0LX/f0BwIJm4dD2QUl3++fx4emolWXc2/Ab/lWHH/rvQFZ51in7mqHKNEhG7S9SKe
	 emmXRCqNYjuVw==
Message-ID: <4b35251a112d6593ce41741fbcb9517b35e5f287.camel@kernel.org>
Subject: Re: [PATCH] SUNRPC: Restore NUMA_NO_NODE for svc thread allocations
 in global mode
From: Jeff Layton <jlayton@kernel.org>
To: Ameer Hamza <ameer.hamza@truenas.com>, cel@kernel.org, neil@brown.name, 
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com
Cc: trondmy@kernel.org, anna@kernel.org, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, frederic@kernel.org,
 alexander.motin@truenas.com, 	caleb.stjohn@truenas.com
Date: Wed, 22 Jul 2026 15:10:44 -0400
In-Reply-To: <20260722182012.2063936-1-ameer.hamza@truenas.com>
References: <20260722182012.2063936-1-ameer.hamza@truenas.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-07-22 at 23:20 +0500, Ameer Hamza wrote:
> Commit d57e43b72bf2 ("SUNRPC: Update svcxdr_init_decode() to call
> xdr_set_scratch_folio()") changed svc_pool_map_get_node() to return
> numa_mem_id() instead of NUMA_NO_NODE, because __folio_alloc_node()
> cannot accept NUMA_NO_NODE. That return value is not equivalent: it
> is evaluated in the context of the task creating the nfsd threads,
> once per thread created, and it is passed to kthread_create_on_node()
> and to the per-thread allocations in svc_prepare_thread().
>=20
> Since commit d1a89197589c ("kthread: Default affine kthread to its
> preferred NUMA node"), the node argument of kthread_create_on_node()
> no longer only places the task structure and stack: a kthread created
> with a real node id normally affines itself to that node's CPUs when
> it is first woken to run its thread function. All nfsd threads are
> typically started together, by one task writing to
> /proc/fs/nfsd/threads, so under the default pool_mode=3Dglobal each
> nfsd thread is now affined to the local-memory node of the CPU its
> creating iteration happened to run on - typically the same node for
> every thread. The CPUs of the other nodes are then unable to run
> nfsd at all, and the threads' allocations - svc_rqst structures,
> page pointer arrays, newly allocated task stacks, and the per-RPC
> pages allocated at run time - all prefer that one node.
>=20
> Restore the NUMA_NO_NODE behaviour that global mode has had since
> commit 11fd165c68b7 ("sunrpc: use better NUMA affinities"), and
> handle NUMA_NO_NODE at the one call site that cannot take it by
> resolving it to numa_mem_id() there, exactly as alloc_pages_node()
> did for the scratch page before the conversion. The mapped percpu
> and pernode branches are unchanged. Unpooled services such as lockd
> and the NFS client callback service also take this fallback when no
> percpu or pernode map is active, restoring their thread placement in
> that case.
>=20
> A bisect of a 2x NFS READ throughput regression between v6.17 and
> v6.18 converged on d57e43b72bf2. On the affected 4-node server every
> nfsd thread comes up with its CPU affinity restricted to the CPUs of
> a single node; with this change the threads are runnable on all CPUs
> again and the observed regression is resolved.
>=20
> Fixes: d57e43b72bf2 ("SUNRPC: Update svcxdr_init_decode() to call xdr_set=
_scratch_folio()")
> Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
> ---
> The pool-mode rework in nfsd-testing already removes global mode,
> so this fix is based on nfsd-fixes and aimed there and at stable
> (v6.18+), where the regression ships. Tested on a v6.18-based
> 4-node server: without this patch all nfsd threads come up affined
> to one node; with it they are runnable on all CPUs.
>=20
>  net/sunrpc/svc.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index ae9ec4bf34f7..16b1ca1a7ae3 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -352,7 +352,7 @@ static int svc_pool_map_get_node(unsigned int pidx)
>  		if (m->mode =3D=3D SVC_POOL_PERNODE)
>  			return m->pool_to[pidx];
>  	}
> -	return numa_mem_id();
> +	return NUMA_NO_NODE;
>  }
>  /*
>   * Set the given thread's cpus_allowed mask so that it
> @@ -711,7 +711,9 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_=
pool *pool, int node)
>  	rqstp->rq_server =3D serv;
>  	rqstp->rq_pool =3D pool;
> =20
> -	rqstp->rq_scratch_folio =3D __folio_alloc_node(GFP_KERNEL, 0, node);
> +	rqstp->rq_scratch_folio =3D __folio_alloc_node(GFP_KERNEL, 0,
> +						     node =3D=3D NUMA_NO_NODE ?
> +						     numa_mem_id() : node);
>  	if (!rqstp->rq_scratch_folio)
>  		goto out_enomem;
> =20
>=20
> base-commit: 5c4851e4cdfc3204128f88991be64a6e3929d3d0

The patch seems sane. I wonder how much we should care about people
using global mode on real NUMA hw though? The better fix for those
folks would be to move to pernode, most likely.

Oh well...

Reviewed-by: Jeff Layton <jlayton@kernel.org>
