Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:47335 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965043Ab2CTPyH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2012 11:54:07 -0400
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=iso-8859-1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4F68964A.2030602@rath.org>
Date: Tue, 20 Mar 2012 11:53:31 -0400
Cc: Rick Macklem <rmacklem@uoguelph.ca>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Message-Id: <3E60500E-4C18-47DE-824C-129345254EDA@oracle.com>
References: <716104306.1267694.1332195933869.JavaMail.root@erie.cs.uoguelph.ca> <4F688655.1090703@rath.org> <806F806A-D458-4888-9397-4B3C811F9C50@oracle.com> <4F68964A.2030602@rath.org>
To: Nikolaus Rath <Nikolaus@rath.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 20, 2012, at 10:38 AM, Nikolaus Rath wrote:

> On 03/20/2012 10:01 AM, Chuck Lever wrote:
>> 
>> 
>> Sent from my iPad
>> 
>> On Mar 20, 2012, at 9:29 AM, Nikolaus Rath <Nikolaus@rath.org> wrote:
>> 
>>> On 03/19/2012 06:25 PM, Rick Macklem wrote:
>>>> Nikolaus Rath wrote:
>>>>> On 03/19/2012 02:39 PM, J. Bruce Fields wrote:
>>>>>> On Mon, Mar 19, 2012 at 02:29:46PM -0400, Chuck Lever wrote:
>>>>>>> 
>>>>>>> On Mar 19, 2012, at 2:27 PM, J. Bruce Fields wrote:
>>>>>>> 
>>>>>>>> On Mon, Mar 19, 2012 at 01:47:14PM -0400, Chuck Lever wrote:
>>>>>>>>> 
>>>>>>>>> On Mar 19, 2012, at 1:36 PM, J. Bruce Fields wrote:
>>>>>>>>>> Well, sure, but all I'm proposing here is returning
>>>>>>>>>> NFS4ERR_INUSE in the
>>>>>>>>>> case where we get setclientid's with the same client-provided
>>>>>>>>>> id.
>>>>>>>>>> There'd be no change of behavior in the case of multiple clients
>>>>>>>>>> sharing
>>>>>>>>>> an IP (which is fine, of course).
>>>>>>>>> 
>>>>>>>>> The migration draft proposes that clients use the same
>>>>>>>>> nfs_client_id4 string for all of a server's IP addresses. Would a
>>>>>>>>> server then be obliged to return NFS4ERR_CLID_IN_USE if a client
>>>>>>>>> attempts a SETCLIENTID with the same boot verifier and
>>>>>>>>> nfs_client_id4 on more than one IP address for the same server?
>>>>>>>> 
>>>>>>>> That's also not this case, sorry, this time with all the
>>>>>>>> conditions:
>>>>>>>> 
>>>>>>>>   - if the nfs_client_id4 is the same, and
>>>>>>>>   - if the flavor is auth_sys, and
>>>>>>>>   - if the client IP address is different,
>>>>>>>>   - then return NFS4ERR_INUSE.
>>>>>>> 
>>>>>>> This still breaks for multi-homed servers and UCS clients. The
>>>>>>> client IP address can be different depending on what server IP
>>>>>>> address the client is accessing, but all the other parameters are
>>>>>>> the same.
>>>>>> 
>>>>>> OK. So probably there's nothing we can do to help here.
>>>>>> 
>>>>>> As a bandaid maybe a rate-limited log message ("clientid X now in
>>>>>> use
>>>>>> from IP Y") might help debug these things....
>>>>> 
>>>>> Since you guys keep Cc'ing me, I'll chime in with a rather naive
>>>>> suggestion: if all that's required is a unique id for every client,
>>>>> why
>>>>> not use the MAC of the first network interface, independent of it
>>>>> being
>>>>> used for communication with the server?
>>>>> 
>>>> I think this works fairly well for "real hardware", but I'm not so sure
>>>> about clients running in VMs. (I don't really know how the VMs assign
>>>> MAC addresses to their fake net interfaces and what uniqueness guarantees
>>>> those have. I remember the old freebie VMware client for Windows just
>>>> had a config file that assigned the MAC. I bet half the installations
>>>> on the planet had the same MAC as the default config file:-)
>>> 
>>> But as I understand, the clientid doesn't have to globally unique, just
>>> unique for the given NFS server.
>> 
>> Global uniqueness is required to support Transparent State Migration.
>> 
>>> I think if you have two virtual
>>> machines with the same MAC connecting to the same NFS server, you have
>>> different problems anyway.
>>> 
>>> 
>>>> ps: Also, although it's not very relevant, getting the MAC address of
>>>>   the first ethernet interface isn't easy in FreeBSD. I have no idea
>>>>   if the same is true of Linux. (I'd also be worried that "first"
>>>>   might not be fixed?)
>>> 
>>> It doesn't need to be the same interface all the time, I just meant the
>>> first as in not a specific one.
>> 
>> The nfs_client_id4 string must not change across a reboot.  Otherwise the server won't be able to figure out which open and lock state to discard when the client reboots.
> 
> But I thought that at the moment one of the client's ips is used for the
> clientid? That's certainly changes regurlarly for DHCP or multi-homed
> clients.

You are correct that using an IP address in this string is not optimal.  Obtaining some other unique identifier (say a MAC address) that won't ever change across a reboot is a difficult challenge.  Currently most client implementations do insert both the client IP and server IP address in the nfs_client_id4 string.  In fact, RFC 3530 recommends the use of IP addresses as part of this string.

However, NFSv4.1 I believe is driving the adoption of uniform client strings (that is, the nfs_client_id4 string is the same no matter what server the client talks to), and Transparent State Migration support in NFSv4.0 may well also require the use of a uniform client string.

In other words, I think the use of IP addresses in the client strings will be phased out over time.  We believe that using a MAC address is not much better than an IP address.  I've got a patch for Linux that allows administrators to insert a UUID into this string, set via a kernel boot parameter (much like the root= boot parameter).  This is optional, and can remain fixed over the life of the client system.  Aside from using the client's FQDN, a UUID is probably the best we can do.

> Best,
> 
>   -Nikolaus
> 
> -- 
> »Time flies like an arrow, fruit flies like a Banana.«
> 
>  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




