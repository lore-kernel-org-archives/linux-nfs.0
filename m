Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45E694207A;
	Sun,  5 Jul 2026 01:16:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783214203; cv=none; b=EaZXSDRFeC1xW++xjhVouVLUE/3g4LhjdRgeeIETu3JiphcR1BtpY6nuhsePHO5Pu+qlzoCIeHP0GJEXiYHyF2hCWGStIPjJVFWb9f/5pUTM4ZuUVCFd1kmTO1M5A5qtq7DODzA9RGx0LoYB9kYsRSqS5lMaZ+2dbrKfUVD/CXk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783214203; c=relaxed/simple;
	bh=otmSyEE4r4W6IWXiP/y5hUShoMAMAB0YFm14wMkqnt0=;
	h=MIME-Version:Date:From:To:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=pGQpWYYyz/jz9PpUzgSLLwLhJiz8KIsUdHhbB+NRDT5015g8DYjjaofFX16x5keFSHL41ZDqCrujlFnCUccHDiogZNC5bEPQmVXPrCFWTx7lcKB8iDNdgOJqn1cGpQvjE/ufCI4WHMOa3QXHpTgYVAIySu5w3ZODR02YOEue/qg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UepoQlbJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UepoQlbJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 76B851F000E9;
	Sun,  5 Jul 2026 01:16:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783214201;
	bh=igvSi8BiREbcSC0oNNsjOWRl0EPberDPu7faJjPRXrQ=;
	h=Date:From:To:In-Reply-To:References:Subject;
	b=UepoQlbJ8QtRVlnl91Rie+XrPdIkwbHaNMsESC0rSJBxPZvpEwEqfAu1lt9t6VH8y
	 USfyVobBXzqAXQA2HLtrXwvGOoc+n3gzTjydRLzhDFvbOiDQx0vPYuEKg476bTXV8K
	 8x9niA1R9XgWtD1ZhnyJxnOeM1MnV5X99IVkogu/uNgE5gltDt1qtWQgePsm/B42ca
	 0T30ovtRsuCur6WPqzCf8xHmSVzbq6QHl+CDu4S/hQRD5/5Sq+EJEq6L0pYWvtnOj1
	 hLHu9oEVWEZnp/5sgw+Jl2K//7OAGTdS4FpdcCwFfbROK3giEl1yLbnaNdPn6EQh3g
	 X0VoNnncKntdg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6ED2CF40068;
	Sat,  4 Jul 2026 21:16:40 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 04 Jul 2026 21:16:40 -0400
X-ME-Sender: <xms:eLBJarmy0ZsUQVvfE7jhNWBJ6k_h_uWGOz2-fUoYzGYymD9Gi8A9Ig>
    <xme:eLBJapoi9sp_kPpE5yeJfz3XqjBE9hfrn5Hn9GCYN-sH9YhIiJBZj_RqniOnAFIJg
    H2HlUXLvS6fucLyAB6MQgMNPyBpR8asLM1jxyFLFLpqG6iQqNUszTU>
X-ME-Proxy-Cause: dmFkZTGGPrGEcY3Xavg7LixQR434I8qQcsHVc+5LV0XIzwtFC2//o1Lx0ZU2guU0T7W/Rf
    t3Kby0aaQCmN1hWVuNJKYVCqPvYuT0exDmeVkafQNBJ3KiHDVCQFnIf+SUnMAkKYYh7U4v
    yNhrW2CswauWkQyj9pP3nHOkOuIBISAPWFrl/5jGFEgXRkiAK7Fxbn+0apyDULg3iRmi67
    76dfT2TszxRLiIr6bTNVez4eHk/EIyGw0BuhbiAmQAM2nfcbYmcmxdj+W9sF1reUGoZcsN
    arzI7l/nek3XTrLqV1AVfpROWSV8WWcg1DOwUu37dIss1IwMT/VzqZeC3I8q0Jmw4/JII/
    7Us7RehNGf0TIjYPXTd8V27708ftFjA5vBCxI0Fzvg7JeYnNLHKObiyo5G2BtOucBxtqkS
    48UsRafqQV+jikCld2pH4gNVeDMxVPmdBT136V2HH1oD+lnw3Y2FgoUz/Vbi3aF2WBDZnY
    +poQ0DMocRzjbs+hDDvFNsjDUgPvqT3zZYs2v1OTqBm4xDlpi1cSRSa9JhE1xNgqtqZJrz
    MbOA5eMcuNRSSutupmraSbBv4+ytgG4OhPt0OiE5vd4U90nToBFmFUUO+oFv4rX1Bo32zk
    bA0VkxO7zsn+D3MQR4VEDxe+qg9ZM0RESnszWHUfufl2UOJSuIoMNGF4w+Jg
X-ME-Proxy: <xmx:eLBJaoG_sTYISWnVP9vF9ZNsztmpPCMblmWQfZweB0zQTpdReJKYtQ>
    <xmx:eLBJatVtYEUVFiGWbCJY-WeprbiFpQt5Lfs2sI2hWhTqOw6b4QmjEQ>
    <xmx:eLBJakVy26UhoHoFEjlIBKlvjxQ2-_-75RNM08xKtA6TeuPOAyONeQ>
    <xmx:eLBJarKFaScc0uYQVnwXg4E4LObxJXIvI3ZWYAOUffIk0Rf3exG4Zw>
    <xmx:eLBJasCtQbkiWWfR5aj3Iv15Rb5vxp1T-cBJl2P_So3vnkfqI-y6It1W>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4B5BD780AB8; Sat,  4 Jul 2026 21:16:40 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Sat, 04 Jul 2026 21:16:20 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Guangshuo Li" <lgs201920130244@gmail.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <4fe80ee0-d032-4355-abff-eb499dbe2288@app.fastmail.com>
In-Reply-To: <20260704172300.254447-1-lgs201920130244@gmail.com>
References: <20260704172300.254447-1-lgs201920130244@gmail.com>
Subject: Re: [PATCH] nfsd: Fix dentry refcount leak in nfsd_set_fh_dentry()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sat, Jul 4, 2026, at 1:23 PM, Guangshuo Li wrote:
> nfsd_set_fh_dentry() gets a dentry reference before checking whether an
> NFSv2 or NFSv3 filehandle resolves to a V4ROOT export. Such filehandles
> are rejected, but the rejection path jumps to out before the dentry is
> stored in fhp->fh_dentry.
>
> As a result, fh_put() will not see the dentry, and the out path only
> drops the export reference. The dentry reference obtained by dget() or
> exportfs_decode_fh_raw() is therefore leaked.
>
> Add a separate error path for the V4ROOT rejection case that drops the
> dentry reference before dropping the export reference.
>
> Fixes: 8a7348a9ed70 ("nfsd: fix refcount leak in nfsd_set_fh_dentry()")
> Signed-off-by: Guangshuo Li <lgs201920130244@gmail.com>

Thanks for the report. It appears that there is already a fix for this
issue queued in nfsd-next:

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/commit/?h=nfsd-next&id=ce7d3cc59012382bad5946b4cfc2cdcaabb81163


-- 
Chuck Lever
