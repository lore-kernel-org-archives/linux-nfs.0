Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:51126 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503Ab1DTPJj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 11:09:39 -0400
Subject: Re: [PATCH] svc: make sure mountd can get ports from /etc/services
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DAEA782.2090108@cn.fujitsu.com>
Date: Wed, 20 Apr 2011 11:08:23 -0400
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Message-Id: <AD03EC99-CB5C-41BA-AE0B-FEA7A8D48B6E@oracle.com>
References: <4DAD48C7.9090808@cn.fujitsu.com> <94B98C85-8FAE-4B72-A782-F0B0DFD83674@oracle.com> <4DAEA782.2090108@cn.fujitsu.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 20, 2011, at 5:29 AM, Mi Jinlong wrote:

> 
> 
> Chuck Lever:
>> Hi MJ-
>> 
>> On Apr 19, 2011, at 4:33 AM, Mi Jinlong wrote:
>> 
>>> At RHEL, if user set port for mountd at /etc/services as 
>>> "mount   12345/tcp", mountd should be bind to 12345, but the 
>>> latest nfs-utils, mountd get a rand port, not 12345.
>>> 
>>> This patch make sure mountd be bind to the port which was set
>>> at /etc/service.
>> 
>> I don't think this is documented anywhere.  Is there a reason it should work this way?
>> 
>> The typical way to set mountd's port is to use a command line option.  That's the way it works for all the other RPC daemons.  By default the ports are set up at random and registered with rpcbind.  That's why clients use rpcbind, and not /etc/services, to find these services.
> 
>  I don't have a depth research, agree with you.
>  But I got different result when I set port for mountd at /etc/services
>  between nfs-utils-1.2.3 and nfs-utils-1.2.2.

IMO that's unintentional behavior.  Could I ask a favor: would you bisect nfs-utils to find out exactly where this started and ended?

>  I just think we should get the same result at new nfs-utils as older.

Is there a real-world use case for this feature?  Why isn't the command line option adequate?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




