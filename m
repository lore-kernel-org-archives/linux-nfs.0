Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F1102DECCC;
	Wed, 21 Jan 2026 14:14:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769004879; cv=none; b=hV0sJPYV8OhnsImLsY9YDlHDj8PHubj1ftPVJ92NmhCzuru1IXlfhwotkvCsOBrNp8Zc7CMyZZsmvvqAgOkfKuZKDrHSk4SbwsAIiNCvx6kOXskTVekJCKDHzKeBsnydh/xun1JczBEgNhZi7iuI99ichLfW0USVieUxbOYgKeg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769004879; c=relaxed/simple;
	bh=ZSIa9oi5DcWZsu908TKULsi4N4pbs3uuKg/9b/8WOok=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=GzM6Dru7ods0a/2VaC/gkb9Giv4zUODyG7360aveIRz5A6upASYZPJ3U1+hdXgqMHlJsF1Q0aOLXtRfUzNrds8HRlpNLQ/aRMsMPES8muvp9fHzDGC7bBiwQbgV7Wno1mi9T0HvGjsbbH8cGrpB/rdZcShmQGfEjKWZObdqr2r0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EDrX2387; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EDrX2387"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 485F8C4CEF1;
	Wed, 21 Jan 2026 14:14:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769004879;
	bh=ZSIa9oi5DcWZsu908TKULsi4N4pbs3uuKg/9b/8WOok=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=EDrX2387jt2zy9qDnYtcY+/nBJzA3u7kNEb91ygo1UB8ZQO4hydc+dfOKRKT6971r
	 im293MKyicfyZVpzXkF6cAbt42SZ+BUKtqcZZ/vhhfKp15veF3EA3G0E8xb8O70OfR
	 IwI0DQHTLNZpLJIZ18G4Z746V3ysZ2vderAOoB8PFOj/EuSlPwD8aQYRt8AAAtox1z
	 mz+fYu/rgOznHEJHnhw7mo/OEX7Vcngl9WeLg7XZjeCITcDliza2EYrLDA9FsAyTAC
	 N6TtL8ANwbIU2qFiZNc+DdxS+n/qyAbwHZ98mRore8cli5fDj1c0AJOWYFFkktP/Hi
	 FG/OfoS4OldXQ==
Message-ID: <9bfdde0e-efe5-4e23-b95d-6f70836ed59c@kernel.org>
Date: Wed, 21 Jan 2026 09:14:36 -0500
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
Content-Language: en-US
From: Chuck Lever <cel@kernel.org>
Organization: kernel.org
In-Reply-To: <20260121085641.GC16458@lst.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 1/21/26 3:56 AM, Christoph Hellwig wrote:
> Another reply, sorry.  I noticed I skipped over the end while reviewing
> the 3rd patch.
> 
>> +	u32 i, total_len = 0;
>> +
>> +	if (nr_bvec == 0 || offset >= bvec[0].bv_len)
>> +		return -EINVAL;
>> +
>> +		if (check_add_overflow(total_len, bvec[i].bv_len, &total_len))
>> +			return -EINVAL;
>> +	}
>> +	total_len -= offset;
>> +
>> +	iter.bi_sector = 0;
>> +	iter.bi_size = total_len;
>> +	iter.bi_idx = 0;
>> +	iter.bi_bvec_done = offset;
> 
> I'd much rather have the callers pass in the bvec_iter, as that's
> more useful.

"The callers" -- Can you clarify whether you mean that the API
consumers would pass in a bvec_iter, or whether the iter is
entirely internal to rw.c ?


> We can probably look into factoring the quoted code
> into a helper if that's useful.
> 


-- 
Chuck Lever
