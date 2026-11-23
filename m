Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=46.4.95.116
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795451218;
	b=GzlLxY9Wlr1w2f5x/edgLwgjSA39pQTn8XEczjoeZNCHJJVAK+EmthTKIAQT6qK7woY4
	 tWbXTcbecVpTATEKWwzslATWrX0JcUogHggd+0fslmtZSIXQ28lXgsPzzk96C1IYRvsXI
	 B2xwrCpCV/XDFwdnMYuVv47KBGizYUi24RoEkUYjVn0yyUW98Kjk2TS+5v8KuLpAWNYAD
	 AQ+YyR/G3OLoby9zoUcXM+IFtuw+9biUk9zrg7g4WUlbj5KlDDeUIpvdoZO/6156TXqb4
	 MQBjoVr7J10ScU447wFaRmE1fy4DmEe2qAb2wuCoE+4fHDBcuyz3rTg79nPrAGzITjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795451218;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Date:From:To:cc:
	 Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type;
	bh=PHV6lBrqCPczsVQk1+oW7kxLGeOEGRqD59BaxpJ84GI=;
	b=Pvk8rSSDV0LvbTOxk3yepQ7I46qBgPEvfrWEpkd+mJltxNdjyaOE857z1qwX9SNiWCLq
	 JYKSHv4W/1foUeq+c5KmQJ5gZIXRBmJ8tocbOiInfKeNeW/Zxf3JsNKbQkcaCHbHqXRpH
	 gzUgbLUX7w4xnrLBdHGIpEkY3ZDDVCMHQZd6KXUWs0yNpZ4ijym9VMvxkjzuhXburhq2n
	 5j+PQrBN0dX4NjzvosN1eVvGgA0P8wLGxorZcg7Mu0bcCErE6avW/YfYwhxgChAyXBU4L
	 hjfZ422pDBUh2GLiDzo+Sdii3Y2bSz+sXCtyjUnhfSpwG4wYWJkPrdtAqMc+GRCT6Ag==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=dolda2000.com;
	spf=none smtp.mailfrom=dolda2000.com;
	dkim=pass header.d=dolda2000.com header.i=@dolda2000.com header.a=rsa-sha256 header.s=dolda header.b=EFSjRk1k;
	arc=none smtp.remote-ip=46.4.95.116
Received: from ansgar.seatribe.se (ansgar.seatribe.se [46.4.95.116])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (prime256v1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E4045606A31E;
	Mon, 23 Nov 2026 16:26:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E4045606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=dolda2000.com
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=dolda2000.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=dolda2000.com header.i=@dolda2000.com header.a=rsa-sha256 header.s=dolda header.b=EFSjRk1k
Received: from [2001:9b1:40cc:0:ffff:e9ff:2d3f:febd] (helo=nerv.dolda2000.com)
	by ansgar.seatribe.se with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <fredrik@dolda2000.com>)
	id 1xVWsZ-0004YM-02;
	Mon, 23 Nov 2026 17:26:55 +0100
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=dolda2000.com;
	s=dolda; t=1795451214;
	bh=b8WnSVWZR86BAJmjP2w0UP9N+pVWyNW/CB71luTA9wY=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=EFSjRk1kHYIsJI8KVQWXT57l8pocxXSb67XbbUZcBwPmApMN6txuO13ayKxs8ycAv
	 OFu77g7Coka662KmEeKSJvY8Lz4kHJDTgqd71DPSmkQAmUtenjPvUC0/CjYo9tYKLq
	 tepf3vIm2VmwXpFOkicst0wcSoS5V5Tsdy6uWNee7XO2y8Qv/ydk1+PIxcuoLsz7mn
	 HlgU7zIOzxLYDzZbOzoAV5JXgFTvxC/cOFWZY0QMNwmHOwPHtq7QxX+5y7Wa9qozSD
	 J2osTt8eCUx0DLU15iNsiD3LKCOncRVXcmstuJrymEW8w3U/f5EDIdkvVa+u1/F+oj
	 Uat/DUjac3ASw==
Received: from shack.dolda2000.com (shack.dolda2000.com [192.168.1.187])
	(authenticated bits=0)
	by nerv.dolda2000.com (8.18.1/8.18.1/Debian-6) with ESMTPSA id 6ANGQr1S011770
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NO);
	Mon, 23 Nov 2026 17:26:53 +0100
Date: Mon, 23 Nov 2026 17:26:53 +0100 (CET)
From: Fredrik Tolf <fredrik@dolda2000.com>
To: Chuck Lever <cel@kernel.org>
cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Make svcauth_gss sequence-number window size
 tunable
In-Reply-To: <9f8f700f-a10f-4aff-a385-4300c8164f1b@app.fastmail.com>
Message-ID: <a09eb43b-3078-d6e8-1529-8aee1eb302b0@dolda2000.com>
References: <20261123005648.29562-1-fredrik@dolda2000.com> <9f8f700f-a10f-4aff-a385-4300c8164f1b@app.fastmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed

On Mon, 23 Nov 2026, Chuck Lever wrote:
> I don't think this is a SunRPC scheduling problem. Rather it's that the
> crypto handling sometimes takes a while (and I don't know why that is)
> and that delays one RPC just enough to trigger the sequence number
> window check.

I think that it is. I reckon that, since nfsd handles requests 
concurrently, there are no particular ordering guarantees on the sequence 
number checks. While it's true that the particularly long time that the 
MIC verification can take seems to be the actual cause of the issue in 
these cases, I don't think making that go away would be an actual 
root-cause fix.

As I mentioned, I considered other heuristic solutions -- one of them was 
to effectively hold a lock during the MIC+seqnum check, or other 
mechanisms that would compensate for the time the MIC verification might 
take, but in the end I didn't consider them technically correct either. 
Again, since the request processing is concurrent, I reckon that, while 
much more unlikely, there could be other scheduling issues (ECC/MCE 
hickups, interrupt storms, &c&c) that could delay a particular nfsd thread 
from even reaching svcauth_gss_verify_header before the window has already 
excluded it by the work of other, faster-working threads. A *lot* less 
likely, yes, but still hard to consider technically correct and fixing 
the root cause, no?

As I said, in a UDP context, I imagine this wouldn't be a problem, since 
the failing packet would just be considered lost and retransmitted, but 
that's not how things happen over TCP. Unless a TCP connection can also be 
made to just consider such requests lost and having them retransmitted 
later instead of closing the channel, I imagine the only real root-cause 
fix is to serialize the GSS verifier checks, so that they happen in TCP 
stream order, and that seems quite difficult to do given the asynchronous 
nature of the sunrpc servicing implementation, which is why it comes back 
to a scheduling problem.

Again, since I considered that problem quite difficult to solve, that's 
why I suggested this solution in the interim, just because I'm sitting 
with disconnection storms on my home network that sometimes makes it very 
difficult to get anything done. ;)

At least that's how I analyzed it, but I'm really not familiar with the 
NFS/sunrpc code; I'm normally just an ordinary home user of it. Thoughts?

--
Fredrik Tolf
