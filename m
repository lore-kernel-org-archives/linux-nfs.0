From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/6] IPv6 support for nfs-utils tcpwrapper shim
Date: Fri, 15 Jan 2010 13:27:59 -0500
Message-ID: <1FFE8210-7E78-4A65-A56F-A5030BB26600@oracle.com>
References: <20100115174426.30104.3492.stgit@localhost.localdomain> <4B50AE34.3020009@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:28315 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757940Ab0AOS3Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 13:29:25 -0500
In-Reply-To: <4B50AE34.3020009-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 15, 2010, at 1:04 PM, Steve Dickson wrote:
> On 01/15/2010 12:49 PM, Chuck Lever wrote:
>> These patches provide IPv6 support for the tcpwrapper shim inside
>> nfs-utils.  It assumes that the generic tcpwrapper library can
>> support IPv6 addresses.  It has not been extensively tested, but
>> I think the framework is reasonable, and only minor bug fixes might
>> be needed as we go along.
> Did you do any simple "hello world" testing?

I've build-tested them.  Jeff and I had them applied while doing the  
statd testing.  They don't appear to cause problems when no allow/deny  
sets exist.

I thought we would have more time to test and review these, so I  
haven't done more extensive testing so far.  In any case, I don't  
think they will be harmful, and can serve as a place marker for that  
feature as the beta moves forward.

> steved.
>
>>
>> ---
>>
>> Chuck Lever (6):
>>      tcpwrapper: Add support for IPv6
>>      tcpwrapper: Eliminated shadowed declaration warnings
>>      tcpwrapper: Fix signage problems in the tcp_wrappers hash  
>> function
>>      tcp_wrapper: Clean up logit()
>>      tcp_wrappers: Use getifaddrs(3) if it is available
>>      tcpwrappers: Use xlog() instead of perror(3) and syslog(2)
>>
>>
>> aclocal/ipv6.m4               |    4 -
>> configure.ac                  |    2
>> support/include/tcpwrapper.h  |   12 +-
>> support/misc/from_local.c     |  112 +++++++++++++++++++----
>> support/misc/tcpwrapper.c     |  203 +++++++++++++++++++++++ 
>> +-----------------
>> utils/mountd/mount_dispatch.c |    6 -
>> utils/statd/statd.c           |    5 -
>> utils/statd/statd.man         |    3 -
>> 8 files changed, 223 insertions(+), 124 deletions(-)
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



