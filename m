Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191276;
	b=IOyT/CXJsjzm/vV7cjRhqlSRgd6EX6nE2yH/w476ktU6y9F2iEbtDtrPSZeg3SZXkIa8
	 Tnw76JD41rvk79VhBDP2ipOuOh9y976eiotECNg0mhfqqNVwTg33JiBHKq3lHmechi5xz
	 /hokLkKhQfDo0QMQQmLf1xHnJbW3SipFIkr43mFfh5HZ5wY85hQayN1WXMZ9AiSTmM+G0
	 9CEctPCftJSAwC9jBEYevJJYp3o+dfJ7pljaagmJDW9mx////yTSdq9t3EtbfbsrbH19/
	 Yi8cvFWNjDhbLMyYK9vDOTy6IcsbE0ESlmuNmQl3xLEFFafd+MTp/SsS3mGBg6n92pg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191276;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=QJI+3QYl6M34cW59A4Ttd4K0+VKvDeNcsgVuBRFnJC8=;
	b=VCLcTdP207W7QuKbqj6UK4jskd4bTfrueRhmFK4VYCwHnY/TWudIQhXUJNi0lpkmM1IL
	 JdhnaHhPcxyFp0uReq8jUj80nbQloIKCd5ZDjuYhP2OiuL+sBJF4va+AewUlLomk+Ful3
	 6zvMkDZDJU+4b/kiBcjdN7bqID4/eB6N3d97oWucmcOoFvBxuzeXPhk8IctGMWV8NYsEB
	 h3ITl4TvuEvylVeKvR78jq5jtB562etDwnRc18MxjYhYIaCB3eQAxAoX/5UrpcGyUfj0q
	 ocVKTCdhaeVRTm/00tcGG9F/gNXL4tfx5a0a/5YGMhAEE2jyeebA67IcnQ62oPuqKDQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AAA5606A325
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:14:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1AAA5606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id C98A46732A; Fri, 20 Nov 2026 17:14:32 +0100 (CET)
Date: Fri, 20 Nov 2026 17:14:32 +0100
From: Christoph Hellwig <hch@lst.de>
To: Chuck Lever <cel@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Sergey Bashirov <sergeybashirov@gmail.com>,
	Konstantin Evtushenko <koevtushenko@yandex.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Decode block and SCSI layoutupdates from a
 local xdr_stream
Message-ID: <20261120161432.GC31082@lst.de>
References: <20261119-blocklayout-decode-stream-v1-0-d71322f42c28@kernel.org> <20261119-blocklayout-decode-stream-v1-3-d71322f42c28@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261119-blocklayout-decode-stream-v1-3-d71322f42c28@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Thu, Nov 19, 2026 at 01:33:53PM -0500, Chuck Lever wrote:
>  
> -	nfserr = nfsd4_block_decode_layoutupdate(&rqstp->rq_arg_stream,
> -			&iomaps, &nr_iomaps, i_blocksize(inode));
> +	nfserr = nfsd4_block_decode_layoutupdate(&xdr, &iomaps, &nr_iomaps,
> +						 i_blocksize(inode));

Can we please keep the sane tab-based alignment instead of the stupid
after pening brace one that creates nothing but constant churn for
every change in the function signature while also massively reducing
readability?

The rest looks good.
