Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E498442AF9B
	for <linux-nfs@vger.kernel.org>; Tue,  1 Sep 2026 15:19:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788275960; cv=none; b=Kj5GlhFPYeh6jz61X4RVGO6uG0o1dC/fu+4FrkH8vVFb8eQCm4SZqkQMrGrN9BfUz4jRrjjsTNQ8EaEcJhE+utB556MaDKM0l4oNY0p/LuVReS0r5ALR/YuOJGjKmF14dxypHXltrRI2OtOt0ES6Jk2g5IxtS+/Sp+bKkVFMqf4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788275960; c=relaxed/simple;
	bh=K/ZcV9SR2P2QYRvwEKjdm4n9J4nRmYOhSxOU8nmjck8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=HFCG7nULUWsU8eA05OOGv21D/2BxW3mFcsKPClog917h2rLnXp2nqZ8Gh0BpbWCSwvNn8gSGyZkfTMqWc2jDsdGsKmV0WUTGE/lZAmjaxNNh/m25zDwQGMQvAaeoaANSrR8EPzTrp1RSx2AX+m+kn3UYcKeRLsdSiuxTIwIDY7s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TvR92UQO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TvR92UQO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5E0FD1F00A3A;
	Tue,  1 Sep 2026 15:19:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788275958;
	bh=T8hVAAFq8nLXDzFROIdNIyz355aFQ3u4T9wwv41XM+8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=TvR92UQOXpZh/MJjJyylElZOzWTZTzI6KwKy9Q0rqrF34Zpf7BM2+cddYYRqSkTEf
	 59WnHcehR9s8rXcnnqcLhZnbQgLFs5S1hY6rq7YFD5nM2cbsrWVWcVTEtnxmGFdH66
	 gM06Bb3pzYmXJBYw0XoZODPmgeUKBNo5JlyWZdwSdt0eJya7y07sE28ujlFnvSpZ/4
	 ouUaXP0ZFLmReaVVR5jdrn/okyOhp+Sf3+ZC8IDnBr0FdRFntXFnCTmf/eOCJ3wddu
	 SUMPJkHpkW4KBZsl2mgj+yCjqHy2pCCL9GrV+kn9aHn3mmDI7TULDPn9T9zt4KSvxi
	 o/OPomkq5OoIw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 8574CF4006C;
	Tue,  1 Sep 2026 11:19:17 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 01 Sep 2026 11:19:17 -0400
X-ME-Sender: <xms:9eyWanpzYrq8a8tqptF-058OfZpcMbqCJiqjSRX3HindWsOOeAzVcQ>
    <xme:9eyWaseasetMubUnJ9DYNNQGGlHPkqAGdC45R1ZRMw6FJg1-H-ehXe9-sG2UagdTS
    7FMOGOAFvjKNUbi2aXLkafcvXJpnoYuzTZ1v78MGXCsna681iwHsLN3>
X-ME-Proxy-Cause: dmFkZTFTbqlX6RzWhAPEQg6A6hUFJaVSZLzoWksCRUQlMdc2Q88F8lIvNJD5I5PvW0PLmE
    nnOs9AavJGw1LhcD4mLF6oz1SC53l7jHVjzEBJI4DF9AOSFkjsyXvj6iYc12XgWJrW7Gr7
    FTnIdH4Zb6Egds1U59cySIyFTkbw1Y3kwG/1SUX2e7KjmqQm7cjSRTPbluLKO6RsZLwrih
    DGYVWvCJHFpEC40c+Q70pbPbcZfyJ/KflejdambIZZk8tl32tYep4wHm7vtpbBh9KdILro
    U4uOyTM9CC9NDzyYplRNevNWYSmQLoEYpGTB8ZnsdIQXWrV1rneT+QqXjhLxKoodK0nYfZ
    cLFnX1XlCcIk4mPA+/Y9cZ7JnhbIbcrBkhK6kAmQ3NtTMor1uSFh6r45psnhcYd/1Q6nTt
    d3dKoUPrx9k47goec/w/U7SACvz0nW35wCqTUEdX7y3mVH8mTq6ByGRb30kMB4kDxXZ+Td
    Swtsqv9ClGsYL4GeuT+LmwBttzqwbcHytUWJP1QoeEcIvCH2Et3SDUK5BwSX5eHALcfsZM
    ROxuV18Wg5olhmbNxpXQG8woZIhMJd/RF/y/CioP5fu15CdC3HvPjCllu+KiHAcTVhZGE1
    QNiprIDqabrbWQrpHnSgBT2q9fxulOxAwvSHzw6J+eg4FoeWOUpQe/gx4PaQ
X-ME-Proxy: <xmx:9eyWavoyeKm8Vfof70LJo_-7X4D5jY_UQXCmI6PoZJY0U0KS4cKqsw>
    <xmx:9eyWalpOKtEZi9gYkj4pia2FLTqmuvCXjq1jt1sSgbySE2Hbgiwbtw>
    <xmx:9eyWauaII9t5Lrwq1iXNH3oDM5IvGm42v_ylfFinyt0RbRNN3B2XHQ>
    <xmx:9eyWaj_O2xW0wlMr2SJkryGWdKmxtDIQKkwdpDH6lqFw4GyT88CJtA>
    <xmx:9eyWask_FRWgfIY41LWKfiNY8Jv1nMGkmuRPSJlRpjx0wSRf3SBaV0FQ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5AB0E7811F0; Tue,  1 Sep 2026 11:19:17 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AlyFZM-VFrMc
Date: Tue, 01 Sep 2026 11:19:01 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: "Thomas Haynes" <loghyr@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <d5af1492-5bc3-4ac8-b4e8-d454b7caafdf@app.fastmail.com>
In-Reply-To: <20260901-delegts-v1-1-9937f7ee4370@kernel.org>
References: <20260901-delegts-v1-1-9937f7ee4370@kernel.org>
Subject: Re: [PATCH] nfsd: accept a backdated timestamp from a delegation holder
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Tue, Sep 1, 2026, at 9:09 AM, Jeff Layton wrote:
> A client with an attribute delegation reports the file times in a
> SETATTR at DELEGRETURN. nfsd ignores a time that moves backwards. It
> then stamps the c/mtime with the current time, so the file keeps the
> DELEGRETURN time. cp -p, rsync -t and tar -x lose timestamps.
>
> The client applies an explicit utimensat() to its own inode. It sends no
> SETATTR while it holds the delegation, so the backdated value reaches
> nfsd only as TIME_DELEG_MODIFY. The client can send an RPC for each time
> change instead. That also works, but it loses the caching that the
> delegation allows.
>
> The delegation makes the client the authority for these times, so treat
> its SETATTR as a statement of fact. The client can set the same value
> with an ordinary SETATTR, which nfsd applies without a check.
>
> - nfsd accepts a backwards atime or mtime.
> - An mtime that moves backwards sets the ctime to the current time.
>   The ctime never moves backwards.
> - nfsd still clamps a future time.
> - The CB_GETATTR path keeps the old rule. A backwards time there shows
>   a stale report.
>
> RFC 9754 says that the server ignores a time before the original time.
> This patch does not follow that sentence. The same section also says
> that the server MUST accept the change or MUST reject it with
> NFS4ERR_DELAY. A silent discard does neither. A retry after
> NFS4ERR_DELAY carries the same backdated value, so that option cannot
> succeed.
>
> There is still one gap: nfsd cannot tell an explicit utimensat() from a
> report of a write. An mtime after the delegation and before the current
> time therefore sets the ctime to that mtime, instead of to "now". RFC
> 9754 requires this. Fixing that would require the client to issue an RPC
> for the mtime.
>
> Fixes: 3952f1cbcbc4 ("nfsd: fix SETATTR updates for delegated timestamps")
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> Assisted-by: Claude:claude-opus-5


Hi Jeff, LLM-generated review suggested the below finding is a blocker.

> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index bb74eef43938..fa3a43c20e95 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c

[ ... ]

> @@ -1302,21 +1315,23 @@ vet_deleg_attrs(struct nfsd4_setattr *setattr, struct nfs4_delegation *dp)
>  	struct timespec64 now = current_time(dp->dl_stid.sc_file->fi_inode);
>  	struct iattr *iattr = &setattr->sa_iattr;
>  
> -	if ((setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS) &&
> -	    !nfsd4_vet_deleg_time(&iattr->ia_atime, &dp->dl_atime, &now))
> -		iattr->ia_valid &= ~(ATTR_ATIME | ATTR_ATIME_SET);
> +	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS)
> +		clamp_deleg_time(&iattr->ia_atime, &now);
>  
>  	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY) {
> -		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
> -			iattr->ia_ctime = iattr->ia_mtime;
> -			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
> -				dp->dl_setattr = true;
> -			else
> -				iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET);
> -		} else {
> -			iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
> -					     ATTR_MTIME | ATTR_MTIME_SET);
> -		}
> +		clamp_deleg_time(&iattr->ia_mtime, &now);
> +
> +		/*
> +		 * The ctime must not move backwards. Carry the mtime into it
> +		 * only when that advances it; otherwise clear ATTR_CTIME_SET so
> +		 * that notify_change() stamps the ctime with the current time,
> +		 * which is what a local utimensat() would do.
> +		 */
> +		iattr->ia_ctime = iattr->ia_mtime;
> +		if (!nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
                                                             ^^^^^^^^^^^^

Is dp->dl_ctime the right value to compare against here?  It is sampled
once, when the delegation is granted, and nothing refreshes it after
that:

fs/nfsd/nfs4state.c:nfs4_open_delegation() {
    ...
	dp->dl_atime = stat.atime;
	dp->dl_ctime = stat.ctime;
	dp->dl_mtime = stat.mtime;
    ...
}

Is there anything that stops a client from sending more than one SETATTR
with TIME_DELEG_MODIFY while it holds the delegation?

Say the first one carries an mtime T5 that is later than dl_ctime.
nfsd4_vet_deleg_time() returns true, ATTR_CTIME_SET stays set, and the
inode ctime becomes T5.

If a second SETATTR then backdates the mtime to T3, where dl_ctime < T3 <
T5, the comparison is still against the grant-time dl_ctime.  It returns
true again, so ATTR_CTIME_SET stays set and T3 is carried into ia_ctime.

notify_change() -> setattr_copy() -> inode_set_ctime_deleg() then drops
that update, because T3 is older than the T5 already in the inode:

fs/inode.c:inode_set_ctime_deleg() {
    ...
	/* If the update is older than the existing value, skip it. */
	if (timespec64_compare(&update, &cur_ts) <= 0)
		return cur_ts;
    ...
}

The mtime moves back to T3 and the ctime stays at T5, so the ctime is
neither carried from the mtime nor stamped with the current time.  That
looks different from the comment just above it, and from the commit
message: "An mtime that moves backwards sets the ctime to the current
time."

Would comparing against the inode's current ctime work better here?  The
inode is already in hand for the current_time() call at the top of the
function.

> +
> +		dp->dl_setattr = true;
>  	}
>  }


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
