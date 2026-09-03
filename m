Received: from smtpo75.interia.pl (smtpo75.interia.pl [217.74.67.75])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 812474B1489
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 14:06:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.74.67.75
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788444371; cv=none; b=clxr4PSf5TCIH+5T7626JmbC+yhOURH8SRCm255OBo3IlWDGRL1nYys5xgLT1zyExXB83PtZPGckwb3oiW8CsmJRLRYJoou1L/HZYpbmPRstZvSk2fTcmSyYc3K2S0WM7X1ipFGGsAymlSv04kI8VeYCLpPn+zYw5N2aVXRHLSc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788444371; c=relaxed/simple;
	bh=jIg0gQVea/HpkmYQ6hpRxOBNe+E0GsfphvWvKN4xPmE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=bHIi549Bmb2XrSeoQiKgEtfmws1Cl6qSQkmM6VGOuD8iM0laJfpMBhAis+EWOZjI7n1E1CvWHG8x/7LNSDifCGVc1UVFlYCYQ+wRlzDUnO6OZoHc0WqK0JW9cKs0/I6ADGIyms+H7Blep16qT1s58JXhquUprMQg1G902gSAzSE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=poczta.fm; spf=pass smtp.mailfrom=poczta.fm; dkim=pass (1024-bit key) header.d=poczta.fm header.i=@poczta.fm header.b=nU0Dj+Yc; arc=none smtp.client-ip=217.74.67.75
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=poczta.fm
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=poczta.fm
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=poczta.fm header.i=@poczta.fm header.b="nU0Dj+Yc"
Received: from nr200 (unknown [80.68.231.31])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (P-256) server-digest SHA256)
	(No client certificate requested)
	by poczta.interia.pl (INTERIA.PL) with ESMTPSA;
	Thu,  3 Sep 2026 16:05:50 +0200 (CEST)
Date: Thu, 3 Sep 2026 16:05:47 +0200
From: Slawomir Stepien <sst@poczta.fm>
To: Chuck Lever <cel@kernel.org>
Cc: syzbot <syzbot@kernel.org>, syzkaller-bugs@googlegroups.com,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Layton <jlayton@kernel.org>, Jakub Kicinski <kuba@kernel.org>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	Paolo Abeni <pabeni@redhat.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Simon Horman <horms@kernel.org>,
	linux-kernel@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>, syzbot@lists.linux.dev,
	Tom Talpey <tom@talpey.com>
Subject: Re: [PATCH] sunrpc: reject socket already in use in svc_addsock()
Message-ID: <apl-u5wtRUO6o5wC@nr200>
References: <554e50fa-697c-4e57-b5a5-a1c280816436@mail.kernel.org>
 <c31de847-f77f-4dd8-87c4-46e3d21c57a9@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c31de847-f77f-4dd8-87c4-46e3d21c57a9@app.fastmail.com>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=poczta.fm; s=dk;
	t=1788444353; bh=4yzE0r6uHgl6auw9ViVevz1l+8qKEPBoHma3z4nNR2U=;
	h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type;
	b=nU0Dj+YcWB8dzesRuOdepnOzLEnxTfRXHtH3xyuzIM8MPUznP1whML583lcbWvA2V
	 7zCNtepXFEZv0HxIFP1tTXNmOEzCG6tIN7AXIjuA/NE3Ng58j/uBGaZGNEqNU/eYXh
	 BW4suu84bIyRxBIgEjMcQazuy+NqPCI8pljVV0po=

On wrz 03, 2026 09:48, Chuck Lever wrote:
> On Thu, Sep 3, 2026, at 9:28 AM, syzbot wrote:
> > From: Slawomir Stepien <sst@poczta.fm>
> >
> > When a socket is added to an RPC service via svc_addsock() (for example, by
> > writing its file descriptor to /proc/fs/nfsd/portlist), svc_setup_socket()
> > saves the original socket callbacks (such as sk_state_change) into struct
> > svc_sock and replaces them with RPC-specific callbacks (such as
> > svc_tcp_state_change). It also attaches the new svc_sock to
> > sk->sk_user_data.
> >
> > If the same socket file descriptor is added to an RPC service again,
> > svc_addsock() invokes svc_setup_socket() a second time on the same socket.
> > During the second setup, svsk->sk_ostate is assigned the socket's current
> > sk_state_change callback, which was already replaced with
> > svc_tcp_state_change. When a state change event subsequently occurs on the
> > socket (for example, when connect() is called), svc_tcp_state_change()
> > invokes svsk->sk_ostate, calling itself in an infinite recursion until the
> > kernel stack overflows and triggers a stack guard page fault:
> >
> > BUG: TASK stack guard page was hit at ffffc900030b7ff8 (stack is
> > ffffc900030b8000..ffffc900030c0000)
> > Oops: stack guard page: 0000 [#1] SMP KASAN NOPTI
> > ...
> > Call Trace:
> >  <TASK>
> >  svc_tcp_state_change+0x76/0x2e0 net/sunrpc/svcsock.c:917
> >  svc_tcp_state_change+0x76/0x2e0 net/sunrpc/svcsock.c:917
> >  svc_tcp_state_change+0x76/0x2e0 net/sunrpc/svcsock.c:917
> >  ...
> >  tcp_done_with_error net/ipv4/tcp_input.c:4877 [inline]
> >  tcp_reset+0x176/0x380 net/ipv4/tcp_input.c:4909
> >  tcp_rcv_synsent_state_process net/ipv4/tcp_input.c:6903 [inline]
> >  tcp_rcv_state_process+0x13bc/0x48a0 net/ipv4/tcp_input.c:7197
> >  tcp_v4_do_rcv+0xafc/0x1530 net/ipv4/tcp_ipv4.c:1876
> >  sk_backlog_rcv include/net/sock.h:1192 [inline]
> >  __release_sock+0x25b/0x390 net/core/sock.c:3260
> >  release_sock+0x190/0x260 net/core/sock.c:3859
> >  inet_wait_for_connect net/ipv4/af_inet.c:616 [inline]
> >  __inet_stream_connect+0x863/0xe00 net/ipv4/af_inet.c:710
> >  inet_stream_connect+0x66/0xa0 net/ipv4/af_inet.c:755
> >  connect_socket net/socket.c:2141 [inline]
> >  __sys_connect_file net/socket.c:2166 [inline]
> >  __sys_connect+0x316/0x450 net/socket.c:2183
> >  ...
> >  </TASK>
> >
> > Fix this by checking if so->sk->sk_user_data is already set in
> > svc_addsock() before proceeding with svc_setup_socket(). If it is already
> > non-NULL, return -EBUSY to prevent re-initializing an active socket.
> >
> > Fixes: fa9251afc33c ("SUNRPC: Call the default socket callbacks instead 
> > of open coding")
> > Assisted-by: Gemini:gemini-3.7-flash Gemini:gemini-3.1-pro-preview 
> > syzbot
> > Reported-by: syzbot+c9834a0c0215e6d8697a@syzkaller.appspotmail.com
> > Closes: https://syzkaller.appspot.com/bug?extid=c9834a0c0215e6d8697a
> > Link: 
> > https://syzkaller.appspot.com/ai_job?id=30de91d1-1d14-4676-8c38-a3564f7acf48
> > Signed-off-by: Slawomir Stepien <sst@poczta.fm>
> >
> > ---
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 50e5e7f5b..e8cc4329f 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -1541,6 +1541,9 @@ int svc_addsock(struct svc_serv *serv, struct net 
> > *net, const int fd,
> >  	err = -EISCONN;
> >  	if (so->state > SS_UNCONNECTED)
> >  		goto out;
> > +	err = -EBUSY;
> > +	if (so->sk->sk_user_data)
> > +		goto out;
> >  	err = -ENOENT;
> >  	if (!try_module_get(THIS_MODULE))
> >  		goto out;
> >
> >
> > base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
> 
> A similar fix is already in nfsd-testing:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/commit/net/sunrpc/svcsock.c?h=nfsd-testing&id=7e8d1b4845aac4ad3c7bcd39032754917f5b966d

Ah ok, a different extid of syzbug that's why I've missed it. Thanks!

-- 
Slawomir Stepien
