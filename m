Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 462A01E47CC
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 20:59:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792011598; cv=none; b=RiaqhjJiSXiGEFzoQSZUIrHpE2HeN9BVR5as5qAmdBWuiRKDOxvmyD8q41N4w9YAaJTQO/VMMfWWv5hqknjXVqjVM7jycox1j27qDXzNeFtjBhbkN3RISK672Oj9WMV+qdRhWd8kReN0Ih5QukbTUkkJCIlrqWJcCmsqYhABjdg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792011598; c=relaxed/simple;
	bh=2oCjHr81QUJVATj6BXPhGXAcI5Cs4F3eGM+4dJ33vwc=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=goprnGcQK6NL6FOBtI6xXLy4FeuJkQWmmzdLXajoGXTU+qRL/GoxnIiWz5LsaCdzR8qNwX2ySS75i0ySVICXhjBehLIKtJdeuQe3HkPbFQKEl2ZXR9o2YLhQXVyMQPlX/90DIC8ivL0Is/TvRIk8UQWFxRvkJOfSpAQGoW9lxM4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GAs0CFKz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GAs0CFKz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7EA9C1F000C5;
	Wed, 14 Oct 2026 20:59:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792011596;
	bh=Oh7kXVZne2oNAuIqnkcBEJjKh1a/dkvekelbmTkA3zo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=GAs0CFKz4YwS92HVviUv/ZMfFS+1Kb1fMTpKGkSPJY2FI5Njlkl5qgenzjXB3hXxm
	 Vd8a5EA/oqBXLnummv0o/Exl1AQNbJVkpdmKcjykCvVnD08bZM013vpnT9ohdyOfI1
	 /HaaayIiLi/+Tcz+dR4BrLoS+hChhmWzK/PF2cr9cwP6TZiP0o02bu1H4ESdCSEzm9
	 t1/MrbM9iz3GZBFZmaYDK5i+bNur4YgCVqdteVOqV3IBpheRejhOsYXFFl5ZZoD0WP
	 5u8Q1AJDlQyji5AcPidbzTunjLq2rX+8S3OpwvTRkYeXLtWDZrMTxN4i4M4q8TRBtp
	 G6axw60mVJr5w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C899EF40067;
	Wed, 14 Oct 2026 16:59:55 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 14 Oct 2026 16:59:55 -0400
X-ME-Sender: <xms:S-3PahHLgL_l9MmCHstnFaWP55my6hYQhJe2bXhiX9kyKIz3cGeWsg>
    <xme:S-3PahKQgg04p3OoJ1xWFP7dsHaa_JbJzZfcYolp7o6BDbP7plPSTHWfQKtSCv0t1
    Pg8KtqLU71tzwVUvwqLXkQQCG9FPR4VdQTW1Gw3zo4tbGY9aNK5jlc>
X-ME-Proxy-Cause: dmFkZTEX3v/qNxXVjkXeMMphQIEosvCv3vbSSTnFOS77eTnHvzrC73Oj6lZtShWj81QlsW
    xkjuNpXdOXGqQt0skSilPLwc2Yz9Q+keBFFBK9wPaoOEq0MhOtPdB3luj0k0yfYBXsrIjG
    tWDIG7Tj50XG6S5i+EYBBc6uhmjLHrFK1Yd2dca1eAghsgt4FZrCUoP+UGO+wUHpeAdrCf
    ule47G9hXlXWkKj4Huq+YZnMULzjeVjO9s2+/E+WWUMRnO3rZZONtcdnuoibGvESD6M183
    HZndtCqlNiFnJm+EJ7yzn71n5agdyjH92LQlgXxfvi0GrM1YfeNfhC0Lz7C7giXcEC9ZSr
    IjvaROVH6ggAulQ3Kww3CsSzb8NOb/Q+9PSWlWKxnk1F4LP0yyuqVqBNrjzi38LSFLplIA
    XgwnL8mqCu7BEIJgRI5eX0KieBa6AAf/W1SWR5UW3xTFxBaPujChUAeai2SWwtnDeO/QHb
    kHWhDgUmZ1ZL6ypN80zhE6u1peS8V9kuv7i6wMyr7Dp/+qKkrmb25Z5u5Ti2zpkrxLjcQh
    /6Ea6lSxXqjfa11EK3qONJ9gOU8BEHQDXHXAqz4YMqd8aNpSvKqzlAxhxmMGf/+4BoyTGo
    eMRkud6QwKMf3cy7NqrzSlGNveQVZQn15acq3zKRrgn6wQhYl+fFu9bzr3RA
X-ME-Proxy: <xmx:S-3Paof3friItoe39ZJLj1CAmeeXGlXCbbOki20fe3uBe8fXpyirVw>
    <xmx:S-3PaiWA5Q2XgQC0ZX226KCCP0djzzX4WGbfNACiUcYYfp3uvjgsuw>
    <xmx:S-3PapDbjR0z0nt75SDKri62DYdM4m5gufntJ9AIJykhew3fazx3aw>
    <xmx:S-3Pat5a1KOEKgZ5MnK1g0TD2kC-u1981X7WKgP9qCnt915i113DDg>
    <xmx:S-3Pag1GplCs70hpj_EmrTt3fx-bphqPVXL-o5osPwMPk7CrzQmCGI6W>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A2A85782738; Wed, 14 Oct 2026 16:59:55 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AdioI0pOYI0J
Date: Wed, 14 Oct 2026 16:59:35 -0400
From: "Chuck Lever" <cel@kernel.org>
To: daejun7.park@samsung.com
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Christoph Hellwig" <hch@lst.de>,
 "Benjamin Coddington" <bcodding@redhat.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <deacbd2d-a82f-4691-92e5-0ea98856c3cc@slotpi15m67>
In-Reply-To: <20261014-nfsd-layout-recall-v2-2-764462bddfd1@samsung.com>
References: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
 <20261014-nfsd-layout-recall-v2-2-764462bddfd1@samsung.com>
Subject: Re: [PATCH v2 2/7] nfsd: answer NFS4ERR_DELAY instead of waiting for a layout
 recall
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/14/26, Daejun Park wrote:
> @@ -2384,6 +2384,14 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		spin_unlock(&async_copy->cp_copy.cp_clp->async_lock);
>  		status = nfs_ok;
>  	} else {
> +		struct inode *src = file_inode(copy->nf_src->nf_file);
> +		struct inode *dst = file_inode(copy->nf_dst->nf_file);
> +
> +		/* A copy can be done as a clone, which breaks both files */
> +		status = nfserrno(nfsd_break_layouts(src,
> +						     dst != src ? dst : NULL));
> +		if (status)
> +			goto out;
>  		status = nfsd4_do_copy(copy, copy->nf_src->nf_file,
>  				       copy->nf_dst->nf_file, true);

This recalls layouts only for a synchronous COPY. The asynchronous
branch above it hands the same work to nfsd4_do_async_copy(), which
calls nfsd4_do_copy() with no recall at all. An async COPY whose
destination is held under an RW block layout by another client then
writes through the MDS page cache while that client writes the same
extents directly to the device. XFS breaks layouts for truncate,
fallocate and remap, but not for a buffered or spliced write, so
nothing below NFSD catches it either.

The recall therefore belongs before the sync/async split, so both
paths will execute it.

Nit: See if you can cut down the verbiage in the new comments.
kdoc comments are meant to document API contracts. Operational
details can be described close to the code itself (concisely,
please).


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
