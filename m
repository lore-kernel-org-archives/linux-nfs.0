Received: from fhigh-a3-smtp.messagingengine.com (fhigh-a3-smtp.messagingengine.com [103.168.172.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 598D635C698;
	Fri, 31 Jul 2026 08:36:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785487013; cv=none; b=NQUU+9ixuqF1Ig5eStmT/eXw33MbIxrk1iszNX4KYXT0pCFpV3+ovUPPY6dNzTkTXnTDjSjhVShgHNHjpBeXaevY95ZGyPzvnpDnEJNPZCGovhGBFBtN/lKxqCpOZIN4PVMrglK1CAgdKXA6hZ/hgC4dNRkK29Bm6gj0RPiN5rA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785487013; c=relaxed/simple;
	bh=UhHiy/GEJsPCrU9SuTgC4oXUK6ZB5y+Ya7RWZpJ6CRM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=iZ2VNM27C0whF71kN1eYyCOV83hobgjISEoLBuwzd1+rE7T6FBOcNeZXWZHD2vDRw9rbrKbpiLg0l2J8z/iyn1npz8X077c9E45qdtiTsWOrOhaaKvCgrbCX1l7TNBKDeoSP6lc4crpLZkHDuRborIJa6OomrTH+ey+sjHsaGtI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net; spf=pass smtp.mailfrom=queasysnail.net; dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b=OmYVEnxp; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=YxRlSkdv; arc=none smtp.client-ip=103.168.172.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b="OmYVEnxp";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="YxRlSkdv"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 5C31C1400124;
	Fri, 31 Jul 2026 04:36:49 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-09.internal (MEProxy); Fri, 31 Jul 2026 04:36:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=queasysnail.net;
	 h=cc:cc:content-transfer-encoding:content-type:content-type
	:date:date:from:from:in-reply-to:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=fm3;
	 t=1785487009; x=1785573409; bh=55/Dki21CPp0xTBDv9wxOurQpKr17pIb
	AbJ3Rj0bSAM=; b=OmYVEnxpVgj0NTismDMgBPCC0Dk+JYL/Rx6dskGbWNi4ipFv
	7L6iO9jOnEoLDssvi2o3Ej+JzwrAJcbkaLD9GkF8HbnWPB6B7CLKuMPYJQsghLjh
	tU1R+vAqTt3JzeKjH/Rw8QeOHbUMirkKBl5Czq3GUk+XIZ0DvhIiglK37xqD1S52
	ipXPm5azx2n5pGhVjREJ8Gd1xHVUDLutnyISbudrT2uqUSVDQTh3PLS5O6K7yCIo
	biNX95WU4eVgBekaYfTGqnTHSBux2Taa8yHSw+ttThKIEY/1wuR8Hc+gJs9MqdD+
	WnpDjZqflO0Ap9g6hCyt3oDSBRPl72eRyMN1iA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1785487009; x=
	1785573409; bh=55/Dki21CPp0xTBDv9wxOurQpKr17pIbAbJ3Rj0bSAM=; b=Y
	xRlSkdvrcoy3LY3UQgNsdY118QxPig2aGadla/lVVfOueMXNEBLtiMKL1Zy0kCzw
	1tShhE/z6yFpNop2fjOGuH+5f8PqBwort7HWy+d3pmhywsWes2P1QynMY3bZuvzX
	/YJ+rB8DEdE4ycyn0ybW8gX/QYFox8EhkcmKC2aJqvc/CyXzR+Mn3SNqB/rAH8v0
	c2SeZ3Xy8aN0c4L+Tc9hgH2VCYSaQHjn5maQpIZi889mU2zVjZIz1Yk5QEviRz0F
	byZ2jf3ScCInMC7THd4ZwJvPQWfRz8kTKiXQyaj03Y31wySknuIe0bqK5q13diLY
	TgdqUXLcXccTNowJZecqA==
X-ME-Sender: <xms:oF5satoUjOdYqmz07MH6VJ14rTNDOQG42SMu32cLrbsDOs8cp4pH6A>
    <xme:oF5sagEwA-qKoOrBBmV52-idKCGvGrcxl1UF1iQ1K0xBynXnEzhJCYL4HCEG-loOL
    2zbvl9fXORsW7Rig0bKt0uQUkmmGAamP31kViUo821k28NG-WSnfWHo>
X-ME-Received: <xmr:oF5sap_GSwBMFtVD_6Mz30UnwMm5swSYEHYlhRffOEdeNdM1hU0xzrNoNow>
X-ME-Proxy-Cause: dmFkZTF7RoPB8mCkeCg4uacjPZ1PgHkmVmiuKI3QLAjZiadC6Yk41rqNXzn6XTESWPoBHt
    AcPxwSusquJGEJJVgeICF/RY0js4wDCBZ5uXXrzpdrBLlI2AYAujGZ5ne17O4odKtkJ6vE
    jEVjXUeyZDodLNJ4AinRBPe5r8mDG+O9aXmPwpelPLuReX+nfvZtLyBof23MJ5yWTsXKk0
    OejG3JS7ynFTsOMrlCwbM8SNg992OLXpV8gBzmNl5AP+K5Zg+NGGFlipFJIDQ+UCJqOK8D
    qPInMtQoiemoqd+ZKgIOfZ4VHUuY3qlCyCmuVI4o43de15YSvgaUVqcQ/VKytQgIKNd3C6
    Qv+zX6OmDEgYzPk/C7lQvcPQHrNX0EYOSQxylMCC7h1G+nhNne3EK9h+SgFlgms4r8F5r3
    MJDotkzK5B4s570gBMhP6lr+tXblaDhqDmWNpM7qvwHpybyihAoDI9oQxGUyhR/Ewli8wP
    iI3Upr23vBCBb8UYe6rjwxgHw8di1lf5lFegjtcR0KpiYGj4Ai2/AO0O4h5reof9W1Cw61
    mXEYc3a5rYK5W6yib9kB8vWazMfCtaQkUrT075HsMzgtgIr2HGiH2EkScxUokD4G0q9v2i
    ROI0Ql2k8Jofmw0zHITSZb8VXNyOSVypbE717M2Q/FKXbHvdjQw8aL5JDOkg
X-ME-Proxy: <xmx:oF5salQ73Id2MzP81C-_KSqm00IkA-YBTaE-GOBXOqk6_t4-0Fz1OQ>
    <xmx:oF5samrFLVrnzJNddhSx9WH0EQGVZsefHmgijcYicB9lDBJx6qivyg>
    <xmx:oF5saqOpRSKDTptOZ6MonWWqHCd6jnxu0c237rtW_SQJzcXDFv1kXA>
    <xmx:oF5sakw0p_51Z15LbYyhfhojBd19qgUVbshWPw7y457RxWsMhCnmnQ>
    <xmx:oV5saqXaXf9gtstpXhAzWaEtaQtUqn7hcd6kCVN-RHXQb9nHdkKlpGTa>
Feedback-ID: i934648bf:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 31 Jul 2026 04:36:48 -0400 (EDT)
Date: Fri, 31 Jul 2026 10:36:46 +0200
From: Sabrina Dubroca <sd@queasysnail.net>
To: Chuck Lever <cel@kernel.org>
Cc: Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
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
Message-ID: <amxenihnJifrwuYv@krikkit>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
 <20260728185124.72e421c8@kernel.org>
 <480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
 <20260728193058.7f6b453b@kernel.org>
 <a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
 <20260729163142.4f41484f@kernel.org>
 <amtcwSO24GGq_qd0@krikkit>
 <20260730143556.4a8463fd@kernel.org>
 <6deaada6-b916-4232-9df9-fff27472e98c@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6deaada6-b916-4232-9df9-fff27472e98c@app.fastmail.com>

2026-07-30, 20:12:22 -0400, Chuck Lever wrote:
> 
> 
> On Thu, Jul 30, 2026, at 5:35 PM, Jakub Kicinski wrote:
> > On Thu, 30 Jul 2026 16:16:33 +0200 Sabrina Dubroca wrote:
> >> 2026-07-29, 16:31:42 -0700, Jakub Kicinski wrote:
> 
> >> > Off the top of my head I think a setsockopt which pre-seeds the content
> >> > type so that the read returns an errno if the queued content type is
> >> > different could be a simple fix. You'd configure that on your sockets
> >> > to DATA and once you see a EWHATEVER you'd assume that some special
> >> > record arrived and the socket has to be handed back over to the TLS
> >> > control path. This is literally the first thing that comes to mind,
> >> > IDK how ugly it will look in reality so no promises.  
> >> 
> >> But then you're back to "read_sock stopped, caller has to take some
> >> special action to handle the next bit of payload". It's not better
> >> than "read_sock, and do a recvmsg when read_sock says it's not DATA".
> 
> But the “recover the control type with a separate operation” is strictly
> better than “pass a CMSG buffer to every I/O operation just in case” ;-)

That's up to every user to decide :)

> > My bad, I replied without looking at the code.
> > We already constrain control records in the way I proposed.
> > rcvmsg (w/o cmsg) and read_sock will error out if the next
> > record is control.
> 
> Almost.
> 
> There is no API contract for ->read_sock, but the TLS read_sock
> implementation itself will return -EINVAL for two unrelated reasons:
> 
>   - net/tls/tls_sw.c:2068-2072 — entry gate: sk_psock_get(sk) returns
>     non-NULL, so the socket is under sockmap/BPF. Drop the ref and
>     refuse before even acquiring the reader.

You can ignore this one, it's just a leftover that 79511603a65b ("tls:
remove dead sockmap (psock) handling from the SW path") missed. I'll
get back to cleaning all this up once I'm not drowning in reviews
(I'm sure being on holidays next week will help with that).

>   - net/tls/tls_sw.c:2111-2115 — per-record: tlm->control !=
>     TLS_RECORD_TYPE_DATA. The record is requeued rather than consumed.
> 
> As far as I can tell, no other socket provider that implements read_sock
> will return -EINVAL. But this isn’t a documented guarantee that a
> socket consumer can depend on, currently.
> 
> What would make this just a little friendlier is having distinct errnos
> for these two conditions, and a kdoc API contract that documents them.

+1 on the API contract doc. I have no idea what read_actor does to
desc, how that relates to the returned value, and if it modifies the
skb it gets in any way. That makes it hard to figure out the correct
behavior for tls_sw_read_sock().

Maybe we should even come up with some new internal errno (like one of
the >=512 in include/linux/errno.h). And maybe this -errno return
should be desc->error instead. I really don't know how read_sock is
supposed to behave.

-- 
Sabrina
