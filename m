Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793776354;
	b=gfZzYEO30Z4Y1iLrKryO2A6hapCofENsM6BSCo0kWVdIXJfYdbtMN1F92h7rnEk6P+OR
	 kO0XfT7jQTzLPPPrCspvoDPjeUiFeFvwhnxIZZ0lnuc1lf70+9CILVZRpToDUqfWGIZhP
	 9EvDrbSFZuRUAoro+s13ysdKXsAF4gAcNio9yPW1YmY/VwT3DEyPL71JHMVGNfm7Ihe3d
	 pxqUlxZY4sZl+16YRxrmHSCgFzXM7byPunZ7QyAIhtMd5CP7ir6LDGD5o+HdhHxFNbL4Y
	 Cjv3A8RWskFWcriTH2r4cWnG//ykqUR09NtgnYLLUTtNAAVpOexBswiNjDoDjTWLMCQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793776354;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=Gvcc1SfUzRuxC7HCa25XUjDGmMMCYpKYK9b5tao3ttk=;
	b=Q8fU2ro2eb/CSJsNIgZh5Q0rqg1ohPE5YznWESOo7ZObXsusR5ub1S54H125zHNjR8Bd
	 q3o82lzdtN7FtGyrFeftsbcUojJ+q+Chq0DH+Y8zxgVdthrw7BwsxT4bTsDR7ColDcLKC
	 R7S9FuRqxNOcvz+YJQ2YebGJTUTDLP9mRHnqd98Ka75Z91gjtV3Fswl/pis8lS12Z54Tm
	 Pa+prRDgfwuKuGBiW08ekt3Ckr1KSotFyQDjTg5CJ4RikFaxgTRU210lGSThX4Y0uVwhN
	 J3jyARB2UeCKmcurhREVoL5wzmQJNkyuAZxdHo2GnqLfrv+6jLGcBFjqKhB7zg7aPwg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F5aeriKi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BCCF606A32E
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 07:12:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=F5aeriKi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA53B1F000C1;
	Wed,  4 Nov 2026 07:12:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793776353;
	bh=Gvcc1SfUzRuxC7HCa25XUjDGmMMCYpKYK9b5tao3ttk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=F5aeriKidfl6vZf9bxk2KQHM7JXEhrqs+dexlHRy+D4Bqw3MolKx8HdetIak44CXk
	 TqKjSXq/PFlxCF8cTksoqMcJ/21sGZY1R0jNAwBOOufPpJ+4aV/8UeZefV7bVsQ6qV
	 vaJMB8z04Mm6fnfpSbpjY2i/eo+XGcDR1HoRN5JsttM09GPjUt7lFh6k5zbGpaHuXf
	 qlDHliVbGR195VF4fSpCVU1ZZLjfgq8bOAh3H07vICpl8bgxqlwpM7EOiptIhtE+sd
	 apgyKJ/iz+HuoeaSpyCc3Ykl5eGyzpLyDNeFn17XU7eHWCm4CjT3JtW9xb92DIuQKa
	 2eCT6Y1nuhDmQ==
Date: Wed, 4 Nov 2026 08:12:29 +0100
From: Krzysztof Kozlowski <krzk@kernel.org>
To: Wentao Liang <vulab@iscas.ac.cn>
Cc: Anna Schumaker <anna@kernel.org>, Trond Myklebust <trondmy@kernel.org>, 
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: release the state owner reference in
 __nfs42_ssc_open()
Message-ID: <20261104-amiable-cheetah-of-politeness-badd8b@quoll>
References: <20261104021550.1468884-1-vulab@iscas.ac.cn>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261104021550.1468884-1-vulab@iscas.ac.cn>


On Wed, 04 Nov 2026 02:15:50 +0000, Wentao Liang wrote:
> __nfs42_ssc_open() takes a reference on the nfs4_state_owner with
> nfs4_get_state_owner(), but the success path never releases it.
> nfs4_get_open_state() takes its own reference when it creates a new
> state, and the existing-state path does not consume the caller's
> reference either, so the owner reference obtained at open time stays
> around for the lifetime of the server.  Every inter-server copy source
> open therefore leaks one state owner.
> 
> Release the reference once the open context has been installed on the
> file, as the success path in nfs4_do_open() does.
> 
> Fixes: ec4b092508982 ("NFS: inter ssc open")
> Cc: stable@vger.kernel.org
> Assisted-by: DeepSeek-V4.1-Flash and OpenAI Codex
> Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
> ---
>  fs/nfs/nfs4file.c | 1 +
>  1 file changed, 1 insertion(+)
> 

Multiple things here:
1. Your team ignored completely previous feedback. Multiple times.

2. You use multiple identities with this email address, thus I doubt that we
   speak with an actual person.

3. Your bot does not even bother running checkpatch, right?

4. Nothing of this was reproduced nor tested.

5. Finally, the same feedback:
You sent multiple independent patches, to multiple independent
subsystems. The amount of these patches clearly suggest this was
AI generated and most likely not tested.

More importantly, you sent all this work without properly organizing
relevant patches into patchsets. This makes reviewing difficult
and might cause multiple reviewers to address the same issue.
Replying to the entire set is impossible and requires handling each
patch independently, instead of applying or discarding the set.
Maintainers also won't see the bigger picture of your work. Quite
worrying.

This is on the verge of hostile patch: bomb us with so many
contributions, we won't be able to handle them in efficient manner,
like responding ONCE to ask you to slow down.  Considering all this
is untested and LLM generated, I have even more doubts whether this
should be considered for review.

Please read kernel documentation BEFORE posting more work. It will
explain you how to identify subsystems, how to organize your work per
subsystem (so a patchset grouping multiple patches with a short cover
letter), how to document the issue discovery method and what was
or was not tested.

Best regards,
Krzysztof




