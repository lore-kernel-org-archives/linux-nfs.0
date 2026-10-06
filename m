Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 578F03E49FC
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 13:49:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791294585; cv=none; b=RTdnaHvMNJu9OfLsqZzvjsClRsjAY+JhV/lKwV/Y+kKbIdsuqnuyxUgw6/ejzAz+Bjx04BZoZOwX4jkczAwc85qIpSZQng/d53gxf4O323jiv8FON04Ie3i869w8YfW+Ptbkk+O91qFcPzO2PRpXrnqmbdcVTocJofGzUTFnwRc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791294585; c=relaxed/simple;
	bh=6CTBkfAkhDbr+UbdfIfeDu4WQTxWeZ+dqXtnB3MxTn8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=A6AYP/gU/73GMS5YXYrl1vTtCrUkw13ZjyO9FyK6JBAOtUgY9BDYs0GLPhjLD9qTtdDHpCf83kpr8/YamrPU5h+3pPdybhzjMu6x11b0nm/ZDmX7kZ5KyKFBMov38vwi5IdWOL8JW3P95h7jpVp8wggFIw9JghOhNw+OpVqu19o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SC5xjDvf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SC5xjDvf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A06DB1F00898;
	Tue,  6 Oct 2026 13:49:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791294584;
	bh=fYUlDfcTXtHnMlGGxp9hRSHW5ZNlMrip87KE9hfYWN0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=SC5xjDvf4C6tUrNIbEornETljplLWME5rt5axes3v7m5/TlHVJ82KPpGFqRhPndFJ
	 SI+eFTjQ6g7w1C410AvTRLDhgWXugqpPy1efe0OV7cVDOK3EjLYwuVfMTS9fXSe3RQ
	 CAbXUI53Tc9tVJlKUgVDpbedKzrKGWKIhWnEEGVupeZNJjrJUqZdxlBnr9ijfhrZI1
	 oi4RC/WI5DxwBxrUWGandejXCCidSNSMCTPdrt5yqDuI/nwCviyq71ivxm0cW4HyJq
	 kx55grouWe8vQS47RtYHjWC3eb5RU+wqI0ZTcX+qwcaYZ5D/YEF9K+08QNgNururKj
	 t55gI90gZGvzA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E8A8FF40068;
	Tue,  6 Oct 2026 09:49:42 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 06 Oct 2026 09:49:42 -0400
X-ME-Sender: <xms:dvzEapteuZ6rPWY-v-F6vIPNPsmqBg80PulOy3lyHjV1-zcZY-hasA>
    <xme:dvzEatRdX5yEm7kBkNp6z1c5wWEjZMglmwONi1uC5nL5vK4-_6mZnvuVX6haSnEX1
    4p5HPDvrJGoOhX8lWx5aE5DypAQg61nSZ5STB95_ofHHm_O-lZO9L8>
X-ME-Proxy-Cause: dmFkZTEQj2MwhCWjsqOOYYJsjpnv9BHpjhHy7mzUCBX60nRy8PdB8RexhXYkHSojpPCNrR
    X0Tar1DnY1MMW5xCflk5ezT65O7Gq/68cGhSsdVuVxf4iA3+j6mWMp/HWmFat69Eb8cSnq
    di63V8YvUazWAKNly4Kl3SgUk7u9bVY9NjYbKFxnZxOAmoy9g4zcjKNWdMir/L2PVi1NxZ
    tBliKHIjfTOdV68hsfwe2xC1vALCskImzyBcu47vokyfMXJTqSoXEwfZbj3lU2bMyHP9l9
    m/0DYe/SaOurGKnCMNZzQkXKYhhgSt7hhAaWSeHjdnh2dWapBuu80e+RTelmHczNbh2dBI
    TFMNkU5Gpkszx9VJb5Q4xkZggo78P2Jbgqmpmmwjzfbv0wTitZL9Rs6M5Udx8wQieIwgCZ
    1bwfkllrDGLBJiV/BovY8BsYLkvweY/h+E2anvEglp0QPUNuKawAnLtTlvqs+RLsKhHvS1
    WhPTOh+4nbaO9QDFA4KMEk0ADfM95Z3HkuDp7bYJeDprIhfZOE8Qi/ORjP8F73ydbUKck9
    qI5Y9DckmimBY1W4EUuPTq2tteNA6GLFCHmmckC6LZNG9f0quqUEpi/+ruP4hoU5+VI+/R
    clKeym48dTHOpgyu+VGJYGD7MSEWH2G3so+o+Ks8b2nvAsAyDzpzOYkraR5Q
X-ME-Proxy: <xmx:dvzEagF2YVwqGpyWlFJKnPAx85fK_vgZq4L08Uvao2K_uIgpm08QGw>
    <xmx:dvzEahf2breMONOigwlAMzVxanS_2e-SV1h4Wjo2mT5V_U-bzQRf0g>
    <xmx:dvzEapp_JGSYYydbF_GxJJ6MUWDSXWzRqO_Irp4CSkPgOrdp-MRIug>
    <xmx:dvzEaiAvke7gNf2fbAUD15RKiurwmOI_bl1Ib-VXWIoLpjpM4kvRKg>
    <xmx:dvzEaifyl7InUrWlujdnFBqNEfL7ku6cIArZNvqS3kaEy154AMqWnrg2>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id CC35B780070; Tue,  6 Oct 2026 09:49:42 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A0AjzbTE56vN
Date: Tue, 06 Oct 2026 09:49:22 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "J Louis Kaplan" <Louis.Kaplan@arm.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 "Anna Schumaker" <anna@kernel.org>, "Jason Gunthorpe" <jgg@ziepe.ca>,
 "Leon Romanovsky" <leon@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>
Message-Id: <4c1f4d35-4c30-49b9-85c7-de6be58fdf81@app.fastmail.com>
In-Reply-To: <20261006090028.3412544-2-Louis.Kaplan@arm.com>
References: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
 <20261006090028.3412544-2-Louis.Kaplan@arm.com>
Subject: Re: [RFC PATCH 1/6] sunrpc: Add helpers to build bvecs from contiguous pages
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Oct 6, 2026, at 5:00 AM, J Louis Kaplan wrote:
> Add helpers to describe contiguous runs with multipage bvecs. These
> functions have no callers. They are used in later commits.
>
> Accept a caller-supplied maximum bvec length so transport callers
> can enforce direct memory access (DMA) mapping and device segment
> length limits. Also support counting entries without populating
> an array so callers can size their allocations using the same
> coalescing rules.
>
> Coalescing requires contiguous physical memory and page descriptors,
> and is disabled under KMSAN. Xen constraint handling remains WIP.
>
> Signed-off-by: J Louis Kaplan <Louis.Kaplan@arm.com>
> Assisted-by: LLM
> ---
>  include/linux/sunrpc/svc.h | 90 ++++++++++++++++++++++++++++++++++++++
>  1 file changed, 90 insertions(+)
>
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index dfadea50e0c6d..e651c2312a912 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -11,6 +11,7 @@
>  #ifndef SUNRPC_SVC_H
>  #define SUNRPC_SVC_H
> 
> +#include <linux/bvec.h>
>  #include <linux/in.h>
>  #include <linux/in6.h>
>  #include <linux/sunrpc/types.h>
> @@ -376,6 +377,95 @@ static inline void svc_thread_init_status(struct 
> svc_rqst *rqstp, int err)
>  		kthread_exit(1);
>  }
> 
> +/**
> + * svc_pages_to_bvec - build one bvec from physically contiguous pages
> + * @bv: bio_vec to initialize, or NULL to only measure the next extent
> + * @pages: first page-array slot in the range
> + * @nr_pages: number of page-array slots available from @pages
> + * @offset: byte offset in @pages[0]
> + * @len: maximum byte count to describe
> + * @max_bvec_len: maximum byte count in one bvec
> + *
> + * Return: The number of bytes described by @bv. The scan stops at a missing
> + * or physically non-contiguous page.
> + */
> +static inline unsigned int
> +svc_pages_to_bvec(struct bio_vec *bv, struct page *const *pages,
> +		  unsigned int nr_pages, unsigned int offset,
> +		  unsigned int len, unsigned int max_bvec_len)

Generally any function larger than two or three lines is to be
kept out of line. net/sunrpc/svc.c, perhaps, would be appropriate
here.


> +{
> +	unsigned long first_pfn;
> +	unsigned int bytes, used = 1;
> +
> +	if (WARN_ON_ONCE(!nr_pages || offset >= PAGE_SIZE || !len ||
> +			 !max_bvec_len || !pages[0]))
> +		return 0;
> +	first_pfn = page_to_pfn(pages[0]);
> +
> +	bytes = min3(len, max_bvec_len,
> +		     (unsigned int)(PAGE_SIZE - offset));
> +	while (bytes < len && bytes < max_bvec_len && used < nr_pages) {
> +		// TODO: handle Xen merge constraints, see `bvec_try_merge_page`
> +		//	 for reference, or unify helper functionality
> +		if (IS_ENABLED(CONFIG_KMSAN))
> +			break;
> +
> +		if (!pages[used] ||
> +		    page_to_pfn(pages[used]) != first_pfn + used ||
> +		    pages[0] + used != pages[used])
> +			break;
> +		used++;
> +		bytes = min3(len, max_bvec_len,
> +			     (used << PAGE_SHIFT) - offset);
> +	}
> +
> +	if (bv)
> +		bvec_set_page(bv, pages[0], bytes, offset);
> +	return bytes;
> +}
> +
> +/**
> + * svc_pages_to_bvecs - build bvecs for a service page-array range
> + * @bvecs: bio_vec array to populate, or NULL to only count the entries
> + * @pages: first page-array slot in the range
> + * @nr_pages: number of page-array slots available from @pages
> + * @offset: byte offset in @pages[0]
> + * @len: byte count to describe
> + * @max_bvec_len: maximum byte count in one bvec
> + *
> + * If @bvecs is not NULL, it must have room for the count returned by a
> + * preceding count-only call.
> + *
> + * Return: The number of populated or required bvecs, or zero if the range
> + * cannot be described from the supplied page-array slots.
> + */
> +static inline unsigned int
> +svc_pages_to_bvecs(struct bio_vec *bvecs, struct page *const *pages,
> +		   unsigned int nr_pages, unsigned int offset,
> +		   unsigned int len, unsigned int max_bvec_len)
> +{
> +	unsigned int remaining = len;
> +	unsigned int nents = 0;
> +
> +	while (remaining && nr_pages) {
> +		struct bio_vec *bv = bvecs ? &bvecs[nents] : NULL;
> +		unsigned int advanced;
> +		unsigned int bytes;
> +
> +		bytes = svc_pages_to_bvec(bv, pages, nr_pages, offset,
> +					  remaining, max_bvec_len);
> +		if (!bytes)
> +			break;
> +		advanced = (offset + bytes) >> PAGE_SHIFT;
> +		offset = offset_in_page(offset + bytes);
> +		pages += advanced;
> +		nr_pages -= advanced;
> +		remaining -= bytes;
> +		nents++;
> +	}
> +	return remaining ? 0 : nents;
> +}
> +
>  struct svc_deferred_req {
>  	u32			prot;	/* protocol (UDP or TCP) */
>  	bool			secure;	/* RQ_SECURE of the original request */
> -- 
> 2.43.0

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
