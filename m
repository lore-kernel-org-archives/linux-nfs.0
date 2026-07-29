Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6733647CA91;
	Wed, 29 Jul 2026 12:23:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785327803; cv=none; b=jR2y570VPvoWIidOdB64avkpndDSKDXIJ0an4eSkSnDGlTkTwyArJoUquM+/lxLSe77E7hJPku4ARKXrK8YoUahAh+MQcKgzMjk6XGeD+misIoKj/o8QLTyXJ/FeDTXyy838Bn6vamADX1Y2cUHHYkuAONTkdWSZvK80HXFTw2I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785327803; c=relaxed/simple;
	bh=n8Eq+6+Nhabtgy8GnoTwIOfS6ttg6xbpMsrfwdi/K2c=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=WpVlW4ciPeYXNnI5/KHhhr+I/kDA5qDlrLyaw0lx0KNBZMxPngE7sbranuqaaB53GZXIFms4jxUFulgfWtr+CXs2+DNUl/QGBMEagzLR9Q51VpQxwiebNrxlS1qvtphXTFt8I4gXWM3vFDuWJ3e32yFvGAsvKIStWAYYHcGb1LM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net; spf=pass smtp.mailfrom=queasysnail.net; dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b=gsozdCQW; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=c0/dNjdx; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b="gsozdCQW";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="c0/dNjdx"
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailfout.stl.internal (Postfix) with ESMTP id 013811D000D9;
	Wed, 29 Jul 2026 08:23:16 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-07.internal (MEProxy); Wed, 29 Jul 2026 08:23:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=queasysnail.net;
	 h=cc:cc:content-transfer-encoding:content-type:content-type
	:date:date:from:from:in-reply-to:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=fm3;
	 t=1785327796; x=1785414196; bh=FjyWDcU0AQmtNTB7vEHZRRZ3y0JXpUzK
	aPUWS4TnRNM=; b=gsozdCQW8M4slO9m2Al4quBNj5zWOyyrCdYVk8uLh1kYiTf/
	CaA0GbEdMGS+5eHIhIFDBpSPjK5g6b2pIlpY2hQRmIgx1Q5Acp2ovfgKm+r3EmJ5
	z9h+qmjjwXrXo8lMvdRyyLD1zmaOJchi7q7mmf/46k+DcTYAuchd/WX9QHgI5e5S
	TzkDDKkOWA1j/Rj7QJnWiV41uHSKGpwP2oiRcQe0jAcOCZjr2B9BTU/oBQLGn9/t
	piiiuek7ohPNSD47TniWR/JGnQcUizOJ3ebJu8zqas7dClF904CT/a3fDay9l0BC
	Rr4Xnci9lBKgtqgKRSLYkeF84YGxRSGIMJd9gQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1785327796; x=
	1785414196; bh=FjyWDcU0AQmtNTB7vEHZRRZ3y0JXpUzKaPUWS4TnRNM=; b=c
	0/dNjdxcpyvR5Vkz3EhNUI+/lC/vZbCnDmhpFrx0RN8ZVqxHPqDwpQoFmM1NXUdK
	p8FQa0lBTn2taUkOFtVtei62vVSHTjICGfu0WwkynhpP3e+fAf9j+d8F1AtVz3HU
	yubRND5W/FpYxPkUefjm4mR7qiDkcfUPUIdxEhhp3EUK6VuiaeXJiuhTagoYB1ht
	6RTnW60lDJGeH8RB3y1Pil+Q9BWc5FZDiprlrZRqwHVZiWwR9tpvEul5h8C5B4Xr
	tPaKIJqZ9A+GMLlYcTlWfZmDav/LkdNiKMioVMzV8T+XyLN5DD8wXcih1rKVJYIU
	WKMJAMzFEGGwmGpAeuMZg==
X-ME-Sender: <xms:tPBpalzdOSSlXBf-Igff4kYyTG5U4tgAKFWBhkpEoVxQ7hbdIV1lOQ>
    <xme:tPBpaltb_nVYMLej4kxwOTyytiElPM8iNWr7fnrRm5aCeQtLDivCEueFW1ny0xGvk
    R7oB-j-ZxmS0CPa3ClrhwI3Rm25OfoG7Lsn7LEcpWMUMNjA-Tf6g30>
X-ME-Received: <xmr:tPBpavEXKEYfzwoeoJh_JN2ICvBz0A4a264GbgkgiYRaEZaW5ak8IETq9iM>
X-ME-Proxy-Cause: dmFkZTFy9VLstGC/2JcdpGCUEJUK2PuokghQUZYXXVIWYSAQOOOeIK+6vlG3o8tX1idpjb
    1PHrG9dAgQIo5ypYYC0qtY3cChtoy2fp/jCSB7yeyU0FN3durHDdbxeQ+CBKqSfHuaiEic
    vMWUb509ccfuHqTBkPmeJHn+btYOQHCNl67P1clA46qs8HQqIQ7PGsu/JGILF+Hn1D3jK1
    dzr+Li6MpLHGQXKgDpe73QxdN2ObNJbKqGGvIpR8iTmqvoPh70wNHs3xzAw8SPq/4xSdPc
    IzdhyfUqb1mAgaasV0aEoKgeHTsme1Ao0dajfkHJn0xpGy6usq+cwOqPooDPwD2NSqg5O3
    Z+F1/GOk8LgyqEYMIR6dZosT0takI/Oneplo/f+1M6KY7LJN29s96z2d1ZSgb0PdDFMKNe
    PGKtPYoKHFVXXeq8+8hNQDJoUC4SQ6g09DVYO2bAKL/Vc9GURYv49Q7mgQPyXKfGJVWwE4
    8vBNodZQb+VJbzWIopLwYhBr0BReaZH+PC2xravXShPQ/MMRJ/8+Dp7RiLRaEGMun1tx9b
    MiP+vE6kJO3H7ND86cVSmLuiXWZwtU9Ifsa4DCGqjhnGHt3YvCC4Dkf7GT3iI9IlTu5VGn
    4U5noyZo/n3Ufc9wrZ+19RYDvFH6XdMa3fHM0tETBcFjBebowqgjt+HAEBPg
X-ME-Proxy: <xmx:tPBpaj6HUksZdpZj87eKdKS-I-FWUndbMP31fSu7rova__7vRCUJxw>
    <xmx:tPBpagxUeMM3zWCKF1qmpF2fSSq1sSWLMXAJ4-Yw8kihUrIHZ8woGQ>
    <xmx:tPBpap3wgex4l2Jq0BM5CTAFIuBZZkG35TtseW5ZmWEzO-5-XbH6Vg>
    <xmx:tPBpar4IjnyYK3oy5D2vIB6Uxx9aQmP9ViNDOZ4NvBSsX40o5ZKwvQ>
    <xmx:tPBpanlYb8acziyIEb4ysKeH9OPo0X4Z-ce7We48iVrR7Uv_HIniMrTV>
Feedback-ID: i934648bf:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 29 Jul 2026 08:23:15 -0400 (EDT)
Date: Wed, 29 Jul 2026 14:23:13 +0200
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
Message-ID: <amnwsWrxv6KvrZ_L@krikkit>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
 <20260728185124.72e421c8@kernel.org>
 <480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
 <20260728193058.7f6b453b@kernel.org>
 <a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>

2026-07-28, 22:51:30 -0400, Chuck Lever wrote:
> 
> 
> On Tue, Jul 28, 2026, at 10:30 PM, Jakub Kicinski wrote:
> > On Tue, 28 Jul 2026 21:57:21 -0400 Chuck Lever wrote:
> >> > To me this is an ugly one-off workaround that doesn't fit into 
> >> > the proto_ops (only TLS will use it). And you seem to net out
> >> > to the same LOC on SUNRPC side with and without this?  
> >> 
> >> It’s not about LOC. It’s about not cluttering the normal I/O
> >> path with a lot of exception processing to handle TLS Alert
> >> records. The CMSG API is very difficult to use and leaks the
> >> alert messages into I/O buffers (which for in-kernel consumers
> >> are page cache pages). It’s piss-poor API design.
> >
> > I'm not arguing that it's amazing. Doesn't mean we will YOLO
> > a special proto callback for every protocol stacking :/
> 
> No-one is asking you to roll over. Review means you get to steer
> us in the right direction, and I promise to do the leg work. Terse
> rejection doesn’t move the discussion forward. It stops it cold.
> 
> Complaining about slop also does not tell me where you need this
> to go. I use AI to go from blank page to RFC/v1. Where we go next
> is up to human taste, as always.

RFC/v1 wasn't sent to netdev.

[jumping to the end of your reply]
> I thought the RFC series cover letter made it clear that we are
> looking for input and direction, not to sell a completely formed idea.

Then this should have been tagged as "RFC v2". "PATCH v2" sounds more
like a fully formed idea.


I see in the RFC thread some doubts about whether read_sock is
actually helpful with TLS.

Ignoring the "does read_sock even help?" aspect, how much improvement
are you seeing by going from "read_sock with fallback to recvmsg+cmsg
in case we get a non-DATA record" to "read_sock_rectype"? (current
svcsock [before this series] doesn't use read_sock, it may be good to
compare those 3 variants and not just "old read_sock vs new
read_sock", but "read_sock vs read_sock++" is the important one to
justify an API change)

Non-DATA record should be fairly uncommon, I'm not that convinced "oh
well let's try again" once in a while causes a measurable degradation.

Even with recvmsg(), you have 2 choices:
 - pass a cmsg every time, and check the record type for every recv
 - don't pass a cmsg, and do a retry when you get -EIO

This proposal (call a different CB depending on record type) is... an
"interesting" approach.

> >> > There needs to be a very strong reason for us to add APIs for
> >> > in kernel consumers.  
> >> 
> >> This is not a helpful position. Your objection is the same
> >> every time, treating the in-kernel users as second-class
> >> citizens.
> >
> > No, it's not a second class citizen. But kernel consumers have a
> > tendency to break all abstractions and insert hacks all over the place
> > just because they are not forced to go via uAPI boundary which forces
> > people to think about the API design.
> 
> Granted that user space self-tests can’t reach kernel-only APIs.
> But that is what Kunit is for.
> 
> 
> > You just need to try a little harder to produce a better solution.
> > Rework or augment existing callbacks to let your achieve the behavior
> > you want.
> 
> My original approach was to add a new read_sock variant because I
> suspected you wouldn’t want read_sock itself to grow another argument.

Given that there's only 2 existing consumers of read_sock (strp and
nvme, and I'm not sure why strp/sockmap use it at all) [1], and 3
arguments to read_sock, adding an argument would be ok IMO. The
implementation (tls_sw_read_sock/tls_sw_read_sock_rectype) ends up
being a small wrapper around a function that does the actual work with
a NULL check, might as well propagate that to the callers.

For me the problem is more that this new argument is very specific to
TLS, and dropping something TLS-specific in a generic API (struct
proto_ops) is quite ugly. If we want to make this generic, we're back
to cmsg (or something cmsg-like). And then the benefit for users of
read_sock gets down to avoiding the "try read_sock, then fall back to
recvmsg" logic.


[1] well, there's also some users that call tcp_read_sock directly
[1], but I think they can be ignored other than "they'll need to pass
NULL since .read_sock = tcp_read_sock"
drivers/infiniband/sw/siw/siw_cm.c	tcp_read_sock(sk, &rd_desc, siw_tcp_rx_data);
drivers/infiniband/sw/siw/siw_qp.c	tcp_read_sock(sk, &rd_desc, siw_tcp_rx_data);
drivers/scsi/iscsi_tcp.c		tcp_read_sock(sk, &rd_desc, iscsi_sw_tcp_recv);
net/rds/tcp_recv.c			tcp_read_sock(sock->sk, &desc, rds_tcp_data_recv);

-- 
Sabrina
