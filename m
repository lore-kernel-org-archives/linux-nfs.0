Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40937 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbbJWVuB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Oct 2015 17:50:01 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v3 16/16] NFS: Enable client side NFSv4.1 backchannel to use other transports
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtQ+iUnuxFzZ6kOHaC=EGj1ptB_P6odciBe3MnuSZ4PBiA@mail.gmail.com>
Date: Fri, 23 Oct 2015 17:49:54 -0400
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7EB7B74A-77BF-404C-A2B6-ACABBB337FC4@oracle.com>
References: <20151016131958.6819.98407.stgit@oracle-122.nfsv4bat.org> <20151016132612.6819.74118.stgit@oracle-122.nfsv4bat.org> <CAHQdGtQ+iUnuxFzZ6kOHaC=EGj1ptB_P6odciBe3MnuSZ4PBiA@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 23, 2015, at 5:29 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> 
> 
> On Fri, Oct 16, 2015 at 6:26 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > Pass the correct backchannel transport class to svc_create_xprt()
> > when setting up an NFSv4.1 backchannel transport.
> >
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
> > Tested-By: Devesh Sharma <devesh.sharma@avagotech.com>
> > ---
> >  fs/nfs/callback.c               |   33 +++++++++++++++++++++------------
> >  include/linux/sunrpc/xprt.h     |    1 +
> >  net/sunrpc/xprtrdma/transport.c |    1 +
> >  net/sunrpc/xprtsock.c           |    1 +
> >  4 files changed, 24 insertions(+), 12 deletions(-)
> >
> > diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> > index 75f7c0a..46ed2c5 100644
> > --- a/fs/nfs/callback.c
> > +++ b/fs/nfs/callback.c
> > @@ -99,15 +99,22 @@ nfs4_callback_up(struct svc_serv *serv)
> >  }
> >
> >  #if defined(CONFIG_NFS_V4_1)
> > -static int nfs41_callback_up_net(struct svc_serv *serv, struct net *net)
> > +/*
> > + * Create an svc_sock for the back channel service that shares the
> > + * fore channel connection.
> > + * Returns the input port (0) and sets the svc_serv bc_xprt on success
> > + */
> > +static int nfs41_callback_up_net(struct svc_serv *serv, struct net *net,
> > +                                struct rpc_xprt *xprt)
> >  {
> > -       /*
> > -        * Create an svc_sock for the back channel service that shares the
> > -        * fore channel connection.
> > -        * Returns the input port (0) and sets the svc_serv bc_xprt on success
> > -        */
> > -       return svc_create_xprt(serv, "tcp-bc", net, PF_INET, 0,
> > -                             SVC_SOCK_ANONYMOUS);
> > +       int ret = -EPROTONOSUPPORT;
> > +
> > +       if (xprt->bc_name)
> > +               ret = svc_create_xprt(serv, xprt->bc_name, net, PF_INET, 0,
> > +                                     SVC_SOCK_ANONYMOUS);
> > +       dprintk("NFS: svc_create_xprt(%s) returned %d\n",
> > +               xprt->bc_name, ret);
> > +       return ret;
> >  }
> >
> >  /*
> > @@ -184,7 +191,8 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
> >                 xprt->bc_serv = serv;
> >  }
> >  #else
> > -static int nfs41_callback_up_net(struct svc_serv *serv, struct net *net)
> > +static int nfs41_callback_up_net(struct svc_serv *serv, struct net *net,
> > +                                struct rpc_xprt *xprt)
> >  {
> >         return 0;
> >  }
> > @@ -259,7 +267,8 @@ static void nfs_callback_down_net(u32 minorversion, struct svc_serv *serv, struc
> >         svc_shutdown_net(serv, net);
> >  }
> >
> > -static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct net *net)
> > +static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
> > +                              struct net *net, struct rpc_xprt *xprt)
> >  {
> >         struct nfs_net *nn = net_generic(net, nfs_net_id);
> >         int ret;
> > @@ -281,7 +290,7 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct n
> >                         break;
> >                 case 1:
> >                 case 2:
> > -                       ret = nfs41_callback_up_net(serv, net);
> > +                       ret = nfs41_callback_up_net(serv, net, xprt);
> >                         break;
> >                 default:
> >                         printk(KERN_ERR "NFS: unknown callback version: %d\n",
> > @@ -364,7 +373,7 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
> >                 goto err_create;
> >         }
> >
> > -       ret = nfs_callback_up_net(minorversion, serv, net);
> > +       ret = nfs_callback_up_net(minorversion, serv, net, xprt);
> >         if (ret < 0)
> >                 goto err_net;
> >
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index 82c0839..88bae18 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -170,6 +170,7 @@ struct rpc_xprt {
> >         struct sockaddr_storage addr;           /* server address */
> >         size_t                  addrlen;        /* size of server address */
> >         int                     prot;           /* IP protocol */
> > +       char                    *bc_name;       /* backchannel transport */
> 
> Can we perhaps just replace this with a 'add_backchannel()' method in struct rpc_xprt_ops? There aren't any other users for 'bc_name' , and it needs to be a per-transport const anyway.
> 
> IOW add a per-transport method of the form:
> 
> static int xs_tcp_add_backchannel(struct svc_serv *serv, struct rpc_xprt *xprt, int flags)
> {
> return svc_create_xprt(serv, "tcp-bc", xprt->xprt_net, PF_INET, 0, flags);
> }
> 
> that can be called directly from nfs41_callback_up_net().

Makes sense, I will give that a shot.


> >         unsigned long           cong;           /* current congestion */
> >         unsigned long           cwnd;           /* congestion window */
> > diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> > index 845278e..c60bbc8 100644
> > --- a/net/sunrpc/xprtrdma/transport.c
> > +++ b/net/sunrpc/xprtrdma/transport.c
> > @@ -337,6 +337,7 @@ xprt_setup_rdma(struct xprt_create *args)
> >         /* Ensure xprt->addr holds valid server TCP (not RDMA)
> >          * address, for any side protocols which peek at it */
> >         xprt->prot = IPPROTO_TCP;
> > +       xprt->bc_name = "rdma-bc";
> >         xprt->addrlen = args->addrlen;
> >         memcpy(&xprt->addr, sap, xprt->addrlen);
> >
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 3084163..d82d00b 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -2858,6 +2858,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
> >         transport = container_of(xprt, struct sock_xprt, xprt);
> >
> >         xprt->prot = IPPROTO_TCP;
> > +       xprt->bc_name = "tcp-bc";
> >         xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
> >         xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

—
Chuck Lever



