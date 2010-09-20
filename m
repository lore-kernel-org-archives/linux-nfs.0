Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:16444 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756894Ab0ITQWv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:22:51 -0400
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
Content-Type: text/plain; charset=utf-8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100920153157.GA20589@sith.mimuw.edu.pl>
Date: Mon, 20 Sep 2010 12:21:45 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Message-Id: <02C38759-5236-454B-8F7B-02F9419B1532@oracle.com>
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com> <20100917190413.GB21111@sith.mimuw.edu.pl> <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com> <20100917222227.GA22144@sith.mimuw.edu.pl> <DC671AB7-F3AF-4E70-B42E-4FF991D16E43@oracle.com> <20100920153157.GA20589@sith.mimuw.edu.pl>
To: =?utf-8?Q?Jan_R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 20, 2010, at 11:31 AM, Jan Rękorajski wrote:

> On Mon, 20 Sep 2010, Chuck Lever wrote:
> 
>> 
>> On Sep 17, 2010, at 6:22 PM, Jan Rękorajski wrote:
>> 
> [snip]
>>> 
>>> What about TCP then?  My patch was a by-product of trying to make '-h <IP>'
>>> also work for tcp sockets, so if we skip unbindable addresses for UDP,
>>> then will it be ok to do the same for TCP?
>> 
>> Interesting.  Now that I've actually looked at the documentation >>
>> blush << rpcbind(8) explicitly says that "-h" is only for UDP.  I seem
>> to recall that the legacy portmapper had a problem on multi-homed
>> hosts where a request was received on one interface, and the reply was
>> sent out another.
>> 
>> This is certainly a problem for datagram transports, but shouldn't be
>> an issue for connection-oriented transports: the reply is always sent
>> on the same connection as the request was received.
>> 
>> Can you say a little more about why do you need "-h" to work for
>> connection-oriented sockets?
> 
> I have a multihomed nfs server, and I don't want the portmapper to even
> listen on an outside interface.

Understood, but that is accomplished with firewalling, these days.  Usually, NFS servers are not run on the edge of private networks unless they are serving files to public hosts.

None of NFS's RPC daemons allow you to set a bind address, with one exception.  rpc.statd allows one to specify a "bind address" in the form of a host name for reasons specific to the NSM protocol.

If this is NFSv4 only, ostensibly rpcbind is not needed.  I know our implementation today still clings to rpcbind a bit, but theoretically at least, you could just leave it unstarted if you are only running an NFSv4 service.  rpc.mountd should also allow itself to be run without starting network listeners in recent versions of nfs-utils.

I'm not necessarily arguing against the idea of adding a bind address command line option, but this _would_ be a change to long established historical behavior, and it would not be consistent with many of the other Linux RPC services I'm aware of.  So, I'd like to be absolutely sure we understand what you need here, and ensure we can't address it with existing administrative controls.

> Second thing is a host for vservers
> (http://linux-vserver.org), I need to run portmapper in guests but
> rpcbind listening on INADDR_ANY is not letting me.

Can you say more?  Maybe it's a bug.

> And finally it's good
> to be consistent, it's strange to me that someone may want to limit only
> the UDP part of portmapper (modulo network issues you mentioned).

"-h" was added to address an issue specific to Linux UDP sockets.  It's not a feature, but a bug fix that is UDP-specific.  TCP doesn't need this bug fix.

-- 
chuck[dot]lever[at]oracle[dot]com




