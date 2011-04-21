Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23974 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab1DUOL0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Apr 2011 10:11:26 -0400
Subject: Re: [PATCH] svc: make sure mountd can get ports from /etc/services
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DAFA7AB.9020507@cn.fujitsu.com>
Date: Thu, 21 Apr 2011 10:11:11 -0400
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Message-Id: <5A8AD10C-81A4-4088-BCFA-08D0BA2337C7@oracle.com>
References: <4DAD48C7.9090808@cn.fujitsu.com> <94B98C85-8FAE-4B72-A782-F0B0DFD83674@oracle.com> <4DAEA782.2090108@cn.fujitsu.com> <AD03EC99-CB5C-41BA-AE0B-FEA7A8D48B6E@oracle.com> <4DAFA7AB.9020507@cn.fujitsu.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 20, 2011, at 11:42 PM, Mi Jinlong wrote:

> 
> 
> Chuck Lever:
>> On Apr 20, 2011, at 5:29 AM, Mi Jinlong wrote:
>> 
>>> 
>>> Chuck Lever:
>>>> Hi MJ-
>>>> 
>>>> On Apr 19, 2011, at 4:33 AM, Mi Jinlong wrote:
>>>> 
>>>>> At RHEL, if user set port for mountd at /etc/services as 
>>>>> "mount   12345/tcp", mountd should be bind to 12345, but the 
>>>>> latest nfs-utils, mountd get a rand port, not 12345.
>>>>> 
>>>>> This patch make sure mountd be bind to the port which was set
>>>>> at /etc/service.
>>>> I don't think this is documented anywhere.  Is there a reason it should work this way?
>>>> 
>>>> The typical way to set mountd's port is to use a command line option.  That's the way it works for all the other RPC daemons.  By default the ports are set up at random and registered with rpcbind.  That's why clients use rpcbind, and not /etc/services, to find these services.
>>> I don't have a depth research, agree with you.
>>> But I got different result when I set port for mountd at /etc/services
>>> between nfs-utils-1.2.3 and nfs-utils-1.2.2.
>> 
>> IMO that's unintentional behavior.  Could I ask a favor: would you bisect nfs-utils to find out exactly where this started and ended?
> 
>  Hi Chuck,
> 
>  It's after your patch "mountd: Support TI-RPC mountd listener" 
>  (commit id:b551b1fd0052de9b8c674b30c39d9f2a1e9d79cc).
> 
>  Before this patch, mountd call rpc_init to create rpc socket,
>  after it, if HAVE_LIBTIRPC is defined, mountd will call 
>  nfs_svc_create to create rpc socket, that appears.

Thanks.  I don't immediately see how that code path consults /etc/services.  There are no calls to getservby{name,port}(3) in either mountd or in libtirpc.  Did I miss something?  Any idea?

You said it stopped working after a while.  Can you bisect that as well?

Note that if nfs-utils is built without TI-RPC support, rpc_init() is still used instead of nfs_svc_create().  If nfs_svc_create() is indeed the proximal cause of this behavior, mountd won't consult /etc/services if it is built without TI-RPC support.  So it might be a bug if this works for some build configurations and doesn't work for others.  The question is should it always work, or should it never work; see below.

> 
>> 
>>> I just think we should get the same result at new nfs-utils as older.
>> 
>> Is there a real-world use case for this feature?  Why isn't the command line option adequate?
>> 
> 
>  I have a test site which depend on this feature.
>  If this feature indeed unnecessary, I will try to modify my test site.

Without knowing more about your test site, I claim it can and should use the "-p" option on rpc.mountd.  If your distribution of choice is Red Hat-based, you can set this in /etc/sysconfig/nfs (see MOUNTD_PORT=).

In other words, we have a documented and supported mechanism now, that should always work, for setting mountd's listener port.  Can you explain in detail why allowing /etc/services to have this effect is also necessary?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




