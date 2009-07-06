From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind
 registrations.
Date: Mon, 06 Jul 2009 13:14:16 -0400
Message-ID: <1246900456.11267.34.camel@heimdal.trondhjem.org>
References: <20090528062730.15937.70579.stgit@notabene.brown>
	 <20090528063303.15937.62423.stgit@notabene.brown>
	 <A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com>
	 <18992.35996.986951.556723@notabene.brown>
	 <A51FBC9A-6B56-4DF3-A657-D1E6508F8FEE@oracle.com>
	 <E4516F53-E0D1-494D-A62C-1035D3A8F1FB@oracle.com>
	 <4A51F125.5080709@suse.de>
	 <A8A87823-B37B-43ED-82A1-5A822C9C880C@oracle.com>
	 <4A52217E.9050207@suse.de>
	 <4E8F91E6-4E55-44BB-889B-DDB9910129BF@oracle.com>
	 <1246898450.11267.12.camel@heimdal.trondhjem.org>
	 <68129579-E484-4E7E-B38D-4E14ED5A5B1D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Neil Brown <neilb@suse.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61645 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbZGFROc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jul 2009 13:14:32 -0400
In-Reply-To: <68129579-E484-4E7E-B38D-4E14ED5A5B1D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-07-06 at 12:57 -0400, Chuck Lever wrote:
> On Jul 6, 2009, at 12:40 PM, Trond Myklebust wrote:
> > On Mon, 2009-07-06 at 12:31 -0400, Chuck Lever wrote:
> >> I have considered that.  AF_LOCAL in fact could replace all of our
> >> upcall mechanisms.  However, portmapper, which doesn't support
> >> AF_LOCAL, is still used in some distributions.
> >
> > As could AF_NETLINK, fork(), pipes, fifos, etc... Again: why would we
> > want to saddle ourselves with rpc over AF_LOCAL?
> 
> TI-RPC supports AF_LOCAL RPC transports.
> 
> [cel@matisse notify-one]$ rpcinfo
>     program version netid     address                service    owner
>      100000    4    tcp6      ::.0.111               portmapper  
> superuser
>      100000    3    tcp6      ::.0.111               portmapper  
> superuser
>      100000    4    udp6      ::.0.111               portmapper  
> superuser
>      100000    3    udp6      ::.0.111               portmapper  
> superuser
>      100000    4    tcp       0.0.0.0.0.111          portmapper  
> superuser
>      100000    3    tcp       0.0.0.0.0.111          portmapper  
> superuser
>      100000    2    tcp       0.0.0.0.0.111          portmapper  
> superuser
>      100000    4    udp       0.0.0.0.0.111          portmapper  
> superuser
>      100000    3    udp       0.0.0.0.0.111          portmapper  
> superuser
>      100000    2    udp       0.0.0.0.0.111          portmapper  
> superuser
>      100000    4    local     /var/run/rpcbind.sock  portmapper  
> superuser
>      100000    3    local     /var/run/rpcbind.sock  portmapper  
> superuser
>      100024    1    udp       0.0.0.0.206.127        status     29
>      100024    1    tcp       0.0.0.0.166.105        status     29
>      100024    1    udp6      ::.141.238             status     29
>      100024    1    tcp6      ::.192.160             status     29
> [cel@matisse notify-one]$
> 
> The listing for '/var/run/rpcbind.sock' is rpcbind's AF_LOCAL  
> listener.  TI-RPC's rpcb_foo() calls use this method of accessing the  
> rpcbind database rather than going over loopback.
> 
> rpcbind scrapes the caller's effective UID off the transport socket  
> and uses that for authentication.  Note the "owner" column... that  
> comes from the socket's UID, not from the r_owner field.  When a  
> service is registered over the network, the owner column says  
> "unknown" and basically anyone can unset it.
> 
> If the kernel used AF_LOCAL to register its services, it would mean we  
> would never use a network port for local rpcbind calls between the  
> kernel and rpcbind, and rpcbind could automatically prevent the  
> kernel's RPC services from getting unset by malicious users.  If /var/ 
> run/rpcbind.sock isn't there, the kernel would know immediately that  
> rpcbind wasn't running.

So what? You can achieve the same with any number of communication
channels (including the network). Just add a timeout to the current
'connect()' function, and set it to a low value when doing rpcbind
upcalls.

What's so special about libtirpc or rpcbind that we have to keep
redesigning the kernel to work around their limitations instead of the
other way round?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
