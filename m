Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:52308 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562Ab0DAVKD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 17:10:03 -0400
Message-ID: <4BB50B60.2080009@oracle.com>
Date: Thu, 01 Apr 2010 17:08:48 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/11] lockd: Allow mount option to specify caller_name
References: <20100401183724.6395.60353.stgit@localhost.localdomain>	 <20100401190400.6395.52787.stgit@localhost.localdomain>	 <1270151136.13329.8.camel@localhost.localdomain> <1270152061.13329.15.camel@localhost.localdomain>
In-Reply-To: <1270152061.13329.15.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/01/2010 04:01 PM, Trond Myklebust wrote:
> On Thu, 2010-04-01 at 15:45 -0400, Trond Myklebust wrote:
>> On Thu, 2010-04-01 at 15:04 -0400, Chuck Lever wrote:
>>> NLMPROC_LOCK requests have a "caller_name" argument which is supposed
>>> to contain the hostname the server uses to call the client back.
>>> Linux simply stuffs the system's utsname in this field, but this is
>>> not always the correct choice.  For example:
>>>
>>>    o  If an unqualified hostname is used for the client's utsname,
>>>       it could be ambiguous when the server tries to resolve it
>>>    o  If the client's actual hostname is determined by DHCP, it may
>>>       not match its utsname
>>>    o  If the NFS mount was done in a network namespace, the namespace
>>>       name won't match the client's utsname
>>>    o  If the client has multiple network interfaces, it should provide
>>>       a hostname that matches the source address used to contact the
>>>       server
>>>
>>> In all of these cases, user space can determine the correct value of
>>> the caller_name argument at mount time.
>>>
>>> So, add a mount option that allows user space to specify the value of
>>> the caller_name argument of NLMPROC_LOCK requests.  If not specified,
>>> the kernel continues to use the init utsname, as before.
>>
>> This argument makes no sense. Mount points do _not_ follow network
>> namespace boundaries, so making this hostname of yours a mount option
>> will make matters worse, not better.

Um, "this hostname of yours" is snide and unnecessary.  It's the 
caller_name string, and it's been an argument of NLMPROC_LOCK and used 
for lock recovery ever since NFSv2 was invented.  Let's keep it civil, 
please.

So, ignore the network namespace example, then, and consider the 
majority of the examples above.

The server's statd stores the client's caller_name string on the monitor 
list, and uses it as part of a heuristic to match incoming SM_NOTIFY 
requests.  If we send an accurate caller_name string in our NLMPROC_LOCK 
requests, there's a better chance that the remote statd will recognize 
us when we reboot.  Refer to Talpey's Cthon slides or _NFS_Illustrated_ 
for visual aids.

This applies to three of the four examples I provided above:

1)  It's been a best practice for a long time to ensure that your Linux 
client's nodename (ie its utsname) matches it's fully-qualified domain 
name, and for exactly this purpose (see NetApp TR-3183).  With this 
mount option, the correct caller_name can be determined automatically.

What happens if the client's utsname is unqualified, and then it 
contacts a server that is already talking to a client with the same 
unqualified hostname in a different domain?  The result is that the 
server will have to choose between these two clients when one of them 
reboots.

2)  If a client's address is assigned automatically, it won't 
necessarily match its utsname.  That's true of my laptops on wireless, 
for example.  In that case, my Dell laptop would send "SM_NOTIFY 
ellison.1015granger.net" from, say, anon-dhcp-108.1015granger.net. 
statd's DNS monname matching heuristic might fail.

Note that most contemporary Linux servers store the client's address 
rather than the caller_name string, but that just means our server won't 
recognize a client's reboot if the client is assigned a different 
address after it reboots, and that DNS configuration is especially 
critical to get lock recovery right.

If our client is operating with an automatically assigned IPv6 address, 
where a router gives an IPv6 address prefix, and the rest of the address 
is constructed from the NIC's MAC address, or, if our IPv4 address is 
DHCP-assigned by MAC address, what happens if we shut down the client, 
and then replace the NIC?  What if our client switches from wireless to 
wired?

In other words, we can't rely solely on source IP address to identify 
rebooting hosts.

3)  If the client is talking to a server on a private area network, 
there's no guarantee the server will recognize the client's caller_name 
string if it's the hostname of the client on the public side network. 
It may even attempt to contact the client via it's public side name, 
which might fail, depending on how the network is set up.

Therefore, I assert that this feature is needed to support multi-homed 
locking adequately, and to provide better lock recovery in the face of 
dynamically assigned IP addresses.

-- 
chuck[dot]lever[at]oracle[dot]com
