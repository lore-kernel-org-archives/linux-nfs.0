Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:59642 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbaBSK0j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Feb 2014 05:26:39 -0500
Message-ID: <530486D9.7010502@parallels.com>
Date: Wed, 19 Feb 2014 14:26:33 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Weng Meiling <wengmeiling.weng@huawei.com>, <greg@kroah.com>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <devel@openvz.org>
Subject: Re: [PATCH] nfsd: check passed socket's net matches NFSd superblock's
 one
References: <20131230142339.16166.28243.stgit@localhost.localdomain> <20140103222226.GD5164@fieldses.org> <52FEC818.7030604@huawei.com> <20140217221900.GA8401@fieldses.org> <53037A03.4020603@parallels.com> <20140218154406.GD4319@fieldses.org>
In-Reply-To: <20140218154406.GD4319@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

18.02.2014 19:44, J. Bruce Fields пишет:
> On Tue, Feb 18, 2014 at 07:19:31PM +0400, Stanislav Kinsbursky wrote:
>> 18.02.2014 02:19, J. Bruce Fields пишет:
>>> On Sat, Feb 15, 2014 at 09:51:20AM +0800, Weng Meiling wrote:
>>>> Hi Bruce,
>>>>
>>>> The upstream has merged your git tree for-3.14, but there is no this patch?
>>>> Do you forget this patch?
>>>
>>> Apologies, I'm not sure what happened.
>>>
>>> Looking back at it....  The patch causes all my pynfs reboot recovery
>>> tests to fail.  They're just doing a "systemctl restart
>>> nfs-server.service", and "systemctl status nfs-server.service" shows in
>>> part
>>>
>>> 	ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS $RPCNFSDCOUNT (code=exited, status=1/FAILURE)
>>>
>>> So the patch is causing rpc.nfsd to fail?  No network namespaces should
>>> be involved.
>>>
>>> I haven't investigated any further.
>>>
>>
>> Hi Bruce,
>> Are you sure, that exactly this patch broke your pynfs tests?
>> BTW, systemd manipulates namespaces. Maybe the patch revealed some pynfs internal bugs?
>> What do you think?
>
> It's really just "systemctl restart nfs-server.service" that the patch
> breaks, pynfs isn't involved much.
>
> The patch I'm actually using follows, but I believe the only difference
> is in the printk message?
>

Yep, looks true.
That's strange: "systemctl restart nfs-server.service" works for me on Fedora 18 with kernel, based on your repo.

> --b
>
> commit e1f2922c12cb59baba0f2c7726bee992a0861310
> Author: Stanislav Kinsbursky <skinsbursky@parallels.com>
> Date:   Mon Dec 30 17:23:59 2013 +0300
>
>      nfsd: check passed socket's net matches the NFSd superblock's
>
>      The file descriptor written to the nfsd/portlist file could be for a
>      socket in a different network namespace from the network namespace that
>      the nfsd filesystem was mounted in, and this can cause a crash.
>
>      For example: "ip netns exec" creates a new network and mount namespace,
>      which duplicates the nfsd mount point which was created in the init_net
>      context.  Thus NFS server stop in the nested network context leads to
>      RPCBIND client destruction in init_net.  Then, on nfsd start in the
>      nested network context, the rpc.nfsd process creates a socket in the
>      nested net and passes it into "write_ports", which leads to RPCBIND
>      socket creation in init_net context for the same reason (the nfsd mount
>      point was created in the init_net context). An attempt to register
>      passed socket in nested net leads to panic, because no RPCBIND client is
>      present in the nested network namespace.
>
>      This patch adds a check that the passed the socket's net matches the
>      nfsd superblock's net, and returns -EINVAL error to user space if not.
>
>      Reported-by: Weng Meiling <wengmeiling.weng@huawei.com>
>      Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>      Cc: stable@vger.kernel.org
>      Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 7f55517..1331766 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -699,6 +699,11 @@ static ssize_t __write_ports_addfd(char *buf, struct net *net)
>   	if (err != 0 || fd < 0)
>   		return -EINVAL;
>
> +	if (svc_alien_sock(net, fd)) {
> +		printk(KERN_ERR "%s: socket net is different from NFSd's\n", __func__);
> +		return -EINVAL;
> +	}
> +
>   	err = nfsd_create_serv(net);
>   	if (err != 0)
>   		return err;
> diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
> index 62fd1b7..947009e 100644
> --- a/include/linux/sunrpc/svcsock.h
> +++ b/include/linux/sunrpc/svcsock.h
> @@ -56,6 +56,7 @@ int		svc_recv(struct svc_rqst *, long);
>   int		svc_send(struct svc_rqst *);
>   void		svc_drop(struct svc_rqst *);
>   void		svc_sock_update_bufs(struct svc_serv *serv);
> +bool		svc_alien_sock(struct net *net, int fd);
>   int		svc_addsock(struct svc_serv *serv, const int fd,
>   					char *name_return, const size_t len);
>   void		svc_init_xprt_sock(void);
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index b6e59f0..3ba5b87 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1397,6 +1397,17 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>   	return svsk;
>   }
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
>   /**
>    * svc_addsock - add a listener socket to an RPC service
>    * @serv: pointer to RPC service to which to add a new listener
>


-- 
Best regards,
Stanislav Kinsbursky
