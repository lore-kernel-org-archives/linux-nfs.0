Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:19562 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050Ab0A1QFv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2010 11:05:51 -0500
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <19787C23-3104-4DF5-A173-ACE3473AA169@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <4B60BE9E.6020702@redhat.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH] mount.nfs: Don't fail mounts when /etc/netconfig is nonexistent
Date: Thu, 28 Jan 2010 11:05:01 -0500
References: <4B606CA5.2090607@RedHat.com> <4B60816E.5070108@oracle.com> <4B608905.90708@RedHat.com> <25FE1491-19BF-47AC-8AF2-50D474E67B7D@oracle.com> <4B60BE9E.6020702@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Peter-

On Jan 27, 2010, at 5:30 PM, Peter Staubach wrote:
> Chuck Lever wrote:
>> On Jan 27, 2010, at 1:42 PM, Steve Dickson wrote:
>>> On 01/27/2010 01:09 PM, Chuck Lever wrote:
>>>>> Author: Steve Dickson<steved@redhat.com>
>>>>> Date:   Wed Jan 27 11:19:00 2010 -0500
>>>>>
>>>>>    In a very sparse environments certain system files (like
>>>>>    /etc/netconfig) may not exist. In these environments don't
>>>>>    fail mount if all the need information (like network protocols)
>>>>>    exist and are well known.
>>>>>
>>>>>    Signed-off-by: Steve Dickson<steved@redhat.com>
>>>>
>>>> I totally disagree with this.  If HAVE_LIBTIRPC is set, then the  
>>>> runtime
>>>> TI-RPC package should be installed, in its entirety, on the run- 
>>>> time
>>>> systems.  If autoconf and RPM can't trust the given dependency
>>>> information, then all bets are off.
>>> Well in some environments "all bets are off" is just not good  
>>> enough...
>>
>> Limited disk space does not mean that RPM is suddenly allowed to  
>> ignore
>> dependencies.  Clearly someone decided that it was OK to install only
>> part of the TI-RPC run-time on this system, despite the dependency
>> nfs-utils has on libtirpc.
>>
>>> Mount has always worked in these type of  environments before and
>>> I think we should continue to...
>>
>> No one is arguing that point.
>>
>>>> The right fix is to either:
>>>>
>>>> a) install a non-TI-RPC version of mount.nfs, or
>>>>
>>>> b) make sure /etc/netconfig is available when RPM, pkgconfig, and
>>>> autoconf say it should be.
>>>>
>>> Sparse environments generally have a finite amount of space, that
>>> is simple unchangeable... so the above "luxuries" are simply not
>>> available...
>>
>> I'm sorry you feel that /etc/netconfig is a luxury, but the fact is  
>> it's
>> currently a mandatory part of the TI-RPC run-time.  Why be  
>> surprised if
>> TI-RPC based applications stop working when the run-time they  
>> depend on
>> is incorrectly installed?
>>
>> If /etc/rpc and /etc/protocols are installed on this system, then
>> there's no reason to exclude /etc/netconfig.  The file is all of 768
>> bytes (and can be made smaller immediately by leaving out the block
>> comment at the top).  If there really is no room for an additional  
>> file,
>> then you need a different solution (see below).
>>
>> Frankly, if disk space is so tight on this system, you should embrace
>> using the non-TI-RPC mount.nfs, because it's disk footprint is
>> significantly smaller than the current TI-RPC based mount.nfs, and  
>> you
>> get exactly the functionality that you get with your patch applied.
>>
>>>> I assume since you are not patching other parts of mount.nfs that  
>>>> look
>>>> for /etc/rpc and /etc/protocols that these files _do_ exist?  Or  
>>>> does
>>>> glibc also do this hack of filling in well-known values?
>>>>
>>> Lets keep this in perspective... the "well-known" values in this  
>>> patch
>>> things like TCP and UDP... when protocol == IPPROTO_TCP the well  
>>> known
>>> value
>>> is "tcp" (or "tcp6" depending on the family)... Values that have not
>>> changed for years and will not change for years...
>>>
>>> On the umount side, the file should not be consulted in the first  
>>> place
>>> since all the information needed in /etc/mtab... Of course things
>>> can change between mount and umounts but I truly do no think the
>>> meaning of "udp" will change from being IPPROTO_UDP....
>>>
>>> Making mount more bullet proof and allowing it (continue to) work  
>>> in all
>>> different types of environments is a good thing... imho...
>>
>> You've fundamentally misunderstood my objection to your patch.
>>
>> In nfs-utils, we've replaced the glibc RPC implementation with TI- 
>> RPC.
>> Today, if you want the TI-RPC versions of these utilities to "just  
>> work"
>> then the whole TI-RPC run-time must be installed on the target  
>> systems.
>> Note well that the TI-RPC enabled statd will also fail to start if
>> /etc/netconfig does not exist, and this will cause NFS mounts to  
>> fail as
>> well.  Likewise, a TI-RPC enabled mountd will fail to start in this
>> situation.
>>
>> Now, if you want to ensure that TI-RPC applications will continue to
>> work in the absence of parts of the TI-RPC run-time, then you should
>> address that in libtirpc, not in every application that uses it.
>> /etc/netconfig is not a part of mount.nfs, it's a part of TI-RPC.
>>
>> It also appears that your new logic might assume the values of  
>> "tcp" and
>> "udp" when an admin purposely excludes them from /etc/netconfig.   
>> What
>> if an admin wants to start only IPv6 listeners for statd, nfsd, and
>> mountd?  Somehow, mounting "tcp" and "udp" still work, even though we
>> claim in the man page that these are netids, not protocol names.   
>> That
>> would be a bug.
>
> Chuck, it feels as if you are under the impression that this
> is a general purpose deployment that Steve is attempting to
> make to work.  It is not.  It is a very restricted use, ie.
> to install a system.

This request was made to the upstream maintainer and he has passed it  
to the community, thus someone thought it might have generic interest  
(or, perhaps they just wanted someone else to maintain this hack).

If we are to maintain this new behavior, we (not being the original  
authors) should attempt to understand what is required, and try to fit  
this into our plans and the provided code and APIs.  Unfortunately  
there were very few details offered in the patch description, so we  
are left to assume.

> Thus, the resources available are very
> restricted.  The restriction is not diskspace, per se, but
> the memory footprint which would be required to hold it.
>
> The suggestion to use the non-TI-RPC version is interesting,
> but has some very negative ramifications.  It would mean that
> we would have to test the TI-RPC flavor and the non-TI-RPC
> flavor.  It would also limit future development to that which
> could be supported via the non-TI-RPC version.  This seems
> unnecessarily limiting.
>
> While I don't agree with what the anaconda folks have done,
> picking and choosing as they have, they have done so.  I
> think that we should work with them to figure out why they
> have chosen to do so and whether it is valid or not.
>
> All that said, what is the technical problem with including
> this support?  There is no possibility that "tcp" or "udp"
> will ever change meaning, at least not in our lifetimes.

If this is for Anaconda, I assume that eventually they will want to  
support NFS/IPv6, so we are going to have to make user space TI-RPC  
work in a restricted environment.

The technical issues are:

1.  /etc/netconfig is a mandatory part of TI-RPC (as it is currently  
implemented), so not having it means that the library _will_ be broken  
in all kinds of ways.  That must be addressed if we want our TI-RPC- 
based tools to operate without /etc/netconfig.

2.  All TI-RPC applications that run in a restricted environment will  
have the same problem.  Thus the problem should be addressed in TI- 
RPC, not in any particular application that uses it.  That would  
affect rpcbind, statd, ypbind, showmount, and maybe others.

3.  The absence of a particular netid has specific semantics.  You  
can't just assume "tcp" if there's no "tcp" netid in the /etc/ 
netconfig file.  It doesn't matter how traditional the string "tcp" is  
-- that's simply not the way this API works.

4.  We've changed mount.nfs to make "proto=" take a netid, not a  
protocol name without deference to an address family.  We are now  
being asked to go back to the original behavior, which was that "tcp"  
means either tcp over IPv4 or over IPv6.

> The bottom line is that I could agree, that this isn't the
> most aesthetically pleasing architecture and implementation.
> However, sometimes, the code must run in a non-perfect
> world and hence, compromises must be made.

I should have said "I totally disagree with this _approach_."  I don't  
have a problem with supporting a restricted environment.  But we do  
need to understand what is required first.  In general, there's no  
possible way we can take a significant feature change and support it  
if we don't understand how it's supposed to work.

My current proposal to address this problem is to emulate the contents  
of /etc/netconfig inside libtirpc (specifically in the set/ 
endnetconfigent code) if the /etc/netconfig file does not exist.  The  
emulated contents of the file would essentially match the semantics of  
what we have soldered into the kernel.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




