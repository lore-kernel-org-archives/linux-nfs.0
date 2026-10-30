Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793375905;
	b=yDsJQiieQI1JcsWq9aCENJux+qShKF33kKLpqpidG22flbLkGQWYglWMPRT8DAtDvUHJ
	 JBp34AMUmy6w9mEoNOmwRi31ukD0OToMPeiQ8nIz1owZdvTn3oR5afZEjcCJuP4nElGs0
	 JQRou/FBRxs5/zm5fkCtA4CtqcGeiaPcWs2qBj9yufMjI3nwU7x6as9aMzHqOfnUZez+m
	 dcnGeBA8NPjrACMgdQb03BRNUkSQiy8A80JqtkszSOZp+NpeF6s3BZFYxRxqFGIl3NNNb
	 UwOMdsMni2Ai6q0Drsz/CFJcuupZBVn8u1ghw/u79I3GSEbqsjpvrRosEoFcs8M1l3g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793375905;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=ugsmaR88kMN2oQcAWD1Lmksjvku/rI/ItVMJJDmlBq0=;
	b=lGUTpe0dbUa8rUBjEg5WUBbBnQGiivcuNPC2XEOc6YKe6BME4dsJnjiucfk71T3s2akz
	 pGSU5fopArbRmB2KiTbVBNKRyoG/hdAX/YthbBYprmwkyR3pvwCcrtQCoG05t8/KU9CVK
	 WwuRKl0XoXkSZ+bsn36gNGZnHmOvl9gn7T0RfxP+b9dQZzDorpwAf+/JWiK4l+ZLGWBHM
	 S5ld85YnPMj4dzZVajfR4xAO8noNKOkkfdeq7jXm0RkXTj4n5A45I/bQ4bvBjoaSiR8gB
	 YPL+jNxd2YXipYC0q8tLZAUVAjsh7IcoLKaf1NJpbPa7WRXdOhM5GS95S2Tww9MlPhw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nNNSeTag;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA55E606A31E
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:58:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nNNSeTag
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 35CD81F0093A;
	Fri, 30 Oct 2026 15:58:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793375904;
	bh=ugsmaR88kMN2oQcAWD1Lmksjvku/rI/ItVMJJDmlBq0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=nNNSeTagU0VnLwmLnkH1nohIhaYRCH2lunpUrGjaIoZFfzDW/iTWhoa+qg0PExDu7
	 NdzNGKOnqTHswL5Pv2r1pDzIuct2s1g3GHq0ohTlQHmX0OmOPW8ql4xOsXYB+LOt2D
	 tIsU8XFcgHsIp3HIdvLXZ5FbtSGvm+yljMEQgJOaJzo1q/ZPWkf49QQirKoMjQYV94
	 eMLzdWhFNl6Sv/6PsVg250K2uU86rkmzZxk8ISce+HLJQzAl/uwcyOeqrmlIZ/jLJe
	 gemS/OSze2et3FmW3HNt3t1kqel1wOLgD/rO1NBD7FkMwDVlot71c704CMD1DxuLfZ
	 mP8kkoFI3lsnA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 79EC7F40066;
	Fri, 30 Oct 2026 11:58:23 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 30 Oct 2026 11:58:23 -0400
X-ME-Sender: <xms:n77kai88DUUTglfGlBzBFUSsARsLm8mcTRcPnAT_Vf1BDdncVxGqgw>
    <xme:n77katitl2PoKVuQrdmHAwJyjGP4GWke7yKwUovoyBvG0sOHcbhJAcz6UXpl_0HnL
    pKd3fMlI51-x8n9l4Wb4XgORdOL3N_eZKnGEtnMCaQ3yudC4Jr22iDC>
X-ME-Proxy-Cause: dmFkZTFX2upPFkA+ir9bI85RztKcmS3kRsRwGerZaHXB3r82fdvD+Vn3CiTcnvlqqZBK5N
    FkoQehjBnWvafo++deD/r9jFhyYYlRkCbAvvWJwIcLB8S7hAw+7XetjvbNa1l4ndNmKoQ2
    XpaoxUW4cfBU07x1tbA3YRxPXrkHWJzb8xBTKXAngKqBBSbj0/LYKUA+TqZdxk4U9nm1MH
    Ky2ia/Ra0GU8Z6MQ/cSZlDaBEHFr8slQ5js2R7qX7RVGuRXJc6W6L1EQGFlj97VgKQJshx
    megpW/RP3qrpm8xbJDA7m4dUVkd9VuVppeNl8t48yydw5dYVpzVwx7VfMP8/Nh8Sq/5seF
    braCPQfNnHlmIFin+sJja71MzMGyoxIdC8gfW3qt6uDLe+FWXOEmaZUfE/6TXp/wLX07Iu
    jRahXDcI0Pb1+OpLG5dfk93nP2j+CjdwENaBI52L8R877hS7pOhUmFqrus36Ke+AJ01tqk
    sYdOGrcfA8tgLzXN3+0+HPFjMBqULSLw3MZST/KKDCJQn1upZ0mTenu8MD+trsbRVnwZZt
    et5e14L9xdkO1V/VQepviz4bWlWJUgUOYOlVhNRkYHV8y1kXND4H84k2fCqEtZ1lOIYs5G
    RDUUpjvv1I+jUdsIS3JE8Hp79M/VXm9aiibTWcY0Tspobnj7xKHUXEWtE2bQ
X-ME-Proxy: <xmx:n77kas67i2dJfY7Ij99oON3YuJXbxqJmdsS6xhmwTZwzUEQhby6Z6w>
    <xmx:n77kalqO7E-H-xlbN3ErPqTkitJ7IlKohvQ8uvHcrexUmGHO-hW_5w>
    <xmx:n77kaujz9kAX0wWPsZfjXz-AHEM9Hsv6TlTqPEYLcp6Y6C9JEsiJ0g>
    <xmx:n77kavLKuZxeXPqBvh7X7WVDFZwgcBOUlJYjvw3GfUkg8q_3YKxbNA>
    <xmx:n77kauDeWwiCqYpm9WdX0KFaiKTcEzEg5b7-zY8TmIa9S8lVljIqvhY7>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5B276782738; Fri, 30 Oct 2026 11:58:23 -0400 (EDT)
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
X-ThreadId: Abyb5r1jT_QR
Date: Fri, 30 Oct 2026 11:58:03 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Roland Mainz" <roland.mainz@nrubsig.org>
Cc: linux-nfs@vger.kernel.org, jlayton@kernel.org
Message-Id: <8b36e5be-be1a-46ac-8317-364e0c3cb193@slotpi15m67>
In-Reply-To: 
 <CAKAoaQm__zC=xuL-gqzqdv4127Tv=Ro+6J7=utN0qBqG=RgUfg@mail.gmail.com>
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
 <877e743a38f4784f351615a9d72a4d6033a3869d.camel@kernel.org>
 <CAKAoaQm__zC=xuL-gqzqdv4127Tv=Ro+6J7=utN0qBqG=RgUfg@mail.gmail.com>
Subject: Re: [PATCH 00/10] NFSD: Randomize clientids, session IDs, and COPY_NOTIFY
 tokens
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, Oct 30, 2026 at 11:39 AM Roland Mainz <roland.mainz@nrubsig.org> wrote:
> IMO it would be nice to have a way to turn this off at NFS server startup...

I'd like to understand the use case better. Can you say concretely what
consumes the contents of these tokens, and what breaks when they are
random?

The protocol mandates that nothing on the client side should care about
the non-sequence ID parts of these cookies. RFC 8881 defines the client
ID as a server-chosen shorthand (Section 2.4), gives the stateid's
"other" field no meaning beyond identifying a set of locks (Section
8.2.2), and declares sessionid4 as an opaque array. The seqid field is
the one part of a stateid that carries client-visible semantics, and
this series leaves that field alone; it is still a monotonically
increasing integer.

So if a client or a middlebox is interpreting these values, that is
behavior the spec does not support, and I'm not inclined to add a knob
to accommodate it. On the other hand, if the need is operational, say
correlating packet captures with server-side events or diffing traces
between runs, there may be a better way to provide that than
predictable tokens.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
