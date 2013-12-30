Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:37389 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755713Ab3L3O0E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Dec 2013 09:26:04 -0500
Subject: [PATCH] nfsd: check passed socket's net matches NFSd superblock's one
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: wengmeiling.weng@huawei.com, greg@kroah.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 30 Dec 2013 17:23:59 +0300
Message-ID: <20131230142339.16166.28243.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

Reported-by: Weng Meiling <wengmeiling.weng@huawei.com>
Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: stable@vger.kernel.org
---
 fs/nfsd/nfsctl.c               |    5 +++++
 include/linux/sunrpc/svcsock.h |    1 +
 net/sunrpc/svcsock.c           |   11 +++++++++++
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7f55517..f34d9de 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -699,6 +699,11 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net)
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
index 62fd1b7..947009e 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -56,6 +56,7 @@ int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
 void		svc_sock_update_bufs(struct svc_serv *serv);
+bool		svc_alien_sock(struct net *net, int fd);
 int		svc_addsock(struct svc_serv *serv, const int fd,
 					char *name_return, const size_t len);
 void		svc_init_xprt_sock(void);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b6e59f0..3ba5b87 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1397,6 +1397,17 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	return svsk;
 }
 
+bool svc_alien_sock(struct net *net, int fd)
+{
+	int err;
+	struct socket *sock = sockfd_lookup(fd, &err);
+
+	if (sock && (sock_net(sock->sk) != net))
+		return true;
+	return false;
+}
+EXPORT_SYMBOL_GPL(svc_alien_sock);
+
 /**
  * svc_addsock - add a listener socket to an RPC service
  * @serv: pointer to RPC service to which to add a new listener

