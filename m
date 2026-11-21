Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=80.69.43.37
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795264255;
	b=1ZjAL27ik3r8pArHrOxG6tMK72JtksVOTp0Lxbp68oLYgkI7vrAP9HJjdu4Fb2TzapQu
	 rYMR9OYaC9+gdrNiSn3Z+Z83poyR6inOzi/pL/am3eRkJst3jMhYCF0BehlhhrrNxYmR6
	 DUTeS0FsR9N9p6u9qzqLC/06386r0HUn0hw901ld+sVxeSIr8y64FsWnspN2m0whQTXv1
	 M+fIzKfuWA9Zb4nYkXCR2qpAFcCYHT+ihT+JDfLpC5xXsiFqIFQ90Qp9P/o9j4APg9FA4
	 gv4EzfzDJgann3voeOVVbdyBgkcOO97uS/qUOBc3Sjpgdhv9w+abIc033xoDuU49QaA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795264255;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Date:From:To:Cc:
	 Subject:Message-ID:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=NvdKb50ja2nv9naVYzdyhx+yIDMWqCwfYQ8Ecq0us9Y=;
	b=oddHZYTjfKoh76CTB0mk1vjdEEgisKtSmNKk0c5hj3jabp+qQbPrjjRO012dFuCAqUN+
	 wvBr3pgjHPtmEjZoDvPP6r9oj9WvBc8DcOjaAC2igrkR7CKC/gpw97SazL6kfCjqBcsND
	 LKSDVg8V8hlkcW+fDKIByJcQZ7PP6Ej91Q/ddwaTqw9NU5VSX/06fkGFQvyXjyk5L2GEd
	 F/zai2i6sPxdVoRUl9nRD1ivFZLGpDmavlfZcdjK6ZKf4Uv+lki/ayxhPxYsu6qIaYYT6
	 UDNxhUZ9oWasvVzUEtA8PefuYP1ygeO/MY/oIZx7e4jiPlfT63Hj2a2El2RbH7IVcNA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=vozeler.com;
	spf=pass smtp.mailfrom=vozeler.com;
	dkim=pass header.d=vozeler.com header.i=@vozeler.com header.a=rsa-sha256 header.s=max-2024-2 header.b=czjgOx0g;
	arc=none smtp.remote-ip=80.69.43.37
Received: from imap.hinterhof.net (imap.hinterhof.net [80.69.43.37])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87060606A32A;
	Sat, 21 Nov 2026 12:30:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 87060606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=vozeler.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vozeler.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=vozeler.com header.i=@vozeler.com header.a=rsa-sha256 header.s=max-2024-2 header.b=czjgOx0g
Received: from dp.vpn.hinterhof.net (i59F45518.versanet.de [89.244.85.24])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange x25519 server-signature RSA-PSS (4096 bits) server-digest SHA256
	 client-signature RSA-PSS (4096 bits) client-digest SHA256)
	(Client CN "x201t.vpn.hinterhof.net", Issuer "Max Vozeler" (not verified))
	by imap.hinterhof.net (Postfix) with ESMTPS id A38C68FB862;
	Sat, 21 Nov 2026 12:30:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=vozeler.com;
	s=max-2024-2; t=1795264249;
	bh=1jQ8jSmnuUwyckou/IUtpXO7t6jYpOfstTV/OBJ0Xb4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=czjgOx0g3/Asbj6YQMK/YD9cgSpMF8zM8dabdrbCTquTgU62yiaC8s/se//zNJg9i
	 nmtm290uW+2eclh1PqHuqBUdQhruDXYWjsr9zAPHdDEHXbnpyMLCBjy1jkXRoWkF5y
	 8euF0eNqqlspt6f4OTMA1l5QSHqKvfa204C05OYBi36Way4lLMaqYumOfLlqq9kJpu
	 v5qBYtNU+gk3lLHgpWl/AQ6lFZCuvdCcrZQmIKQuaPKumB9DiwJgxs5S6sgiDaRrGa
	 jzfHQXcb+VRlxGkWdc1oQ3IGO23S0p3j2OJrXCCVDWJEw4Op/AD99PFm/ojbajht3D
	 hSJZnLhouo6FQ==
Received: by dp.vpn.hinterhof.net (Postfix, from userid 1000)
	id 43B2826018A; Sat, 21 Nov 2026 13:30:49 +0100 (CET)
Date: Sat, 21 Nov 2026 13:30:49 +0100
From: Max Vozeler <max@vozeler.com>
To: Chuck Lever <chuck.lever@oracle.com>, Sasha Levin <sashal@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Chris Mason <clm@meta.com>, Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org,
	regressions@lists.linux.dev
Subject: Re: [Regression linux-6.1.y]: NFSv4 server: sec=krb5p mount fails
 with EIO in 6.1.192
Message-ID: <awGO-R42ggk_WEga@dp.vpn.hinterhof.net>
References: <awBIdxOJ4XSXuc7S@dp.vpn.hinterhof.net>
 <awFyZbQE8pDyOxUy@dp.vpn.hinterhof.net>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="1fHbNZ7pjevDWFIY"
Content-Disposition: inline
In-Reply-To: <awFyZbQE8pDyOxUy@dp.vpn.hinterhof.net>

--1fHbNZ7pjevDWFIY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

#regzbot introduced: 82cf21374fb7ee55b37be9afb6704ba0eeffb236

On Sat, Nov 21, 2026 at 11:28:53AM +0100, Max Vozeler wrote:
> On Fri, Nov 20, 2026 at 02:17:43PM +0100, Max Vozeler wrote:
> > after upgrading an NFS server (Debian bookworm) to 6.1.192
> > (Debian linux-image-6.1.0-55-amd64), NFSv4 clients fail to mount exports
> > using sec=krb5p with EIO.
> > 
> > Downgrading the server back to 6.1.190 (linux-image-6.1.0-54-amd64)
> > makes things work again.
> > 
> > Good: 6.1.190 (Debian linux-image-6.1.0-54-amd64)
> > Bad:  6.1.192 (Debian linux-image-6.1.0-55-amd64, linux-image-6.1.0-56-amd64)
> 
> Reproduced with vanilla 6.1.191 and 6.1.192
> 
> Good: 6.1.190
> Bad: 6.1.191, 6.1.192

bisect points to

commit 82cf21374fb7ee55b37be9afb6704ba0eeffb236
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 2 12:07:07 2023 -0500

    SUNRPC: Convert unwrap_priv_data() to use xdr_stream
    
    [ Upstream commit 42140718ea26c47fb06c679451a6aa6703545136 ]
    
    Done as part of hardening the server-side RPC header decoding path.
    
    Reviewed-by: Jeff Layton <jlayton@kernel.org>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Stable-dep-of: a919c5c88769 ("SUNRPC: svcauth_gss: enforce krb5 token minimum length")
    Signed-off-by: Sasha Levin <sashal@kernel.org>

This seems to have been part of a larger series, only parts of which
were backported for a919c5c88769 ?

Best regards,
Max

--1fHbNZ7pjevDWFIY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename=bisect.log

git bisect start
# status: waiting for both good and bad commits
# bad: [08889840163ebcdb7e24bf7ec311bc2e6fc3aaea] Linux 6.1.191
git bisect bad 08889840163ebcdb7e24bf7ec311bc2e6fc3aaea
# status: waiting for good commit(s), bad commit known
# good: [79807e970724c1f90cee1316361d61b80db4eef6] Linux 6.1.190
git bisect good 79807e970724c1f90cee1316361d61b80db4eef6
# good: [91c2a5d201daf66fa3f42b8a383bb89174bde2c8] serial: core: fix infinite loop in handle_tx() for PORT_UNKNOWN
git bisect good 91c2a5d201daf66fa3f42b8a383bb89174bde2c8
# bad: [ab8c8e027fa8f9314340a96999dd3309b7f80d61] fbdev: ssd1307fb: defer I2C transfers from damage callbacks
git bisect bad ab8c8e027fa8f9314340a96999dd3309b7f80d61
# good: [35b46918d5deee01fade7e2f2075a7c238a2a0e8] cifs: prevent readdir from changing file size due to stale directory metadata
git bisect good 35b46918d5deee01fade7e2f2075a7c238a2a0e8
# good: [91abd8383fd0588d1fcc31120d6344150a64ba5a] net: sched: cls_api: add filter counter
git bisect good 91abd8383fd0588d1fcc31120d6344150a64ba5a
# bad: [ed126ca71d4d949ad99f40b974a8f7685e808f8b] net/packet: defer vmalloc TX_RING free until skbs finish
git bisect bad ed126ca71d4d949ad99f40b974a8f7685e808f8b
# bad: [82cf21374fb7ee55b37be9afb6704ba0eeffb236] SUNRPC: Convert unwrap_priv_data() to use xdr_stream
git bisect bad 82cf21374fb7ee55b37be9afb6704ba0eeffb236
# good: [8da6f765098d46e5b3178ef4b2f8273c9ba1d3bb] SUNRPC: Rename automatic variables in unwrap_priv_data()
git bisect good 8da6f765098d46e5b3178ef4b2f8273c9ba1d3bb
# first bad commit: [82cf21374fb7ee55b37be9afb6704ba0eeffb236] SUNRPC: Convert unwrap_priv_data() to use xdr_stream

--1fHbNZ7pjevDWFIY--
