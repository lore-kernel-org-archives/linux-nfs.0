Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014Ab0A1PjR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 10:39:17 -0500
Message-ID: <4B61AFA1.7090806@RedHat.com>
Date: Thu, 28 Jan 2010 10:39:13 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: Don't fail mounts when /etc/netconfig is nonexistent
References: <4B606CA5.2090607@RedHat.com> <4B60816E.5070108@oracle.com> <4B608905.90708@RedHat.com> <25FE1491-19BF-47AC-8AF2-50D474E67B7D@oracle.com>
In-Reply-To: <25FE1491-19BF-47AC-8AF2-50D474E67B7D@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/27/2010 03:57 PM, Chuck Lever wrote:
> On Jan 27, 2010, at 1:42 PM, Steve Dickson wrote:
>> On 01/27/2010 01:09 PM, Chuck Lever wrote:
>>>> Author: Steve Dickson<steved@redhat.com>
>>>> Date:   Wed Jan 27 11:19:00 2010 -0500
>>>>
>>>>     In a very sparse environments certain system files (like
>>>>     /etc/netconfig) may not exist. In these environments don't
>>>>     fail mount if all the need information (like network protocols)
>>>>     exist and are well known.
>>>>
>>>>     Signed-off-by: Steve Dickson<steved@redhat.com>
>>>
>>> I totally disagree with this.  If HAVE_LIBTIRPC is set, then the runtime
>>> TI-RPC package should be installed, in its entirety, on the run-time
>>> systems.  If autoconf and RPM can't trust the given dependency
>>> information, then all bets are off.
>> Well in some environments "all bets are off" is just not good enough...
> 
> Limited disk space does not mean that RPM is suddenly allowed to ignore
> dependencies.  Clearly someone decided that it was OK to install only
> part of the TI-RPC run-time on this system, despite the dependency
> nfs-utils has on libtirpc.
This has been a practice (cherry picking pieces from RPMS) for a 
very long time (so I'm told)....
 
> 
>> Mount has always worked in these type of  environments before and
>> I think we should continue to...
> 
> No one is arguing that point.
> 
>>> The right fix is to either:
>>>
>>> a) install a non-TI-RPC version of mount.nfs, or
>>>
>>> b) make sure /etc/netconfig is available when RPM, pkgconfig, and
>>> autoconf say it should be.
>>>
>> Sparse environments generally have a finite amount of space, that
>> is simple unchangeable... so the above "luxuries" are simply not
>> available...
> 
> I'm sorry you feel that /etc/netconfig is a luxury, but the fact is it's
> currently a mandatory part of the TI-RPC run-time.  Why be surprised if
> TI-RPC based applications stop working when the run-time they depend on
> is incorrectly installed?
> 
> If /etc/rpc and /etc/protocols are installed on this system, then
> there's no reason to exclude /etc/netconfig.  The file is all of 768
> bytes (and can be made smaller immediately by leaving out the block
> comment at the top).  If there really is no room for an additional file,
> then you need a different solution (see below).
/etc/protocols is but /etc/rpc is not.

> 
> Frankly, if disk space is so tight on this system, you should embrace
> using the non-TI-RPC mount.nfs, because it's disk footprint is
> significantly smaller than the current TI-RPC based mount.nfs, and you
> get exactly the functionality that you get with your patch applied.
I don't think supporting two different packages is the answer...

> 
>>> I assume since you are not patching other parts of mount.nfs that look
>>> for /etc/rpc and /etc/protocols that these files _do_ exist?  Or does
>>> glibc also do this hack of filling in well-known values?
>>>
>> Lets keep this in perspective... the "well-known" values in this patch
>> things like TCP and UDP... when protocol == IPPROTO_TCP the well known
>> value
>> is "tcp" (or "tcp6" depending on the family)... Values that have not
>> changed for years and will not change for years...
>>
>> On the umount side, the file should not be consulted in the first place
>> since all the information needed in /etc/mtab... Of course things
>> can change between mount and umounts but I truly do no think the
>> meaning of "udp" will change from being IPPROTO_UDP....
>>
>> Making mount more bullet proof and allowing it (continue to) work in all
>> different types of environments is a good thing... imho...
> 
> You've fundamentally misunderstood my objection to your patch.
> 
> In nfs-utils, we've replaced the glibc RPC implementation with TI-RPC. 
> Today, if you want the TI-RPC versions of these utilities to "just work"
> then the whole TI-RPC run-time must be installed on the target systems. 
> Note well that the TI-RPC enabled statd will also fail to start if
> /etc/netconfig does not exist, and this will cause NFS mounts to fail as
> well.  Likewise, a TI-RPC enabled mountd will fail to start in this
> situation.
The -o nolock option used so statd or rpcbind, for that matter, is not needed...

> 
> Now, if you want to ensure that TI-RPC applications will continue to
> work in the absence of parts of the TI-RPC run-time, then you should
> address that in libtirpc, not in every application that uses it. 
> /etc/netconfig is not a part of mount.nfs, it's a part of TI-RPC.
Technically I see no difference whether its done in the mount command
or library... theoretically I think it makes more sense to leave it
up to the applications to decide if they want to fail if /etc/netconfig
does not exist... Why should a library make that type of assumption
on behalf of an application?
  
> 
> It also appears that your new logic might assume the values of "tcp" and
> "udp" when an admin purposely excludes them from /etc/netconfig.  What
> if an admin wants to start only IPv6 listeners for statd, nfsd, and
> mountd?  Somehow, mounting "tcp" and "udp" still work, even though we
> claim in the man page that these are netids, not protocol names.  That
> would be a bug.
If values are read out /etc/netconfig, this code will not be deployed...
that's now people can setup IPv6 only listeners... 


steved.

