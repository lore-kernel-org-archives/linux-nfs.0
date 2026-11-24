Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549564;
	b=ozyiPM0zYGARA7n9Y+48ghCKhX/hzuZ9SiI/mNNdgVNVYyj805fB9wyCi3BOnzQ+VfbR
	 iQVlPRLWMdWp7D+P0jSJtAQHhm7q7To59K1Jqy71/rBJeIHHq+g+ShlRza8tFbY+sx8Tq
	 vBHpTrUQq/AeyTvblfEZFWy6Chvz4a7J8ceVn1h7zz+tgUEYxToJDnU/E2ihUjdLhOPpc
	 jkdd23rZcgXp9Hce+0g1bgcTY4KjF14Cbw6hnPq0bypJtoefiAYx0hj+tuCO5Lt/+WFvB
	 LwILKOmxRRBmhCUXx3bDyDPT7ognhs5rJjpd8m6SWIf/ExZ6dlqcPWRB7YiHavgToeg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549564;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=LCofSNFbI0s1rXSkfWimx4CW5OYd0h6fVWA5DvQGnYI=;
	b=ZqbXe3K9neRCIfo8mJ2i+IXWgwUTUSF+/BDWg1BNOsHe+U75TXuJu7w1R940YLNZatIm
	 dmOTG1kzEA4O1FVFYPlnnrQCM7ltgpykNz7U4ONSRUIjQBGhjrZXgCCZY4pjG1zIQJpoz
	 lGEoI+eYpfwkr2zjmXq6BG1kS1aXHWh8lhRcnkPG9l6xY1Y4Ta4VerT7r9bXx+TOi0p+3
	 hqd1rOOouPMpLdRNYknrUIDpNOiEearPdi0rYxOFpNE1CVlhsLUtnEuZeHA7asXy28jQp
	 dlBEtrty32AgdKb33pcLQQCFElp8PsUIL5skxbSAUENKZOyZ3HUuoQ1fk6akC9OHl/g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DOrJXpN0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23B18606A32A
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 19:46:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DOrJXpN0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6651A1F000D0;
	Tue, 24 Nov 2026 19:46:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549563;
	bh=LCofSNFbI0s1rXSkfWimx4CW5OYd0h6fVWA5DvQGnYI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=DOrJXpN0CWZGj84b9CtTMaBUbpL+5JVeEwn5x/rTnWXUlQVeKhSZSPavxyzUzyy+t
	 /49PI8hnFa8qfJ7kAnIiHB/ULAwmOFnQAigluN/nlJwbqu2NuOMrOu00CyVKDTlI0x
	 gdGRh0vV2zLP65TgMgQh3NBGldu/WlYnmXR+pA8ap+3oqU7JGEIlGswTJyBBmKTfAD
	 7ndV+W0Y2X2mLCbIJen+FLNyPm0DPNc8MuiM1WoG5aLYLs+i2Pz3SsFVaOUY0Rlw+l
	 2uro637s/cXMCVsZpYs2hF6ZRcviTOaixu4ibgcSrSGLmQxWYwMc0Vbqgg4KP5cuaf
	 O/gHuSBdFwT9Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A2E20F40066;
	Tue, 24 Nov 2026 14:46:02 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 24 Nov 2026 14:46:02 -0500
X-ME-Sender: <xms:eukFa1yGttBhT_zlj41HWJKXpoEHy2_nDY-ebJn_Z9zUuyExktYJ5Q>
    <xme:eukFawGxzFqdcBU4m1MNMjiXwmvQr1wmFK2uOKMu9iZVutsxa19_cYnEXMMmaDkpI
    RA0y1JiG089_Q2zOnwqHFXnHfikKRpxZazWreGbB1WkXcIJBvfGc5XR>
X-ME-Proxy-Cause: dmFkZTG0pnDsNYC7eqjWX5ieTnxMV9rAf3IVl9Gmg7GollZX2e1AGywMzijAaxV8zf1Tsa
    1xI1Jsuh08PebEKLgahCxaXGlu3IX5/A+9P56MqURhMiwRl2L/yInLknM5QjHLku2EKiNA
    no7lWBZ5Oui/Q7LIMWC5X4K7dQ1Bpwa3v8HM2CnLYA6GWJ2GgngbTOrZ2r7HjsICTclvvV
    BhIVur7228o/uVtRE2SrZTxGIYmc2L7/uulrbHFSAt0WBvm2FWbvdm13KOeHFqitM7K6Xl
    tDbKr1KhO8kOshtXvjO2U0ku6YEgMvQCvzDat/WDYfPvx8lyQdt2A+zsd8LwFqkfhwUQVD
    rUtx8DdT2WijmV8TqIn2If2ClFH0cB0rm+wrY1Hpr8Zk/vkG+VupQWJDRSDpLLfo5UqwX7
    /lNey15XCT8GsQRCgM7QEteWF1J9YPrBpeSCkxSz+GIdEWrZ5TwS17d5XUz9AgXPXILTIJ
    Wk7X1T86nlojVBhbQn7k7YixemssSVwZyz5YfiVjkE/HmfYnVTlvKZx5XAb/B5lY71/7Vv
    QIMd16XV1M27Dxc7/yvSqxea99mEKy+IGnB4llZHJtLGTf0KP/PFj7bsyX0EQzDDCD9KLa
    LZ+pNMMi+YvzJ1ljktZex6j4TQiae9+SFbVsz3MyCWO4xZO7eR91YSvB4Cdw
X-ME-Proxy: <xmx:eukFa0H_JHtpqgM3XOZtpEDTdF37PI34_ChDFkzS73drk2XsvlTGmQ>
    <xmx:eukFa3Uy6s45TQeW8xtEie3qR9EMbodOelobU_vLkLXsQoEJFfO1uw>
    <xmx:eukFa0woJ6W3LHFiW7OUAsK0ntmcyUKkqOxhchNgcIwNMVVAhH-Wtw>
    <xmx:eukFa0RuqG4swe7zOTMDpLmKET91RUFKi3fm5bpIawScutIDH8kYXQ>
    <xmx:eukFa4hbO5Jg33MqgdOkdm_UTgqPnTReRlEW1VbRjjzQEHs2xcPnh-F6>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 72B6B780070; Tue, 24 Nov 2026 14:46:02 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AEoWWOHHZmTg
Date: Tue, 24 Nov 2026 14:45:42 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Dominik Maier" <dmnk@google.com>, "Jeff Layton" <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 linux-nfs@vger.kernel.org, dmnk+artist@google.com
Message-Id: <3124cf61-a6c4-4d38-b0ac-d4d7a62ae4b4@slotpi15m67>
In-Reply-To: <20261124180606.73719-2-dmnk@google.com>
References: <20261124180606.73719-1-dmnk@google.com>
 <20261124180606.73719-2-dmnk@google.com>
Subject: Re: [PATCH v2 1/2] nfsd: return GDD4_UNAVAIL when nfsd_file_acquire_dir()
 fails
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

> Note: matching your snippet, this folds any nfsd_file_acquire_dir()
> error into GDD4_UNAVAIL; let me know if you prefer narrowing it to
> status == nfserr_acces so errors like NFS4ERR_NOTDIR or NFS4ERR_WRONGSEC
> still surface directly.

Yes, please narrow it. My snippet was too broad.


> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index b76320c265e1..dd17a6b47222 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -2873,8 +2873,10 @@ nfsd4_get_dir_delegation(struct svc_rqst *rqstp,
>  	__be32 status;
>
>  	status = nfsd_file_acquire_dir(rqstp, &cstate->current_fh, &nf);
> -	if (status != nfs_ok)
> -		return status;
> +	if (status != nfs_ok) {
> +		gdd->gddrnf_status = GDD4_UNAVAIL;
> +		return nfs_ok;
> +	}

nfsd_file_acquire_dir() verifies the filehandle with S_IFDIR, so a
GET_DIR_DELEGATION on a regular file fails here with nfserr_notdir.
RFC 8881 lists NFS4ERR_NOTDIR for this operation. With this change,
NFSD replies NFS4_OK to a client that asks for a delegation on a
regular file.

The empty-filehandle case is less obvious. Both retry paths in
nfsd_file_do_acquire() call fh_put() on cstate->current_fh before
they call fh_verify() again. If that second fh_verify() fails (say,
nfserr_stale after a racing unlink), current_fh.fh_dentry is NULL when
this function returns nfs_ok. Doesn't the trailing GETATTR then fail
with NFS4ERR_NOFILEHANDLE, rather than GET_DIR_DELEGATION reporting
the stale handle?

Testing for nfserr_acces covers both cases. __fh_verify() calls
nfsd_set_fh_dentry() before nfsd_permission(), so an nfserr_acces
always comes back with fh_dentry set:

	if (status == nfserr_acces) {
		gdd->gddrnf_status = GDD4_UNAVAIL;
		return nfs_ok;
	}
	if (status != nfs_ok)
		return status;


-- 
Chuck Lever
