Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.math.uiuc.edu ([130.126.108.26]:59518 "EHLO
	mail1.math.uiuc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab0HDQXG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 12:23:06 -0400
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
Message-Id: <4A465B1D-9DEE-43C3-AD40-7EEFB2A88321@illinois.edu>
From: Jonathan Manton <jmanton@illinois.edu>
To: Jim Rees <rees@umich.edu>
In-Reply-To: <20100804154533.GA13950@merit.edu>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: Kerberized NFS (v3 and v4) does not work if Kerberos token is >= 2048 bytes (if PAGE_SIZE == 4096)
Date: Wed, 4 Aug 2010 11:22:55 -0500
References: <E820D075-2582-4FF8-B788-14D41070DA29@illinois.edu> <D17BAFDB-6B3B-40B6-9C28-5689D18FBBA5@netapp.com> <20100804154533.GA13950@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 4, 2010, at 10:45 AM, Jim Rees wrote:

> Andy Adamson wrote:
>
>> When a user with a Kerberos token of 2048 bytes or larger attempts to
>> access a filesystem mounted using Kerberized NFS, the NFS server  
>> locks up
>> for 30 seconds, and ultimately the call fails.
>
>  Yes, this limitation has been known for a long time. We ran into  
> this same
>  issue using X.509 certs and spkm3. I imagine PKINIT will also hit  
> this
>  limitation.
>
> But shouldn't it fail right away instead of locking up for 30 seconds?
>

It seems to me that it should error out with a log message, rather  
than simply trying over and over again.

> Does the entire server lock up, or just that one rpc?
>

The concrete manifestation of this is that all of the NFS kernel  
processes run continuously.  So on a single-processor system, it takes  
100% of the CPU for those 30 seconds.  On a multiprocessor system (at  
least my RHEL system), the NFS kernel processes keep affinity with a  
CPU, so it just consumes one processor.  I have not tested if other  
NFS requests can be processed during that window on a multiprocessor  
system.  It does not really "lock up", but rather monopolizes the CPU  
with high-priority kernel threads.

Related to this, it was a real pain for me to debug, since setting any  
of the rpcdebug flags in rpc simply overloaded the logging subsystem.   
I had to put an ssleep() in svcauth_gss_handle_init() in order to get  
debugging output I could use from rpcdebug.

> Can a malicious client use this as a DOS?

Yes.

> Does it require a valid ticket,
> or will any ticket >= 2048 do?

I believe that all of the validity-checking of the token is done in  
the upcall rpc.svcgssd, not in the sunrpc kernel code.  I am a kernel  
newbie though, so I am not sure.
