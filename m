Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5FA502F9C32;
	Thu, 22 Jan 2026 00:51:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769043075; cv=none; b=XrfegoJPXTvmVRv4K2tqwNRAN1D7ifKfvyPD7Ys2fmFOA0s4eYIUOooufO/F+uNe+p3IBH5IXvRRQ9keqD6g2ol4kE1zkfUBoVXsbjf8PDBGKype0cCtlLXachuaBZJmEUKqAhkv7X93YqCwzYHCDhFYz+dg8uBxzJV79lSFFBw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769043075; c=relaxed/simple;
	bh=qt2R8zIYwwkNN1lwa9TaqZD5ofFrJR0jpYn05puXesc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=IC6dmfonzM5lifzkUl70WqyAgHKY5FomjYrNVJDNezzHR8EI9XK5pN/jJipnG+J5e9K5p/vYv/q+YLfGDcYWrrtDTD+hw/BAy042GbaXvpvSEnLVUa+yn0zmnBqSfL013LkHQROcI3G0yE0r4ZNWkmXtacHBCgyM+zSUQuaGSqw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CJs/O4P0; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CJs/O4P0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7B8A7C4CEF1;
	Thu, 22 Jan 2026 00:51:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769043074;
	bh=qt2R8zIYwwkNN1lwa9TaqZD5ofFrJR0jpYn05puXesc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=CJs/O4P0YfbYKpHWkH3ZRUT0T5S/VWdgatexI+L4dq98jmUtq+Xs95Ykm7/LqAA+C
	 RcVfwwnlOCQUwrMQ7W8kvZJJsA1J5axwh+gADA5Ak3gfkWQHajC+sRo6cNqmSaQ2Sh
	 lzg8g3WKBtx0JK9SzpU7BmUyN5JWsEqsHdSlcZpD5goEv85ZLZO+77R0rYYQ2cqko5
	 cWEziPFhNzrxu9bG5OTiSl9mqauQ+vPxvflj4YqaKcrrPPEuWynATD31kUBI4RNQqc
	 JX9At87eYHzhadr0RpaBr6kRHMxiVePNVsI1xvUvCvj5f57e5HOIz7hqYQCyBKwWHU
	 i9i4xGvvvE6og==
Date: Thu, 22 Jan 2026 00:51:12 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Benjamin Coddington <bcodding@hammerspace.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Rick Macklem <rick.macklem@gmail.com>, linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org
Subject: Re: [PATCH v2 1/3] NFSD: Add a key for signing filehandles
Message-ID: <20260122005112.GA946159@google.com>
References: <cover.1769026777.git.bcodding@hammerspace.com>
 <6d7bfccbaf082194ea257749041c19c2c2385cce.1769026777.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6d7bfccbaf082194ea257749041c19c2c2385cce.1769026777.git.bcodding@hammerspace.com>

On Wed, Jan 21, 2026 at 03:24:16PM -0500, Benjamin Coddington wrote:
> +		sip_fh_key = kmalloc(sizeof(siphash_key_t), GFP_KERNEL);
> +		if (!sip_fh_key) {
> +			ret = -ENOMEM;
> +			goto out;
> +		}
> +
> +		memcpy(sip_fh_key, &uuid_fh_key, sizeof(siphash_key_t));

Note that siphash_key_t consists of a pair of native-endian u64's:

    typedef struct {
            u64 key[2];
    } siphash_key_t;

If you copy a byte array into it, the result will differ on little
endian vs. big endian CPUs.

You may want to do le64_to_cpus() on each u64, like what
fscrypt_derive_siphash_key() does.

- Eric
