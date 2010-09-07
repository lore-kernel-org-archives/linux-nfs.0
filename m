Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63663 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab0IGVPa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 17:15:30 -0400
Subject: Re: [PATCH 0/2] Make libtirpc work with old style portmapper
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <201009072258.22044.okir@suse.de>
Date: Tue, 7 Sep 2010 17:15:00 -0400
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        Steve Dickson <SteveD@redhat.com>
Message-Id: <F1626B79-BFE6-4616-9317-A6075AEA8B61@oracle.com>
References: <201008301503.19783.okir@suse.de> <201009071327.07291.okir@suse.de> <F1D592E6-35AD-45DA-B69E-044D59500DFB@oracle.com> <201009072258.22044.okir@suse.de>
To: Olaf Kirch <okir@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 7, 2010, at 4:58 PM, Olaf Kirch wrote:

> On Tuesday 07 September 2010 17:36:58 Chuck Lever wrote:
>> Probably not a bad idea.  But I thought this was a problem for applications
>> that are calling rpcb_{un,}set(3t), not apps that are invoking the legacy
>> variants.  How does this new patch address the problem?
> 
> No, it's a problem with legacy apps calling pmap_set/unset. They simply
> stop working if you use pmap_set + libtirpc + portmap.

I think the crux of the problem is the latter half: libtirpc + portmap.

>> What happens if you try the other way around: try the AF_UNIX mechanism
>> first, then the legacy mechanism?  It's arguable that any application
>> calling the pmap_{un,}set(3t) interface would likely expect the old
>> behavior anyway, but could probably benefit from the additional security
>> if rpcbind, rather than portmap, is running locally.
> 
> I don't think apps coded to the old pmap_* interface will benefit
> in any way from the new security model. These services expect a
> root/non-root split of privilege, and that's what they get with
> PMAP_SET/UNSET, no matter whether they talk to rpcbind or portmap.

I haven't thought carefully about it, but that's probably correct.

>>  1.  rpcb_{un,}set(3t) need to work whether rpcbind or portmapper are
>> running 2.  pmap_{un,}set(3t) should still invoke rpcb_{un,}set(3t) under
>> the covers to ensure they get advanced security when available
>> 
>> This is because you can build legacy apps against libtirpc (which want
>> robust pmap_{un,}set(3t) no matter which portmapper is running), but you
>> can also construct TI-RPC enabled apps that may be running on a system
>> with only portmap (which want robust rpcb_{un,}set(3t)).  So I think you
>> have to fix both APIs.
> 
> The latter is a problem indeed, and I guess we need to fix it as well.
> The one that I wanted to address first and foremost is applications
> using the legacy API

Yes, I agree both are a problem.  The "rpcb_{un,}set(3t) + TI-RPC-enabled application running on a host with only portmap running" was the problem that was reported to me (twice, separately) a while ago.

-- 
chuck[dot]lever[at]oracle[dot]com




