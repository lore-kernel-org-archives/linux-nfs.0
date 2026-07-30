Received: from fout-a6-smtp.messagingengine.com (fout-a6-smtp.messagingengine.com [103.168.172.149])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6769043BDCB;
	Thu, 30 Jul 2026 14:16:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.149
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785420999; cv=none; b=OCeDUIJn7qpPenYV82Ar8xWp5mXJwZ+oNCxATJZT0uVFo/HaXntLRDfyg2h9orQi3tS0UXlGSrs0RRvEgGH/aSPmked8Y8iqS7C3PT4f65OGkn6uYt9n4vgnjQuedw+oTU2pgX9BNUgc4a0uoXEfCV3hU0P7aJSai3zmmFjZGN4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785420999; c=relaxed/simple;
	bh=neyuCrtmmIrWJ/iVD0cqPhZqHnNftIit3tNwhhtFy2Q=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=bVMoUzsKIJxb4MhLApP8bboF9CCB7csC2y0Qa3FaAoti0A7q2iK5VmRyN5oAAqu5prIccYU+I77R1DXvQK8b/HYdUhlyQKlXEvJYCkWw69UOv8DNABdMj1rBDY2pO+W+SIVpB9Ba3t7h/hVnwYjKmXm0NmA01y9ruu3Tsx5hCPA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net; spf=pass smtp.mailfrom=queasysnail.net; dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b=klOTFwzt; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=FYxXsxHz; arc=none smtp.client-ip=103.168.172.149
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b="klOTFwzt";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FYxXsxHz"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.phl.internal (Postfix) with ESMTP id 85D3AEC01B5;
	Thu, 30 Jul 2026 10:16:36 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Thu, 30 Jul 2026 10:16:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=queasysnail.net;
	 h=cc:cc:content-transfer-encoding:content-type:content-type
	:date:date:from:from:in-reply-to:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=fm3;
	 t=1785420996; x=1785507396; bh=e22OP4qR6VMUdIgHXf2EU5bTioavoTrM
	CQbP68IkrAE=; b=klOTFwztwLwOvU+Ij0HSQKn+FFBcU+0olmBds+XGv4Xyv3/q
	36+uwEfDwmjSo3JnPbrtv0v6mb6mIfTGUtl95YyjdxWInXFfqOSo3CXNmBUnIWZk
	PSNWIVXSdHFlRoF/ja2E+/b+tpPZaLMaIg7k7tbVdjPnaVp2OY6GEroj4jx2Mhn0
	kStcH/3WqkXxc6SXUItSa849njsVn5JK0wls5j6JdEt/HP7qXu4mitksdlBa1h09
	kfWC1WhGqKQRSSZ01sGQ5oKJzJ6hGw+X2/H8WjTaYfKy3QEvKZpDwmTjUp/EUwyx
	QDiEUISaWKpnuAuPfAcis7Khmhqo25379ecBoQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1785420996; x=
	1785507396; bh=e22OP4qR6VMUdIgHXf2EU5bTioavoTrMCQbP68IkrAE=; b=F
	YxXsxHznsnmxH/fwkJWG/+r04Qeyuk1DSEUvR9rBarZJCTWfTjbilO85Iwb8X+yz
	zLy/a6sa74dTqE7Nnnt0G5GFRN5gAnDE4+G+X6XuPIpDSuArW333zimD50D/e292
	i3yce+oIpwJqNpEBKFU+DeOR6/+G1w4WGu+KzWPJu5lTCxHV3EV/vz6ohKDA3U/F
	7BS0QEhj0Ypwzy2llmxVdKaMIsQbQ1zA4Pxt2LOFHT02hFWJf8fuRj38M28DYH29
	Gl34svSWzD+C9zP+T0Enc3RBVaFzFgEEYSitr+sYcB/AybaZ03zguDkwVbQ95AKr
	akq1/SRzB0aSsd8eUmamQ==
X-ME-Sender: <xms:xFxrarAmApjk6kYeOgKZVL5l4DTA_pqWG4m-tlkPDBMM3pS5m2XWzw>
    <xme:xFxrah8MlyVJH95dqiJNtuCSVSXEesSie3-lnoll89EvmCZxC7PtPzQpss9TtQ6Ac
    yEVdXi0wgkALkLRJD-8xYkXR35vkUsysU0dODnFlmErKuetuS6XDg>
X-ME-Received: <xmr:xFxramVzqyWEl4i7nCM0FdBRInUvkM34x9S1dkYP5C2EPnx3LXZ2hOHT-0A>
X-ME-Proxy-Cause: dmFkZTGLLBkJ6ZVUV3LnEzngFLMlIUsRBFCHzkrYUmJPwtiwCHdQ9B5yaqM8iUq5/SltAJ
    klJUul8cCDtP0rQokE2+Penaiue+l4yIWbmSj5GMWfw7oynZ1iZY/EfteVnQI04GhtLeFG
    MqXOzquqaCe/ClHBLXoI2JZI4WNnRXh8FjQlVJ3K4w+TLoqvQ3IMRZMer1ghUfzD+JTIQC
    fySNcnLDpWqPMbrq41raFnQJDnfv3P1hI+QDCuFio32/VEuPTneCThV53IVVmerKZ//pU6
    RQC6QC3qiEznB5TmkGL8td57xpCpum0qmsBw8cIluX5z1vqFevzhB+ZkmPJnKgRtUJXpNj
    EKoGRfwmsZR6qTVAzvJFZW+9P9r4gxI8rtL1ni+YGfSt91LylhC5qiCybaok6aEhbA2cjF
    gcBhXg6T4zqFn8WqySpFjwx6XLxOl3G1+vtYCSBE7WuMoSE0GgNZySA/x7kciyA9nKYd+6
    RC0uebugREK9ceHc6Da1kWTyztFEIyaeutM7hV7HTrkamTdPQ9/VUebXrhK2GgEbowlLNJ
    OSVWwejG+qYk5ugPOkgyDMicLP9kTHv8P2wAsNJNGzRCzb/X5buLjZPfoKa7W3hDM6LZgb
    tSJ6fkQLTW9VXLDo9fbYBqQlqmqpMuw+EyeEE0EL98sjzPUKx9fkl399oEgA
X-ME-Proxy: <xmx:xFxraqKvWmF2XzPio1jfdTSW4RpFxnEFIXGZ1iGt2tcKhpUQ1ncjiw>
    <xmx:xFxraqBea23UmzspUnK87GLTC1TowILwiuhGjDdY0Sko21h--ETngg>
    <xmx:xFxraqFp7rxU4PF-v3H-TBhqLaytFcm9RtRQFhw-W5hLODDnKp3OrQ>
    <xmx:xFxranInJ7f3Z6aN61gL46NYwGaR7HmsBuYedezBFQ722RJFEnF9Ew>
    <xmx:xFxraj2DnPopppfeLJ_vxYyopw9ezLRXYpPlvw9TFJBBCXtXnYj6VWVj>
Feedback-ID: i934648bf:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 30 Jul 2026 10:16:35 -0400 (EDT)
Date: Thu, 30 Jul 2026 16:16:33 +0200
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
Message-ID: <amtcwSO24GGq_qd0@krikkit>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
 <20260728185124.72e421c8@kernel.org>
 <480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
 <20260728193058.7f6b453b@kernel.org>
 <a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
 <20260729163142.4f41484f@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260729163142.4f41484f@kernel.org>

2026-07-29, 16:31:42 -0700, Jakub Kicinski wrote:
> On Tue, 28 Jul 2026 22:51:30 -0400 Chuck Lever wrote:
> > >> It’s not about LOC. It’s about not cluttering the normal I/O
> > >> path with a lot of exception processing to handle TLS Alert
> > >> records. The CMSG API is very difficult to use and leaks the
> > >> alert messages into I/O buffers (which for in-kernel consumers
> > >> are page cache pages). It’s piss-poor API design.  
> > >
> > > I'm not arguing that it's amazing. Doesn't mean we will YOLO
> > > a special proto callback for every protocol stacking :/  
> > 
> > No-one is asking you to roll over. Review means you get to steer
> > us in the right direction, and I promise to do the leg work. Terse
> > rejection doesn’t move the discussion forward. It stops it cold.
> 
> With LLMs tho, the entire human effort is in finding the right design,
> rather than the code. So asking maintainers to hand hold everyone thru
> their features is unrealistic.
> 
> Off the top of my head I think a setsockopt which pre-seeds the content
> type so that the read returns an errno if the queued content type is
> different could be a simple fix. You'd configure that on your sockets
> to DATA and once you see a EWHATEVER you'd assume that some special
> record arrived and the socket has to be handed back over to the TLS
> control path. This is literally the first thing that comes to mind,
> IDK how ugly it will look in reality so no promises.

But then you're back to "read_sock stopped, caller has to take some
special action to handle the next bit of payload". It's not better
than "read_sock, and do a recvmsg when read_sock says it's not DATA".

-- 
Sabrina
