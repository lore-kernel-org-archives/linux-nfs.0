Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792523312;
	b=I/FPtHmgUtFyBGBIfrWloSIN1Hz4EVyPnoVZNMvcY5Jwu/CDZ4FI1B+qdwglxYkP1XjN
	 R9zP1lOn3UdKM542e754ehJmWO3HC21FP2woS1hX7V0/pyqZNJ7AYSyrPh/hLJutzyyGp
	 DJb1MdJhFv8+/8rJ9p1b9+qAHFPG4MEJMCqll8wKoysuEdZCFT/7T3YnNjl901V6+DIVM
	 zqaTyQn8HDWx81xH6BDmkD7qD8HTtA61VSGUhVkcguIkUbcHAfrS/p6Ppk7qh0d8raAYn
	 4WK2iLl0I0Q0GIYqgOuP59ACETvKJoEppa7Yi6Q7wgu3h7eHzvQvjwjyjUup7jQzzgQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792523312;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=zqDWx72JxW3XoyhcbzSZpzCX8lSH1FbDdSuSKJXe0xc=;
	b=ThxDm0883Z+4y7KmfUBw/Jlf2+qPBUE1UXpw6gaa7hhME+6TqTqE6bp5vQ0rJItXy1hc
	 uR71KW2Tz4h/zIGtnI9f4auSIbeQrlL733hramI3CqCCzL3eNgBQ1cYTbY4FMg0VES4Sw
	 LHk3r/KpQ1gdaGxtwXH9W5/KmBlxgoumcphT5Mx6jC2RrmIbEUBpErsB2EokkOdhSNOJv
	 ytySKzdHkGQehaF12nyr8e8bOGqecGe9UM7nQbCJkcjS+gHFdwD4z+r598ald//mZp8Fp
	 G79IsmFCL02Peu5Mw5W7pSZYijSVbDOYTBhUNp8YFJi4x5vd6J8V8W+VzDFYp2HCdcg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fcmydM5m;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1828606A31A;
	Tue, 20 Oct 2026 19:08:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fcmydM5m
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C17601F000C9;
	Tue, 20 Oct 2026 19:08:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792523311;
	bh=zqDWx72JxW3XoyhcbzSZpzCX8lSH1FbDdSuSKJXe0xc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=fcmydM5mzhZIi6XAObdZBicXoQerq88aCSOo8wIl4QTjF5jA+xH65vU80LIRTNniI
	 RBsHzabuMHKUpeccsPYTj27yhKpDJnS4nY5iohhQUaoZQrY3xMJ7EwrbNZV8686UDi
	 6YQDJ/X3UQXrqFVeJJjD4n6KPKsKyuERZrJGjchunkwxrV/KC1hyjG7hJcPoZu8L6d
	 vkiaf77HxWpz8h3FnlU8ldQVAYd5VssyAH3dIwgOz1cwdRBc+antk1VOrylxto/xTW
	 Z1Blw+jlImZ+6ZtYe5QOqcLpZthZs9u4SXkFl/OK3HWGFKCy0eaoqpT7AcGcqQbgQq
	 nw2G10bAum5Rg==
Date: Tue, 20 Oct 2026 12:08:30 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Donald Hunter <donald.hunter@gmail.com>, "David S. Miller"
 <davem@davemloft.net>, Eric Dumazet <edumazet@kernel.org>, Paolo Abeni
 <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, Chuck Lever
 <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga Kornievskaia
 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
 <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
 <anna@kernel.org>, Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-kselftest@vger.kernel.org
Subject: Re: [PATCH] nfsd: add NFSD_CMD_FILEHANDLE_GET for root filehandle
 lookup
Message-ID: <20261020120830.750d3794@kernel.org>
In-Reply-To: <20261020-nfsd-filehandle-get-v1-1-8c54f625800b@kernel.org>
References: <20261020-nfsd-filehandle-get-v1-1-8c54f625800b@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Tue, 20 Oct 2026 11:32:16 -0400 Jeff Layton wrote:
> rpc.mountd still fetches export root filehandles via the
> /proc/fs/nfsd/filehandle transaction interface to satisfy v2/3 MNT
> requests.
> 
> Add a netlink equivalent:
> 
> FILEHANDLE_GET takes domain, path and maxsize and replies with the
> composed handle, mirroring write_filehandle() semantics. Include a
> kselftest covering validation and byte-parity with the /proc interface.
> 
> Signed-off-by: Jeff Layton <jlayton@kernel.org>

Reviewed-by: Jakub Kicinski <kuba@kernel.org> # ynl
