Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:39176 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754510Ab0ITTZV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 15:25:21 -0400
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
Content-Type: text/plain; charset=utf-8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4C97B00A.3030300@candelatech.com>
Date: Mon, 20 Sep 2010 15:24:31 -0400
Cc: =?utf-8?Q?Jan_R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>,
        Steve Dickson <SteveD@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-Id: <6A427AEF-1D63-4518-B7A7-39DF8261CA27@oracle.com>
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com> <20100917190413.GB21111@sith.mimuw.edu.pl> <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com> <20100917222227.GA22144@sith.mimuw.edu.pl> <DC671AB7-F3AF-4E70-B42E-4FF991D16E43@oracle.com> <20100920153157.GA20589@sith.mimuw.edu.pl> <02C38759-5236-454B-8F7B-02F9419B1532@oracle.com> <20100920164856.GA20925@sith.mimuw.edu.pl> <FC6FA83D-52D7-411A-A18F-4A143A60992E@oracle.com> <4C97B00A.3030300@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 20, 2010, at 3:03 PM, Ben Greear wrote:

> On 09/20/2010 11:53 AM, Chuck Lever wrote:
>> 
>> On Sep 20, 2010, at 12:48 PM, Jan Rękorajski wrote:
>> 
>>> On Mon, 20 Sep 2010, Chuck Lever wrote:
>>> 
>>>> 
>>>> On Sep 20, 2010, at 11:31 AM, Jan Rękorajski wrote:
>>>> 
>>>>> On Mon, 20 Sep 2010, Chuck Lever wrote:
>>>>> 
>>>>>> 
>>>>>> On Sep 17, 2010, at 6:22 PM, Jan Rękorajski wrote:
>>>>>> 
>>>>> [snip]
>>>>>>> 
>>>>>>> What about TCP then?  My patch was a by-product of trying to make '-h<IP>'
>>>>>>> also work for tcp sockets, so if we skip unbindable addresses for UDP,
>>>>>>> then will it be ok to do the same for TCP?
>>>>>> 
>>>>>> Interesting.  Now that I've actually looked at the documentation>>
>>>>>> blush<<  rpcbind(8) explicitly says that "-h" is only for UDP.  I seem
>>>>>> to recall that the legacy portmapper had a problem on multi-homed
>>>>>> hosts where a request was received on one interface, and the reply was
>>>>>> sent out another.
>>>>>> 
>>>>>> This is certainly a problem for datagram transports, but shouldn't be
>>>>>> an issue for connection-oriented transports: the reply is always sent
>>>>>> on the same connection as the request was received.
>>>>>> 
>>>>>> Can you say a little more about why do you need "-h" to work for
>>>>>> connection-oriented sockets?
>>>>> 
>>>>> I have a multihomed nfs server, and I don't want the portmapper to even
>>>>> listen on an outside interface.
>>>> 
>>>> Understood, but that is accomplished with firewalling, these days.
>>> 
>>> It always was, but it's nice not needing to worry if I closed/opened all
>>> that's neccessary.
>>> 
>>>> Usually, NFS servers are not run on the edge of private networks
>>>> unless they are serving files to public hosts.
>>> 
>>> I would, if I could :)
>>> 
>>>> None of NFS's RPC daemons allow you to set a bind address, with one
>>>> exception.  rpc.statd allows one to specify a "bind address" in the
>>>> form of a host name for reasons specific to the NSM protocol.
>>> 
>>> I may be wrong here, but maybe it's because it was always portmapper
>>> doing the binding, so if portmapper couldn't then no one thought of
>>> adding this to RPC daemons.
>> 
>> If rpc.mountd is running on a host, and rpcbind is not, it doesn't matter.  A port scanner can still find and attack the open mountd port.  The best and safest approach, IMO, is to use a firewall, and then test it with a remote port scanner service.  Our rpcbind implementation has tcp_wrapper already built in, for instance, but I use the iptables firewall in Fedora 13 (and, I keep RPC services on hosts inside the firewall, not on the firewall itself).
> 
> This is true, but if the argument against adding support to various components is
> always 'no, because the others don't support it', then we are never going
> to make progress in this direction!

I'm merely observing that none of the others support this, and have never supported it.  To add support for listener binding properly, we will need to do it across the board.  But I don't think the case has been made that adding the ability to bind to a specific listener address is exactly what is needed here.

The reason that these other RPC services do not support this today is because before rpcbind, it was not possible for the portmapper to direct RPC clients to specific interfaces. The new rpcbind itself adds that support via universal addresses.

However, it was decided a while ago that Linux wouldn't allow our kernel services to bind to anything but ANYADDR.  So they all register as ANYADDR:port.  rpcbind's ability to advertise a specific address was regarded as somehow insecure.

The Linux NFS implementation is a mix of kernel and user space services.  It will take some understanding to see if and how the kernel NFS services will work together with multiple instances of user space services.  I personally regard that as a difficult problem.

>> If we want to add this feature properly, we will have to change a broad range of user space components.  Therefore it will be a non-trivial undertaking.
>> 
>> For one thing, there appears to be more than one virtualization suite available for Linux (containers, kvm, and so on).  If our NFS infrastructure (both client and server) is to be adapted for lightweight virtualization then I think we need a clear idea of how networking (host naming, interface assignment, routing, and so on) is going to work in these environments.
>> 
>> Just so you (and Ben) know, I intended to add support during the recent rpc.statd rewrite for multiple hostnames and multiple interfaces, exactly for the purpose of having our NLM and NSM implementations support container-like virtualization.  This idea was NACK'd.
> 
> I'm sorry to hear it was NACK'd, but even if so, I think it's not a reason to
> reject other changes that start adding support for binding to IPs.

I don't have the authority to reject anything.  I'm simply explaining the history, and requesting that we slow down and think about some of the details.

If we regard binding to specific listener addresses as a good way to proceed, I think we have an architecturally complex task ahead of us.  Having a common agreed-upon vision in front of us is important to getting the details right.  I don't think we should just start hacking this stuff in while the NFS community and its reviewers don't have a clear vision about what is going to happen eventually.

-- 
chuck[dot]lever[at]oracle[dot]com




