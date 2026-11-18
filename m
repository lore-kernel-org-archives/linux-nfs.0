Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795044178;
	b=zozhxpWATrAEfDC5BSAvlzn2CMFzmIwYaSqZJsb8/Ra0L/EMt9zwQ2bpH4RMol5e3t4L
	 HTdMF9cBDUxU5UDjQ+K8o5ZEx64CB4u5lqENa8XQ7oBagOfJB0/b1lrZW9IsfTooa4axN
	 zpuK3SdZKuaP6B5HsyYBIxUXybtQ0JJV/0KpBYbfBFBNhIfIjcpprX0bZraGacK7oTrnV
	 6ryB/3Aljxmx2JEP/mqyVYys1+0D2eDUjyGQZTo/I8QVrcT6TQONDs98rbItKNf+S5FWd
	 1nxb8bVcGXN2DRHLpkSueIkzyi/esIg/NRLblPIQIj0K1bpRrhXPmVCZYNDRpJ1FbHQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795044178;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=5fXaSXu72hpodaaQYTSyes/tSnQsJEGBgwvJaku5WSM=;
	b=5ehhWw99g8MftG4cTPorXVFgUgyE6FcPDLcdG2GQFifDT+CDh8kTuMjNpqdiJKhMX6if
	 BXP/D2MAHPQhr34Ioo7xnjdivFDJK5w+mG6CkMFNgu3nWBB/gi8zpJPBkAt6D/2QrwMaU
	 qWfrxvrrGojYWkjbm3WseZJO38kqdvYNKGGlyPkUkvf/WomglOWvZ/aTABr/GMFhhr5aJ
	 IqHHjDlPG9uX2pj3N5J4rDdy4KmRJSh8aXqDgWmqqhg2GFfiUgJOeB2JjWB2qSwAKmDLw
	 MLsPWu9SHio6GuqL36+Jjq+EA9BOIdGwELScgYYU5wXUxoBqhQOgYdouMQ3jr5ws47Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LwhR8bxc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6E3E606A32F
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 23:22:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LwhR8bxc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 218C91F000C6;
	Wed, 18 Nov 2026 23:22:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795044178;
	bh=5fXaSXu72hpodaaQYTSyes/tSnQsJEGBgwvJaku5WSM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=LwhR8bxc6jPA8SXP4h9JOzrVcxtQSKOnEOBVRYuTnqjeI5mJFvLcHYwT+zW2Q4Oz2
	 +o49rtROQJL0a1+azHfN4GZzl6TUBD6muod83eBoz+VscjshYuM8woewRuiJJ8Jk3o
	 6AiwqXUtw5QO3Bm4nMnTDsLUrQImN28Xen8NgXmgMXtMuvZzLpqqkE1AuHKik7sK8k
	 reaEGLczmUTittkjPCR+y41Edx0XbI5xuaDBf7e3ikYaRPwsZiFxiGMGuuOHwbWDuZ
	 2rShYovlAU6EC2gb1cICDqQJsk7aej1zXjNCvNl1MiEnhR/hfLOxKawRPG2H+B6Wr6
	 xA3YSC4RFVmaQ==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 29ADDF4006A;
	Wed, 18 Nov 2026 18:22:57 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Wed, 18 Nov 2026 18:22:57 -0500
X-ME-Sender: <xms:UTP-annVx_Nf_z_1BJY3M0P-5feZf0t0mzjlOGYMZlke5yHWNeM2Gw>
    <xme:UTP-alpu--rHTS4tCz9IHl8eSwKHSIZSQqvEUc3zHH39xkeKMvGnyj74vXq5Ahx0N
    _KRiNe98zXY9mFNH9x9RdeBvn-B0lfeA5qC5ou3_7cXjhpsZnDB-EPS>
X-ME-Proxy-Cause: dmFkZTEZ/cLdvqYYBWZjYTDN/Eqcz7T1gh+VCiGpAm55JHOqn8yPN6a2d5j5o41lIX3D2c
    3vp3topRTXjWqm8wE9ZrkxDFcDavl4WCALOrq6fAD9XMsbvtq44p5Ik2B/FJ5M7HwkqBDk
    YPmsLL08Rplv2svFMBvu3qtHIpQTk8URqXsWqyTcQ1XTAhGvBC1nw/q9Z+Pv/dvypM2uMP
    OiBzti1rjh7B50isuTnibFr+oseQg1kcVRe1li62yNIUqAiBjGINOI74JBcDsectFn7Cp7
    jq91D1Hgmaibz/7OxnDOSshzYKpNA9O82VBkR27+lpwsK5Gb0ErfOpT8DeiadaCPSHGHp8
    QFvPedPC/ImboF74qt+9yB2yUuh28pPOomoqhRY6N29eKzGDn3uPNJ/zn+oCsIDWxOvj1D
    sXGZ2dVnBf5u0L5fXHQj6dfxbjT6r7Jy7Ua4/v9c4/+10pjJ3Lcax5G4kLT5KAjpof8aim
    eMvY0cmUjMkCYyrhleSh9klzp2j2ghNlFehF3scYE1BRWbyuGm4k3AtWRPvHpWXG3xFZyf
    kw8gSFBeONTpcQ6h9chpnZuWxBk5Rygr/hlgdmoOXtxN+k+buaHChVaf33iSDNSROvSHzY
    2AvFQq5Z95O1pnHohpejBy1leNT16yuxxd6IOgyxQ+tqIK+Nzd6f9lIctOrA
X-ME-Proxy: <xmx:UTP-ahNepSdGPNvNxlTgid1m55Hbs6FJfu7wMF_D0-Hr8Bt882TMPA>
    <xmx:UTP-ahwukoAv3zpXGYCbE3SX0DmrmKJY3Yc6VgXo5E164l2f0viNLQ>
    <xmx:UTP-aqv_u4r51OwUtxbxOvLfrS9ZWioou7n5y7TdmeCHj_n-Buseng>
    <xmx:UTP-aq7L-UPQiE1YGezH3Psl9nMJGckyhEcFwlCowN7CpwaFzifC5g>
    <xmx:UTP-apQgrY5J22iiW15UckjPd5ZN0h0vEca2dl4lSy93xsgEg4Z32azv>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0C437B6006E; Wed, 18 Nov 2026 18:22:57 -0500 (EST)
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
X-ThreadId: AG3tNfSP9AyZ
Date: Wed, 18 Nov 2026 18:22:36 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Mike Snitzer" <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Message-Id: <1addac19-9415-40a5-af21-9ccd8e86b6a9@app.fastmail.com>
In-Reply-To: 
 <79610683ae2bb6d39feb578a27481d588c245d45.1795024981.git.bcodding@hammerspace.com>
References: <cover.1795024981.git.bcodding@hammerspace.com>
 <79610683ae2bb6d39feb578a27481d588c245d45.1795024981.git.bcodding@hammerspace.com>
Subject: Re: [PATCH 1/4] pNFS/flexfiles: use the MDS for locked-folio writeback without
 a layout
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Ben,

On Wed, Nov 18, 2026, at 1:36 PM, Benjamin Coddington wrote:
> From: Benjamin Coddington <bcodding@hammerspace.com>
>
> nfs_writepage_locked() writes back one folio that its caller holds
> locked, for nfs_wb_folio(), nfs_wb_folio_reclaim() and migration.  When
> there is no layout segment and the file's layout header carries
> FF_FLAGS_NO_IO_THRU_MDS, ff_layout_pg_get_mirror_count_write() refuses
> the write with -EAGAIN.  nfs_do_writepage() redirties the folio and
> returns the -EAGAIN, and nfs_wb_folio() passes it to nfs_updatepage(),
> nfs_flush_incompatible(), nfs_read_folio() and nfs_launder_folio().  A
> read(2) or write(2) on a blocking file then fails with EAGAIN, for
> example when another open context has dirtied the same folio while a
> layout is being recalled.
>
> Resending from nfs_wb_folio(), as nfs_writepages() does, would hold the
> folio locked across the resends.  A bulk recall can't complete while
> nfs_writepages() holds a layout segment, and nfs_writepages() would be
> waiting for that folio's lock.
>
> FF_FLAGS_NO_IO_THRU_MDS is a hint (RFC 8435, section 5.1.2).  Mark the
> descriptor that nfs_writepage_locked() uses with a new pg_allow_mds
> bit, and send its write through the MDS when there is no layout
> segment.  When ff_layout_pg_init_write() can't use a data server, send
> such a write to the MDS too, instead of retrying with the folio locked.
>
> ff_layout_pg_init_write() switches a write to the MDS by resetting the
> descriptor and returning -EAGAIN, which nfs_wb_folio() also passes up,
> with or without the flag.  When nfs_wb_folio() gets -EAGAIN, wait for
> any part of the folio already under writeback, as its loop does, and
> write the folio once more with a descriptor that goes straight to the
> MDS.  nfs_wb_folio_reclaim() still returns the error, and
> nfs_release_folio() keeps the folio.
>
> Fixes: 1d62e659c0bf ("NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS in 
> pg_get_mirror_count_write")
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c |  5 +++--
>  fs/nfs/pagelist.c                      |  1 +
>  fs/nfs/write.c                         | 19 +++++++++++++++----
>  include/linux/nfs_page.h               |  5 +++++
>  4 files changed, 24 insertions(+), 6 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 5c289737366f..2b0a0af469fb 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -1176,7 +1176,8 @@ ff_layout_pg_init_write(struct 
> nfs_pageio_descriptor *pgio,
>  					       mirror_ds, dss_id, OP_WRITE);
>  		if (IS_ERR(ds)) {
>  			nfs4_ff_layout_put_deviceid(mirror_ds);
> -			if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
> +			if (pgio->pg_allow_mds ||
> +			    !ff_layout_no_fallback_to_mds(pgio->pg_lseg))
>  				goto out_mds;
>  			pnfs_generic_pg_cleanup(pgio);
>  			/* Sleep for 1 second before retrying */
> @@ -1229,7 +1230,7 @@ ff_layout_pg_get_mirror_count_write(struct 
> nfs_pageio_descriptor *pgio,
>  			0, NFS4_MAX_UINT64, IOMODE_RW,
>  			NFS_I(pgio->pg_inode)->layout,
>  			pgio->pg_lseg);
> -	if (NFS_I(pgio->pg_inode)->layout &&
> +	if (!pgio->pg_allow_mds && NFS_I(pgio->pg_inode)->layout &&
>  	    ff_layout_hdr_no_fallback_to_mds(NFS_I(pgio->pg_inode)->layout)) {
>  		/*
>  		 * FF_FLAGS_NO_IO_THRU_MDS: no current lseg but the server's
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 71f0ce2bc4ea..aa6d7b658d79 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -871,6 +871,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor 
> *desc,
>  		     int io_flags)
>  {
>  	desc->pg_moreio = 0;
> +	desc->pg_allow_mds = 0;
>  	desc->pg_inode = inode;
>  	desc->pg_ops = pg_ops;
>  	desc->pg_completion_ops = compl_ops;
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 0b42d31f7a75..ec6b771b8dbe 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -627,15 +627,16 @@ static int nfs_do_writepage(struct folio *folio, 
> struct writeback_control *wbc,
>   * Write an mmapped page to the server.
>   */
>  static int nfs_writepage_locked(struct folio *folio,
> -				struct writeback_control *wbc)
> +				struct writeback_control *wbc, bool force_mds)
>  {
>  	struct nfs_pageio_descriptor pgio;
>  	struct inode *inode = folio->mapping->host;
>  	int err;
> 
>  	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
> -	nfs_pageio_init_write(&pgio, inode, 0, false,
> +	nfs_pageio_init_write(&pgio, inode, 0, force_mds,
>  			      &nfs_async_write_completion_ops);
> +	pgio.pg_allow_mds = 1;
>  	err = nfs_do_writepage(folio, wbc, &pgio);
>  	pgio.pg_error = 0;
>  	nfs_pageio_complete(&pgio);
> @@ -2057,7 +2058,7 @@ int nfs_wb_folio_reclaim(struct inode *inode, 
> struct folio *folio)
>  		return -EBUSY;
>  	if (folio_clear_dirty_for_io(folio)) {
>  		trace_nfs_writeback_folio_reclaim(inode, range_start, len);
> -		ret = nfs_writepage_locked(folio, &wbc);
> +		ret = nfs_writepage_locked(folio, &wbc, false);
>  		trace_nfs_writeback_folio_reclaim_done(inode, range_start, len,
>  						       ret);
>  		return ret;
> @@ -2084,6 +2085,7 @@ int nfs_wb_folio(struct inode *inode, struct 
> folio *folio)
>  		.range_start = range_start,
>  		.range_end = range_start + len - 1,
>  	};
> +	bool force_mds = false;
>  	int ret;
> 
>  	trace_nfs_writeback_folio(inode, range_start, len);
> @@ -2091,7 +2093,16 @@ int nfs_wb_folio(struct inode *inode, struct 
> folio *folio)
>  	for (;;) {
>  		folio_wait_writeback(folio);
>  		if (folio_clear_dirty_for_io(folio)) {
> -			ret = nfs_writepage_locked(folio, &wbc);
> +			ret = nfs_writepage_locked(folio, &wbc, force_mds);
> +			/*
> +			 * -EAGAIN asks for a resend, which can't wait for a
> +			 * layout with the folio locked: resend it through the
> +			 * MDS once any part of it already sent has completed.
> +			 */
> +			if (ret == -EAGAIN && !force_mds) {
> +				force_mds = true;
> +				continue;

I think I've managed to confuse myself thinking about this. If ret = -EAGAIN,
we restart the loop with 'force_mds = true'. Won't folio_clear_dirty_for_io()
return 'false' the second time around and bypass the nfs_writepage_locked() call?

I would not be surprised if I'm misunderstanding how something works here.

> +			}
>  			if (ret < 0)
>  				goto out_error;
>  			continue;
> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
> index c38e4b380be5..d64332afc374 100644
> --- a/include/linux/nfs_page.h
> +++ b/include/linux/nfs_page.h
> @@ -120,6 +120,11 @@ struct nfs_pageio_descriptor {
>  	u32			pg_mirror_idx;	/* current mirror */
>  	unsigned short		pg_maxretrans;
>  	unsigned char		pg_moreio : 1;
> +	/*
> +	 * Set when the caller holds the folio locked and can't wait for a
> +	 * layout: the write goes through the MDS instead of waiting for one.
> +	 */

Any way to whittle down this comment to just a few words so it matches the
style that we usually use? (See pg_mirror_idx a few lines above it).

Thanks,
Anna

> +	unsigned char		pg_allow_mds : 1;
>  };
> 
>  /* arbitrarily selected limit to number of mirrors */
> -- 
> 2.53.0
