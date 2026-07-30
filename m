Received: from fout-b4-smtp.messagingengine.com (fout-b4-smtp.messagingengine.com [202.12.124.147])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56929404BD5;
	Thu, 30 Jul 2026 23:09:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.147
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785452980; cv=none; b=FELmpM9d9GwkcNGVJxyFqmc+TgZ3A0mRhKnoYhv4kELCnkqf4CyiltGudSudtBOwCF71DYUwd22CTHOeDotYMTjCS8R4eJoaxK0S7UJw+NgAw4XkQETVpZ8rLYrWct+PtMHAvzRc1Dwz4aJ18pdn5eA0F6s4BFA60vS+lDCQGCM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785452980; c=relaxed/simple;
	bh=p8vcO9sqYN8YGBKmhGTuSESszkicWRx14lcnGRZEhbc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Zy2r+p4qg4FpQriCO2VZaz3yQsnPjHrKjyE7P6pojAjl/sHoV7CdnmcMAFKbjGvB0wF5KggBTfokC0VGjxIH2ohGBK3YHtSklYNmPKqSK5QNJPHKjaUza68M+m5W9f8WV4ThV9r5AUTbpwzZHEJgzjf2Qb+rokadIsfV4AuHsIU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net; spf=pass smtp.mailfrom=queasysnail.net; dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b=NVmdkuZT; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=czLT6riA; arc=none smtp.client-ip=202.12.124.147
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b="NVmdkuZT";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="czLT6riA"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id 3503A1D00120;
	Thu, 30 Jul 2026 19:09:36 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Thu, 30 Jul 2026 19:09:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=queasysnail.net;
	 h=cc:cc:content-transfer-encoding:content-type:content-type
	:date:date:from:from:in-reply-to:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=fm3;
	 t=1785452976; x=1785539376; bh=p8mXE8RqAAFfOuwZkx+RyJGiSlmZs059
	fFe8cZB1vz4=; b=NVmdkuZTL3CIhifCITdGadXrohKRhupkomU//lQoLTt0OF/U
	M7nGahTIRiMH+mrE2nXkSBXbSo0qnOFntjx3I7t1/LFvjXpX5qwyT9xmo7apX34b
	2/ohbv6avZrMF/QkLc7PO9SUTE7qGgRFchJ6ALNC9SHCLmnKvggapNNoW2EnsiCf
	C7OW0stlZGU8Pur9MajhjV8YvohNdZWJGXNX1ozt/XEXr0psIkDVAROf9BPLzM7s
	+JlHaoNi2pzJbsrXRheiLroF2W52v0+5wSMhC/C/v7li3t6ULJQua6QZ1SpoZqd4
	44+dmcNWU7UJiFF5trn5UHFDEIDWA8ZMm/2oHw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1785452976; x=
	1785539376; bh=p8mXE8RqAAFfOuwZkx+RyJGiSlmZs059fFe8cZB1vz4=; b=c
	zLT6riAWyoFVpkdEYp45CryApBx11J8CT54rwY0TAeV+QsZaaPS3wSxy+FtHH0FG
	Sf46HuB+aic6QF7ioC8/ML7Nt8KM3fQ3jIv9TrKK11gxlPgCSRX74FBQwqBD2JJe
	FpoOmKpgXEDuZZ6LqCRJvNy4EllEK/TgLdzVLt2g07AQ0BpKLqmGxTRAnSb7shi5
	UgttIFtBtMEuOVzdXXcnIKJVSqAWnZhuE/qUTDPQdFW2IWTgas7EpYoHQYtLo3Q9
	3zUUt+8MqeDpIqiTZNXONzkwGOyT/Eas5AakiPBdIHsxy6320+PE1RnUeTW/2Vkn
	fc2SVzoqLp87WjJ633WWQ==
X-ME-Sender: <xms:r9lratAVuEL_tSUIhhBdvNuUvwnHhtP5H1PdZcS_z62O-ha5ZT68Vw>
    <xme:r9lrar-cZHvC99pJqNtfETvgCXcWEtswtrOzhmuMqNQuWPSsqHUIJ5srzK9ryLu3G
    w9FOogApTzRN5eTZkMDNTB3-J4dmLui17nr9ekOpBBszVQqbVB4lAkY>
X-ME-Received: <xmr:r9lraoXHoXHMiJNHzAOLMo4NNNUXQCC8afmCzrWwcQOJvDOKjlrTm0mdeDA>
X-ME-Proxy-Cause: dmFkZTFX0J2mwK0ucs+bNdNdsXX5JEB1iH9hBaw/20LZzznGsfd769sIYQ6qyKOZO2I6jG
    uJElLJhiPAeoBeMNNRAwZNu+KfT4zJHjVE3aZ2Ci1FpFoDnBYikVOIU1TipVptH227b4ut
    /D5W3gNggJwgwgpaNnw3rM1quzOBBljzZTZkvg5chFj3pk4bg+DUmsBrE2A33adxMlusFJ
    pVIh/wIq6+IMQVHrO9lleJfdfX6iy8eBcfO5iB3Ri1jf85bxd1ciThEd1v4Dryofu51p2g
    IIY4Kc7rbrW9gISdrsyK3zjW3u8voftJb/cNT9gzFFYn/1JHee01XmMtUvbjkDA7zQ3cRy
    taFwHniCW7xoAUz0+vBry54qizOeR/spxvxTgUjZY6atzNi9sbtf6A8w4E4qSFeEEzoDT2
    F46bGGvh7jp0l+8k4DxDSN+f1pzuv8/l6PZP/ki+Y4QB8SDKuHds+SNJcftH6Vm8mQIRtV
    UeXna6jPW4xf8C+nD8zyfmzUjGEjypNJaQAG/SdN91QHDyAduRh9YWTiRiKBACfcd7oWwv
    jZx3onT2aZKDf2ICm23oZm9H8q7I/sp4jFUwox0PbNLRrWfq0o1axfqNW4tIvBqHmoVAmJ
    zIS8bmOh7hOafLgECT53o5nxvvZFgX/w0FEcYtr9KElm0Xr+orJiWU6Vtc3w
X-ME-Proxy: <xmx:r9lrakJBUVYF_Xave2M0o1py_DfaC87nMxMU9JF_TTz17Qnze1Fk1Q>
    <xmx:r9lrasAfvUBLaYWRc5xZZAaXaRpbdtdGCp92hgbkSQE_ZT9kxLde8g>
    <xmx:r9lrakFkwPNIvkE0AdoyuPW2_SJvgmr6gjMm92RewDTqUvBpozm9Jg>
    <xmx:r9lrapKdOoH-S14C-7e5k46YhKggHvIUxtlFnAIQU2JDbmQyPE2XWg>
    <xmx:sNlrat0jAkZLsBDGcH0_4VTrCeehf6yzMplONhiHka0506I5ru2FCm9D>
Feedback-ID: i934648bf:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 30 Jul 2026 19:09:35 -0400 (EDT)
Date: Fri, 31 Jul 2026 01:09:33 +0200
From: Sabrina Dubroca <sd@queasysnail.net>
To: Jakub Kicinski <kuba@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	Shuah Khan <shuah@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
	linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype
 proto_ops for control record delivery
Message-ID: <amvZraHU3n2sQts1@krikkit>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
 <20260728185124.72e421c8@kernel.org>
 <480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
 <20260728193058.7f6b453b@kernel.org>
 <a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
 <20260729163142.4f41484f@kernel.org>
 <amtcwSO24GGq_qd0@krikkit>
 <20260730143556.4a8463fd@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260730143556.4a8463fd@kernel.org>

2026-07-30, 14:35:56 -0700, Jakub Kicinski wrote:
> On Thu, 30 Jul 2026 16:16:33 +0200 Sabrina Dubroca wrote:
> > 2026-07-29, 16:31:42 -0700, Jakub Kicinski wrote:
> > > On Tue, 28 Jul 2026 22:51:30 -0400 Chuck Lever wrote:  
> > > > No-one is asking you to roll over. Review means you get to steer
> > > > us in the right direction, and I promise to do the leg work. Terse
> > > > rejection doesn’t move the discussion forward. It stops it cold.  
> > > 
> > > With LLMs tho, the entire human effort is in finding the right design,
> > > rather than the code. So asking maintainers to hand hold everyone thru
> > > their features is unrealistic.
> > > 
> > > Off the top of my head I think a setsockopt which pre-seeds the content
> > > type so that the read returns an errno if the queued content type is
> > > different could be a simple fix. You'd configure that on your sockets
> > > to DATA and once you see a EWHATEVER you'd assume that some special
> > > record arrived and the socket has to be handed back over to the TLS
> > > control path. This is literally the first thing that comes to mind,
> > > IDK how ugly it will look in reality so no promises.  
> > 
> > But then you're back to "read_sock stopped, caller has to take some
> > special action to handle the next bit of payload". It's not better
> > than "read_sock, and do a recvmsg when read_sock says it's not DATA".
> 
> My bad, I replied without looking at the code.
> We already constrain control records in the way I proposed.
> rcvmsg (w/o cmsg) and read_sock will error out if the next
> record is control.
> 
> I guess I don't understand what Chuck meant when he said that
> he has control data leaking into page cache ;/

I think "if you do recvmsg with a cmsg and pages, your control records
end up in the pages".

To avoid that, you'd have to run recvmsg-nocmsg/read_sock to get all
the DATA out, then once you know the next chunk of payload is a
control record (and hopefully nothing else is reading from your
socket), one recvmsg+cmsg into a separate buffer.

The weird read_sock_rectype magic here avoids all that.

-- 
Sabrina
