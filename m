From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Bug#579397: STAT_FAIL to debian for SM_MON of 192.168.120.254,
 No canonical hostname found for 192.168.120.254
Date: Thu, 03 Jun 2010 17:08:18 -0400
Message-ID: <4C0819C2.2020203@oracle.com>
References: <4BF71C27.7070309@nchc.org.tw> <1274492328.11828.3.camel@localhost> <4BFA99CD.2040902@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steven Shiau <steven@nchc.org.tw>, 579397@bugs.debian.org,
	linux-nfs@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42887 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655Ab0FCVK1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jun 2010 17:10:27 -0400
In-Reply-To: <4BFA99CD.2040902@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/24/10 11:22 AM, Chuck Lever wrote:
> On 05/21/10 09:38 PM, Ben Hutchings wrote:
>> On Sat, 2010-05-22 at 07:49 +0800, Steven Shiau wrote:
>>> Same problem here. However, mine is on the client side.
>>> On sid system, running kernel is 2.6.32-5-686, nfs-common is 1:1.2.2-1.
>>> When I mount my NFS server 192.168.120.254, it works. However, if I want
>>> to use some tool which need to lock file to save the file on the NFS
>>> server, e.g.
>>> vgcfgbackup -f $NFS_MNT_POINT/vg.cfg
>>> I get the message "lockd: cannot monitor 192.168.120.254", and the
>>> message shown on the /var/log/daemon.log:
>>> May 21 08:52:44 debian rpc.statd[1298]: STAT_FAIL to debian for SM_MON
>>> of 192.168.120.254
>>> May 21 08:52:44 debian rpc.statd[1298]: No canonical hostname found for
>>> 192.168.120.254
>> [...]
>>
>> nfs-utils 1.2.2 includes the change:
>>
>> commit 8ce130c4c828b9d13d429f22160f992b9c1d45cd
>> Author: Chuck Lever<chuck.lever@oracle.com>
>> Date: Thu Jan 14 12:24:15 2010 -0500
>>
>> statd: Support IPv6 in sm_mon_1_svc()
>>
>> This appears to have removed support for IPv4 literals. Was this
>> intentional?
>
> statd usually requires a DNS reverse mapping for any host it monitors.
> Does your DNS have a reverse mapping for 192.168.120.254?
>
> It looks like the new logic is more restrictive than the old statd when
> mon_name is a presentation address. The old code simply allowed
> presentation addresses with no reverse mapping. The new code requires a
> reverse DNS mapping for presentation addresses. I think even an entry in
> /etc/hosts would allow a raw address to work in this case.
>
> We can probably remove the reverse mapping constraint for presentation
> addresses. A simple fix might be to change statd_canonical_name() from:
>
> freeaddrinfo(ai);
> if (!result)
> return NULL;
>
> to
>
> freeaddrinfo(ai);
> if (!result)
> return strdup(hostname);
>
> Let me know if this works.

Any update?  I have a patch ready for nfs-utils to fix this regression, 
but I need confirmation that it addresses your problem.
