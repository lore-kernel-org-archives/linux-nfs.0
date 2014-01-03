Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35046 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbaACWWg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jan 2014 17:22:36 -0500
Date: Fri, 3 Jan 2014 17:22:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: wengmeiling.weng@huawei.com, greg@kroah.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH] nfsd: check passed socket's net matches NFSd
 superblock's one
Message-ID: <20140103222226.GD5164@fieldses.org>
References: <20131230142339.16166.28243.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131230142339.16166.28243.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 30, 2013 at 05:23:59PM +0300, Stanislav Kinsbursky wrote:
> There could be a case, when NFSd file system is mounted in network, different
> to socket's one, like below:
> 
> "ip netns exec" creates new network and mount namespace, which duplicates NFSd
> mount point, created in init_net context. And thus NFS server stop in nested
> network context leads to RPCBIND client destruction in init_net.
> Then, on NFSd start in nested network context, rpc.nfsd process creates socket
> in nested net and passes it into "write_ports", which leads to RPCBIND sockets
> creation in init_net context because of the same reason (NFSd monut point was
> created in init_net context). An attempt to register passed socket in nested
> net leads to panic, because no RPCBIND client present in nexted network
> namespace.

So it's the attempt to use a NULL ->rpcb_local_clnt4?

Interesting, thanks--applying with a minor fix to logged message.

--b.

> 
> This patch add check that passed socket's net matches NFSd superblock's one.
> And returns -EINVAL error to user psace otherwise.
> 
> Reported-by: Weng Meiling <wengmeiling.weng@huawei.com>
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> Cc: stable@vger.kernel.org
> ---
>  fs/nfsd/nfsctl.c               |    5 +++++
>  include/linux/sunrpc/svcsock.h |    1 +
>  net/sunrpc/svcsock.c           |   11 +++++++++++
>  3 files changed, 17 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 7f55517..f34d9de 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -699,6 +699,11 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net)
>  	if (err != 0 || fd < 0)
>  		return -EINVAL;
>  
> +	if (svc_alien_sock(net, fd)) {
> +		printk(KERN_ERR "%s: socket net is different to NFSd's one\n", __func__);
> +		return -EINVAL;
> +	}
> +
>  	err = nfsd_create_serv(net);
>  	if (err != 0)
>  		return err;
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 62fd1b7..947009e 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -56,6 +56,7 @@ int		svc_recv(struct svc_rqst *, long);
>  int		svc_send(struct svc_rqst *);
>  void		svc_drop(struct svc_rqst *);
>  void		svc_sock_update_bufs(struct svc_serv *serv);
> +bool		svc_alien_sock(struct net *net, int fd);
>  int		svc_addsock(struct svc_serv *serv, const int fd,
>  					char *name_return, const size_t len);
>  void		svc_init_xprt_sock(void);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index b6e59f0..3ba5b87 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1397,6 +1397,17 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>  	return svsk;
>  }
>  
> +bool svc_alien_sock(struct net *net, int fd)
> +{
> +	int err;
> +	struct socket *sock = sockfd_lookup(fd, &err);
> +
> +	if (sock && (sock_net(sock->sk) != net))
> +		return true;
> +	return false;
> +}
> +EXPORT_SYMBOL_GPL(svc_alien_sock);
> +
>  /**
>   * svc_addsock - add a listener socket to an RPC service
>   * @serv: pointer to RPC service to which to add a new listener
> 
