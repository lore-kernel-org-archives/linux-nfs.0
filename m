Received: from smtpo63.interia.pl (smtpo63.interia.pl [217.74.67.63])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 720AB3A6B76
	for <linux-nfs@vger.kernel.org>; Thu, 14 May 2026 22:53:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.74.67.63
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778799223; cv=none; b=asr1/zAzAibWMAgejZq9Irma2E4gbE03E+Li9Rrf4w9C2WIeSbWtVwdjzjuxFSN1FhscMXzRtUvB3Os2HlqTVRSlmPg5auW2zvU8JCNckPSaJx0fVUYrimrBnkY25urFIL2TbOVeMN3Eh8XFgTeBp7cZLYp/FjaULch+CIWNNh8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778799223; c=relaxed/simple;
	bh=8otikSoXFPdpLfOTfF3VMUvjp/Z2zSChNUkhA3oXku0=;
	h=Date:From:Subject:To:Cc:In-Reply-To:References:Message-Id:
	 MIME-Version:Content-Type; b=HTQflor5VGdMHOcjGP+KUiWWOKoqKWtgp+Mbj5gr1f28WPF5xojfxakLJkCtKndQhH3TcNjGGvZj9xTQokUfchp18oxJ7sW4FaQVYlpwBPiGKICdmd/6GFiTg0HT8QaT8Af8Fmz6Ti24g6SgYOypf5ob/4RNUJ09CsiplFqE1xg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=interia.pl; spf=pass smtp.mailfrom=interia.pl; dkim=pass (1024-bit key) header.d=interia.pl header.i=@interia.pl header.b=XGzF3PlF; arc=none smtp.client-ip=217.74.67.63
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=interia.pl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=interia.pl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=interia.pl header.i=@interia.pl header.b="XGzF3PlF"
Date: Fri, 15 May 2026 00:52:21 +0200
From: vermaden <vermaden@interia.pl>
Subject: Re: Increase FreeBSD NFSv4 nfsd buffer size? Re: Increase default
 NFSv4 server size "max_block_size" to 4MB
To: Rick Macklem <rick.macklem@gmail.com>, Cedric Blancher
	<cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	"freebsd-hackers@freebsd.org" <freebsd-hackers@freebsd.org>
X-Mailer: interia.pl/pf09
In-Reply-To: 
	<CAM5tNy4zgRBFAmwWCApAYvTHuhVtnkQRdhG1xpjekUnhdtsA2Q@mail.gmail.com>
References: 
	<CALXu0UdOR8mVr=8pwNP95FnOsOk1w1A2=DcayKk3YnDfS+PzUA@mail.gmail.com>
	<5acaa8e7-0691-4cbd-b501-c26831a7be81@app.fastmail.com>
	<CAM5tNy7GG0awNYYJWv0968e5CMoUstr0GcrNwuNKP4x3Yrp3JQ@mail.gmail.com>
	<CALXu0UckL3YYXVLz5Qn0shoZ+TU8uOxRy2FCpL5mAhLniinJyg@mail.gmail.com>
	<CAM5tNy76P-1Q2EhJ4zXUtc=EwRYgke8ZqJEYvM=sRyY77rxHLA@mail.gmail.com>
	<CALXu0Ucq2Wwyuu3BUzv0i6_2UNBPDRVzXVgH4O056PoZOzEgRA@mail.gmail.com>
	<CAM5tNy7Crx-MHAO1DKwdWJdwLQX=kWrPFPke1-uLbZ4DYPnTcg@mail.gmail.com>
	<CAM5tNy4zgRBFAmwWCApAYvTHuhVtnkQRdhG1xpjekUnhdtsA2Q@mail.gmail.com>
Message-Id: <ylbouteyvryomeedhmin@fdeb>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=interia.pl; s=dk;
	t=1778799144; bh=rdf2eefdCeZp7mxJtfOsFl1hWcutTEyWdbPuvtCFOIc=;
	h=Date:From:Subject:To:Message-Id:MIME-Version:Content-Type;
	b=XGzF3PlF4OGArDmJFyRI/bBiiP/+1J2++yeQT7oROTqZsN79I6lkGeTpJB/+jiatX
	 +Jr39dlWFrroqvY2nlSZtoI2nZPfSmwf/5oe0GloJQDmq1o73hBn3rVY/452Ex0kxq
	 Cn2LlLVDx9VawaFJ60uWjsAmQCIZxh7cgnRIRSHA=


> To enable it, put this line in /etc/rc.conf:
> nfs_server_maxio=4194304
> and this line in /etc/sysctl.conf:
> kern.ipc.maxsockbuf=18892800 (or larger)
> 
> rick

An idea ... if 'nfs_server_maxio' already sets the 'vfs.nfsd.srvmaxio' maybe it should automatically also set 'kern.ipc.maxsockbuf' to 4*nfs_server_maxio first?

I mean ... if someone wants to just use /etc/rc.conf for this - that seams reasonable ... and if someone uses /etc/sysctl.conf file instead - he will have both of them there anyway and will not use 'nfs_server_maxio' option:

    vfs.nfsd.srvmaxio=ASD
    kern.ipc.maxsockbuf=8*ASD

Regards,
vermaden




