Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795443789;
	b=r8wKlaROCN0uMGclwbswRHsii8uQ5v7R6kbqaAZ4OL8Nj2nCULCCXubUniuERlgeAkgZ
	 FXl6bDsDHNoVOziYRpwOnAZa17Q/qyGys4p35pNRT38nBum/hOEgQMNyoSDD+ccmXD9pf
	 8pBI/Y//wkl4sdAE/rsj07aLpyO8GbbZD0SFvzCJ2WnLgCxdrOpI0YOBvZ+Q3JyAvKfgh
	 jj9JrbrtqqZjcsM82ZY3EDrTTOJ3G58b6gQ3IORDN/B38eEZmid9oXg51NSbpCih2bdF7
	 v9I0aH50nz8TeVXgogZvAZPo76DfN7K1YHnXkWBbf8XphCJ7epGgTsg3fTmS5R5Fn+w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795443789;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=FFSbXtCb0eXokMChSAk5HoJ7/XmHEmmDCTf1574wGVk=;
	b=rexDCNJMSOMtY/6bPpSF+4RB/r7wigsYC79IWCZnW4fRaTau3UMSdAQEw23nsfvLS/Ow
	 Hj1PCZepDsyOd2PKS58+hcMWb9bBSbgVLWRomEg1DGOogjYxQDwGe8NUohGy/xkPy6A8W
	 ZG1WA3AJmY64hp5BtAelfP/p7FhUkxmA7e7UhzzfrU5XuLTAR1Pdxj04ojbJS0udPymrB
	 3XD1yrcXvVe+Vts8+HiRl8kRDc10xkwNOhInYDHFSYMBII+oluSO/BYXe24tYWJviiVeH
	 4Z1E/VFSRF5VT6HjOXkCbyFb0p2r2J5tpYGVP6gLJ60QIYVTqvI8+IBRcmqDnchj4VA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aOpvgIKg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6EE7606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:23:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aOpvgIKg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F66C1F000D2
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:23:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795443789;
	bh=FFSbXtCb0eXokMChSAk5HoJ7/XmHEmmDCTf1574wGVk=;
	h=Date:From:To:In-Reply-To:References:Subject;
	b=aOpvgIKgwYuagFCvbS85ZAaVFvXHcs9NtVipnnvxLPKaQ6bH4VeKh9KkQDULP30+e
	 eqNOdx1Hy2qFMQQyCKVLt6Vt0C3dDyHTxTnx9KchLs7895ga451DGcOlwSB9oHD0+s
	 jI1p20nSVfMIjwLAscUQw/j+ycC3NHUoUVuta3WK2RktNzRDyb4iRO2ljvHQTZ98VW
	 DLc2i24cDKZOXLt7j8UQdcSofhBJCh47jImINZ/av6p5oZ3eDGUzAX7bp4eR/3KFO+
	 cUtiZQwe4jzUMRxr7EF83Y7ke0tRt+MgUGhgdiS4egFXx6yUjw1XJgdJuo6A/X6mPF
	 oWi/n0vyfpDGA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A9B1DF40068
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 09:23:08 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 23 Nov 2026 09:23:08 -0500
X-ME-Sender: <xms:TEwEawmlYfzhnpjwelA-tlOjLgKey7MbjPmwQNc1ZJKOYVxokHuUyg>
    <xme:TEwEa6outP2T5kyG8TbpiZqJIaNeKbAezOaTyJucrC1RnVykSuRd6zYpMOQkjbHoV
    hhFM8CbFBsf2-Z9pCH0lspyrj3ne2PpXwW_AxRG6n6ej5-JvumtM0Y>
X-ME-Proxy-Cause: dmFkZTEiwzn6A5f5rSuo3tsqVuEQyW5ensZuS3ht5+TBfBW759HcQ7nZ8ZAoMyUTBMgSpD
    App44Yuu0HcdMXPnaIspZbO9U6pwT5QFLOJuf/awa4LqFkO6ufyIvWVTuwlJ3jtmInXX3A
    glmUQl3K6Su5a32f4/w1ewUt7aYr6BlMZImw0V2TYmqBuphdnOnxSwFQOABu5B4lAJq74L
    LcHwWixN7ylKlUnvhjqR8Be85vzQO8lrTurGu3PlNBBFxzwOdsQvkc92xQAbswcujGbUx0
    SD4ARaGQU5TwYp2vNhzvvg+xQkXc52nsUy+CXEsZZWE+suuiX49HwjfDFFiy2K5OwPnRaD
    6Gz1SztIevR4TCn+Hdr4fU+UbTiYBxExx0cFfWXt6WXJsntJkRO2q0P0sXeHvxKmeKvrbB
    NNd0eAI5G7BxnSTOx4FJWBDK782jxVXYfcgXlqFXWA8iKyBTfTsmNXcxo/+kndbudITevI
    diAPggDX/FEPrTHsOXxdkDY2TaJC6PXJZRtMJjkvT0cptwHi7w6zNlZwyaFLVytmDkKRO6
    WU9ySbbvrG6xU6y2LasT6o2ciVIV2O6qhoiIBDAAMHobatUsKNrSvSz03yqu/i+6Npz8hF
    aBMdqLsc6wijX5+nfZylRptacJP3Lqryz3pLJI8u8kla4JKCP8mBnZUAa99A
X-ME-Proxy: <xmx:TEwEa6Vwv5FPmKLC84MWw75OX5hrZrlTCIIc556Laf_0RUoLqqZW_A>
    <xmx:TEwEa2i1SGSZs4azcF6O5NJRAWh2chfEvTGnIAlhyPYwqRBNAriK1Q>
    <xmx:TEwEa7Si9RJDdr7D9Rc9PoR7MSjnymhyqCAt47x-soOb2HjEt8lndw>
    <xmx:TEwEa5HrXprFzXlRt_AeDc8WWtcQJtNwOr3f054AqfR7BdTaaU4wCw>
    <xmx:TEwEazmcufjgy_vn8ETOf8_OBhtctTBgLDm13l-nJSb2wexu76RWzXPP>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 96527780075; Mon, 23 Nov 2026 09:23:08 -0500 (EST)
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
X-ThreadId: AKzItFI1RcM3
Date: Mon, 23 Nov 2026 09:22:48 -0500
From: "Chuck Lever" <cel@kernel.org>
To: linux-nfs@vger.kernel.org
Message-Id: <6bf939ae-c29e-475c-9261-0cddfc31805a@app.fastmail.com>
In-Reply-To: 
 <CA+1jF5pNXvipBz8Hh3LWn=H07JJGEJPVH_hWZYCE8GhB96kvgg@mail.gmail.com>
References: 
 <CA+1jF5pNXvipBz8Hh3LWn=H07JJGEJPVH_hWZYCE8GhB96kvgg@mail.gmail.com>
Subject: Re: Which Debian version has working krb5p support in NFS server?
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Mon, Nov 23, 2026, at 5:03 AM, Aur=C3=A9lien Couderc wrote:
> Which Debian version has working krb5p support in NFS server? We tried
> to start a test campaign with krb5p, but that project stalled in
> September because neither Debian 12 or Debian 13 seem to have working
> krb5p support.

Have you reported this to Debian? The status of krb5p is "supported"
so if you find that it isn't working, the right thing to do is work
with your distributor.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
