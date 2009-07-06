From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind registrations.
Date: Mon, 6 Jul 2009 13:51:47 -0400
Message-ID: <71D4E90D-471B-4BFA-B47C-6A5BFD0754E9@oracle.com>
References: <20090528062730.15937.70579.stgit@notabene.brown> <20090528063303.15937.62423.stgit@notabene.brown> <A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com> <18992.35996.986951.556723@notabene.brown> <A51FBC9A-6B56-4DF3-A657-D1E6508F8FEE@oracle.com> <E4516F53-E0D1-494D-A62C-1035D3A8F1FB@oracle.com> <4A51F125.5080709@suse.de> <A8A87823-B37B-43ED-82A1-5A822C9C880C@oracle.com> <4A52217E.9050207@suse.de> <4E8F91E6-4E55-44BB-889B-DDB9910129BF@oracle.com> <1246898450.11267.12.camel@heimdal.trondhjem.org> <68129579-E484-4E7E-B38D-4E14ED5A5B1D@oracle.com> <1246900456.11267.34.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Neil Brown <neilb@suse.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:20544 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329AbZGFRvx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2009 13:51:53 -0400
In-Reply-To: <1246900456.11267.34.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul 6, 2009, at 1:14 PM, Trond Myklebust wrote:
> On Mon, 2009-07-06 at 12:57 -0400, Chuck Lever wrote:
>> On Jul 6, 2009, at 12:40 PM, Trond Myklebust wrote:
>>> On Mon, 2009-07-06 at 12:31 -0400, Chuck Lever wrote:
>>>> I have considered that.  AF_LOCAL in fact could replace all of our
>>>> upcall mechanisms.  However, portmapper, which doesn't support
>>>> AF_LOCAL, is still used in some distributions.
>>>
>>> As could AF_NETLINK, fork(), pipes, fifos, etc... Again: why would  
>>> we
>>> want to saddle ourselves with rpc over AF_LOCAL?
>>
>> TI-RPC supports AF_LOCAL RPC transports.
>>
>> [cel@matisse notify-one]$ rpcinfo
>>    program version netid     address                service    owner
>>     100000    4    tcp6      ::.0.111               portmapper
>> superuser
>>     100000    3    tcp6      ::.0.111               portmapper
>> superuser
>>     100000    4    udp6      ::.0.111               portmapper
>> superuser
>>     100000    3    udp6      ::.0.111               portmapper
>> superuser
>>     100000    4    tcp       0.0.0.0.0.111          portmapper
>> superuser
>>     100000    3    tcp       0.0.0.0.0.111          portmapper
>> superuser
>>     100000    2    tcp       0.0.0.0.0.111          portmapper
>> superuser
>>     100000    4    udp       0.0.0.0.0.111          portmapper
>> superuser
>>     100000    3    udp       0.0.0.0.0.111          portmapper
>> superuser
>>     100000    2    udp       0.0.0.0.0.111          portmapper
>> superuser
>>     100000    4    local     /var/run/rpcbind.sock  portmapper
>> superuser
>>     100000    3    local     /var/run/rpcbind.sock  portmapper
>> superuser
>>     100024    1    udp       0.0.0.0.206.127        status     29
>>     100024    1    tcp       0.0.0.0.166.105        status     29
>>     100024    1    udp6      ::.141.238             status     29
>>     100024    1    tcp6      ::.192.160             status     29
>> [cel@matisse notify-one]$
>>
>> The listing for '/var/run/rpcbind.sock' is rpcbind's AF_LOCAL
>> listener.  TI-RPC's rpcb_foo() calls use this method of accessing the
>> rpcbind database rather than going over loopback.
>>
>> rpcbind scrapes the caller's effective UID off the transport socket
>> and uses that for authentication.  Note the "owner" column... that
>> comes from the socket's UID, not from the r_owner field.  When a
>> service is registered over the network, the owner column says
>> "unknown" and basically anyone can unset it.
>>
>> If the kernel used AF_LOCAL to register its services, it would mean  
>> we
>> would never use a network port for local rpcbind calls between the
>> kernel and rpcbind, and rpcbind could automatically prevent the
>> kernel's RPC services from getting unset by malicious users.  If / 
>> var/
>> run/rpcbind.sock isn't there, the kernel would know immediately that
>> rpcbind wasn't running.
>
> So what? You can achieve the same with any number of communication
> channels (including the network). Just add a timeout to the current
> 'connect()' function, and set it to a low value when doing rpcbind
> upcalls.

I suggested such a scheme last year when we first discussed connected  
UDP, and it was decided that especially short timeouts for local  
rpcbind calls were not appropriate.

In general, however, the network layer does tell us immediately when  
the service is not running (ICMP port unreachable or RST).  The  
kernel's RPC client is basically ignoring that information.

> What's so special about libtirpc or rpcbind that we have to keep
> redesigning the kernel to work around their limitations instead of the
> other way round?

I'm not sure what you're referring to, in specific.

However, since rpcbind is a standard network protocol, the kernel  
really does have to talk the protocol correctly if we want to  
interoperate with non-Linux implementations.  For local-only cases, we  
need to ensure that the kernel is backwards compatible with portmapper.

In this case, Suresh and Neil are dealing with a problem that occurs  
whether rpcbind or portmapper is running -- basically during shutdown,  
if user space has killed those processes, the kernel waits for a bit  
instead of deciding immediately that it should exit.  Nothing to do  
with TI-RPC, though TI-RPC does offer a potential solution (AF_LOCAL).

In the mount.nfs case, user space uses RST/port unreachable  
specifically for determining when the server does not support a  
particular transport (see nfs_probe_port).  That code is actually  
baked into the mount command, it's not part of the library.  If we  
want to see version/transport negotiation in the kernel, then the  
kernel rpcbind client has to have the ability to detect quickly when  
the remote does not support the requested transport.  Again, nothing  
to do with TI-RPC.

In both cases, it turns out that the library implementations in user  
space already fail quickly.  RPC_CANTRECV is returned if an attempt is  
made to send an rpcbind query to an inactive UDP port.   
RPC_SYSTEMERROR/ECONNREFUSED is returned if an attempt is made to send  
an rpcbind query to an inactive TCP port.  In my view, the kernel is  
lacking here, and should be made to emulate user space more closely.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
