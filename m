Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C058299959;
	Wed, 29 Jul 2026 01:55:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785290128; cv=none; b=MGVnSi+LBbemHJJRyx4ZOi2ab1aeKt7s8J0dEH/wuhk38j8ro2TqD17YDKZmO5daOdBfS+9REQHXypfM2jloSPUMq/+YKqtmVU2aOErx5F8tKcnhGOrV687NVNyq9NSQzuqS3qcyuUKEn4rs86A1QGgSdYOK2JA5telbDaA1/cE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785290128; c=relaxed/simple;
	bh=Pjde1q0g7QGLdgaY1H6cw1u3CKPCuGipuahVxByvFZc=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ICxzFOw91EqnmQLQyJ3ITp84q7ZyB4kCsfmNMgVWpTfPUJGOH9JbmQ6pa/XkBgjfSnLZd3dokvOoHCYHYkNZrL6691Afp55U6oAovaoK+0oTXOzQDmu1WO3Fwoc7Izc5RbnQJnm9fHVW9PFtaiEvvV4Fn/AfhJiq7AtmTsqNISU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lqMGkZu1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lqMGkZu1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A2EC31F000E9;
	Wed, 29 Jul 2026 01:55:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785290127;
	bh=echbaU/pnXRdj3dnkF4Rdh3Sa2jxj+7ZtfiEQv23Ul0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=lqMGkZu1UM77dAXvguyykXJiGzPMmPFLICUjdCVfHmYb4QUwNFwTlawWKVVhAkbVE
	 q+6Zq/MXig8XPNyAid/I8NRNmpIt3Rc3R2R0BaSB9gCfT5ncaR18Yvcal5oEjw74Ot
	 3/sCHIdYTr3R/eyXyar01+S44RopF6ftsrNcLGdt8cUnqshGJm/r0fjKPa2HuSjeRQ
	 CUhGyORzPTZeU2kPGquedRWzyYv7ffZRsiBJpbI0OCO9J22AlJWuKG/iY9+eiauG10
	 sqtwJvRUWjPZrmYsKsM8qsaFL2i/ck5omUjC1hQ9lCNhZvChyUkEqFNtwXNg+x8fAS
	 dcvg7GJtpiIiQ==
Date: Tue, 28 Jul 2026 18:55:25 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>, "Sabrina Dubroca"
 <sd@queasysnail.net>, "Shuah Khan" <shuah@kernel.org>, "Jeff Layton"
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>, "Olga Kornievskaia"
 <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey"
 <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 0/6] Deliver TLS control records to kernel
 read_sock consumers
Message-ID: <20260728185525.27b443a9@kernel.org>
In-Reply-To: <97b61f5f-57df-4a29-85a0-613f7b7e75eb@app.fastmail.com>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
	<20260728184312.20b21582@kernel.org>
	<97b61f5f-57df-4a29-85a0-613f7b7e75eb@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Tue, 28 Jul 2026 21:46:57 -0400 Chuck Lever wrote:
> On Tue, Jul 28, 2026, at 9:43 PM, Jakub Kicinski wrote:
> > On Mon, 20 Jul 2026 10:27:54 -0400 Chuck Lever wrote:  
> >> - The no-data cap (patch 1) is a prerequisite, not a stand-alone fix.
> >>   Once control records reach read_sock, a record carrying no payload
> >>   stops advancing the caller's read descriptor, so a peer streaming
> >>   such records would pin the socket lock and the kernel receive
> >>   context for as long as the flood lasts. Bounding consecutive
> >>   no-data records supplies the return boundary a system call would
> >>   otherwise provide. The cap is scoped to tls_sw_read_sock() alone:
> >>   splice and recvmsg run in the caller's own context, reschedule, and
> >>   drop the lock on return, so they need nothing.  
> >
> > Is it just me or this is incomprehensible slop? Run on sentences 
> > full of terms no kernel developer would use?  
> 
> It makes sense to me. Which terms do you have trouble with?
> 
> Patch 1 is moving to a pre-requisite series, so this can be dropped
> from the cover letter.

Did you write this? If not what model did you use?
