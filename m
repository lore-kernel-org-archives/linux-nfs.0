Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81B473515EC;
	Sat, 15 Aug 2026 16:28:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811329; cv=none; b=jLeGXLnwbk2pQaNgdON8IW6IxZzzu8WI6bKyj5kQM/wbQJ0YxPqkX68Nki+IEiHyNCzhR0Pfv6MIE31G3qE9QiKaq4nc7yw9gC8JO5Gprl6yXLH6NR4po7gBZ5vTUCSFr+2XuW44GeroolFbZUrO60RuS7osWMqLVRz4h1kltlo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811329; c=relaxed/simple;
	bh=PzOgzoX3wL+JjnMa1MbkzGOiI4sG8s2IYs1W9kEdR6c=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qrNS3KfeO6yPxiIYkmlmXyCoZ2XiRFubffZqgmu01LT1CsxuT+VmBAybb7xf7mLwG4i3Ie+KTAG8mu1U9o1oV4Wzy0PNSk9PLYUpH21/Wnin9tXS9IqGbXylwX75MmxQBLEMzzQcSHsdwXpCxmEnZBkWmc6NtQWEmQuQgkJxEPI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=od6xgNS8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="od6xgNS8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 612F51F000E9;
	Sat, 15 Aug 2026 16:28:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811328;
	bh=ShiSCIL+jwy2kKkLVlLV1PebMFsO8hLbpmFevVT9ZxE=;
	h=From:To:Cc:Subject:Date;
	b=od6xgNS8xG/bGCfWgmBttOChZemLdT9e4HXroXS/Psmvnul+lCgvCwsWjT2hf4rxO
	 7KJqZNtBILyCnK2RFo9xZvGwwaMuIHvvKFWBtou3c0NM5ORfwY4t51U9N+IjbzqCkB
	 7RDTJt7aua4pXtIocCsxOiOmD9LxpoCoEXYKM288iTB5eakFAGmZKk03FOoAWMzECX
	 E6kN8VvMpQgUKx6Yk9W5bubCuzM/lhuNJpIFCW9JCo0dvk4MME4pbDczD6lhij/SN1
	 bh9WtYbXh/0h+GSgbWvdwKhtCJFDvw7fc6FUppYPVFvLPghXDUrpO1+1FXtqDD1/f2
	 GRx+ypNqMBnNw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	syzbot+54cdc566f64abf51b7f1@syzkaller.appspotmail.com
Subject: [PATCH v1] SUNRPC: Reject a socket that already has an svc_sock attached
Date: Sat, 15 Aug 2026 12:28:44 -0400
Message-ID: <20260815162844.8219-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Writing the same socket descriptor to /proc/fs/nfsd/portlist twice
attaches a second svc_sock to one socket. svc_setup_socket() saves
the socket's callbacks before installing its own, so the second
attach records svc_write_space() as the old write_space callback.
svc_udp_init() invokes that callback by way of svc_sock_setbufsize(),
and svc_write_space() then calls itself until the kernel stack is
exhausted:

  BUG: TASK stack guard page was hit at ffffc900037d7ff8
   svc_write_space+0x90/0x2b0 net/sunrpc/svcsock.c:429
   svc_write_space+0xe6/0x2b0 net/sunrpc/svcsock.c:430
   ... 700 more ...
   svc_sock_setbufsize+0x18d/0x220 net/sunrpc/svcsock.c:386
   svc_udp_init net/sunrpc/svcsock.c:854 [inline]
   svc_setup_socket+0xb2f/0x1090 net/sunrpc/svcsock.c:1498
   svc_addsock+0x2fd/0x760 net/sunrpc/svcsock.c:1547
   __write_ports_addfd fs/nfsd/nfsctl.c:742 [inline]
   write_ports+0xa5b/0xcc0 fs/nfsd/nfsctl.c:861
   nfsctl_transaction_write+0x106/0x1a0 fs/nfsd/nfsctl.c:112

svc_data_ready() and svc_tcp_state_change() chain through their saved
callbacks the same way, so a TCP descriptor added twice recurses on
the next incoming segment instead. Reaching any of this takes a
writer on portlist, and the nfsd filesystem sets no FS_USERNS_MOUNT,
so the reproducer needs CAP_SYS_ADMIN in the initial user namespace.

Reject a socket that already carries sk_user_data. svc_setup_socket()
overwrites that field unconditionally, so a socket some other
consumer has claimed is one NFSD would corrupt whether or not the
callbacks recurse.

Fixes: b41b66d63c73 ("[PATCH] knfsd: allow sockets to be passed to nfsd via 'portlist'")
Reported-by: syzbot+54cdc566f64abf51b7f1@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=54cdc566f64abf51b7f1
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7a423e9ee74d..5a2d52284d75 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1614,6 +1614,9 @@ int svc_addsock(struct svc_serv *serv, struct net *net, const int fd,
 	err = -EISCONN;
 	if (so->state > SS_UNCONNECTED)
 		goto out;
+	err = -EBUSY;
+	if (so->sk->sk_user_data)
+		goto out;
 	err = -ENOENT;
 	if (!try_module_get(THIS_MODULE))
 		goto out;
-- 
2.54.0

