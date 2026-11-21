Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=80.69.43.37
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795256938;
	b=u7vbo37YslqGv1POmPjtOUkOOxMC3pxXibputPG3kh1jWJAZQwI1/Imrt9yQ5idR1UV9
	 xo2wORkvRQ3hnw1I3cyHtkQzak2E5DlhVkAw1gQsVHVOwj8cOTREN0qpIyd9QGpOjWZoZ
	 mRviEm13IdkV5MsLUc/1NJlMcv80mRPblMULlHtaNF3ua5SauIr7fXGcV635JieMYVuY/
	 dOzfL3IyMRviYlcxNqUKD2tXIRIGHyJiNX9j0I1rHizwEffCLmxZQGpR1WfUZ7xSHVgGI
	 I+wQ8XPdHDizHkdfBtiYmfvA0UMYWX34YZUiFbFELU0DS+99QHMkSPlxc4rVoVIcL1w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795256938;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Date:From:To:Cc:
	 Subject:Message-ID:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=2Co9x+IoJ8inJ5dNzFWRuM1acq8EeJ2/yY8TmzJbKJk=;
	b=EfrFQG0YmddebHtEs/SZ+lTRlFdqUCI4pTMlokQk0gGq4SS4S/ufHfZYB7LQ5eHQ/n6H
	 z4qc8D81Vt+W08yMrxDeWYIQVz0enCuh02fezYmYX3Wjkaxuibislau0TNXOO2s+dpTck
	 J7xbIhHuonKpG4TFFXm7Bodc775oDoWostDTW1LLyDTTN9hcDVLmKY/rah1viOPF+gqk4
	 Bk2JKTneHZtOEUasAsPEh6KuDR02hZFTZY0T8SWvv+CQoyOX5SVnydpMIaLZoNuDinmMn
	 sZO7JFTlr89mXCPrOLoXPLmN76ABsaJtaSpg9VyvgT8Eh+tmknxXncZuqxYcHv/ObbQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=vozeler.com;
	spf=pass smtp.mailfrom=vozeler.com;
	dkim=pass header.d=vozeler.com header.i=@vozeler.com header.a=rsa-sha256 header.s=max-2024-2 header.b=nac0sj86;
	arc=none smtp.remote-ip=80.69.43.37
Received: from imap.hinterhof.net (imap.hinterhof.net [80.69.43.37])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A437606A320;
	Sat, 21 Nov 2026 10:28:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6A437606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=vozeler.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vozeler.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=vozeler.com header.i=@vozeler.com header.a=rsa-sha256 header.s=max-2024-2 header.b=nac0sj86
Received: from dp.vpn.hinterhof.net (i59F45518.versanet.de [89.244.85.24])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange x25519 server-signature RSA-PSS (4096 bits) server-digest SHA256
	 client-signature RSA-PSS (4096 bits) client-digest SHA256)
	(Client CN "x201t.vpn.hinterhof.net", Issuer "Max Vozeler" (not verified))
	by imap.hinterhof.net (Postfix) with ESMTPS id 94FF08FB872;
	Sat, 21 Nov 2026 10:28:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=vozeler.com;
	s=max-2024-2; t=1795256933;
	bh=cEvO1ZKPKk8kkVr4u3EZ6YwfXYohAzhLkqNt8cz4ajE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=nac0sj86BiL7wgHJztYzZ4YlLf8F+ouFfWgmoLiPqSrh2hR3TCn1boCukGLEOLSWp
	 NeXi1suClQWHw/Pg+2dc5no6TmGjLb4Rqdtf3RApSPpv6096H1ib+wsk56gBVPtyFK
	 ilFCRXEjP81BbaF7dZB8VhtlFwOs3Uwk7Q972ap1F/PcUnMkjI0T+qpjQT51PAZAe0
	 iuQSs+VqciV3ty42slu9UfR+Q+fKWE9t9ojci7d0SXALpv4yFsGOinXnMlB7ERJqra
	 PWS36bYynDCGaenxHIGFyvV9xyQvgqrDQN619MvcJDqqFWAtS6ZvbSR4T2lcZepArX
	 3wEtW9tBO2geQ==
Received: by dp.vpn.hinterhof.net (Postfix, from userid 1000)
	id 3724426018A; Sat, 21 Nov 2026 11:28:53 +0100 (CET)
Date: Sat, 21 Nov 2026 11:28:53 +0100
From: Max Vozeler <max@vozeler.com>
To: linux-nfs@vger.kernel.org
Cc: stable@vger.kernel.org, regressions@lists.linux.dev
Subject: Re: [Regression linux-6.1.y]: NFSv4 server: sec=krb5p mount fails
 with EIO in 6.1.192
Message-ID: <awFyZbQE8pDyOxUy@dp.vpn.hinterhof.net>
References: <awBIdxOJ4XSXuc7S@dp.vpn.hinterhof.net>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <awBIdxOJ4XSXuc7S@dp.vpn.hinterhof.net>

#regzbot introduced: v6.1.190..v6.1.191

On Fri, Nov 20, 2026 at 02:17:43PM +0100, Max Vozeler wrote:
> after upgrading an NFS server (Debian bookworm) to 6.1.192
> (Debian linux-image-6.1.0-55-amd64), NFSv4 clients fail to mount exports
> using sec=krb5p with EIO.
> 
> Downgrading the server back to 6.1.190 (linux-image-6.1.0-54-amd64)
> makes things work again.
> 
> Good: 6.1.190 (Debian linux-image-6.1.0-54-amd64)
> Bad:  6.1.192 (Debian linux-image-6.1.0-55-amd64, linux-image-6.1.0-56-amd64)

Reproduced with vanilla 6.1.191 and 6.1.192

Good: 6.1.190
Bad: 6.1.191, 6.1.192
