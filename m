Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:51219 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbaD3C44 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 22:56:56 -0400
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <greg@kroah.com>, <lizefan@huawei.com>,
        <skinsbursky@parallels.com>, <h.huangqiang@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3.4 9/9] nfsd: check passed socket's net matches NFSd superblock's one
Date: Wed, 30 Apr 2014 10:43:44 +0800
Message-ID: <1398825824-6360-10-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>

commit 3064639423c48d6e0eb9ecc27c512a58e38c6c57 upstream.

There could be a case, when NFSd file system is mounted in network, different
to socket's one, like below:

"ip netns exec" creates new network and mount namespace, which duplicates NFSd
mount point, created in init_net context. And thus NFS server stop in nested
network context leads to RPCBIND client destruction in init_net.
Then, on NFSd start in nested network context, rpc.nfsd process creates socket
in nested net and passes it into "write_ports", which leads to RPCBIND sockets
creation in init_net context because of the same reason (NFSd monut point was
created in init_net context). An attempt to register passed socket in nested
net leads to panic, because no RPCBIND client present in nexted network
namespace.

This patch add check that passed socket's net matches NFSd superblock's one.
And returns -EINVAL error to user psace otherwise.

v2: Put socket on exit.

Reported-by: Weng Meiling <wengmeiling.weng@huawei.com>
Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
[wengmeiling: backport to 3.4: adjust context]
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfsctl.c               |  5 +++++
 include/linux/sunrpc/svcsock.h |  1 +
 net/sunrpc/svcsock.c           | 16 ++++++++++++++++
 3 files changed, 22 insertions(+)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index cebc9ef..4db777d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -660,6 +660,11 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net)
 	if (err != 0 || fd < 0)
 		return -EINVAL;
 
+	if (svc_alien_sock(net, fd)) {
+		printk(KERN_ERR "%s: socket net is different to NFSd's one\n", __func__);
+		return -EINVAL;
+	}
+
 	err = nfsd_create_serv(net);
 	if (err != 0)
 		return err;
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index cb4ac69..e4c6cec 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -42,6 +42,7 @@ void		svc_sock_update_bufs(struct svc_serv *serv);
 int		svc_sock_names(struct svc_serv *serv, char *buf,
 					const size_t buflen,
 					const char *toclose);
+bool		svc_alien_sock(struct net *net, int fd);
 int		svc_addsock(struct svc_serv *serv, const int fd,
 					char *name_return, const size_t len);
 void		svc_init_xprt_sock(void);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f190ea9..4c23cfc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1441,6 +1441,22 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	return svsk;
 }
 
+bool svc_alien_sock(struct net *net, int fd)
+{
+	int err;
+	struct socket *sock = sockfd_lookup(fd, &err);
+	bool ret = false;
+
+	if (!sock)
+		goto out;
+	if (sock_net(sock->sk) != net)
+		ret = true;
+	sockfd_put(sock);
+out:
+	return ret;
+}
+EXPORT_SYMBOL_GPL(svc_alien_sock);
+
 /**
  * svc_addsock - add a listener socket to an RPC service
  * @serv: pointer to RPC service to which to add a new listener
-- 
1.8.2.2


