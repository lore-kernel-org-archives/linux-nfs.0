Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26042 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869Ab0IULz2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 07:55:28 -0400
Message-ID: <4C989D23.6030309@RedHat.com>
Date: Tue, 21 Sep 2010 07:55:15 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: =?UTF-8?B?SmFuIFLEmWtvcmFqc2tp?= <baggins@sith.mimuw.edu.pl>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
References: <20100917181251.GA21111@sith.mimuw.edu.pl> <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com> <20100917190413.GB21111@sith.mimuw.edu.pl> <DA851F94-8AFB-448D-B48D-BC4ACAD8F395@oracle.com> <20100917222227.GA22144@sith.mimuw.edu.pl> <DC671AB7-F3AF-4E70-B42E-4FF991D16E43@oracle.com> <20100920153157.GA20589@sith.mimuw.edu.pl> <02C38759-5236-454B-8F7B-02F9419B1532@oracle.com> <20100920164856.GA20925@sith.mimuw.edu.pl> <FC6FA83D-52D7-411A-A18F-4A143A60992E@oracle.com>
In-Reply-To: <FC6FA83D-52D7-411A-A18F-4A143A60992E@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/20/2010 02:53 PM, Chuck Lever wrote:
> 
> On Sep 20, 2010, at 12:48 PM, Jan Rękorajski wrote:
> 
>> On Mon, 20 Sep 2010, Chuck Lever wrote:
>>
>>>
>>> On Sep 20, 2010, at 11:31 AM, Jan Rękorajski wrote:
>>>
>>>> On Mon, 20 Sep 2010, Chuck Lever wrote:
>>>>
>>>>>
>>>>> On Sep 17, 2010, at 6:22 PM, Jan Rękorajski wrote:
>>>>>
>>>> [snip]
>>>>>>
>>>>>> What about TCP then?  My patch was a by-product of trying to make '-h <IP>'
>>>>>> also work for tcp sockets, so if we skip unbindable addresses for UDP,
>>>>>> then will it be ok to do the same for TCP?
>>>>>
>>>>> Interesting.  Now that I've actually looked at the documentation >>
>>>>> blush << rpcbind(8) explicitly says that "-h" is only for UDP.  I seem
>>>>> to recall that the legacy portmapper had a problem on multi-homed
>>>>> hosts where a request was received on one interface, and the reply was
>>>>> sent out another.
>>>>>
>>>>> This is certainly a problem for datagram transports, but shouldn't be
>>>>> an issue for connection-oriented transports: the reply is always sent
>>>>> on the same connection as the request was received.
>>>>>
>>>>> Can you say a little more about why do you need "-h" to work for
>>>>> connection-oriented sockets?
>>>>
>>>> I have a multihomed nfs server, and I don't want the portmapper to even
>>>> listen on an outside interface.
>>>
>>> Understood, but that is accomplished with firewalling, these days.
>>
>> It always was, but it's nice not needing to worry if I closed/opened all
>> that's neccessary.
>>
>>> Usually, NFS servers are not run on the edge of private networks
>>> unless they are serving files to public hosts.
>>
>> I would, if I could :)
>>
>>> None of NFS's RPC daemons allow you to set a bind address, with one
>>> exception.  rpc.statd allows one to specify a "bind address" in the
>>> form of a host name for reasons specific to the NSM protocol.
>>
>> I may be wrong here, but maybe it's because it was always portmapper
>> doing the binding, so if portmapper couldn't then no one thought of
>> adding this to RPC daemons.
> 
> If rpc.mountd is running on a host, and rpcbind is not, it doesn't matter.  A port scanner can still find and attack the open mountd port.  The best and safest approach, IMO, is to use a firewall, and then test it with a remote port scanner service.  Our rpcbind implementation has tcp_wrapper already built in, for instance, but I use the iptables firewall in Fedora 13 (and, I keep RPC services on hosts inside the firewall, not on the firewall itself).
> 
> [ ... snipped ... ]
> 
>>>> Second thing is a host for vservers
>>>> (http://linux-vserver.org), I need to run portmapper in guests but
>>>> rpcbind listening on INADDR_ANY is not letting me.
>>>
>>> Can you say more?  Maybe it's a bug.
>>
>> It's more of a design flaw, vserver is an isolation techique, and if I
>> bind to some port on INADDR_ANY on host then I can't bind to that
>> port on guests. I don't know the implementation details, but network
>> interfaces other than lo are not (maybe can't be) isolated enough.
> 
> The problem is the guest listeners get EADDRINUSE, or equivalent, since they are sharing a network namespace with the host?
> 
>>>> And finally it's good
>>>> to be consistent, it's strange to me that someone may want to limit only
>>>> the UDP part of portmapper (modulo network issues you mentioned).
>>>
>>> "-h" was added to address an issue specific to Linux UDP sockets.
>>> It's not a feature, but a bug fix that is UDP-specific.  TCP doesn't
>>> need this bug fix.
>>
>> Of course, but why not change a bugfix into a feature?
> 
> If we want to add this feature properly, we will have to change a broad range of user space components.  Therefore it will be a non-trivial undertaking.
> 
> For one thing, there appears to be more than one virtualization suite available for Linux (containers, kvm, and so on).  If our NFS infrastructure (both client and server) is to be adapted for lightweight virtualization then I think we need a clear idea of how networking (host naming, interface assignment, routing, and so on) is going to work in these environments.
> 
> Just so you (and Ben) know, I intended to add support during the recent rpc.statd rewrite for multiple hostnames and multiple interfaces, exactly for the purpose of having our NLM and NSM implementations support container-like virtualization.  This idea was NACK'd.
> 
Would you mind gigging out and  post the pointer to the discussion 
where your you are talking about... Just to refresh us as to the 
ins and outs as to why it got NACKed...  Because I do agree we
has to become much more virt friendly since virtualization
is the future....  So with this perspective, maybe we should take
another look at your patches... 

steved.

