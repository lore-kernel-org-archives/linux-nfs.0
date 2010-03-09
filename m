Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37018 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153Ab0CIUwY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 15:52:24 -0500
Date: Tue, 9 Mar 2010 15:53:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: reboot recovery
Message-ID: <20100309205349.GD26453@fieldses.org>
References: <20100309014624.GF2999@fieldses.org> <4B9687D7.7010902@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B9687D7.7010902@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 09, 2010 at 12:39:35PM -0500, Chuck Lever wrote:
> Thanks, this is very clear.
>
> On 03/08/2010 08:46 PM, J. Bruce Fields wrote:
>> The Linux server's reboot recovery code has long-standing architectural
>> problems, fails to adhere to the specifications in some cases, and does
>> not yet handle NFSv4.1 reboot recovery.  An overhaul has been a
>> long-standing todo.
>>
>> This is my attempt to state the problem and a rough solution.
>>
>> Requirements
>> ^^^^^^^^^^^^
>>
>> Requirements, as compared to current code:
>>
>> 	- Correctly implements the algorithm described in section 8.6.3
>> 	  of rfc 3530, and eliminates known race conditions on recovery.
>> 	- Does not attempt to manage files and directories directly from
>> 	  inside the kernel.
>> 	- Supports RECLAIM_COMPLETE.
>>
>> Requirements, in more detail:
>>
>> A "server instance" is the lifetime from start to shutdown of a server;
>> a reboot ends one server instance and starts another.
>
> It would be better if you architected this not in terms of a server  
> reboot, but in terms of "service nfs stop" and "service nfs start".

Good point; fixed in my local copy.

(Though that may work for v4-only servers, since I think v2/v3 may still
have problems with restarts that don't restart everything (including the
client).)

>> Draft design
>> ^^^^^^^^^^^^
>>
>> We will modify rpc.statd to handle to manage state in userspace.
>
> Please don't.  statd is ancient krufty code that is already barely able  
> to do what it needs to do.
>
> statd is single-threaded.  It makes dozens of blocking DNS calls to  
> handle NSM protocol requests.  It makes NLM downcalls on the same thread  
> that handles everything else.  Unless an effort was undertaken to make  
> statd multithreaded, this extra work could cause signficant latency for  
> handling upcalls.

Hm, OK.  I guess I don't want to make this project dependent on
rewriting statd.

So, other possibilities:
	- Modify one of the other existing userland daemons.
	- Make a separate daemon just for this.
	- ditch the daemon entirely and depend mainly on hotplug-like
	  invocations of a userland program that exist after it handles
	  a single call.

>> Previous prototype code from CITI will be considered as a starting
>> point.
>>
>> Kernel<->user communication will use four files in the "nfsd"
>> filesystem.  All of them will use the encoding used for rpc cache
>> upcalls and downcalls, which consist of whitespace-separated fields
>> escaped as necessary to allow binary data.
>
> In general, we don't want to mix RPC listeners and upcall file  
> descriptors.  mountd has to access the cache file descriptors to satisfy  
> MNT requests, so there is a reason to do it in that case.  Here there is  
> no purpose to mix these two.  It only adds needless implementation  
> complexity and unnecessary security exposures.
>
> Yesterday, it was suggested that we split mountd into a piece that  
> handled upcalls and a piece that handled remote MNT requests via RPC.  
> Weren't you the one who argued in favor of getting rid of daemons called  
> "rpc.foo" for NFSv4-only operation? :-)

Yeah.  So I guess a subcase of the second option above would be to name
the new daemon "nfsd-userland-helper" (or something as generic) and
eventually make it handle export upcalls too.  I don't know.

>> Before starting the server, and writing to allow_client, statd will
>> manage boot times and old clients using files in /var/lib/nfs:
>>
>> 	If boot_time exists:
>> 		- It will be read, and the contents interpreted as an
>> 		  ascii-encoded unix time in seconds.
>> 		- All client records older than that time will be removed.
>> 		- The current boot_time will be recorded to
>> 		  new_boot_time (replacing any existing such file).
>> 		- All remaining clients will be written to allow_client.
>> 	If boot_time does not exist, an empty /var/lib/nfs/v4clients/ is
>> 		created if necessary, but nothing else is done.
>
> Since I've split out the pieces of statd that manage its on-disk file  
> format (see support/nsm/file.c) it shouldn't be difficult to  
> copy-n-paste the pieces needed to construct /var/lib/nfs/v4clients.
>
> I have some additional patches for statd that can detect system reboots,  
> but again, it would be better perhaps to design for "server nfs restart"  
> rather than a full system reboot.

OK.

>
>> Statd will then wait for create_client, expire_client, and grace_done
>> calls.  On grace_done, it will rename boot_time to old_boot_time, and
>> new_boot_time to boot_time.
>
> Although it's noble to attempt to reuse old code in this way, I think  
> you will be far better off constructing and using a proper scaffold for  
> dealing generically with cache upcalls.  By doing this we avoid the  
> complexity of updating working legacy code, and have a better chance for  
> building something that scales well right off the bat.  This is new  
> code, so why chain yourself to legacy problems?
>
> A starting place could be the work Trond is doing to replace idmapd.

OK, thanks for the review.

--b.
