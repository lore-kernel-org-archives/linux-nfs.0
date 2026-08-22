Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E139B3264F9;
	Sat, 22 Aug 2026 17:02:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787418139; cv=none; b=HwF064QAezTk1QnS4HZvw7Gg1ijM1COtoud12TbNwbsBDkRWxAq2HgUrjbJk4zNqA4iwZLE4LFTXKIY7ikEWd+UJSRUk1POLKBEPxT5byiKCZDOKbmUDgJnDKsGf9uGorzc0NtzNAmV1YX251iqiRNjwz4In+nvzwncdnCSskRs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787418139; c=relaxed/simple;
	bh=tP9nXSCTkwLARlqLxiw4oPWPD2VzynMa8wbgduz0+wo=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=fyqQ0xEOqWE2YWIxHgxdwmbV/aEwA1gcLxy7bWlMxdMZUsYatkQwMOB3YHLIzHo/sGeLrUlmkZyFEth55pvDXrVxk2MQDZ3iKGRGoM0in2rMimjKbbC2IEyJDtxraXZVovMtCBiV37X2N55mlh8sWWhK94qce5nomMgkgIe8B0k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=pass smtp.mailfrom=infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=cF1l84Kx; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cF1l84Kx"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:From:References:Cc:To:Subject:MIME-Version:Date:
	Message-ID:Sender:Reply-To:Content-ID:Content-Description;
	bh=5FhimZe/3supwg5oxoPa0IkzmcIdASJJzneKN7B7Epc=; b=cF1l84KxlrXoaHLQw6wTStcv+t
	DEuJMSA+ykQ84ebBczU0Wnns8mqY9uDPBzHVMwqr6m5LqxGgD2TZGLl+KYvrTBr2PYBq+ndCCWPHH
	bMlgx3GTQ661ymBJ8iQ4WkLy0Z0HXFARbGuRp7xANlRbXSxt48mP4QpMqdNpvdNn74tb1lVa+MzlW
	wPzvGZp4DOw3Czr5815Z9ae/tQKIRI85OlIFt0Pwb8pIFw2bhMkVh3na9Ob62gPl9BwByrBCygG+h
	cz9OCRPAQwanMrn5+IRo7Ax1SL4L4D3Q7jmCX/OkDoMB9N3o52Wsxp8mFdE114sjSkhSpjhcdzY7P
	PJqHFB/g==;
Received: from [50.53.43.113] (helo=[192.168.254.34])
	by bombadil.infradead.org with esmtpsa (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wxp6j-0000000EgAU-1s12;
	Sat, 22 Aug 2026 17:02:13 +0000
Message-ID: <90519e6f-dea2-4556-b928-fd0903e81603@infradead.org>
Date: Sat, 22 Aug 2026 10:02:12 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] NFSD: docs: Fix pNFS SCSI Kconfig symbol
To: Karl Mehltretter <kmehltretter@gmail.com>, Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, Christoph Hellwig <hch@lst.de>,
 linux-nfs@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
 linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20260822081033.82098-1-kmehltretter@gmail.com>
Content-Language: en-US
From: Randy Dunlap <rdunlap@infradead.org>
In-Reply-To: <20260822081033.82098-1-kmehltretter@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit



On 8/22/26 1:10 AM, Karl Mehltretter wrote:
> The pNFS SCSI layout server is controlled by NFSD_SCSILAYOUT.
> NFSD_SCSI has never existed.
> 
> Fixes: f99d4fbdae67 ("nfsd: add SCSI layout support")
> Assisted-by: Codex:gpt-5.6-sol
> Signed-off-by: Karl Mehltretter <kmehltretter@gmail.com>

LGTM. Thanks.
Acked-by: Randy Dunlap <rdunlap@infradead.org>

> ---
>  Documentation/admin-guide/nfs/pnfs-scsi-server.rst | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/Documentation/admin-guide/nfs/pnfs-scsi-server.rst b/Documentation/admin-guide/nfs/pnfs-scsi-server.rst
> index b202508d281d5..a3074450ac158 100644
> --- a/Documentation/admin-guide/nfs/pnfs-scsi-server.rst
> +++ b/Documentation/admin-guide/nfs/pnfs-scsi-server.rst
> @@ -16,7 +16,7 @@ addition to the MDS.  As of now the file system needs to sit directly on the
>  exported LUN, striping or concatenation of LUNs on the MDS and clients
>  is not supported yet.
>  
> -On a server built with CONFIG_NFSD_SCSI, the pNFS SCSI volume support is
> +On a server built with CONFIG_NFSD_SCSILAYOUT, the pNFS SCSI volume support is
>  automatically enabled if the file system is exported using the "pnfs"
>  option and the underlying SCSI device support persistent reservations.
>  On the client make sure the kernel has the CONFIG_PNFS_BLOCK option

-- 
~Randy
