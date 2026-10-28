Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793196592;
	b=EGmMw5shFPwVx6OojvIuTv2c9yvdN3hLZbQYDH+7tnDsvoaLNpfdGFTpwaGG2se0FfuB
	 /1CgOWlyAJo58DBZQStBjKh0DbdzSzS3uAsQcRzE4X6P643YP0zJP93KtriI0kAD8BGmD
	 Qkv6UuDNwdrhxQCSyj5Skin3oLGMqba59yzHLY5BoGr//jNH9JkGHAZ043A59/lzPLBbf
	 OCqbhUQVqgBDx/uLR8cEGZgwATsTVIwr6E+2BxQ2UvnRjr/83ytbQH6XjC3SI9oRjL2uO
	 vNdWaU+Gz5LC9R7izLKbJAu0bxeiqXq3Qb+xQKwIe3tXVHyAn+PaDiLbPGa1BwscQnQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793196592;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=1kn0MYNn3klqieU3xiNKcdfUX1yD5ps9DfxTaR/tgA0=;
	b=IJSaL4/5cFwd/byvqoSjXztGfE1C/SVW5TizRz47d9swaFUMe9oFgbZ1AdEtO7IjnXBT
	 Ho+N7YVGYtgVeuKb+Raf9+l2gDh7Sg3UXSF+4D73DjweMbvyzAYuLMWs1Gc4qvvcirdAG
	 jhxQRe8QgEhffYipWy//QQMxjoEN3pW/TfcwcDdbW3MR08FLkgd6/17lIpFKOxXxukYGN
	 6U/RFv3sn3iYJsvWU0AQzHa/jf0b3x3mFcCI1RaHLXnuGYm02ioxZ/r1mI0KoRzS3wh7a
	 R2FmioiT1l3Etip/OfHsVLGjWU5B27usCcqm8v7/5t2ZLjJkkPqFgfEmatdSZdV89OA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CzPBerAH;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96A51606A324
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 14:09:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CzPBerAH
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0B6DD1F031E1;
	Wed, 28 Oct 2026 14:09:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793196592;
	bh=1kn0MYNn3klqieU3xiNKcdfUX1yD5ps9DfxTaR/tgA0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=CzPBerAHgdAVoL4aGtFtPDzruOFe/vcIMDKw36OYcsPkR0bL/OtjcFkLaECveFQ6s
	 Xxey2N5K6LpHQnihqosY7x80rgx3pnDVxmT+x/ODFDdA/MPsMjR0Dk7xoNib+9StaF
	 IZLCFphwsddIDB0t+TRFr47mSUAj0pv306BhSWqOLLDZ4tPN/yNp2QnnwqOBHLdhzm
	 D3mX9s29UlAtC3lez0pQcyJamkyshrW+mYx/3HP2EROcElgSs+E9YJBoprfl3vZhnb
	 gLGmFwwi7ImE1gqWDZt0OKginfRAtRPwMuhESZcZ6MGd0cYmM1mExH6zQwAs0IlR12
	 Q0aUwaWV6CKMw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 4050BF40068;
	Wed, 28 Oct 2026 10:09:51 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 28 Oct 2026 10:09:51 -0400
X-ME-Sender: <xms:LwLiakjga1SRf55etBlKMSkq1KByUfdoqEqxFiMewG53KBQJpIb_tQ>
    <xme:LwLian0CXuu2XSzGv0rM8Pi58TQTpJyW_onWWhWO16kr5AjM_H4jzU5m1fsnlPlwr
    Eu3Sx6Xq4Kv8ZqB0jpLNVLIdMKHac7StZ2aRYyEYtFvEJ60QHjDV6Wc>
X-ME-Proxy-Cause: dmFkZTFpniufTWQpGmmXVDeWuvA6z2FyEoVKBpuKRRbntwM8E7XhjWhABG/fYI2RZJ8vXN
    5QkHluiRMpaP9ly9vfDwHv5gCvFR4obd4MPvwkV6/T+22QKFjcPkww0MSST2Nv6MlEHu0z
    DvUGCSQXoeQYdZ6r2Y/xy7bfKTkKk1dwzUfh6+H/bflh7+3auD+WITYV+uTNtctawCP30Y
    ivrF6SIIA95HTSbJr5u8SUsCwMA9PFByjI1RIVsKdO59OHIJysqm3Z9iGLuDNd86ARy/FA
    1mWEpApn9iacbGY3l8T5507iDLZIUkrVjA8ksJ7KumVUdzR27nZwLMRHzwWLF5JOnij5pg
    m13LQEuiwj321auvkamJwf+4HUIoe2exSkolHVmGAvkWZvACxO7hE3e3wxPbyEB6u7ez5n
    Jhn2Kt4CQfMCZoWaPVurOyWb6ZMWGwgFHMuDWjtQn1NZFpMX/1QyK9+TPy+CT/NWneEKqR
    sgxsdKl8yU6jhaaL1Qwh+sIhPd4yFqK5S2VqaYoCabbVhMbGxDK6DY7qBi0NnKSBCz2f5h
    ThL0WjoFBQwgJG3vuOwmfN3MFzpd7x2snMYBUUsl1U5oQ4/NYFN3QUQILrlMutWIWLpg9T
    r4FYjzD3KLyzMOh2lAjzc8Sj2DMLxXukKH++KiUEtTkYV8QYOjfUMb3NZRGQ
X-ME-Proxy: <xmx:LwLiapbVi0jBSSXD3F5ea18yL2iT9XUBM-kCRl5EYTQgT4Iaa6gWDA>
    <xmx:LwLiahEjZg5sANw5zltXzZiMFWM-850XN0SHBuLlos6HMFVyQJGIGw>
    <xmx:LwLiaqIIXz4lgUaPW3hBguhPE0e2NJHDsRZ-mYZX9JTbGvB5A5de7A>
    <xmx:LwLiasOY3bOYyKqDD5cUJoC0uYQJ2G3RzUEK43K10jYIcqxkcjGYpw>
    <xmx:LwLiaqmYNw5bxFb13oemmF6TX_5avLLgrsWt8b9XBlutQ-1hLmfWbWwZ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 16191782738; Wed, 28 Oct 2026 10:09:51 -0400 (EDT)
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
X-ThreadId: AqDuBGFLn2G-
Date: Wed, 28 Oct 2026 10:09:30 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Adolph Zeng" <coderzeng@gmail.com>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <69045c2b-ba49-4d42-8c3f-779b6b0573de@app.fastmail.com>
In-Reply-To: 
 <IA1PR12MB662788BBD70D4064432FD117F4602@IA1PR12MB6627.namprd12.prod.outlook.com>
References: 
 <SY9P300MB153090355AAD017CD7216634A6602@SY9P300MB1530.AUSP300.PROD.OUTLOOK.COM>
 <IA1PR12MB662781C8C09627A5CDEBF39DF4602@IA1PR12MB6627.namprd12.prod.outlook.com>
 <11396b5a-249c-4710-9a1f-c078fc50e9ab@app.fastmail.com>
 <IA1PR12MB662788BBD70D4064432FD117F4602@IA1PR12MB6627.namprd12.prod.outlook.com>
Subject: Re: [PATCH] nfsd: prevent SAVEFH from bypassing export security
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Oct 27, 2026, at 6:19 PM, Adolph Zeng wrote:
> Hi Chuck,
>
> Thanks for the clarification.
>
> Before preparing v2, I'd like to make sure I understand what changes 
> are needed. As far as I can tell, v1 already addresses the COPY/CLONE 
> concern you raised.

I think that assessment is correct.

Your v2 will be a response to any subsequent concerns that arise from
v1 review.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
