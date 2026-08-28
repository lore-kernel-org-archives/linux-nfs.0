Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC9E81DF748
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 23:14:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787958901; cv=none; b=OQBFsA9VVdCOwY5bkkrXDPXZBxwvoeL7MO3SOZJRDs9tBEahzBgdAGlk9iaSjGQh6vFbqVXaeZCHaM+nVra5bdlO+Tz8SdQ/5Ea0u5U0Bg5xlbOCzReTrriwOJYeAVXi5fOFQeaHOQkNOd6B2u+wdPLbaOVwgFm0dyLEOoIqa9U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787958901; c=relaxed/simple;
	bh=3XZ7nG6FDNRPDoRz5soavnxZcl9pRKUBmh0/3xMgLfY=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=u8S54b3IAkB6+dCoIrJdlteCCsN9QOvWM436NJzPkjiHUTmbJNJSMM4fhbs1AKsDfkxPcRfKiYtnicKEPU0Ew5Z0h3UuhqSDZ1aicc5Qmpsc8+oK1SvUl27X9iNI5LytWbxwZLlfyzoeF7FxC7szKRJfYpEJtHg5KWxannC9lA4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VxFwZfyP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VxFwZfyP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 26C2B1F000E9;
	Fri, 28 Aug 2026 23:14:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787958899;
	bh=Jp638K8rqZwLOUcskYkJeyjIXBjJ9+YWM8O7zh28iG8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=VxFwZfyPHeFB8deDjIhj45o9mdWZyn5qMpIQuyJpgjnMcURb1LC3eISSQOULbam6b
	 qDeeE3bvQkeAZedrEZmgOQtBAOPsj74TjBrudrzdtWWmdsDo2tchakjAvV5MJXgeSO
	 Khc/SaX8yH9CngxGXs6dpdeaoHI+5ntIyW2LLZ9fPLf8qJXH5eABazchl45s/0JyYO
	 8oM0c8yVxpzUAlQJJj4trRadefxDyCMD199j5IOar1E0R3UJ4AgZDoBgNwOSA0gj7b
	 TOgiGCXmjiZ0PvoXQxIhJOrygvRU4km/89X1hL3qi8+9+P/zB/XlMvuPk5MfELNDFr
	 UWsKPfBjQnf0g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 37770F40066;
	Fri, 28 Aug 2026 19:14:58 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 28 Aug 2026 19:14:58 -0400
X-ME-Sender: <xms:chaSanY-MdZ9eSksLicf-z2HR4qO5eHy_gjVoSM1Ld3pdplRitDNYw>
    <xme:chaSahNwbDXG_z0oS4bSCYBqpZBJqhT1PJxVR7bmJdxSZsooH573eX6ZjcRqQCa5Z
    -RJn1ANWa_ttk7uoR6ZvYfJ7OwRXxfbDy0ia5RwGQB0P_qvgXX2rm4m>
X-ME-Proxy-Cause: dmFkZTGszpJ3TdOte3KPUyGJUs9xdwNETKptCd/tEzRXEumUN9LV9UCj0KBwREzzninqkL
    VyLW9kE6VYtMfR1SpHGPzIIOGLq2ekThDK2P/uGP/GI5QZ2s38dp1ouXkb00ecK0ncrUzs
    1KvncMtwASd8VEDQ8LCvIFpT1TllA8iGVw20AGG7tMEAa927UDvIZKdb8WjEnwpxJUrFBM
    9ipxMpPeSUn9RiODfkSoB8LEmkK6/FttaLRFmH9xxZri+zd6RnXYfzux9xOGc0yeW1oKPW
    QeunhLK21znaidbTeNhnNJ9tlvmGSjYMn9GHMapOmM4vMllvKZ3u9VFDoxqdTJyhzIsON4
    2NZUgrjUJmjb/+elEg0XfuDh3DWySces8QjBrT3NpL01efKFYj1F8hslTqrrq1oIJSEifJ
    yP37UCAGZ8BzHb6n8YCozG9/CebRAguDPf4Qcfe5n9mS/A8YN7i+c+0CE+FdSOGqHDB3Iq
    qLbifAh5FF8Bj/7VIuEf/2mg6tH2p5ApfYiUKRM4Mw13i/fiejDWS32+h6MJrxF6RDvf21
    1AijBmN0axz448ml+knrYPbv+oaG/F5wlNkDufb59wi4GzuKkn3M5BnSD8vK3+OChm9rnc
    BCC1F5gpQ1CVCftmfRcn+5ek4X/R8TAQg86oO3F2mty1St0OrkMs0wZEBSFw
X-ME-Proxy: <xmx:chaSaqW1FDVVBdiFDLL4F435eAvg1QKV5hQkeDN_2vIwPn4i82i2kA>
    <xmx:chaSarhKrMyMJPSpTCdMLuiF7ERAkKCx1Qw0D56TOPrXbuX6jyGdNg>
    <xmx:chaSaipQneOcsXpJVjrwhvgC9aMM7bdDzZqtbYpBx7QD9GMO9IktJA>
    <xmx:chaSahGUWqQ4JPZE1P1vQUOPBeQwVWMPgutpIYzEFMHvuratWSdEnQ>
    <xmx:chaSan5NS2I9LWSiwqrPWJ8xnQObIUBYHjduK-eqvT6SBfzifJTxIA8t>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 12C557811F0; Fri, 28 Aug 2026 19:14:58 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AcUrMSdZQCF-
Date: Fri, 28 Aug 2026 19:14:40 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Tom Rini" <trini@konsulko.com>,
 =?UTF-8?Q?J=C3=B6rg_Sommer?= <joerg@jo-so.de>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Chuck Lever" <chuck.lever@oracle.com>
Message-Id: <8eb7450b-70c2-4354-a92a-7a1296cbd118@app.fastmail.com>
In-Reply-To: 
 <178795659577.3510150.12183147665128116121@noble.neil.brown.name>
References: <20251210002850.318350-1-cel@kernel.org>
 <20251210002850.318350-3-cel@kernel.org> <apE90ZRZB8IW_AiS@jo-so.de>
 <178791679053.3510150.70411349578293852@noble.neil.brown.name>
 <91e02ca3-e985-47fa-aed8-0b50a5d7a3c9@app.fastmail.com>
 <20260828205116.GA266670@bill-the-cat>
 <a9a48faa-2663-40d7-86c8-ec2eaa967cdf@app.fastmail.com>
 <20260828211855.GL3959812@bill-the-cat>
 <a832bec6-fdcf-4405-b8ed-87418bc704cf@app.fastmail.com>
 <178795659577.3510150.12183147665128116121@noble.neil.brown.name>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Aug 28, 2026, at 6:36 PM, NeilBrown wrote:
> On Sat, 29 Aug 2026, Chuck Lever wrote:

>> I'm talking about changing NFSD to return NFSERR_ISDIR, which would
>> be picked up by the first "if" check above, which already exists
>> in U-Boot.
>
> Good idea.
> That matches what OpenSolaris does, which is the closest thing to a real
> standard for NFSv2.
>
> https://web.archive.org/web/20090216190827/http://src.opensolaris.org/source/xref/onnv/onnv-gate/usr/src/uts/common/fs/nfs/nfs_srv.c
>
> lines 619-624.

Exactly. Patch coming soon.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
