Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 33E244AF67B;
	Thu,  3 Sep 2026 13:28:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788442169; cv=none; b=Bu8JSUTKIyL94R+sDgdJfS5Fdm5unpDkcshFJLsS1uuUnpPP1XaMhH6W8oOqL5CTdwLFvWA5HlEX9tA/ZT49VldxaI9Y+zyn4ZFNl7AfzNOEa6i0sG+HZ7Vsfbi6//SrJFw5DjRKj2BiM4EUTBow9+0QjH/VTOifdd7AA1E59Jk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788442169; c=relaxed/simple;
	bh=fhmzhrTpZ4dwuAMAc5n9ojQfW7DvMrtweGJSodoYcFE=;
	h=From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:Date; b=CBSUV2Yt+VSP789/e5USZD1d0K/4sKC0kd+oSFg4qXH7E/lqrYsJEamvdYzObvboY//JwxEXWZYui4dnoQ8MBbVMhtOTy2jSPrGsZnV5Dd6GsLD5gkIuI3E7PIWaPtlGlAy3Y5Y7/0zxJyhtuHdz+k6aa78Dij63D7T6mkEbKCw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FIXwLsSd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FIXwLsSd"
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 89B061F000E9;
	Thu,  3 Sep 2026 13:28:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788442135;
	bh=cXIQqHtsttnd1IPYZ00yXUmi1oQqWL5TqZ5grwGtN4c=;
	h=From:To:Cc:Subject:Date;
	b=FIXwLsSdS9DX0fr11SJz2bWkyNNO3jz17UQ5HvXkpxRs+w2BRnYl7shYjChenn+Nk
	 njSCrtCgXCtIUOFbnL9ClA8lPIJBa4FkTOrpOgjzpxSTS7A2cT09F+vFqRpLyO9zJr
	 Ek0mmix7g6zK0UCe9uNtLA558ArFWsXpb5LXE/wNMnwAcAz7COGbJKh6Y7CEj69hfL
	 R6cp4OHK8ONzxoepJvOFjfpBykPrU5439aahkHv8nliuZhNMTpoFBlrI4no8MUCDvD
	 +L0YDnQr053zE9UFUtKT7E2qt/o4W1XbKOmEgFtH/giRA4rFtTWDB4NWWwm4ALo5ZW
	 oC8HR/exsgwOQ==
From: "syzbot" <syzbot@kernel.org>
To: syzkaller-bugs@googlegroups.com, Slawomir Stepien <sst@poczta.fm>, "Anna Schumaker" <anna@kernel.org>, "Chuck Lever" <cel@kernel.org>, "David S. Miller" <davem@davemloft.net>, "Eric Dumazet" <edumazet@google.com>, "Jeff Layton" <jlayton@kernel.org>, "Jakub Kicinski" <kuba@kernel.org>, <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>, "Paolo Abeni" <pabeni@redhat.com>, "Trond Myklebust" <trondmy@kernel.org>, "Trond Myklebust" <trond.myklebust@primarydata.com>
Cc: Dai.Ngo@oracle.com, horms@kernel.org, linux-kernel@vger.kernel.org, neil@brown.name, okorniev@redhat.com, syzbot@lists.linux.dev, tom@talpey.com
Subject: [PATCH] sunrpc: reject socket already in use in svc_addsock()
Message-ID: <554e50fa-697c-4e57-b5a5-a1c280816436@mail.kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Date: Thu,  3 Sep 2026 13:28:54 +0000 (UTC)

From: Slawomir Stepien <sst@poczta.fm>

When a socket is added to an RPC service via svc_addsock() (for example, by
writing its file descriptor to /proc/fs/nfsd/portlist), svc_setup_socket()
saves the original socket callbacks (such as sk_state_change) into struct
svc_sock and replaces them with RPC-specific callbacks (such as
svc_tcp_state_change). It also attaches the new svc_sock to
sk->sk_user_data.

If the same socket file descriptor is added to an RPC service again,
svc_addsock() invokes svc_setup_socket() a second time on the same socket.
During the second setup, svsk->sk_ostate is assigned the socket's current
sk_state_change callback, which was already replaced with
svc_tcp_state_change. When a state change event subsequently occurs on the
socket (for example, when connect() is called), svc_tcp_state_change()
invokes svsk->sk_ostate, calling itself in an infinite recursion until the
kernel stack overflows and triggers a stack guard page fault:

BUG: TASK stack guard page was hit at ffffc900030b7ff8 (stack is
ffffc900030b8000..ffffc900030c0000)
Oops: stack guard page: 0000 [#1] SMP KASAN NOPTI
...
Call Trace:
 <TASK>
 svc_tcp_state_change+0x76/0x2e0 net/sunrpc/svcsock.c:917
 svc_tcp_state_change+0x76/0x2e0 net/sunrpc/svcsock.c:917
 svc_tcp_state_change+0x76/0x2e0 net/sunrpc/svcsock.c:917
 ...
 tcp_done_with_error net/ipv4/tcp_input.c:4877 [inline]
 tcp_reset+0x176/0x380 net/ipv4/tcp_input.c:4909
 tcp_rcv_synsent_state_process net/ipv4/tcp_input.c:6903 [inline]
 tcp_rcv_state_process+0x13bc/0x48a0 net/ipv4/tcp_input.c:7197
 tcp_v4_do_rcv+0xafc/0x1530 net/ipv4/tcp_ipv4.c:1876
 sk_backlog_rcv include/net/sock.h:1192 [inline]
 __release_sock+0x25b/0x390 net/core/sock.c:3260
 release_sock+0x190/0x260 net/core/sock.c:3859
 inet_wait_for_connect net/ipv4/af_inet.c:616 [inline]
 __inet_stream_connect+0x863/0xe00 net/ipv4/af_inet.c:710
 inet_stream_connect+0x66/0xa0 net/ipv4/af_inet.c:755
 connect_socket net/socket.c:2141 [inline]
 __sys_connect_file net/socket.c:2166 [inline]
 __sys_connect+0x316/0x450 net/socket.c:2183
 ...
 </TASK>

Fix this by checking if so->sk->sk_user_data is already set in
svc_addsock() before proceeding with svc_setup_socket(). If it is already
non-NULL, return -EBUSY to prevent re-initializing an active socket.

Fixes: fa9251afc33c ("SUNRPC: Call the default socket callbacks instead of open coding")
Assisted-by: Gemini:gemini-3.7-flash Gemini:gemini-3.1-pro-preview syzbot
Reported-by: syzbot+c9834a0c0215e6d8697a@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=c9834a0c0215e6d8697a
Link: https://syzkaller.appspot.com/ai_job?id=30de91d1-1d14-4676-8c38-a3564f7acf48
Signed-off-by: Slawomir Stepien <sst@poczta.fm>

---
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 50e5e7f5b..e8cc4329f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1541,6 +1541,9 @@ int svc_addsock(struct svc_serv *serv, struct net *net, const int fd,
 	err = -EISCONN;
 	if (so->state > SS_UNCONNECTED)
 		goto out;
+	err = -EBUSY;
+	if (so->sk->sk_user_data)
+		goto out;
 	err = -ENOENT;
 	if (!try_module_get(THIS_MODULE))
 		goto out;


base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
-- 
See https://goo.gle/syzbot-ai-patches for information about AI-generated patches.
The person who has signed off on the patch is responsible for
addressing comments.
syzbot engineers can be reached at syzkaller@googlegroups.com.
