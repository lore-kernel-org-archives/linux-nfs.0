Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 1A24C4E66B8;
	Fri, 16 Oct 2026 16:02:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.140.110.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792166569; cv=none; b=PUK0+LhPdmNH+guIZArKoTGfZoxdBcEBr6cevdR11trvcfcZBnH6gXHgGuexxliT7LkVKCUZzK7BqD/8YjnaGyqDgmhJE33k4XomWLR/S5tvQQSGE1my8+zgZxioCSoYGeeAKiNzZLyj7OQJSxclcGFOA9D1HnperRHmKl++b8U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792166569; c=relaxed/simple;
	bh=xytVtNLry8rGaKxKcgwuUf33YtgyauXJIawS5GVMY4c=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=f7zY+TjrhO/OQjxHXVFaqTG/GnRpiiaI0rYe2mGMJHnhEfy06V2gZCtt2QDB16AqNT0cJaBQZ3+s8nQXeajvbgHP0z9xYBCvbHZ8PwXk7Ncjf4KU3qveS2m66bY+LTz4w4hqDo+LsRsdDV/xPdtnlChY/Ybpb0/Syla+XrMVdzI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=foss.arm.com; spf=pass smtp.mailfrom=foss.arm.com; dkim=pass (1024-bit key) header.d=foss.arm.com header.i=@foss.arm.com header.b=QxCdFHZx; arc=none smtp.client-ip=217.140.110.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=foss.arm.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=foss.arm.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=foss.arm.com header.i=@foss.arm.com header.b="QxCdFHZx"
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 320E31516;
	Fri, 16 Oct 2026 09:02:44 -0700 (PDT)
Received: from [10.57.79.103] (unknown [10.57.79.103])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7C0243F673;
	Fri, 16 Oct 2026 09:02:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=foss.arm.com; s=main;
	t=1792166567; bh=xytVtNLry8rGaKxKcgwuUf33YtgyauXJIawS5GVMY4c=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=QxCdFHZx499GZ3CfDovH/PN5by6nnxTOVlkVAJhjrgDIefzrHOcvoSqwtBBJTvK7F
	 8BdDjZUefBuiR5C86NEpcAO6T80Kf3cjx4HgTV5mekVlyyTaGZVVp1JxSLI+mhDC/z
	 91ieV/BrEyD0yYxadDIH+FlHo74rh3FxzWc3XAQs=
Message-ID: <7b34d987-80d6-4ac1-bafb-e179a031f231@foss.arm.com>
Date: Fri, 16 Oct 2026 17:02:36 +0100
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: RE: [PATCH v4] svcrdma: Use contiguous pages for RDMA Read sink
 buffers
To: Jonathan Flynn <jonathan.flynn@hammerspace.com>,
 Mike Snitzer <snitzer@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: Leon Romanovsky <leon@kernel.org>, Christoph Hellwig <hch@lst.de>,
 NeilBrown <neilb@ownmail.net>, Jeff Layton <jlayton@kernel.org>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org,
 linux-rdma@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
References: <20260319133610.2556826-1-cel@kernel.org>
 <aiHlPmeZq3WgMwoJ@kernel.org>
 <3cb119b4b2a8aada30c0c60286778a54@mail.gmail.com>
Content-Language: en-GB
From: J Louis Kaplan <louis.kaplan@foss.arm.com>
In-Reply-To: <3cb119b4b2a8aada30c0c60286778a54@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 05/06/2026 23:28, Jonathan Flynn wrote:
> The primary comparison is between the regressed module containing commit
> 18755b8c2f241 and a locally rebuilt module with that commit reverted

Apologies if I missed this from the attached info, but could you
confirm if your tests here and with PAGE_ALLOC_COSTLY_ORDER [1]
included Chuck's commit 58202c29de936?

I ask because this commit removed significant contention in
a prototype with a similar design goal [2].

Thanks

Louis

[1] https://lore.kernel.org/linux-nfs/65a2cdb132b0c28e69a29955e3bd37e7@mail.gmail.com/
[2] https://lore.kernel.org/linux-nfs/20261006090028.3412544-1-Louis.Kaplan@arm.com/

