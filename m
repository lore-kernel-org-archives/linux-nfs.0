Received: from vps0.lunn.ch (vps0.lunn.ch [156.67.10.101])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68F17430B89;
	Sun,  1 Mar 2026 17:39:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=156.67.10.101
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772386796; cv=none; b=W+/OZ2lDvgjM92ncNCKz+2hz8h5LN1xEusWdh8soD3cy0rOtvtvfg0Upwx7iAiGgYT5nd0MVnNiH1NWMZT+/FZE+NdW7hNAg6WUHIe0KutArk+1Jd2Qtq4UpMh1xdwRKD2hO8pj6M7obwIzO5oXP/vDohNNSbkS5Z/7hQkNp+TA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772386796; c=relaxed/simple;
	bh=1cDoQ6aO1AwI0Vi46R/PBILdZTAsbdbx762yzOip7dk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=JTizsdPvG1jtpJGI745fQ4QwG6FXK7dCmi9qnAxSyuUK3VzCA5B2oCN1D5QNwpacNdA3TBoPahSaoJ1z+ydT2mJXZ4kbswoSdPlLhSagcSGO0uR93sc8IykCJaLFLtlftmRQ4c9zL4sr8VoCH2plx3ROfNYHE3ku7eg0iPoCqS8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lunn.ch; spf=pass smtp.mailfrom=lunn.ch; dkim=pass (1024-bit key) header.d=lunn.ch header.i=@lunn.ch header.b=jpKS2kAN; arc=none smtp.client-ip=156.67.10.101
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lunn.ch
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lunn.ch
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=lunn.ch header.i=@lunn.ch header.b="jpKS2kAN"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=lunn.ch;
	s=20171124; h=In-Reply-To:Content-Disposition:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:From:Sender:Reply-To:Subject:
	Date:Message-ID:To:Cc:MIME-Version:Content-Type:Content-Transfer-Encoding:
	Content-ID:Content-Description:Content-Disposition:In-Reply-To:References;
	bh=j2TfC9w+0PrhVgrOoPCuRDYLXe6F8djM5jUwL6kHjkA=; b=jpKS2kANUcpvdtOtfbWievMG35
	Uswuk6IlvR8RW0VhN3p1hEabDJw86Jvp5Nej4WAC5zgo8tuMsqxAybUHflaGUDkiibpfYzlkSv1Mv
	TrbbG8yi+FfC8DJS+FHzLV06cIMbpS9uQnH8alRyt2LNfuVUhWkCK23LyCvPB0dXR1nc=;
Received: from andrew by vps0.lunn.ch with local (Exim 4.94.2)
	(envelope-from <andrew@lunn.ch>)
	id 1vwklc-009PpG-5J; Sun, 01 Mar 2026 18:39:44 +0100
Date: Sun, 1 Mar 2026 18:39:44 +0100
From: Andrew Lunn <andrew@lunn.ch>
To: Sean Chang <seanwascoding@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	David Laight <david.laight.linux@gmail.com>,
	nicolas.ferre@microchip.com, claudiu.beznea@tuxon.dev,
	trond.myklebust@hammerspace.com, anna@kernel.org,
	netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v6 0/2] Fix compiler warnings/errors in SUNRPC and MACB
Message-ID: <0a784056-f57f-4634-aa7a-fd0b5916f40a@lunn.ch>
References: <20260301161709.1365975-1-seanwascoding@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260301161709.1365975-1-seanwascoding@gmail.com>

> - Verified via .lst and nm that both variables (buf) and helper functions 
>   (nlmdbg_cookie2a) are fully optimized out by the compiler when 
>   CONFIG_SUNRPC_DEBUG is disabled.

Thanks for doing this bit. It was needed to show my guess was correct.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
