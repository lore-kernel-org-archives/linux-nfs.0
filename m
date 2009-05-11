From: Frans Pop <elendil@planet.nl>
Subject: Re: svc: failed to register lockdv1 RPC service (errno 97).
Date: Mon, 11 May 2009 16:39:42 +0200
Message-ID: <200905111639.43636.elendil@planet.nl>
References: <200905110248.48695.elendil@planet.nl> <8054CA42-CAFC-4DFC-A3A9-107AF29284EE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8054CA42-CAFC-4DFC-A3A9-107AF29284EE@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 11 May 2009, you wrote:
> On May 10, 2009, at 8:48 PM, Frans Pop wrote:
> > After switching from 2.6.29.2 to 2.6.30-rc5 I get this new message
> > during boot of my home server:
> >   svc: failed to register lockdv1 RPC service (errno 97).
>
> Is this the only instance of this message, or do you see it several
> times?

It's the only one.

> > This looks to be the result of the following commit:
> > commit 363f724cdd3d2ae554e261be995abdeb15f7bdd9
> > Author: Chuck Lever <chuck.lever@oracle.com>
> >    SUNRPC: rpcb_register() should handle errors silently
> >    Move error reporting for RPC registration to rpcb_register's
> > caller.
> >
> > Question is: do I really want to know this? I assume the "failure"
> > happened with previous kernels too, but silently.
>
> The point of that commit was to report errors _less_ frequently.

:-)

> The server-side RPC code is attempting to be more automatic about
> which address families are supported by kernel NFS services.  This
> message tells us that some particular case is not handled yet.  I
> suspect you weren't seeing this error in the past at all.

Correct. Neither this exact error, nor anything remotely similar.

> Can you report more about your server configuration?  What
> distribution is this?

Debian stable (Lenny).
nfs-common and nfs-kernel-server (1.1.2)

I'm using nfs4. rpc.statd is not running; rpc.mountd and rpc.idmapd are.

> Does user space have portmapper or rpcbind? 

portmap (6.0)

> Are you blacklisting ipv6.ko?

No, the server has IPv6 enabled.
I'm using NFS mainly from my laptop though, which does not have an IPv6 
address for my home network.

> What's the output of "rpcinfo" on your server after it has started NFSD?

I guess you mean the -p option?

$ rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100021    1   udp  47955  nlockmgr
    100021    3   udp  47955  nlockmgr
    100021    4   udp  47955  nlockmgr
    100021    1   tcp  41860  nlockmgr
    100021    3   tcp  41860  nlockmgr
    100021    4   tcp  41860  nlockmgr
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100005    1   udp  40032  mountd
    100005    1   tcp  40623  mountd
    100005    2   udp  40032  mountd
    100005    2   tcp  40623  mountd
    100005    3   udp  40032  mountd
    100005    3   tcp  40623  mountd
    391002    2   tcp    792  sgi_fam

Cheers,
FJP
