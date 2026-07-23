Received: from fout-b6-smtp.messagingengine.com (fout-b6-smtp.messagingengine.com [202.12.124.149])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F20133C18B;
	Thu, 23 Jul 2026 14:24:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.149
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784816643; cv=none; b=hcX5W4pFaAFt/HEE2YkbG0iJBDtBGe4kceIype+Jpp1NZyFWTedTrzLUfOh9Cg6qfvqD/QM0l/iig1dq0h2RwnmwS87XyJSILDqe6+FQoiKYuqmukaTX1Fwyn9/hLcLAB2mXgp+1VzhHp/f1pF2UIesENWgg/YzPE6w4XrVlWIo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784816643; c=relaxed/simple;
	bh=bu0er3sj5I1RtYd6BQfpi6JYf/pjsFDGuLIvQeP2lgA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Hb4iKdK+gDuNfNmXIpt5B7Hfa7OnO6Y99/oKF9WNy6O+O+lxU4AEqsQfY4QlQoqxVoeohGYMKZzG6HOj6lHZL8Np9wnylc2YgbVGjWjuJVA7dPrn3tCDb8bf6VuS9j03M6ZbmZfdABnjUVMVgIaQIr/h6X8bzjb8tob1I0EKdC8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net; spf=pass smtp.mailfrom=queasysnail.net; dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b=MWqFIy2F; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=YpwgyoIO; arc=none smtp.client-ip=202.12.124.149
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b="MWqFIy2F";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="YpwgyoIO"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id 2CC031D000C3;
	Thu, 23 Jul 2026 10:23:59 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Thu, 23 Jul 2026 10:23:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=queasysnail.net;
	 h=cc:cc:content-type:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1784816639; x=
	1784903039; bh=8IpgdBx1madmo+vUO1nBUosGSu5bFpHWfo++8p/Mq/k=; b=M
	WqFIy2FS14s5HbeYjlr2LVf+0PhwiFLQWCItQuXsU6H3yBa7be5FrR8U0Kb44hLo
	aMtjOA7QRpmryl2asrYGzva+/HdqldSMHPvFoVI3S5C127mnzWR5zlbHj5QJQDG7
	GPKUdAK8FMxE6qfJbOrhFXsTXQ6lAwjlMNDbAYxG26H0ijPNhqwv8bt+m3EvS2a7
	/reP9ob+mphxE+WDI5C2gHoCoBdJdNnjV6X9YXQsY9L9l5V1myH5dN5hstc2jjVG
	zFTiwpnkIt5s8M5+2hRSxNA4UIKsLkNszzzHpSw/9vLjLlzbf3lxBwNW9H2lJLmr
	9tYx+c3QMNTtf93eOetcA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-type:content-type:date:date
	:feedback-id:feedback-id:from:from:in-reply-to:in-reply-to
	:message-id:mime-version:references:reply-to:subject:subject:to
	:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=
	1784816639; x=1784903039; bh=8IpgdBx1madmo+vUO1nBUosGSu5bFpHWfo+
	+8p/Mq/k=; b=YpwgyoIOfB6OO3RI1TEakf25gpmEeWuiAClvbfrJPeRkrCFgiS8
	kohzL5QluHt/IMxYF6n1HjwW4KTOx1qEr96GfitcrhvjCicJ2wrmx03oWii56EhK
	/FfG/Cvh56VMMdtgDvDhmCBEHMtpysnYMskjDgQR23bxInopmdVcuDxZnj4Jchdl
	aikHwLrAeDr8ULs/4Wh/SCR0oFhmULQj2O+ZNHB1jluQRfLRrtX6zNIj/Sbpasxb
	yz/3PVrhX81O2d1odx5ycDSyhJMBZB6Lc+L49i4bh4ShwMJbeaUmK7VF2UYipdX/
	yESTtKCxB0gWw7SYfVa+LNFwnPaGmN2csnw==
X-ME-Sender: <xms:_iNiaqcsME_eFoM2nP3zE9DxuOj2AE1KZHVcXY5HJMohnAKE4mgOkw>
    <xme:_iNiavEokXG4B6VsVWdt0rMvOzmeR32-LptllUvtba7e3mFZCWpf4_Nqoq1d8fX9h
    BMFcv17UJyAO2YPg6-sFTfrQouPyd5L5GXniUTKsa8ia9EQm-1C5Zg>
X-ME-Received: <xmr:_iNialtAKVMNDOClW6kz7IJyyeGU6D37hmg7FRQ558pgDCN0HXxEA7aDLkg>
X-ME-Proxy-Cause: dmFkZTFSU3WUspyByh0CNMEQ9KE67q5hCs60QVa4QsF0losjbXfho+irFleK+zalqIFpDK
    k4KDOUVXlHh+mR00BoT6623GGNe4XWS++U4JDA/gN+H3QW4FZ/lZNu9XQ0hoT37tmoc/c1
    qpkKjjoBNKo3RTlJ2RScuhqVi9NGxspn+r/XN0ZYhtBZKZ/n5omKgW8t1UFpyUGCLE8qJj
    lLP2u2ySyrrvmkAavXI+9wbfnYD4EPoY/bLmZHdUVLt2tvTM9hQCUBvCUm4K0uxz9ykrrJ
    HCIjH2XpqABerzUK8L6g36xAs1JL1WHNqAWJeYN5LD+1nMfQnFDnrCosgQV9A/f8CkpdLc
    J9WL3WjjHI0O0UOMDChUOe0SD4rwoplTZvJet0qAh+VPqc0KWEPV01JZHpDS6a6fBWQS8A
    /piLkGXj+x1CUspC9rPj0/JXtaLEXxH4ne1Ecg8wfMcicSd6GWA4pZeqWyPNK09OfPjiu2
    14qavyNjp/AyhJads/SxgjX9TRZkBPJ4MAdNePpFCxWjGdStGFBcRuToHp1WhKDmBtagtU
    bYQnSW2SC4ueqKt7CcgsQBXnFk5aaFv+Z/bfdBt7h4Tzedw38GHjTKBeu2+RZ3ecRh51Np
    MVyKeiQp+ApaRqni/aBnK2Hu1s798jGIyjvFYta4qNJrQvL67SRZfGzb07XQ
X-ME-Proxy: <xmx:_iNiappmRYabUIb3BOnLQfs8JRzNu7cJuFmHXl8x44tjKjMRLU_y_w>
    <xmx:_iNiasmJ6-NQyGx3tQSycpfluzutA4afob49hSaNfsn_FTnvKKgTQw>
    <xmx:_iNiamhGDdu1on0c0Jeu5LUBirUn21XZ2iVB4KIxE8rzPxckEKlZEg>
    <xmx:_iNiajU0Svf-KpPUcwQqiA1TM8h5pCTbexNMZ5GCBeF_46l6EgWytw>
    <xmx:_yNiajxoHJOZjlNZj8Lv3AibG3NJPy97p75fMGp-sL8x78g8IkS9bWsR>
Feedback-ID: i934648bf:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 23 Jul 2026 10:23:57 -0400 (EDT)
Date: Thu, 23 Jul 2026 16:23:56 +0200
From: Sabrina Dubroca <sd@queasysnail.net>
To: Chuck Lever <cel@kernel.org>
Cc: Hannes Reinecke <hare@suse.de>, Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	Shuah Khan <shuah@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
	linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 1/6] net/tls: Bound consecutive no-data
 records in tls_sw_read_sock()
Message-ID: <amIj_DG7SuWx8MeY@krikkit>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
 <b9d60674-1ba7-4f23-beee-4ddfffd4dda9@suse.de>
 <909e0132-5c0c-4c0c-b8c5-b90b88ad0231@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <909e0132-5c0c-4c0c-b8c5-b90b88ad0231@app.fastmail.com>

2026-07-23, 09:24:47 -0400, Chuck Lever wrote:
> 
> 
> On Thu, Jul 23, 2026, at 3:11 AM, Hannes Reinecke wrote:
> > On 7/20/26 4:27 PM, Chuck Lever wrote:
> >> A record that delivers no payload -- an empty TLS 1.3 data record
> >> today, a control record once read_sock_rectype() lands -- leaves
> >> tls_sw_read_sock() in its loop without advancing the caller's read
> >> descriptor. A peer that streams such records keeps the receive loop
> >> running, and the socket lock held, for as long as the records
> >> arrive.
> >> 
> >> Cap the number of consecutive no-data records consumed per call. The
> >> count resets on any record that delivers bytes, so a normal stream
> >> is unaffected; a peer supplying only empty records is bounded to
> >> TLS_RX_NODATA_LIMIT iterations before the call returns 0. read_sock

Would a time-based limit be "better" than a packet count? For example
that's what net_rx_action() (net/core/dev.c) does.


> >> consumers treat that as "no progress, re-poll" rather than EOF, so
> >> the connection stays up and makes progress once real data arrives.
> >> 
> >> Only tls_sw_read_sock() needs this cap. Its consumers drive the receive
> >> loop from kernel context -- a work item or service thread holding the
> >> socket lock across the whole call with no return to userspace -- so an
> >> unbounded empty-record stream keeps that context and the lock pinned
> >> for as long as the flood lasts. The cap supplies the return boundary
> >> that a system call would otherwise provide. tls_sw_splice_read()
> >> and tls_sw_recvmsg() already have one: they run in the calling task's
> >> context, reschedule while draining the socket backlog (cond_resched()
> >> in __release_sock()),

tls_sw_read_sock() would also do that via tls_rx_rec_wait(), no?

> >> and drop the socket lock when the call returns. A
> >> flood there costs the caller only its own scheduler time, so the cap
> >> would add nothing.
> >> 
> >> Signed-off-by: Chuck Lever <cel@kernel.org>
> >> ---
> >>   net/tls/tls_sw.c | 13 +++++++++++++
> >>   1 file changed, 13 insertions(+)
> >> 
> > This is technically a fix, so it might be worthwhile sending it
> > on its own.
> 
> My impression is that the issue this patch addresses is not
> reachable until the subsequent patches in this series have
> been applied. Thus I positioned it as a pre-requisite patch
> in this series, and not as part of the earlier "fixes" series.

It looks to me like a follow-up for 3be28e2c9cd0 ("net/tls: Consume
empty data records in tls_sw_read_sock()"). Control records only
become a problem after the rest of the series, but TLS 1.3 empty data
records would get there with the current code, no?

> But light taps with a clue bat are welcome, as always.
> 
> 
> -- 
> Chuck Lever

-- 
Sabrina
