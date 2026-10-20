Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.151
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792486362;
	b=DEpcU+vWuHqK7BeOG2xBM8RRzO/+Rxw2uDt5a0umpYaPQ/sOKNE1JTVaz6lsT/uApRIf
	 9wfpseC6gidrJdNiDsMSHBb/TnxdnKFDJ2qLl8XYc+vG5pwNIUv5S510oEEfPtnOvclie
	 Hfwod2OsFUVbQh8fgUZ+9xiXzm0S8m5qCSJHvXfdD9wvvKvVv48r+2vHoF6uFLliolnng
	 sCQH7rP4s8pbdynOdazUWehW2FoDwiFSp449082dl7+HIZwJCE7GDfdgd8WvRGCBw/KUy
	 j5nE4TdAjJUdindeJFC8cBPO2Kg+wq773TKAvJ/D1XqdzkPrZwg/wQIDWksejP5SkAw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792486362;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=Q9MMleMV2m2Lq7dcBgmANYmT6t6c4XQn8D8ZUNPPUU8=;
	b=JCVl1j4qpLTkBkMAHCjBvsgkpX5BefgvSp8VgVlZa2V2jSOobImK+HAusf2+TeJfX+sz
	 oDs2VksIu3uEo/MzYaAxnY61HwUXxHVBNiBs4gyEqbEN7LKeV8TYSTtRHwE7/WzNVTdlX
	 NNLu1XNxAcs3YWQ+f6VLGFp1uicOZbX2e0KJKLt0GuAknnnOub/nWnXq2KRtrQ222gtV0
	 2eYPE/Slf7xAPKbkTs4rZe+FngBu3oqh6khwblyiSVfRpliNSECwilbPsSwqoviGHJ1xk
	 e0GQAXoZQvPQCdV5HScv1RAIQYFgnGyQLZgLfpW+NK4tWCcbiV0Ogdzs8oQiCh1rEng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=F7CI4O8m;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=dYrnrXA2;
	arc=none smtp.remote-ip=202.12.124.151
Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A888F606A32D
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 08:52:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A888F606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=F7CI4O8m;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=dYrnrXA2
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailfout.stl.internal (Postfix) with ESMTP id DA2D01D000CA
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 04:52:40 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-12.internal (MEProxy); Tue, 20 Oct 2026 04:52:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1792486360; x=1792572760; bh=Q9MMleMV2m2Lq7dcBgmANYmT6t6c4XQn8D8
	ZUNPPUU8=; b=F7CI4O8mcEic0uU2x+cP5m5oIE3sj4EtazO0db7DQZvsVjwG1Oi
	9rEBsNQRrZ4lE9VBcEwL9n1z63YlCT1i+Rq4RH0H0eaiE+L2CF0bTP0pVviT8v61
	77IVg2TAJX7k23I0ekjOH/CQReoAbe9JKVCBHcwAO1YWmjL6J06kZG9ng7XsSHBq
	j/l8+VH/VGx6qecliyhOiaK/PNEE7HvWorHb1pX5h6FPqP6lWXFX5IXidhulltyf
	ymIWS+0z9tsIw3Ialr2btN5E/e1jLA8RgJXO/2Z9FgzXqhg4AkSIlv/x3Lx4dLDl
	mt8UBIH6BM9/Zs5elG3F4R3LExbyx4D77cA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1792486360; x=
	1792572760; bh=Q9MMleMV2m2Lq7dcBgmANYmT6t6c4XQn8D8ZUNPPUU8=; b=d
	YrnrXA26s6GgyHGjrU9DhtYgRn9LdOZXKi1cDUYsfZjM8sih/3enmdEQ0w1HiqZQ
	2i28CVt9IrrTa7BPuHmon21G7L/x8cFWSPjEr84yC1tNfQ0B7y3sDbGREGV2rQ3p
	kHPBCVenILiCEnkYT1ECc7TodPqhyG2q/Zo9LXD+neZNlNHWr0SeqdBR54uqM3Uz
	fxUFlANkeEZ6ODYUyj4s4glnV4vTAgCiYzWX7CLqtquvpD03n31IpExE0KjA31sG
	Ab3x2X3wmALuXr0fgDn3l6iAmSJ94OQ8rnwaz9rhYeZ4BadNQfWKfVhxlDWIdalA
	VGuixxH28QuZY8fBMQGhw==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-06;
	repo=github.com/dkim2wg/interop; date=2026-10-08; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792486360; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:dCqR2Wk5ARDllHd4PExZZrg59wJ9ra9nE6vsD/b/5AzM0UZ
	crwnT9rCSEBtugHpxvbKqxWoTYOiiCvgz+N9IrJ/HdyFgDL6BlJS3AvFaYa+bzXY
	9/JdYyQ/Q16I9vU2OOSBB1ik125uPNiTywq0YWmyBRJduZo7FWQ5pXYz2BjvPcCg
	SKLw40c8se8OjAqdD/8fO1cJ00VDhfc4SNC3GCL/ca+CZxgHKkxAcibctY0pfR3g
	NEXXyh/OugUQ+Af0/vLsQO6ZK2uX1alMc6SeqTclcWdqeuQD4npilhGi0IJv7xTW
	2y8znlNLltQopEauGNHdvNZofqd5WEbEu7XzaWg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-06;
	repo=github.com/dkim2wg/interop; date=2026-10-08; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:c8lccyJYWfKKyeWxf1luXcpSaSCKigb0uctBxvtMAME=:df0JB2lLhYHcjYxv06QZEK3br4qVSKJpMjhwPX4W6pk=;
X-ME-Sender: <xms:2CvXan3slO2O8hbtKF7Dn1w2R02TcBuZUAsKxCXWmShe9ayfCZBbpw>
    <xme:2CvXapxAjlV30Vqx-doPnUm8dA-cGoHT_lPaKOdsHX9mbPu5Y7ZoQIatvib5NS8GG
    YukEVAJRZYRgYcR28OITY36o9Eu5bIyVZR7sAChBiJcm8c1H20>
X-ME-Received: <xmr:2CvXahsFMVxK58v56GqbqZxDhWfKLw44klU4fYCzgJ_HCmDUxSkIzNBfUzyT2P3HKA>
X-ME-Proxy-Cause: dmFkZTFwwLHi58xfXBTemFT4bElaiUAUkOsE4qA/dMttBfQZlD1LHWICGglBg83OSoc+QA
    WwDRU/7ygq94haTmC1Ko76DszPuskvfjAbwO4ZL+W9fHub+dda1oxa06GnH3Cgr/+5WjF6
    9onndR54ku4kSBvDwNuVv3k2u4uM8UUpSR/TVY2CDAPmlfRfBRlW/sqTrzain9mWG/qroP
    j++Jj/YELvVWGnm1Ls8H1VcFuI+fVi1SLBCKwasuAd5pdF2RQTG6uQxQxlQu7AgonVveAo
    VI5vOXK2pZxnDHYFgUndKBdUSIbl+bbvpQmrFbmVKIBgyk/AvQdRvMxUI//xsWZ3t5XeJS
    CXlmrtfp4vg5t8D/J20jpB7himrdi1VbrC0jCSnb6ztYhHIO7Rt8tgL45xEUtbKKyuCC3X
    w033wMlCL3M8EgXFwa4dfaw0BbIcenYuzcz9xq0uLyPpeNUNHtUyrocS2QhmWl0gJvSOKh
    rgU90sdLIs3odoLwBwown6jr3tHupptD5A24cLpKxm9qgTrpkqT8Z6/Pb22m2DB1JYxErO
    g5eVfheX7waQOhR/OI+YuDy0HLIKbk1z2SQ8Qdwp+VHqkdevVwvRFqSrIAU9Ca192tjCCv
    7T7TRPqn6IX7ki+Oi8K3n71kDe9xnU+5P/c0c+bh3KWGPlRU2fOfXMTqb/Hg
X-ME-Proxy: <xmx:2CvXajzeRk69qwnap2F5aMroijp2VUsghtt2Z0uHvYgI5NMUJPcthw>
    <xmx:2CvXasBWnE0o9GwyMtinoYpI_vCTlVCNoAlDFNLE4ouXdcxlS69_0A>
    <xmx:2CvXapeOsYmQ8KS2haSOPmKsobm2ZipktkZMXtTDaErM7xhcCG2kbA>
    <xmx:2CvXaunW8Zn4z_0kr3Ja_Iz7MNM0kwZCqm0h03bqWbFcpj3WVsldAw>
    <xmx:2CvXangX2sjju3Za0xCGtcpVEsuxaTqzyvzE4-begwM81mYgkkmsuUS4>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 20 Oct 2026 04:52:38 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Avi Weiss" <thnkslprpt@gmail.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: wake poll waiters when an empty pipe is unlinked
In-reply-to: <20261020071455.775967-1-thnkslprpt@gmail.com>
References: <20261020071455.775967-1-thnkslprpt@gmail.com>
Date: Tue, 20 Oct 2026 19:52:34 +1100
Message-id: <179248635495.1724252.1875521767773516593@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 20 Oct 2026, Avi Weiss wrote:
> When an empty rpc_pipefs pipe is unlinked, rpc_purge_list() returns
> without waking the pipe wait queue. An existing epoll waiter can
> remain blocked even though rpc_pipe_poll() reports EPOLLHUP and
> EPOLLERR for the disconnected pipe.
> 
> Wake the wait queue after clearing RPC_I(inode)->pipe so existing
> poll waiters are notified regardless of whether messages were purged.

The wake doesn't strictly need to be *after* clearing ->pipe, only
before unlocking the inode.  But after clearing is a good place to put
it.

Reviewed-by: NeilBrown <neil@brown.name>

Thanks,
NeilBrown


> 
> Fixes: 9842ef3557ab ("SUNRPC: rpc_timeout_upcall_queue should not sleep")
> Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
> ---
> 
> Tested with an empty rpc_pipefs pipe in QEMU:
> - 7.3.0 baseline: fresh poll() reports HUP/ERR (0x18),
>   but an existing epoll_wait() times out.
> - 7.3.0 with this patch: fresh poll() reports HUP/ERR (0x18),
>   and epoll_wait() returns events=0x18.
> 
>  net/sunrpc/rpc_pipe.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 9d349cfbc4831..68b4e040a77d9 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -191,6 +191,7 @@ rpc_close_pipes(struct dentry *dentry)
>  	cancel_delayed_work_sync(&pipe->queue_timeout);
>  	rpc_inode_setowner(inode, NULL);
>  	RPC_I(inode)->pipe = NULL;
> +	wake_up(&RPC_I(inode)->waitq);
>  	inode_unlock(inode);
>  }
>  
> 
> base-commit: c03c1a14507dfaf8b856c2608f9ac216021fc222
> -- 
> 2.43.0
> 
> 

