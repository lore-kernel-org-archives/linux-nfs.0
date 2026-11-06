Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793992460;
	b=uQdShzbr5PD11F7oOoGEPFY7mdsx8y/vGSRXnnOykUlgiKYXVj5zOzTAaCJy6j9RfFeS
	 vTnS8/dX7woDEXjfwBax2DxD7QQqh4wXzvypCYhJV4XdX2pk5Bswhss6F/gEUZr/UrpDI
	 lBaTjk4RjBOjx6EH7hSw4DH6JPGb1COFC2A1AE8oeGXnE5250ceQIJ1SEwFL9JYNz3VJR
	 nDu2NeEBTpR1Dg4XI6oEf8CUwADLTK0saAV5jVTnDDQb56z+VSKQTIFS/2y9U6+tiC0gO
	 IGQykkDCZ/to+F9FzDbTZUA9mDj75PdErNevuptuaTAT1GGkXC/AHStgtG9u4rvhUxA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793992460;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=akmDYdWU5FZhev4F7P1UhearEYwmN1Tk4YBFQtfnfmw=;
	b=RYVqueeQt2Yh2ygo3KNtUDM3UuZUjt5BTLafCjT6XiEJoEodoudpR1aZRu7logZ+k27n
	 pINdQsN5V90RCKQYpdfaMwftAwfUglPXNHOjFkl5M82HtGYuEfEf6vvfVx27YIH5nDyi0
	 FPbOtpjSjkX0kLL12XCO61uW5+LdwhUZv06Hz5cLoLTUQGaAyj0yMQ4EJrnsKo6D3AqqB
	 u69eGGBO3fnIswZiESQ/sZ86RyEXDZKc7ZayPd2Su1M2m/tW5CFErh5bXqaCF1QM+KgHE
	 FTyZE+RpvhHE/mFK6r3HFErfcL4ilRVk1oYU8zKeaHWBf9t7U2kfrC5VRFCp7lX/64g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SyzRVsZI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BA49606A32C
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 19:14:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SyzRVsZI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 976C31F0089F
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 19:14:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793992459;
	bh=akmDYdWU5FZhev4F7P1UhearEYwmN1Tk4YBFQtfnfmw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=SyzRVsZITZ0mdp7NRa4Ls/znhBOaPlRlMXGW0l7xCQqSnClHaoEZeJ1VelN63TfbW
	 UMyC9GrAE4eHhpHpsZX0LbRPsSSoL8EBKWvD6dTEb+5OYKwgzpbbpioFMHx8FMIPMP
	 VusIonFwgieUejhLyMQFbVI/l8JulAavnFmQOwU6eRUm5U97ChO2DeVoUrmrhj7a8S
	 sJD1UP5SeKmbBXbYTleKS0iHot1geeAWfsUf7Me7nJArjN7x6DTSq7McQNUAPGUcoV
	 eNq2G8xceDdDIGUmGySXFta7YEzIILTssIvskpEKOogxe+qh6iDJ2GR6H6eV5Ybh9j
	 TtMHkigVj0AXA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id D1911F40066;
	Fri,  6 Nov 2026 14:14:18 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 06 Nov 2026 14:14:18 -0500
X-ME-Sender: <xms:Cifuai91ncRZv7tpBTAytIGgzavEMHXCP-nIHtdAgtSD9t9evmOjXg>
    <xme:CifuatjyNdP2lI8ocdbpUG6fqnPFr2O3t8gZ33M7xg12WL8PeYirX1f7Fb8sfFfht
    l8cdAjXGyU7agbhg6F2H04iO4_zWQffzhdzYxcAkzW3Cp-pglUP_XI>
X-ME-Proxy-Cause: dmFkZTGYjNCHkaNmY3Q+cj2cRyCZmJqRsCQLXmtu2Jep/ORnb0EPacyx7Xb8phlUEc7PkZ
    ZggWDJBSumkvNeARz2TduytgpXPflraybKgrU1VTKQ7//glKxiYfLNtfzrd4xham3l2gnf
    jq1BRy7dnhLJvym/9kOE+kWt5AJho3NaC2UevqURpcgq2+T0pod/N2eW0CXfbcLyekvzzT
    PexvE5cVi0FLKm/boNjZMrIcnzmSOkdgAfmzShqP3bWg8wnlg2KUsabgEg+aatvVAfKymx
    FBzvmQgFBalp5fmmNDDZ51P7G+5H3++J/YB1qk33aLvZ4ZKbBIb+aQdBfedDKDa7NIZrnE
    1VrKs9bpWWgGXEqXGEZ9nBEcya9/aBzktiyPX+uvgf09Loc3WfJ00TX3MRzl/661ASkTc1
    yZ1BI7pp6BO7aFn5bgmCbncN+fmaiHfdsHsfvbvqN56wI8094tWIciDtQ907HM9RsrGhDf
    61Smu/iJq1Lg9fSjUrESDfKDx997p4SzvW5g2igIKlE4QKWbbhEhsIgKsY0KCnrwYc3uzV
    7dHH249yFSlE4MI17P/8tjU1cBGMhz+FHOnGc84XcsPYnSXWdVJI9KbP0bT8g8L3vOb9Ge
    aNkAVPUlee3j+07Zd4wLaAfFRhcmTuxOvRzeH0dSTXYIPGj8FGtbrWKy6omw
X-ME-Proxy: <xmx:CifuaskE8rX-dfRT2DIc8zFv7ujWC1WPuv7S72EAAkIqA2beHkhh0g>
    <xmx:Cifual7_8fFXCN-4BFEj-LG0MsexD4sZB7Z-IGY4CaPBHMYCK1dUMQ>
    <xmx:CifuaqiK-tG-3yUOlaNZLYezOiC8o-iScJP-XxoBzXayP7PDt1QaGQ>
    <xmx:CifuaqH0iJHhCIQJmH9esHcNZMAuJa2if_7L0PLSj-Nv9m6lY8GwvQ>
    <xmx:CifuaoSMEbnKIF48vP-8Z_vNsgP3Vp_9zf5D_UiUDymbBb-ZxPi4vnv5>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B3D8978273B; Fri,  6 Nov 2026 14:14:18 -0500 (EST)
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
X-ThreadId: ApVS97Y0QPbJ
Date: Fri, 06 Nov 2026 14:13:58 -0500
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org
Message-Id: <f3fcdfbd-82d7-4e38-8932-42596a6259ee@app.fastmail.com>
In-Reply-To: <20261106150159.847600-1-cel@kernel.org>
References: <20261106150159.847600-1-cel@kernel.org>
Subject: Re: [PATCH] SUNRPC: Honor page_base beyond the first page in xdr_buf_to_bvec()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Nov 6, 2026, at 10:01 AM, Chuck Lever wrote:
> xdr_buf_to_bvec() takes offset_in_page(page_base) but starts its
> walk at pages[0], so the page index that page_base carries above
> PAGE_SIZE is dropped. nfsd_direct_read() sets rq_res.page_base to
> the pad below the file's DIO offset alignment. When that alignment
> exceeds PAGE_SIZE, as with 8K to 64K logical blocks under xfs or
> ext4 on a 4K-page NFSD, a direct READ whose pad reaches a full page
> sends the page before the one that holds the data. The defect was
> found by inspection, not reproduced.
>
> Advance the page pointer by page_base >> PAGE_SHIFT before the walk.
>
> Commit 2eb2b9358181 ("SUNRPC: Convert svc_tcp_sendmsg to use
> bio_vecs directly") introduced the dropped shift, but no caller
> produced a page_base of a page or more until direct READ.
>
> This fix depends at run time on nfsd4_encode_operation() deriving
> rq_next_page from page_base as well as page_len. Otherwise the READ
> encoder accounts for one page fewer than xdr_buf_to_bvec() now
> transmits, and the last page sent sits outside the release range
> while TCP still references the page.
>
> Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
> Cc: <stable@vger.kernel.org> # v6.19+
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  net/sunrpc/xdr.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 7353109fdbae..7eef50634175 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -161,7 +161,7 @@ int xdr_buf_to_bvec(struct bio_vec *bvec, unsigned 
> int bvec_size,
> 
>  	if (xdr->page_len) {
>  		unsigned int offset, len, remaining;
> -		struct page **pages = xdr->pages;
> +		struct page **pages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
> 
>  		offset = offset_in_page(xdr->page_base);
>  		remaining = xdr->page_len;
> -- 
> 2.56.0

To address the sashiko.dev finding for this patch, I've folded this fix into
"nfsd: account for page_base when advancing rq_next_page" which is currently
in nfsd-next.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
