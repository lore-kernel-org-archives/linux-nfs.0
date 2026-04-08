Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE8613D34AB
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2026 18:25:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775672701; cv=none; b=h3VL1zb9rvTO8rKPmTLp+cHFZWlN3n4udvBOgNeMVN5qlUJudfxOHw4hGhdAiPfNKJTGGMQs2ySF0F7i78kiaRc7ImCZSrfza+uFaGaPqtlsbiVHMEy5lyCrZR/oioC9wZoLkAH6f3dt0sl+IhcCSR1VPTs0LMQP9RR5j0aD8dE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775672701; c=relaxed/simple;
	bh=7AJ729q4Cp/bXTUy72jIeNaMdH0XzQ6V8oT9kikfxxQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=SHjA4yfDA0AQN2YKbFLDmxFaL1Z5JAFv3RbBF1Cjc7VFAGbWZH2AsmQ5ofOVoArdRSNZ6MgPTXGbU76UWTCSTzBkHtilEjzEtmJbeVvd6NMXA31sUKmeMfQb86upkScvpthw23weZiq4xbMDgCwDbMwi+z8PJXiscEYiWBn5BA8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VN8nVagm; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VN8nVagm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E6405C19425;
	Wed,  8 Apr 2026 18:25:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775672701;
	bh=7AJ729q4Cp/bXTUy72jIeNaMdH0XzQ6V8oT9kikfxxQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=VN8nVagmY3KCk0tg5812khNFlCprBzBHpDyNDswACyCoFKqkuHWV6OMOx41zTT/N3
	 ceyyqKw5JfRBmxvPizAj1csryfN+DQ3T83UsKEj7mxBtqzdGdhMtWRSTy1qmc+qh0d
	 CzqcqRGKtKit6yHRTB4M2b8TTBs22iqPZwpKWPzEBMofdQmHH+aBWcVtP+1fYRT951
	 2sqwkxxxYrOTI/clLyUkh3vfuvSHHIXk8fTv7nwqDU+CwfqSuNB7StORWc2qX4PYWQ
	 KF9bHmJ/zK7xTG08B7fUlIu2L6u3o8un4m1+OURyFT/qlsjxGI0OVtDmdjF1k8JOjV
	 56pvkvnqn0+bA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id D0076F40071;
	Wed,  8 Apr 2026 14:24:59 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 08 Apr 2026 14:24:59 -0400
X-ME-Sender: <xms:e53WaYw4uNiZE-YUE3iZiKmXJ05oRSYxpq3DbmDvGkpmVkpLLngeIQ>
    <xme:e53WaXGv3C3GUclKeJU3S8IrLtSmUg3D5fTomiCT4AFs9VXpp-NZwt2RW8GlflFaX
    rFEsJGlteWFWc3vWz6Y-Sp4F5VDk7ta2sf2AZAlheSdR9r1dlO6bWY>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgddvgedvkecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefoggffhffvvefkjghfufgtgfesthejredtredttdenucfhrhhomhepfdevhhhutghk
    ucfnvghvvghrfdcuoegtvghlsehkvghrnhgvlhdrohhrgheqnecuggftrfgrthhtvghrnh
    ephfffkefffedtgfehieevkeduuefhvdejvdefvdeuuddvgeelkeegtefgudfhfeelnecu
    vehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomheptghhuhgtkh
    hlvghvvghrodhmvghsmhhtphgruhhthhhpvghrshhonhgrlhhithihqdduieefgeelleel
    heelqdefvdelkeeggedvfedqtggvlheppehkvghrnhgvlhdrohhrghesfhgrshhtmhgrih
    hlrdgtohhmpdhnsggprhgtphhtthhopedvgedpmhhouggvpehsmhhtphhouhhtpdhrtghp
    thhtohepnhgvihhlsegsrhhofihnrdhnrghmvgdprhgtphhtthhopehmrghthhhivghurd
    guvghsnhhohigvrhhssegvfhhfihgtihhoshdrtghomhdprhgtphhtthhopegrlhgvgidr
    rghrihhnghesghhmrghilhdrtghomhdprhgtphhtthhopegrmhhirhejfehilhesghhmrg
    hilhdrtghomhdprhgtphhtthhopehrohhsthgvughtsehgohhoughmihhsrdhorhhgpdhr
    tghpthhtoheprghnnhgrsehkvghrnhgvlhdrohhrghdprhgtphhtthhopegsrhgruhhnvg
    hrsehkvghrnhgvlhdrohhrghdprhgtphhtthhopehjlhgrhihtohhnsehkvghrnhgvlhdr
    ohhrghdprhgtphhtthhopehmhhhirhgrmhgrtheskhgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:e53Wabg6dllu-SP3M2AEFMA7RNiZb8uEn2osvqZlAmN7haYNw6D9oQ>
    <xmx:e53WaZvrFJWZwqTNX4eZexSNCIODQChXjBEOydigwokvoImfCygIpA>
    <xmx:e53WaehDeN88kO5wDhHDjQnPk6Isx48yjr_pUo05Jplx-O5YPVrnnQ>
    <xmx:e53WaYFPhlYRqNR1L08XS3-8QYHITU3Ka4zhYCWE-tAwDHW2yTARFg>
    <xmx:e53WafIc9q-O16GVLd0x500J7DPSGK1r-YRgJXJ0NLXsiADAcvrBdeOR>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A8E2C780070; Wed,  8 Apr 2026 14:24:59 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Am-qK5lmH61J
Date: Wed, 08 Apr 2026 14:24:39 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "Chuck Lever" <chuck.lever@oracle.com>,
 "Alexander Aring" <alex.aring@gmail.com>,
 "Steven Rostedt" <rostedt@goodmis.org>,
 "Masami Hiramatsu" <mhiramat@kernel.org>,
 "Mathieu Desnoyers" <mathieu.desnoyers@efficios.com>,
 "Jonathan Corbet" <corbet@lwn.net>, "Shuah Khan" <skhan@linuxfoundation.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>
Cc: "Calum Mackay" <calum.mackay@oracle.com>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-trace-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <412e143e-1e99-42a6-a959-654bde4e7038@app.fastmail.com>
In-Reply-To: <20260407-dir-deleg-v1-8-aaf68c478abd@kernel.org>
References: <20260407-dir-deleg-v1-0-aaf68c478abd@kernel.org>
 <20260407-dir-deleg-v1-8-aaf68c478abd@kernel.org>
Subject: Re: [PATCH 08/24] nfsd: update the fsnotify mark when setting or removing a
 dir delegation
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Tue, Apr 7, 2026, at 9:21 AM, Jeff Layton wrote:
> Add a new helper function that will update the mask on the nfsd_file's
> fsnotify_mark to be a union of all current directory delegations on an
> inode. Call that when directory delegations are added or removed.
>
> Signed-off-by: Jeff Layton <jlayton@kernel.org>

> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c8fb84c38637..9a4cff08c67d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c

> @@ -1266,6 +1297,7 @@ static void nfs4_unlock_deleg_lease(struct 
> nfs4_delegation *dp)
>  	WARN_ON_ONCE(!fp->fi_delegees);
> 
>  	nfsd4_finalize_deleg_timestamps(dp, nf->nf_file);
> +	nfsd_fsnotify_recalc_mask(nf);
>  	kernel_setlease(nf->nf_file, F_UNLCK, NULL, (void **)&dp);
>  	put_deleg_file(fp);
>  }

The grant path in nfsd_get_dir_deleg() uses a different ordering
(setlease first, recalc_mask after).

Here, since the delegation being removed is still in flc_lease,
inode_lease_ignore_mask() includes its ignore flags. The mask is
computed as if the delegation is still present.

The result is that stale FS_CREATE/FS_DELETE/FS_RENAME bits remain
in the fsnotify mark. It might be harmless in practice since the
handler finds no leases and returns early, but it creates
unnecessary work.

Should nfs4_unlock_deleg_lease call nfsd_fsnotify_recalc_mask()
after kernel_setlease(F_UNLCK)?


-- 
Chuck Lever
