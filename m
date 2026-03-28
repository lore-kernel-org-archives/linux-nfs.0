Received: from mx1.manguebit.org (mx1.manguebit.org [143.255.12.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BBC6076026;
	Sat, 28 Mar 2026 18:25:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=143.255.12.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774722326; cv=none; b=SQoUV5Fsm1VXLt50rji78AyhrECuO2FqOmTxG40KtDrwGBSP2hQsAzI8Gs2O54qz2KxVHMKXZceFjSc/3DJYK8P2AFLD26i/IGkKMpIf18so8Q/bdoZol1xKwbsXI+EmIUjamTZAMLB01vUMTIxM73xUAESe6J8gkdUJLQ2H6DM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774722326; c=relaxed/simple;
	bh=Lq87BM/si/9yxkQPXegzsv76VU6Y33pxEqAccEH+i7I=;
	h=Message-ID:From:To:Cc:Subject:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=pU7xpTAtWYwuUrJ5xvOgiceirMtnzL+cGppBhIMRytNVoEE3opalGQPGTaxbme4AAmFy2FqSTguhC4jA+EwnxeAOgV24PqZyQROZ8R9Lm/hU6dHWUSBeipCv2A/+q03OgEQqwHyzrZa/3oynptOWpCNTAge09Q80fyYXd37CAkg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org; spf=pass smtp.mailfrom=manguebit.org; dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b=TMb9A7G/; arc=none smtp.client-ip=143.255.12.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=manguebit.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b="TMb9A7G/"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=manguebit.org; s=dkim; h=Content-Type:MIME-Version:Date:References:
	In-Reply-To:Subject:Cc:To:From:Message-ID:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=Z69I1zT1OmIlOxzc4+bvhIZk7bvq6mzxmN8fD3QRepI=; b=TMb9A7G/pcnhz10NHFrg51PrVr
	3wlDJUa9zCWpkzSuigzyubHdRaeadFWW5bNIQfibjOzJ36gZsqXjoEz2im+IrkaFsOMQi+703Ihf9
	V7cCTXht/7WmOhky3lKQ6qotzFfoDoJMprWEz4wD4ipBzN5t5VXUZKnbjWZ2zROFgvAghvudMEd8i
	z9rG34/EoZdtH4RtujdOR1Esk9o79ocIv83FbWbNMlzWKBVeG7jxKZ3SXAy+Boo03lDODOKmgkGq5
	PHcLbA7CrwToSA+EgZdrKMzTURZWJ1Yw9pn2KYFPlsCDrC7DFEr+0uWauT/U2dcFXrLN75pImJJ5x
	n2Iw4NyQ==;
Received: from pc by mx1.manguebit.org with local (Exim 4.99.1)
	id 1w6YLS-00000001ni6-2udw;
	Sat, 28 Mar 2026 15:25:14 -0300
Message-ID: <1776cecc9268b81b426c041fdceae5f8@manguebit.org>
From: Paulo Alcantara <pc@manguebit.org>
To: David Howells <dhowells@redhat.com>, Christian Brauner
 <christian@brauner.io>, Matthew Wilcox <willy@infradead.org>, Christoph
 Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>, Jens Axboe <axboe@kernel.dk>, Leon
 Romanovsky <leon@kernel.org>, Steve French <sfrench@samba.org>,
 ChenXiaoSong <chenxiaosong@chenxiaosong.com>, Marc Dionne
 <marc.dionne@auristor.com>, Eric Van Hensbergen <ericvh@kernel.org>,
 Dominique Martinet <asmadeus@codewreck.org>, Ilya Dryomov
 <idryomov@gmail.com>, Trond Myklebust <trondmy@kernel.org>,
 netfs@lists.linux.dev, linux-afs@lists.infradead.org,
 linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
 ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-erofs@lists.ozlabs.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 05/26] netfs: Fix read abandonment during retry
In-Reply-To: <20260326104544.509518-6-dhowells@redhat.com>
References: <20260326104544.509518-1-dhowells@redhat.com>
 <20260326104544.509518-6-dhowells@redhat.com>
Date: Sat, 28 Mar 2026 15:25:14 -0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

David Howells <dhowells@redhat.com> writes:

> Under certain circumstances, all the remaining subrequests from a read
> request will get abandoned during retry.  The abandonment process expects
> the 'subreq' variable to be set to the place to start abandonment from, but
> it doesn't always have a useful value (it will be uninitialised on the
> first pass through the loop and it may point to a deleted subrequest on
> later passes).
>
> Fix the first jump to "abandon:" to set subreq to the start of the first
> subrequest expected to need retry (which, in this abandonment case, turned
> out unexpectedly to no longer have NEED_RETRY set).
>
> Also clear the subreq pointer after discarding superfluous retryable
> subrequests to cause an oops if we do try to access it.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Paulo Alcantara <pc@manguebit.org>
> cc: netfs@lists.linux.dev
> cc: linux-fsdevel@vger.kernel.org
> Fixes: ee4cdf7ba857 ("netfs: Speed up buffered reading")
> ---
>  fs/netfs/read_retry.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

Reviewed-by: Paulo Alcantara (Red Hat) <pc@manguebit.org>
