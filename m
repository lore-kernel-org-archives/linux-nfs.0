Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D41E61EE7C6;
	Wed, 21 Jan 2026 15:10:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769008250; cv=none; b=cfZjG5gfq3fU5KOzyM5AZY1wDKAUrUkDDysJMx/BIuQAmnOQCingM5ukcvpYCONWvg1tD9R7xGTfEgjps91AYoxeO7Z1vu4MChOGlp51exm01cbhQnSdggkgYK3xOI/iXAifTcTWxDHHoQ+ArBMcAuAH8iSWsWf39UKHWxtrg4Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769008250; c=relaxed/simple;
	bh=6d8UGKTLYxWO6x3c9B1hIaroxJhOIeQ7FGjRaHptDGw=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=Co5ic/JCRkIpY6SG/rxkC4HQHjssmxOh5ifhYn6oJmXzVzf97YoHd9a6cEYFa/thAzLph//P83pyShRVM4aR6iTYcBALD4TbJ5n7sLpgGMA2BJySr6P/FaKVeVELxnvoRoxvQSBzAzjcqi4zMtkQTEnRY0X8iSO8qR3N6PbZxYI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Sj0ZZqjO; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sj0ZZqjO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 69770C4CEF1;
	Wed, 21 Jan 2026 15:10:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769008250;
	bh=6d8UGKTLYxWO6x3c9B1hIaroxJhOIeQ7FGjRaHptDGw=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=Sj0ZZqjOwEIlVwNH2V/r192++tZ9lahSeFVpI2tjq+50YVuk4quCsVEC4RjowrsfU
	 l3Nb9GWDybxhCSf5g/RO50PvwIQ1HPoo6hs6GnWsKvNWP206OcjR5N3AzyKuFweWId
	 mKjIVl5eqTwrefedf/t8/UtgT/Bqi8yZ26vPFYuXGI7akbfVSsGlivRUUGJdLK/5w2
	 G47TSYsePqB9yGPsOlZEIhzqoDu7IAIFzoetBeTV8Qyqafv0Vt7EKbXaUaLYbBj/2p
	 CPcNDVE5FYGWhsJk5NN5webknfBjRI6IWmGCCvN3aEz+mAYzfELgk/0hvoFJpfedey
	 1JkZ91E6OykqQ==
Message-ID: <647a452c-0707-4dd3-a937-1e73566babb7@kernel.org>
Date: Wed, 21 Jan 2026 10:10:47 -0500
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 1/4] RDMA/core: add bio_vec based RDMA read/write API
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@nvidia.com>, Leon Romanovsky <leon@kernel.org>,
 NeilBrown <neilb@ownmail.net>, Jeff Layton <jlayton@kernel.org>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, linux-rdma@vger.kernel.org,
 linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
References: <20260120143124.1822121-1-cel@kernel.org>
 <20260120143124.1822121-2-cel@kernel.org> <20260121085641.GC16458@lst.de>
 <9bfdde0e-efe5-4e23-b95d-6f70836ed59c@kernel.org>
 <20260121145702.GA13953@lst.de>
Content-Language: en-US
From: Chuck Lever <cel@kernel.org>
Organization: kernel.org
In-Reply-To: <20260121145702.GA13953@lst.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 1/21/26 9:57 AM, Christoph Hellwig wrote:
> On Wed, Jan 21, 2026 at 09:14:36AM -0500, Chuck Lever wrote:
>>>
>>> I'd much rather have the callers pass in the bvec_iter, as that's
>>> more useful.
>>
>> "The callers" -- Can you clarify whether you mean that the API
>> consumers would pass in a bvec_iter, or whether the iter is
>> entirely internal to rw.c ?
> 
> I mean passing the iter from the API consumer into rw.c.  In general
> that is the sanes way to deal with a collection of bvecs.
OK. It wasn't clear from your earlier review comments, and I took a
guess. I'll get that done.


-- 
Chuck Lever
