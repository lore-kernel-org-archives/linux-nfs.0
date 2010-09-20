Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49759 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756862Ab0ITQeO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:34:14 -0400
Message-ID: <4C978CEE.7090503@candelatech.com>
Date: Mon, 20 Sep 2010 09:33:50 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: =?UTF-8?B?SmFuIFLEmWtvcmFqc2tp?= <baggins@sith.mimuw.edu.pl>,
        Steve Dickson <SteveD@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com> <20100917190413.GB21111@sith.mimuw.edu.pl> <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com> <20100917222227.GA22144@sith.mimuw.edu.pl> <DC671AB7-F3AF-4E70-B42E-4FF991D16E43@oracle.com> <20100920153157.GA20589@sith.mimuw.edu.pl> <02C38759-5236-454B-8F7B-02F9419B1532@oracle.com>
In-Reply-To: <02C38759-5236-454B-8F7B-02F9419B1532@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/20/2010 09:21 AM, Chuck Lever wrote:
>
> On Sep 20, 2010, at 11:31 AM, Jan Rękorajski wrote:
>
>> On Mon, 20 Sep 2010, Chuck Lever wrote:
>>
>>>
>>> On Sep 17, 2010, at 6:22 PM, Jan Rękorajski wrote:
>>>
>> [snip]
>>>>
>>>> What about TCP then?  My patch was a by-product of trying to make '-h<IP>'
>>>> also work for tcp sockets, so if we skip unbindable addresses for UDP,
>>>> then will it be ok to do the same for TCP?
>>>
>>> Interesting.  Now that I've actually looked at the documentation>>
>>> blush<<  rpcbind(8) explicitly says that "-h" is only for UDP.  I seem
>>> to recall that the legacy portmapper had a problem on multi-homed
>>> hosts where a request was received on one interface, and the reply was
>>> sent out another.
>>>
>>> This is certainly a problem for datagram transports, but shouldn't be
>>> an issue for connection-oriented transports: the reply is always sent
>>> on the same connection as the request was received.
>>>
>>> Can you say a little more about why do you need "-h" to work for
>>> connection-oriented sockets?
>>
>> I have a multihomed nfs server, and I don't want the portmapper to even
>> listen on an outside interface.
>
> Understood, but that is accomplished with firewalling, these days.  Usually, NFS servers are not run on the edge of private networks unless they are serving files to public hosts.
>
> None of NFS's RPC daemons allow you to set a bind address, with one exception.  rpc.statd allows one to specify a "bind address" in the form of a host name for reasons specific to the NSM protocol.

Simply not listening to an IP may be more convenient (and perform better)
than setting up firewalls.

Binding also allows one to specify which interface to use if you have
two interfaces on the same subnet.

I posted a patch a week or two ago that allowed the kernel components
to bind to specific IPs.  I'm glad to see I'm not the only one interested
in this, and hopefully we can start making all parts of NFS able to bind
to specific IPs when requested.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

