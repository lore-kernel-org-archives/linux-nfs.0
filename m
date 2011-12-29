Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:43996 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113Ab1L2QEK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Dec 2011 11:04:10 -0500
Subject: Re: [RFC] RPCBIND: add anonymous listening socket in addition to named one
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=utf-8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4EFC5391.7000601@parallels.com>
Date: Thu, 29 Dec 2011 11:03:25 -0500
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <5E291DB3-7FB3-4108-B254-B59780C64346@oracle.com>
References: <4EFB330A.7070908@parallels.com> <2221B6F7-574A-4CEF-B19F-600932024DEE@oracle.com> <4EFB521B.7060004@parallels.com> <406C7E87-0CCB-4034-8FD8-1602F7DCDBD6@oracle.com> <4EFC5391.7000601@parallels.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 29, 2011, at 6:48 AM, Stanislav Kinsbursky wrote:

> 28.12.2011 21:59, Chuck Lever пишет:
>> 
>> On Dec 28, 2011, at 12:30 PM, Stanislav Kinsbursky wrote:
>> 
>>> 28.12.2011 21:03, Chuck Lever пишет:
>>>> 
>>>> On Dec 28, 2011, at 10:17 AM, Stanislav Kinsbursky wrote:
>>>> 
>>>>> Hello.
>>>>> I've experienced a problem with registering Lockd service with rpcbind in container. My container operates in it's own network namespace context and has it's own root. But on service register, kernel tries to connect to named unix socket by using rpciod_workqueue. Thus any connect is done with the same fs->root, and this leads to that kernel socket, used for registering service with local portmapper, will always connect to the same user-space socket regardless to fs->root of process, requested register operation.
>>>>> Possible solution for this problem, which I would like to discuss, is to add one more listening socket to rpcbind process. But this one should be anonymous. Anonymous unix sockets accept connections only within it's network namespace context, so kernel socket connect will be done always to the user-space socket in the same network namespace.
>>>> 
>>>> A UNIX socket is used so that rpcbind can record the identity of the process on the other end of the socket.  That way only that user may unregister this service.  That user is known as the registration's "owner."  Whatever solution is chosen, I believe we need to preserve the registration owner functionality.
>>>> 
>>> 
>>> Sorry, but I don't get get it.
>>> What do you mean by "user" and "identity"?
>> 
>> When an RPC application registers itself with the local rpcbind daemon, it does so with an AF_UNIX socket.  rpcbind scrapes the UID of the RPC application process off the other end of the socket, and records that UID with the new registration.  For example:
>> 
>> [cel@forain ~]$ rpcinfo
>>    program version netid     address                service    owner
>>     100000    4    tcp6      ::.0.111               portmapper superuser
>>     100000    3    tcp6      ::.0.111               portmapper superuser
>>     100000    4    udp6      ::.0.111               portmapper superuser
>>     100000    3    udp6      ::.0.111               portmapper superuser
>>     100000    4    tcp       0.0.0.0.0.111          portmapper superuser
>>     100000    3    tcp       0.0.0.0.0.111          portmapper superuser
>>     100000    2    tcp       0.0.0.0.0.111          portmapper superuser
>>     100000    4    udp       0.0.0.0.0.111          portmapper superuser
>>     100000    3    udp       0.0.0.0.0.111          portmapper superuser
>>     100000    2    udp       0.0.0.0.0.111          portmapper superuser
>>     100000    4    local     /var/run/rpcbind.sock  portmapper superuser
>>     100000    3    local     /var/run/rpcbind.sock  portmapper superuser
>>     100024    1    udp       0.0.0.0.149.137        status     29
>>     100024    1    tcp       0.0.0.0.152.179        status     29
>>     100024    1    udp6      ::.148.0               status     29
>>     100024    1    tcp6      ::.217.71              status     29
>> [cel@forain ~]$
>> 
>> The last column is the "owner."  That's the UID of the process that performed the registration.  Only processes running under that UID may unregister that service.
>> 
>> This doesn't work for registrations that were performed via a network interface (like lo).  It only works when an application uses the AF_UNIX socket.
>> 
>> The point of this is to prevent other users from replacing a registration.  Now any user can register an RPC service and be sure that it won't be stomped on by some other user.
>> 
>> Whatever solution to your problem you find, it must preserve this behavior.  Will using an anonymous socket allow rpcbind to discover the UID of the registering process?
>> 
> 
> First of all, thanks for detailed explanation.
> And the answer is yes - anonymous socket will allow rpcbind to discover the UID of the registering process.
> At least I don't see any differences in this place between named and anonymous socket (unix_listen and unix_stream_connect).
> 
>> 
>> A TCP socket has two endpoints.  The source address and port for the local endpoint is chosen when the socket is bound.  The destination address and port for the remote endpoint is chosen when the socket is connected.
>> 
>> RPC client consumers, such as lockd, the NFS client, or the MNT client, have to make outbound TCP connections to other hosts.  In user space, RPC TCP sockets use the IP address of the current network namespace as their source address.
>> 
>> If the kernel RPC client makes a TCP connection to another host, how is the TCP socket's source address determined? If the answer is that kernel_bind() chooses this source address, and that kernel_bind() call is performed in the rpciod connect worker, then the source address is always chosen in the root network namespace (unless the rpciod connect worker is namespace aware).
>> 
> 
> This address to bind to is taken from transport, which is set on RPC client creation (which is created in sync mode). So, no problem here, I hope.
> 
>>> I little bit more info about the whole "NFS in container" structure (as I see it):
>>> 1) Each container operates in it's own network namespace and has it's own root.
>>> 2) Each contatiner has it's own network device(s) and IP address(es).
>> 
>> Right.  As above, I assumed the IP address of the current network namespace is used as the source address on outbound TCP connections.  That would mean that the rpciod work queue that handles such connections would have to be network namespace aware.
>> 
> 
> And it is. IOW, rpciod_workqueue just handles rpc_tasks as is.
> 
>> If it is, why isn't this also enough for RPC over AF_UNIX sockets?  The network namespace in effect when the kernel performs the connect should determine which rpcbind is listening on the other end of the AF_UNIX socket in your local network namespace, unless I've misunderstood your problem.
>> 
> 
> Because unix named (!) sockets are not network namespace aware.

OK, this is the part I was unaware of.  Bruce and I had talked about this a few months ago, and my take-away was that these sockets were network namespace-aware, such that this was supposed to work as we want, already.

> They are "current->fs->root" aware.

In other words, these are relative to the local file namespace, not the local network namespace.  I was afraid of that.

> I.e. if this connect operation would be performed on "sync mode" (i.e. from the context of mount of NFS server start operation), then all will works fine (in case of each container works in it's own root, of course).
> But currently all connect operations are done by rpciod_workqueue. I.e. regardless to root of process, started service registration, unix socket will be always looked up by path "/var/run/rpcbind.sock" starting from rpciod_workqueue root. I can set desired root before kernel connect during handling RPC task by rpciod_workqueue and revert back to the old one after connection and this will solve the problem to.
> But this approach looks like ugly hack to me. And also requires additional pointer in sock_xprt structure to bypass desired context to rpciod_workqueue handler.

Can several network namespaces share the same file namespace?  That might cause them to share the same rpcbind, which is undesirable.  Might this also be a problem for user space?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




