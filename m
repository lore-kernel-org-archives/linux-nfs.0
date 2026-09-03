Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CEAC84AF667;
	Thu,  3 Sep 2026 13:48:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788443318; cv=none; b=M1tk+ykGAiflGXZfC+iObKREjebI4inEJ5P9w5wm8bwHEu/MND2qFZhS2GnCYuB6efInK6XGggy4nIIbR6LBoZbh7zIw7txCaN/9bH2AFBX/yh5nngRdLisBg2yl8yCP0EYo7yzAZMXW4PJtqKKTGaUAhKtQYC63SlMmTyYXQxA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788443318; c=relaxed/simple;
	bh=oEvAAjfz0U+lK1cWGw7aIIoiNpfb1AirxCoSm/ZzFZE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=rmeC/tuyRFYqvz313hMy2pSGyrh4BbOmYE284gKb4cU2zIoZGmL8o+xeqrNu2eHi181CPtoqmwKrmsYp4r7P4r1YsGFEq7JjBLJdDAIoWB2CrByZKswjd9ThvqD9K57vduXZbaTqo/TK/PhISP2gP+gxuu8VRJ8KNdLnxDPX0AQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dVndRoYO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dVndRoYO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 192A01F00ACA;
	Thu,  3 Sep 2026 13:48:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788443304;
	bh=TtqO8j8wK9pi/V1Xzs+irJH+oHMIB/Nfd9L7Kz+hqPc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=dVndRoYODSv6sl6bTsd20UVUyQ3oZH3EU2RqEEHFjXu75YUSJTF/sZ6o/FPgoDNYZ
	 cZ71wSGSs/Polv1dppod8kliyLlkEMj7zLt40A8h3P8IEQfZ7o//jgPnE6AyVtuNB4
	 J3Ioi6x/KuLRmJcRC9cFAjZVS3Qk3Cp9dwtRM2eNHy689KUEXz0rrSiBGMB2DoKQOd
	 Md6SNjY1+PEcNQZmqTEOAjeEHSEMv5S1VQk513/2XyedfkbKTCl1WPEzGe5e5vy0Zu
	 dXVaS0fxP0sDD/1pEs9R7bJbuQQd19MlRzA9XjIrO7s+r0eDLowefiAyyx81WnRaGw
	 mSq6N/DPFf5Cg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 49C65F40067;
	Thu,  3 Sep 2026 09:48:23 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 03 Sep 2026 09:48:23 -0400
X-ME-Sender: <xms:p3qZaowR-z8cwHViaXTGSHdYQf8NcoxVuZ50xCC-VDzbjqIU7uhzGA>
    <xme:p3qZanEUSUDNF9X8xXYOzHh6d4gcRDkSpMLyfUJu19T6jNawj0BMbF8jYawvw-KIA
    Lq4OmkH0ezACXb-C11uIfIWS-LPBYkkyr7SflTxC02DBG55OoHIfhM>
X-ME-Proxy-Cause: dmFkZTFiLYsXutNn9er5FUcqaLaBPHs0ZdDmErkPDCBwQIXlTBV+DzcQQPuCj9ZSQnm1ub
    mco9RkD//gbtffkAzwGv0Rr1cDeQKHQFjbX+MVF/YApz+oYIkAjl5dmThQQsMLuorBSEF9
    o4U5TOr9ZOpcoYi7GPeRcnZsDsiWv60pa1fs2yfyQydWzna/6V8X72S0s8DGO5HaGPpiXO
    /uybyeEApG4onHzkLz3D8ReeZFN/098DYbhE2fs4I1Mwwz2sw74HzAeYH94aJUg0ndYRyE
    K4DvsMN3YnI/3uA6cuSW+Fht14/eQDUVb7U0ikXwmuUnwTWomSGT3lY74+PpC8jG00LOBd
    /XlKGM5q4DurVuaIicoPsHkFO8oKTqKMgLr/YdWektCqSdoQpRvB9AP9hsQS6A6auW11Wj
    odBz+lUBZTBlbGT7zV6LuGvdGj9L+6iGN0IcwEnXUjzEzOOi9ZaukvZJC24d0Ira6wercy
    7dRsx7EghgAn0CpUAiTa+ABThmIjP38XO0uj6bCDmnxLC63uMOkHAAHF2UShT8sB8ZNwku
    5rgOPW6ZEoEsZnjF+I4HOYAcCrfKKz+5BNodaaln+L0YlHR4YfwGWpMt8uYiBxKf4Nyhof
    unTF9NpgGvxf4Cqf/bW4yDsTmh51faVHNP4tMkYWzmVZI1pQrtCXp62DNZfQ
X-ME-Proxy: <xmx:p3qZajXqi5FKzsE19hNMm25u86rYiDCwtTy1Gsi_GxDYT8QOSvosNQ>
    <xmx:p3qZap9ATd-fllZvpYhT3bahOhzmtnf_BrXMKtV8LfRhbgicMFMYHw>
    <xmx:p3qZarYW82vQciEYpGcr266JJPBt6Er1iVMZbz4SelGrHtAkA5vjdA>
    <xmx:p3qZahfGC-H02_4Vm1YsfwHCWXTO9offqhg4GINsKOmTl1TNLDzDVg>
    <xmx:p3qZaloj-v6M_Hq-yHflqN0MFyYQWMKPz5glqHCOjpu5coC2JKl9U1Zz>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0CBBE7811F0; Thu,  3 Sep 2026 09:48:23 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ArapIjg4cGhR
Date: Thu, 03 Sep 2026 09:48:06 -0400
From: "Chuck Lever" <cel@kernel.org>
To: syzbot <syzbot@kernel.org>, syzkaller-bugs@googlegroups.com,
 "Slawomir Stepien" <sst@poczta.fm>, "Anna Schumaker" <anna@kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jeff Layton" <jlayton@kernel.org>,
 "Jakub Kicinski" <kuba@kernel.org>, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, "Paolo Abeni" <pabeni@redhat.com>,
 "Trond Myklebust" <trondmy@kernel.org>,
 "Trond Myklebust" <trond.myklebust@primarydata.com>
Cc: "Dai Ngo" <Dai.Ngo@oracle.com>, "Simon Horman" <horms@kernel.org>,
 linux-kernel@vger.kernel.org, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, syzbot@lists.linux.dev,
 "Tom Talpey" <tom@talpey.com>
Message-Id: <c31de847-f77f-4dd8-87c4-46e3d21c57a9@app.fastmail.com>
In-Reply-To: <554e50fa-697c-4e57-b5a5-a1c280816436@mail.kernel.org>
References: <554e50fa-697c-4e57-b5a5-a1c280816436@mail.kernel.org>
Subject: Re: [PATCH] sunrpc: reject socket already in use in svc_addsock()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Sep 3, 2026, at 9:28 AM, syzbot wrote:
> From: Slawomir Stepien <sst@poczta.fm>
>
> When a socket is added to an RPC service via svc_addsock() (for example, by
> writing its file descriptor to /proc/fs/nfsd/portlist), svc_setup_socket()
> saves the original socket callbacks (such as sk_state_change) into struct
> svc_sock and replaces them with RPC-specific callbacks (such as
> svc_tcp_state_change). It also attaches the new svc_sock to
> sk->sk_user_data.
>
> If the same socket file descriptor is added to an RPC service again,
> svc_addsock() invokes svc_setup_socket() a second time on the same socket.
> During the second setup, svsk->sk_ostate is assigned the socket's current
> sk_state_change callback, which was already replaced with
> svc_tcp_state_change. When a state change event subsequently occurs on the
> socket (for example, when connect() is called), svc_tcp_state_change()
> invokes svsk->sk_ostate, calling itself in an infinite recursion until the
> kernel stack overflows and triggers a stack guard page fault:
>
> BUG: TASK stack guard page was hit at ffffc900030b7ff8 (stack is
> ffffc900030b8000..ffffc900030c0000)
> Oops: stack guard page: 0000 [#1] SMP KASAN NOPTI
> ...
> Call Trace:
>  <TASK>
>  svc_tcp_state_change+0x76/0x2e0 net/sunrpc/svcsock.c:917
>  svc_tcp_state_change+0x76/0x2e0 net/sunrpc/svcsock.c:917
>  svc_tcp_state_change+0x76/0x2e0 net/sunrpc/svcsock.c:917
>  ...
>  tcp_done_with_error net/ipv4/tcp_input.c:4877 [inline]
>  tcp_reset+0x176/0x380 net/ipv4/tcp_input.c:4909
>  tcp_rcv_synsent_state_process net/ipv4/tcp_input.c:6903 [inline]
>  tcp_rcv_state_process+0x13bc/0x48a0 net/ipv4/tcp_input.c:7197
>  tcp_v4_do_rcv+0xafc/0x1530 net/ipv4/tcp_ipv4.c:1876
>  sk_backlog_rcv include/net/sock.h:1192 [inline]
>  __release_sock+0x25b/0x390 net/core/sock.c:3260
>  release_sock+0x190/0x260 net/core/sock.c:3859
>  inet_wait_for_connect net/ipv4/af_inet.c:616 [inline]
>  __inet_stream_connect+0x863/0xe00 net/ipv4/af_inet.c:710
>  inet_stream_connect+0x66/0xa0 net/ipv4/af_inet.c:755
>  connect_socket net/socket.c:2141 [inline]
>  __sys_connect_file net/socket.c:2166 [inline]
>  __sys_connect+0x316/0x450 net/socket.c:2183
>  ...
>  </TASK>
>
> Fix this by checking if so->sk->sk_user_data is already set in
> svc_addsock() before proceeding with svc_setup_socket(). If it is already
> non-NULL, return -EBUSY to prevent re-initializing an active socket.
>
> Fixes: fa9251afc33c ("SUNRPC: Call the default socket callbacks instead 
> of open coding")
> Assisted-by: Gemini:gemini-3.7-flash Gemini:gemini-3.1-pro-preview 
> syzbot
> Reported-by: syzbot+c9834a0c0215e6d8697a@syzkaller.appspotmail.com
> Closes: https://syzkaller.appspot.com/bug?extid=c9834a0c0215e6d8697a
> Link: 
> https://syzkaller.appspot.com/ai_job?id=30de91d1-1d14-4676-8c38-a3564f7acf48
> Signed-off-by: Slawomir Stepien <sst@poczta.fm>
>
> ---
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 50e5e7f5b..e8cc4329f 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1541,6 +1541,9 @@ int svc_addsock(struct svc_serv *serv, struct net 
> *net, const int fd,
>  	err = -EISCONN;
>  	if (so->state > SS_UNCONNECTED)
>  		goto out;
> +	err = -EBUSY;
> +	if (so->sk->sk_user_data)
> +		goto out;
>  	err = -ENOENT;
>  	if (!try_module_get(THIS_MODULE))
>  		goto out;
>
>
> base-commit: cee9395acd8043be0644b25c34bfa86623f2b935

A similar fix is already in nfsd-testing:

https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/commit/net/sunrpc/svcsock.c?h=nfsd-testing&id=7e8d1b4845aac4ad3c7bcd39032754917f5b966d


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
