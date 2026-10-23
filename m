Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792777543;
	b=yT6WK/pBueT+8aFUI7D4LdU29jDTMo5/89IEpqxn9ajemxzrl+Pa8UuY3TkpRkwqhVjz
	 mdN1B1uFOmKm4R4FSC/Q2NX2+MfbIqrunGKNi43YO669GJOSfBeliqNEFDbgjEGvEQywf
	 iO+C+fmZyd7rAm9aE7lSkrzyYIOyby+p3f3mW5FeHhTK/UUxKXtj5erK+BKEwW5+bSx9E
	 00D5ciMS9pVcCwtByYfNXBdjokhIeTa3w+WWyUxeZdV2V8Bdswg2kkp66R/gG005QvuvW
	 1HqWYT1MUu1noy653WwReGScqMXiOGqHUOh7fjOxENcFyZV+ShrvYINY2UPz9IpTBRA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792777543;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=+K8VmVMqKOof2bN/ApBJbL1jV/83LdW4iTCquE9kKQw=;
	b=SQAJMZXV96Ouss/q3/6QhHy43Y7mO1GmjPU2bJcWqxguT8QlY9IjEkHLN3Cqw1H1SXQp
	 HR2R5Nb15FN2k2aPtpASdNH8Y8EapVQVUN3e8g91024SsA6MMfaPIWtBgG6Yq82VcTQ4c
	 GNgMkXbiXZasx0o3OAUWcvKGJhFY+lNjBq51vxYW0d0yXODjEU4qS23+tBoSDcPGZj1mr
	 CLmGTZRiof2wpW8J35cEYJs1Ft633m7JQtoMZbD4RvRYNh77j8Rm1u9dxzLKG9lOF7sOY
	 hoX62IJLgaAszblMAFgnH9kg8vz5S0hZvkfkRjIDcBwjilW9mPmrNxtvHgn6TjThu2A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MKrt8z95;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3548F606A31A;
	Fri, 23 Oct 2026 17:45:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MKrt8z95
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6F4E61F01829;
	Fri, 23 Oct 2026 17:45:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792777542;
	bh=+K8VmVMqKOof2bN/ApBJbL1jV/83LdW4iTCquE9kKQw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=MKrt8z95nduJMsZ46pem/LKNckFHs4IOKk0GiFUkc3kcey7f8+E15FB5XwT6Vw94A
	 ROw7OoY/0zcGxwSht62YfzAZPKY5kg+9qq+99CUpROhWdi68EVj1Oow08v1xWlk60w
	 rOyCjvc1N9sycWvglR7FXgBk3MQoeHL9wS4ZbjDg8lNW9hQ/E4xfuafur/6cixXsUK
	 3wk8bvH6TjHQ46YUyxGTiOCspzoTqaDpdqrPlO05KH7WJHHVQa2Gk1xHFiA69+5O1c
	 GTUI9mbf/OJD05Z4QeGfzXWSugs0/vBBSDlOJSJM8Yck8onToyGp2RC66pUFuzHAH9
	 rvh1MsNeZ+prw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A82B9F40067;
	Fri, 23 Oct 2026 13:45:41 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 23 Oct 2026 13:45:41 -0400
X-ME-Sender: <xms:RZ3baiRgESbIfk8wp9J4GDntN9ZHLzKsIejKjhDrXylUTqZSc7OtIA>
    <xme:RZ3baikbhYbg9_KJmjqNbuHwj38uFWUCI2e8xlDBrTc3Im5t3Okte2kkFF2N884-h
    JmO15WeN1S5CFsTC_hXbiFczUcd5m4vWa_gQlRzGZJpLWX65XNR5yU>
X-ME-Proxy-Cause: dmFkZTGw9D+wWvKhDs5hJFHaE33hWLdp5MJJPRON22Zj+F2eCnb7T3BTPUqogEpOQrGpoU
    X53T4/KSX1qcP6T682bAHoWiDbSAvDlKrXjoqUAXHJ+X7DuUjowthh/75oLiGbHVGRrYvy
    Ovxp/qIK0TBACpUtpr9HPOhI/W2aQ0NGI72CDCLfYSyzrinyf2y5Gqt9WZXJirg/VcS2wT
    KyOdEZpnkBtl+peUqWtft1knu0XgIWpBIBcqUUnM3VtMFZcAeRnPDS9Gxo76KWvXUoNzCf
    +dUggxkUwUiEH4RQkmSeyVrhCYKPh8Ucvj6N6zYPK0vcUWmb3W2SiJCxsX5b/HNxc5KZsP
    9xHa/wLBKF8Pm7Hmru+7M0hW2UddErbUSA563BeoGzDDauHiqI1VMpsakrbLG7zeJKmGhZ
    59c/kcupFWVb//JPZAPvOQID0NUlNil8cywKpk8d07LqtLq3EvK9a4DVpp2RknuyHnVZk+
    TSoi+tRv/xUCqRV71Cesv/nC/VV7NoGe8xlYVKq7mbxfT80K4U5WlLP3TVWPr4WCnCwbYC
    g7V2SxXA4RaWKiweCOGD6TSOVF/MJQ+dqamZc7tLBcz09vNRR7UyYR+xdb7h3O8GmdSNsr
    BsPc8f3hwH/a5Ln1Hhp1tYUMJKBRmSg2BFXhm+zQj8nQ4ZFlsNITgmC5qhww
X-ME-Proxy: <xmx:RZ3banEdxmK5GIshwTV18B6HDRUCrQjQGipd6QkFV_2NDPHigXiZlQ>
    <xmx:RZ3bahBbpDx8lD1TeNgaYKt4j52Xvakw_Dqt3-AyFnLwcJ1aeh2P3Q>
    <xmx:RZ3batAIeciA0vfdxa-vLOKT4C0Nei_1GaGckaDgGvsrsuGL6l70lg>
    <xmx:RZ3bavOT-TZZgCJvN4KIld23RQQWCYjYGbtxo7kiHmSm0ousICc6JQ>
    <xmx:RZ3bahOeq4hd0P8PRPwhP2_dJRcQC3CEJ4Fu4AdiaOIuvO2BJXKZSJrM>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8303778273B; Fri, 23 Oct 2026 13:45:41 -0400 (EDT)
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
X-ThreadId: AnedLfdbxVbc
Date: Fri, 23 Oct 2026 13:45:21 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>, "Jeff Layton" <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Christoph Hellwig" <hch@lst.de>,
 "Jens Axboe" <axboe@kernel.dk>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 "Jonathan Corbet" <corbet@lwn.net>, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org
Message-Id: <36498551-15ee-4a55-9757-54aa8a07085a@app.fastmail.com>
In-Reply-To: <20261023024548.71123-2-snitzer@kernel.org>
References: <20261023024548.71123-1-snitzer@kernel.org>
 <20261023024548.71123-2-snitzer@kernel.org>
Subject: Re: [PATCH v8 1/7] NFSD: cut a misaligned direct-mode WRITE at the mapping's
 smallest folio
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Oct 22, 2026, at 10:45 PM, Mike Snitzer wrote:
> nfsd_write_dio_iters_init() cuts a misaligned end of a direct-mode
> WRITE at a multiple of the larger of offset_align and PAGE_SIZE, so
> that the direct middle, which invalidates the page cache over its
> range, never shares a page with a buffered end.  But where the
> mapping's minimum folio order makes the smallest folio a block larger
> than a page, the page cache holds that block as one folio: an end cut
> on a page boundary inside a block leaves the middle and the buffered
> end in the same folio.  The middle's invalidation then drops the folio
> the end wrote, and whichever of the two neighbouring WRITEs comes second
> reads the block back.
>
> Cut a misaligned end at a multiple of the smallest folio the mapping
> allows as well.  Where that is a page, nothing changes.
>
> Fixes: 80728157d1bd ("NFSD: cut a misaligned direct-mode WRITE at page 
> boundaries")
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  fs/nfsd/vfs.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
>
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 9219f8eb386d..ade00dabef18 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1452,13 +1452,15 @@ nfsd_write_dio_iters_init(struct svc_rqst 
> *rqstp, struct svc_fh *fhp,
> 
>  	/*
>  	 * The direct middle invalidates the page cache over its range, so it
> -	 * must not share a page with a buffered end.  An aligned end needs no
> -	 * buffered segment; a misaligned one is cut on a page boundary even
> -	 * where the offset alignment is finer than a page.  A WRITE may end
> -	 * at OFFSET_MAX, so the prefix is sized as a distance rather than
> -	 * by rounding @offset up, which could wrap.
> +	 * must not share a folio with a buffered end.  An aligned end needs no
> +	 * buffered segment; a misaligned one is cut on a boundary of the
> +	 * smallest folio the mapping allows, a page or, where the block is
> +	 * larger, a block, even where the offset alignment is finer.  A WRITE
> +	 * may end at OFFSET_MAX, so the prefix is sized as a distance rather
> +	 * than by rounding @offset up, which could wrap.
>  	 */
> -	cut = max_t(u32, offset_align, PAGE_SIZE);
> +	cut = max3(offset_align, PAGE_SIZE,
> +		   mapping_min_folio_nrbytes(nf->nf_file->f_mapping));
>  	prefix_end = offset;
>  	if (!IS_ALIGNED(offset, offset_align))
>  		prefix_end += min_t(loff_t, cut - (offset & (cut - 1)), total);
> -- 
> 2.52.0

PAGE_SIZE looks dead in the max3(). mapping_min_folio_nrbytes() is always
at least PAGE_SIZE, so the cut is just max(offset_align, min folio). The
new commit message and comment both describe three independent bounds, but
the accurate statement is two: the DIO offset alignment and the mapping's
smallest folio.

Also I would like to keep the helper's unsigned long type instead of
narrowing to u32.

Post an updated version of the v7 patch so we can test and review that
as a single change. This will also archive that revision in the lore
archive. This will likely result in merge conflicts with subsequent
patches in the series. If those are just comment conflicts I can fix
those up when I apply the revised version.

Do not include the new revision of this patch in v9. v9 is now patches
destined for the MM tree(s) while this patch goes to NFSD.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
