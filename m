Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:27889 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754783Ab0CIVJE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2010 16:09:04 -0500
Message-ID: <4B96B893.4030300@oracle.com>
Date: Tue, 09 Mar 2010 16:07:31 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: reboot recovery
References: <20100309014624.GF2999@fieldses.org> <4B9687D7.7010902@oracle.com> <20100309205349.GD26453@fieldses.org>
In-Reply-To: <20100309205349.GD26453@fieldses.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/09/2010 03:53 PM, J. Bruce Fields wrote:
> On Tue, Mar 09, 2010 at 12:39:35PM -0500, Chuck Lever wrote:
>> Thanks, this is very clear.
>>
>> On 03/08/2010 08:46 PM, J. Bruce Fields wrote:
>>> The Linux server's reboot recovery code has long-standing architectural
>>> problems, fails to adhere to the specifications in some cases, and does
>>> not yet handle NFSv4.1 reboot recovery.  An overhaul has been a
>>> long-standing todo.
>>>
>>> This is my attempt to state the problem and a rough solution.
>>>
>>> Requirements
>>> ^^^^^^^^^^^^
>>>
>>> Requirements, as compared to current code:
>>>
>>> 	- Correctly implements the algorithm described in section 8.6.3
>>> 	  of rfc 3530, and eliminates known race conditions on recovery.
>>> 	- Does not attempt to manage files and directories directly from
>>> 	  inside the kernel.
>>> 	- Supports RECLAIM_COMPLETE.
>>>
>>> Requirements, in more detail:
>>>
>>> A "server instance" is the lifetime from start to shutdown of a server;
>>> a reboot ends one server instance and starts another.
>>
>> It would be better if you architected this not in terms of a server
>> reboot, but in terms of "service nfs stop" and "service nfs start".
>
> Good point; fixed in my local copy.
>
> (Though that may work for v4-only servers, since I think v2/v3 may still
> have problems with restarts that don't restart everything (including the
> client).)

Well, eventually I hope to address some of those issues.  But, no use 
tying our NFSv4 stuff to the problems of the v2/v3 implementation.

>>> Draft design
>>> ^^^^^^^^^^^^
>>>
>>> We will modify rpc.statd to handle to manage state in userspace.
>>
>> Please don't.  statd is ancient krufty code that is already barely able
>> to do what it needs to do.
>>
>> statd is single-threaded.  It makes dozens of blocking DNS calls to
>> handle NSM protocol requests.  It makes NLM downcalls on the same thread
>> that handles everything else.  Unless an effort was undertaken to make
>> statd multithreaded, this extra work could cause signficant latency for
>> handling upcalls.
>
> Hm, OK.  I guess I don't want to make this project dependent on
> rewriting statd.
>
> So, other possibilities:
> 	- Modify one of the other existing userland daemons.
> 	- Make a separate daemon just for this.
> 	- ditch the daemon entirely and depend mainly on hotplug-like
> 	  invocations of a userland program that exist after it handles
> 	  a single call.
>
>>> Previous prototype code from CITI will be considered as a starting
>>> point.
>>>
>>> Kernel<->user communication will use four files in the "nfsd"
>>> filesystem.  All of them will use the encoding used for rpc cache
>>> upcalls and downcalls, which consist of whitespace-separated fields
>>> escaped as necessary to allow binary data.
>>
>> In general, we don't want to mix RPC listeners and upcall file
>> descriptors.  mountd has to access the cache file descriptors to satisfy
>> MNT requests, so there is a reason to do it in that case.  Here there is
>> no purpose to mix these two.  It only adds needless implementation
>> complexity and unnecessary security exposures.
>>
>> Yesterday, it was suggested that we split mountd into a piece that
>> handled upcalls and a piece that handled remote MNT requests via RPC.
>> Weren't you the one who argued in favor of getting rid of daemons called
>> "rpc.foo" for NFSv4-only operation? :-)
>
> Yeah.  So I guess a subcase of the second option above would be to name
> the new daemon "nfsd-userland-helper" (or something as generic) and
> eventually make it handle export upcalls too.  I don't know.

I wasn't thinking of a single daemon for this stuff, necessarily, but 
rather a single framework that can be easily fit to whatever task is 
needed.  Just alter a few constants, specify the arguments and their 
types, add boiling water, type 'make' and fluff with fork.

We've already got referral/DNS, idmapper, gss, and mountd upcalls, and 
they all seem to do it differently from each other.

-- 
chuck[dot]lever[at]oracle[dot]com
