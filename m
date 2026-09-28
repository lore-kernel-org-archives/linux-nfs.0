Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DBE74F052C;
	Mon, 28 Sep 2026 16:47:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790614023; cv=none; b=hyjHH7ZTWnmy9jWk0PZB0XGCTX2KMazPK06x1vF5dlQr2df7N5vGBEeW3qG0UboMT15Aq40e6mQCDkWDKUS4tZVR9xIM9jf5jf85flHZZ1qk/4ZXbuxYfMQI27CDithR2AgJJU02/AYyQj+EHka4JPF6qsuuGVb6Em6FcjDeLIs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790614023; c=relaxed/simple;
	bh=5579Eg6Z5fe0PG4+7SsAuuS5yuw/Dk88LhhEyBq9w6s=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Tz4U8aSi6FG5GEXAPDrb1h4usv0mueKfROTFGBKRFpJ4Wxz+zkvaB5kIImaEy2CL6bZ39kcVo5XbtHpHI1FD01WrG1uQQtAz5ZA9OpICg13izBFILis7dsPBQLogNs3Aotl9dBthj5Xch74HByC5g1jHyMnXLo502NcoIHiaBOc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=P5BLIhLs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="P5BLIhLs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D5DF51F000FF;
	Mon, 28 Sep 2026 16:47:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790614022;
	bh=lBD63qaXnWLLBfqnNyC9F+p6A7BTsPL4i4ySuINNZSQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=P5BLIhLsLa1iB8Tiai+IZxptDC69s6fmJjrPYtKF2DSrg7rYBSsn6W4MjXYMH62PN
	 pItVSDKRVM1dw508zdNz/QeBfWWEUZhkIPDSRWN9yutS+yCWLGAdAdNwx0Q2GwqR6L
	 7MdvMXBJl5qQZyQsA7kg85pMAsFhdqTyeglNNM4V6P3KJpu17DzHk8zY6CIauHu8Fr
	 3Ren1qpLWQTA3EkzME5EI1m+je3YKav51Z45xzrLueFEkYwR90v9yLBHnKZ7k51OzW
	 dlLiE8pL94+1eyHK54FIvv80te21RY6cL+z277PqKFMXTHGOw6pAdgzZpYZtk+fFUo
	 ER0ntB1lhWyMw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id DD2CCF40066;
	Mon, 28 Sep 2026 12:47:00 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 28 Sep 2026 12:47:00 -0400
X-ME-Sender: <xms:BJq6aogJxxN1-2rusf7MalzOcUZEeu20Jn2G5-XevXOxOAklB8iG5g>
    <xme:BJq6ar0SPtOmVwQAfTqnl1Hrrz39LFGKsdVVn_t79QsQDMqzGQh8ucofXlGkD6IEh
    _XLTQHUWI2CiIdGqbptLRF3wDk-1qeVjJ3GNigblfxuFOdT23ihsD0T>
X-ME-Proxy-Cause: dmFkZTEn3BuhydjKGekcK6XGycjqHXMYkfn9lQdKutVqXGWlItD2EF/eU1IUa0zjcG2Qtl
    g0wU4NSHILbez1Lz9MMWFdjaQ0FbR35YSmzd4v3BmwBmo17L3Nl3m660fTzH60ojUA5ssl
    PYmZS8Qftnnu088u2qfg0pPek9Pj2tWR6mBqSi+w/b7SOHC0DwXONX2hfQtdNArO2dCQp4
    H77J+NZsM5Rmg5fzkpStcJ7HhWg+k9h3GNnlT11FgP/Xe3OprW832/SXlrlFaLaja2mBJS
    VqoKX8AckRSgkURpUQ7hfpwqasPI5zYZI3K+Nig4KNPj8t8CmmHw+miUg7AIra4VeaQUJs
    HwQau4zWO4rrJlQBNxqF67k8ProjjNJteOkbn4g8noCvZw6bdI1eynrzf3l1/LPOuLNSNm
    Jidj6huNZVa9Vt9wSPva8XDtDRsYBdYyOPyBlz9YiX9KlUkn1+pG2w2tDHVTZVNPB3EZmw
    S5qF1DlEqUAdtKgPlzMquFB6/D/uMbkLF1LQ+9iwSit/PFfoC2gidrNepKOI1tX3hgBCWF
    tTOd7ZnleAt5C/6Uc7kOX1FFYq3GObxa1a3Lr2bstNAHPBrRE71se+S8PsIoyBZW+lSYLR
    4kmFULWKoMGi74l8bRMs5ZwSF+I/jykPeM08i8pQZLdu704IE6JtB01MieGw
X-ME-Proxy: <xmx:BJq6ahZDAfBhiQAVkIVwqyE-EAoYk24pqj_Mg8NqMmt30Uai_QCF1w>
    <xmx:BJq6amWcUJUOfoqyXn4zTeUz5MiCVGCG-Vm4czEPMr4sBOu5tGm9rw>
    <xmx:BJq6amSWYro7GMsxkeBzK9RK2AHUHSn-VQyNBnKseVzP-AkaFCx5EQ>
    <xmx:BJq6akM7C5Tccn7SW71WRRXREZEm_qcVybOVGKLFR8hx4WzO_6rDiA>
    <xmx:BJq6akTdt7_yrjv8DKoJV3sEHX4X_T5TgFYWd9y3Rdplw7JgazQfFq4R>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B42E1780070; Mon, 28 Sep 2026 12:47:00 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Aud5W1lPkfGZ
Date: Mon, 28 Sep 2026 09:46:40 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Dairui Zhang" <zhangdairui@gmail.com>
Cc: linux-nfs@vger.kernel.org, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, stable@vger.kernel.org
Message-Id: <19cd5dc8-170b-42bb-9d2e-04534a368c7b@slotpi15m67>
In-Reply-To: <20260927094535.1745224-1-zhangdairui@gmail.com>
References: <20260927094535.1745224-1-zhangdairui@gmail.com>
Subject: Re: [PATCH] nfsd: fix READ payload landing one page ahead of the XDR
 accounting
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, Sep 27, 2026, Dairui Zhang wrote:
> +	/*
> +	 * rq_next_page only tracks full pages. When the reply stream is
> +	 * mid-page, the payload accounting continues in the current page
> +	 * at base, so the data must be placed there instead of one page
> +	 * ahead.
> +	 */
> +	if (base)
> +		resp->rqstp->rq_next_page = xdr->page_ptr;

xdr_truncate_encode() sets xdr->page_ptr from page_base + page_len.
When a preceding op truncates to an exact page boundary, page_ptr
names the empty page after the last full one, with xdr->p at its
start. The next nfsd4_encode_operation() then sets

   rq_next_page = page_ptr + 1

which is two pages past the last full page, and base is zero here.

How about this instead:

	resp->rqstp->rq_next_page = xdr->buf->pages +
				    (xdr->buf->page_len >> PAGE_SHIFT);

That is the same accounting xdr_reserve_space_vec() extends after
the read, so page and base can never disagree.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
