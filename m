Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B31322AE65;
	Wed, 29 Jul 2026 01:43:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785289395; cv=none; b=V/W+Ea7Je369Yw4cgnWDsGVD+/LM5Ba+P1T4/jo+dh3d65BhAoYHGh0i9mk6ywQaZNOfDsGbTvjQ/k70SZ2w33I60v2kf7w5mPUqdk1NS1QG5/Djl0VzICtie/7hvpdlwaW6SZPeE+0S/0XPol3JoH+02h7o4QXirC7Q1H8+ATI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785289395; c=relaxed/simple;
	bh=oIyk41X5ZpSCbosSjqo1UkivYY2/+g7Tcggvw0G0X/Q=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=mEMHg5zMrx8bK6g0WDNwffM9gjYyFoYa90cV5zGjETO84z5rBBmvz8ojInGQ4DranGGQTMctMiWvFpALQ1c3KvYGb0NwS7gmkfAdRLbdHU8w9DOX7zVhNkxdsCX+akFo0g9MgqNMpDCMQrIZ4QtKTi02f9ULoLNUrzrExkeDNoQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MquVpH+e; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MquVpH+e"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 215A21F000E9;
	Wed, 29 Jul 2026 01:43:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785289393;
	bh=N00GLSISRz/Ulv4ykckOj8Kr6pruetBm+OdZ1a7fNvg=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=MquVpH+eCPFM0djjXbRFFv7zpASpcXul1uTcZwMAaDSrEutTuwrGgvTbxYWBWjQyh
	 LfNn9AKi9gZFAxvyPMjp4Et4O8r6KzTVTvc1gmvp6geqEVvuNHtyExRNWc3aDOukrX
	 beXnCdikhA7ERa2lJC1OraPyxTH9MAZN/mZJZoCA7o41z9v+NDbbutXg54TzAvsptZ
	 p5qBb6illfLzB+GLqzMTZGt6iOM8BIAoPgLkXgHeNCZljHEC/Tb4Ggvknu+IQygkdu
	 B8N32050omrgVnKCWagtEleZhGJ4smzpcyDFUCxFPp6HHOZnDcTxUzZ/Q0o4eRBiV9
	 um+xm1qAC296g==
Date: Tue, 28 Jul 2026 18:43:12 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, John
 Fastabend <john.fastabend@gmail.com>, Sabrina Dubroca <sd@queasysnail.net>,
 Shuah Khan <shuah@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 0/6] Deliver TLS control records to kernel
 read_sock consumers
Message-ID: <20260728184312.20b21582@kernel.org>
In-Reply-To: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Mon, 20 Jul 2026 10:27:54 -0400 Chuck Lever wrote:
> - The no-data cap (patch 1) is a prerequisite, not a stand-alone fix.
>   Once control records reach read_sock, a record carrying no payload
>   stops advancing the caller's read descriptor, so a peer streaming
>   such records would pin the socket lock and the kernel receive
>   context for as long as the flood lasts. Bounding consecutive
>   no-data records supplies the return boundary a system call would
>   otherwise provide. The cap is scoped to tls_sw_read_sock() alone:
>   splice and recvmsg run in the caller's own context, reschedule, and
>   drop the lock on return, so they need nothing.

Is it just me or this is incomprehensible slop? Run on sentences 
full of terms no kernel developer would use?
