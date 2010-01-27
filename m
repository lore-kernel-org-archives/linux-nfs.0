Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:30780 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576Ab0A0U5p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jan 2010 15:57:45 -0500
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <25FE1491-19BF-47AC-8AF2-50D474E67B7D@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4B608905.90708@RedHat.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH] mount.nfs: Don't fail mounts when /etc/netconfig is nonexistent
Date: Wed, 27 Jan 2010 15:57:08 -0500
References: <4B606CA5.2090607@RedHat.com> <4B60816E.5070108@oracle.com> <4B608905.90708@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jan 27, 2010, at 1:42 PM, Steve Dickson wrote:
> On 01/27/2010 01:09 PM, Chuck Lever wrote:
>>> Author: Steve Dickson<steved@redhat.com>
>>> Date:   Wed Jan 27 11:19:00 2010 -0500
>>>
>>>     In a very sparse environments certain system files (like
>>>     /etc/netconfig) may not exist. In these environments don't
>>>     fail mount if all the need information (like network protocols)
>>>     exist and are well known.
>>>
>>>     Signed-off-by: Steve Dickson<steved@redhat.com>
>>
>> I totally disagree with this.  If HAVE_LIBTIRPC is set, then the  
>> runtime
>> TI-RPC package should be installed, in its entirety, on the run-time
>> systems.  If autoconf and RPM can't trust the given dependency
>> information, then all bets are off.
> Well in some environments "all bets are off" is just not good  
> enough...

Limited disk space does not mean that RPM is suddenly allowed to  
ignore dependencies.  Clearly someone decided that it was OK to  
install only part of the TI-RPC run-time on this system, despite the  
dependency nfs-utils has on libtirpc.

> Mount has always worked in these type of  environments before and
> I think we should continue to...

No one is arguing that point.

>> The right fix is to either:
>>
>> a) install a non-TI-RPC version of mount.nfs, or
>>
>> b) make sure /etc/netconfig is available when RPM, pkgconfig, and
>> autoconf say it should be.
>>
> Sparse environments generally have a finite amount of space, that
> is simple unchangeable... so the above "luxuries" are simply not
> available...

I'm sorry you feel that /etc/netconfig is a luxury, but the fact is  
it's currently a mandatory part of the TI-RPC run-time.  Why be  
surprised if TI-RPC based applications stop working when the run-time  
they depend on is incorrectly installed?

If /etc/rpc and /etc/protocols are installed on this system, then  
there's no reason to exclude /etc/netconfig.  The file is all of 768  
bytes (and can be made smaller immediately by leaving out the block  
comment at the top).  If there really is no room for an additional  
file, then you need a different solution (see below).

Frankly, if disk space is so tight on this system, you should embrace  
using the non-TI-RPC mount.nfs, because it's disk footprint is  
significantly smaller than the current TI-RPC based mount.nfs, and you  
get exactly the functionality that you get with your patch applied.

>> I assume since you are not patching other parts of mount.nfs that  
>> look
>> for /etc/rpc and /etc/protocols that these files _do_ exist?  Or does
>> glibc also do this hack of filling in well-known values?
>>
> Lets keep this in perspective... the "well-known" values in this patch
> things like TCP and UDP... when protocol == IPPROTO_TCP the well  
> known value
> is "tcp" (or "tcp6" depending on the family)... Values that have not
> changed for years and will not change for years...
>
> On the umount side, the file should not be consulted in the first  
> place
> since all the information needed in /etc/mtab... Of course things
> can change between mount and umounts but I truly do no think the
> meaning of "udp" will change from being IPPROTO_UDP....
>
> Making mount more bullet proof and allowing it (continue to) work in  
> all
> different types of environments is a good thing... imho...

You've fundamentally misunderstood my objection to your patch.

In nfs-utils, we've replaced the glibc RPC implementation with TI- 
RPC.  Today, if you want the TI-RPC versions of these utilities to  
"just work" then the whole TI-RPC run-time must be installed on the  
target systems.  Note well that the TI-RPC enabled statd will also  
fail to start if /etc/netconfig does not exist, and this will cause  
NFS mounts to fail as well.  Likewise, a TI-RPC enabled mountd will  
fail to start in this situation.

Now, if you want to ensure that TI-RPC applications will continue to  
work in the absence of parts of the TI-RPC run-time, then you should  
address that in libtirpc, not in every application that uses it.  /etc/ 
netconfig is not a part of mount.nfs, it's a part of TI-RPC.

It also appears that your new logic might assume the values of "tcp"  
and "udp" when an admin purposely excludes them from /etc/netconfig.   
What if an admin wants to start only IPv6 listeners for statd, nfsd,  
and mountd?  Somehow, mounting "tcp" and "udp" still work, even though  
we claim in the man page that these are netids, not protocol names.   
That would be a bug.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




