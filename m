Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7DDC3B7A8
	for <linux-nfs@vger.kernel.org>; Sat,  4 Apr 2026 15:01:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775314899; cv=none; b=jCTQObmxrvDvyX4Ws8Qxuu3hOvE7M+XzchoOXynfvidJ876x05mDuTRY2m+8jTZ5JSiKHWm7qCZCZ4U40r+aGrGKtOJc9DF7AyKaEBCxhk1BgBGCVfChxR4hRuo5A+KM8LojaX1O8a+h8QmovizhUDC0tAXUQ2nuclezsJkkilg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775314899; c=relaxed/simple;
	bh=7pntm9ILVajxO+O3fBMq/cp4EKbY7Sbp2hdyHmEK3xY=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=n2O2JSXH0RllawQ3q79xz/dy/9KoQyPRme4ftNhwAfWe9TqewzNNq///NnXjghnnGSCG+OEpFUl2eX806wEreSvohjvvZyXVjJxolB3tZsT+IAlAGnEwPQ/7LDk+a+/p3eVs/fx9j/VvpTP3NungFru0Av+tl6Eqr5MzyRH7f4A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=uR0OnRFA; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="uR0OnRFA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1E884C19424;
	Sat,  4 Apr 2026 15:01:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775314899;
	bh=7pntm9ILVajxO+O3fBMq/cp4EKbY7Sbp2hdyHmEK3xY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=uR0OnRFA3Z8dwhpgFtGLYpFdzwlv7h0YGSAOqC05k7rjpRlO9XPfivvcP4DzKjrMx
	 eeU+SUrgQQggBSwSS+rZKDrdjbwvzHOuSsi8e7deAY+lCQp6Dxu7dpKDW9oonRXpLq
	 7wKLV65FUDKTzIzmPjneIiVMb/DPEoNJsERDSafpmxufugvrUSpoHhQu3spoPrWgZA
	 IGdEu+BJn4IrsSYRoICTRhcnZ9lPmS5ZLizLprm3mjSij405j/goa1csxn7LOVfh0m
	 54gRMkSNTUDHKHnAKeyqdBcf21KWjjEGewEwXiD/xOVULifTZiQ33ddfWI6rTN8DCh
	 gGDUFqVGnG6tw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E5503F40070;
	Sat,  4 Apr 2026 11:01:37 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 04 Apr 2026 11:01:37 -0400
X-ME-Sender: <xms:0SfRafcVbew-q-N8-dF8VvNrzCfW2PeZ2kkjsaaJTWuK64LxXVO5tA>
    <xme:0SfRaQAYcfmDas1gDebYU6r517rqB5Q5DPlURP3SJZdFXnmHw0vI2vzIq4TAU6xfI
    EPCNYVnvmuPPE03jxABlkJwZSHq__ON0_l0reb0iTu1H249M6G0aw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdduvdduiecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefoggffhffvvefkjghfufgtgfesthejredtredttdenucfhrhhomhepfdevhhhutghk
    ucfnvghvvghrfdcuoegtvghlsehkvghrnhgvlhdrohhrgheqnecuggftrfgrthhtvghrnh
    ephfffkefffedtgfehieevkeduuefhvdejvdefvdeuuddvgeelkeegtefgudfhfeelnecu
    vehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomheptghhuhgtkh
    hlvghvvghrodhmvghsmhhtphgruhhthhhpvghrshhonhgrlhhithihqdduieefgeelleel
    heelqdefvdelkeeggedvfedqtggvlheppehkvghrnhgvlhdrohhrghesfhgrshhtmhgrih
    hlrdgtohhmpdhnsggprhgtphhtthhopeejpdhmohguvgepshhmthhpohhuthdprhgtphht
    thhopehnvghilhgssegsrhhofihnrdhnrghmvgdprhgtphhtthhopehjlhgrhihtohhnse
    hkvghrnhgvlhdrohhrghdprhgtphhtthhopegurghirdhnghhosehorhgrtghlvgdrtgho
    mhdprhgtphhtthhopegthhhutghkrdhlvghvvghrsehorhgrtghlvgdrtghomhdprhgtph
    htthhopehokhhorhhnihgvvhesrhgvughhrghtrdgtohhmpdhrtghpthhtohepthhomhes
    thgrlhhpvgihrdgtohhmpdhrtghpthhtoheplhhinhhugidqnhhfshesvhhgvghrrdhkvg
    hrnhgvlhdrohhrgh
X-ME-Proxy: <xmx:0SfRaS09WybdlMPtM07yrEHIg7KzoGw5ugDiFnkp474SszpFMTm1Fw>
    <xmx:0SfRaVzo-keXJyTxRYm8xDRjE1ow4O0JH8zqzJJbHte_kgu5Bi8wew>
    <xmx:0SfRaZFrHFd4X0GYLyyiDx7n0AFbkJnmjn3hN5q30U_OmE6JCKQidQ>
    <xmx:0SfRaYZyt9kjjcdeadbxktINOuHgihdXl5sn0fqvhyjB6pbfzZFQbg>
    <xmx:0SfRabCCYr_33JCOMRlhNyIKITYUEFVK1i-UHdTpe27LGH3RBpQUEGSG>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id BC8D8780070; Sat,  4 Apr 2026 11:01:37 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AOHP4YS4VZaB
Date: Sat, 04 Apr 2026 11:01:16 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Olga Kornievskaia" <okorniev@redhat.com>,
 "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, neilb@brown.name,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>
Message-Id: <d9281142-57c1-4a0d-98b7-1cea19b39cb2@app.fastmail.com>
In-Reply-To: <20260403165335.73070-1-okorniev@redhat.com>
References: <20260403165335.73070-1-okorniev@redhat.com>
Subject: Re: [PATCH 1/1] nfsd: update mtime/ctime on CLONE and COPY in presence of
 delegated attributes
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Fri, Apr 3, 2026, at 12:53 PM, Olga Kornievskaia wrote:
> When delegated attributes are given on open the file is opened with NOCMTIME
> and modifying operations do not update mtime/ctime as to not get out-of-sync
> with the client's delegated view. However, for operations CLONE/COPY server
> should update its view of mtime/ctime and reflect that in any GETATTR queries.
>
> Fixes: e5e9b24ab8fa ("nfsd: freeze c/mtime updates with outstanding 
> WRITE_ATTRS delegation")
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
> ---
>  fs/nfsd/nfs4proc.c | 27 ++++++++++++++++++++++++++-
>  1 file changed, 26 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 99b44b6ec056..66bde3732b03 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c

> @@ -2157,6 +2179,7 @@ nfsd4_copy(struct svc_rqst *rqstp, struct 
> nfsd4_compound_state *cstate,
>  		}
>  	}
> 
> +	restore_nocmtime = nfsd4_clear_nocmtime(copy->nf_dst->nf_file);
>  	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
>  		sizeof(struct knfsd_fh));
>  	if (nfsd4_copy_is_async(copy)) {
> @@ -2199,6 +2222,8 @@ nfsd4_copy(struct svc_rqst *rqstp, struct 
> nfsd4_compound_state *cstate,
>  				       copy->nf_dst->nf_file, true);
>  	}
>  out:
> +	if (restore_nocmtime)
> +		nfsd4_restore_nocmtime(copy->nf_dst->nf_file);
>  	trace_nfsd_copy_done(copy, status);
>  	release_copy_files(copy);
>  	return status;
> -- 
> 2.52.0

For async copies, does this restore FMODE_NOCMTIME before the kthread
performs the actual data transfer?

The async path creates a kthread then falls through to the out: label.
The restore runs here, before the kthread calls nfsd4_do_copy(). By the
time the kthread runs nfsd4_do_async_copy() -> nfsd4_do_copy() ->
_nfsd_copy_file_range(), FMODE_NOCMTIME has already been restored, and
the timestamp update that this patch intends to enable will not take
effect for async copies.

This is probably a variant of the race that Jeff already called out.

-- 
Chuck Lever
