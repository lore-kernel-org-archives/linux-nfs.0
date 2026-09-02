Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 025F24A8A1E;
	Wed,  2 Sep 2026 19:36:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377817; cv=none; b=Vmm914e1t1DMxxiPDF4m4rReB38QyNjQ7zJp5vIG+naKqr5t4yggir3Edo3/dHQxTxmGB/yPu2nuMhDgnfuHLv/aMKhWDKBBdpfHHf4PTzIio1DcGgFhMOCNbklpksibvFKj6vGqqHVJTCIFoIccI5liP0tFVIX1a/P78Z56d3k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377817; c=relaxed/simple;
	bh=fVI/tgLkzIeMXja+DzkLobtti0MHAb5XfVwcydoIMYc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=FEZZSHyESBcqulcrrQmPr4tZv0Zn8jcRRI4QdQ8YUILipQwPkw5PwuEKeLCl1BAcXozLZRG2+5yGQ1LQFjJtBi+EC+PzBG0ZvyTHv2hhWx+FPOwGexTTYaKxzbIJ51+5ZmqdBMIblock+mUSCSwVKwqIJ2Xz+9WXZKxxAqblnzw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Df/PBQxL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Df/PBQxL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3DA4D1F00A3A;
	Wed,  2 Sep 2026 19:36:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377802;
	bh=IM5Gh99nFHx5d31MlQ+xAM3vC+scbkhqFApowcRyVvk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Df/PBQxLHr/dbcoEEpVfyNzAJrZDSsSIHTWQfLXa+epGXiQZRY41w5Ctld3q/CCn6
	 TcBsaFzZWA9ZItwbGmQwUAwJuSv/Y1jm99rZuVhO+HBf5F92tn4GLPo4nZKbsVnHFO
	 lFyTJS7ZGSFZ8hPyHUhoNnI92vr0QIk7g4v37VYKhoEp5SXgEM7qCNj2wrzhLtRUkO
	 bkuMYFKEmT8pkKSlVGe6zz+67W3tNIlBL1Q9wRJzdYyKe/YwX5Mpc9sfzkNHmzD9oI
	 9uovqbULtQzwXlo2nHj0ICgnV3NqjXepPjcriGkTyDrSROlzxUf06zkJUFgzyHJ/bI
	 pQ20zCIg5kyww==
Date: Wed, 2 Sep 2026 09:36:41 -1000
From: Tejun Heo <tj@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
	open list <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH RFC v2 5/8] workqueue: add workqueue_set_affn_scope()
Message-ID: <aph6yYag8LeZxmyn@slm.duckdns.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
 <20260902-performance-v2-5-b71c0c082f9d@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260902-performance-v2-5-b71c0c082f9d@kernel.org>

On Wed, Sep 02, 2026 at 03:28:50PM -0400, Chuck Lever wrote:
> An unbound workqueue's affinity scope can be changed only through
> sysfs. A module whose workqueue contends on the pool lock at the
> default scope has no in-kernel way to select a finer one, because
> alloc_workqueue_attrs() and apply_workqueue_attrs() are not
> exported. Exporting them would also invite a caller to apply freshly

BTW, please feel free to export them.

> +int workqueue_set_affn_scope(struct workqueue_struct *wq,
> +			     enum wq_affn_scope affn_scope)

No need for the line break.

> +{
> +	struct workqueue_attrs *attrs;
> +	int ret = -ENOMEM;
> +
> +	if ((unsigned int)affn_scope >= WQ_AFFN_NR_TYPES)
> +		return -EINVAL;
> +
> +	mutex_lock(&wq_pool_mutex);
> +	attrs = alloc_workqueue_attrs();

Maybe alloc outside mutex and use alloc and mutex guards?

Thanks.

-- 
tejun
