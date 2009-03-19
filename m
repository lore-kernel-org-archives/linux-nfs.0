From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: The next step: nfsvers=4
Date: Thu, 19 Mar 2009 14:13:29 -0400
Message-ID: <1FF921B7-4A44-49D7-8E01-1DAC5D18C1AB@oracle.com>
References: <49C2704F.5050303@RedHat.com> <7A24DF798E223B4C9864E8F92E8C93EC026043D3@SACMVEXC1-PRD.hq.netapp.com> <855593AD-7541-443F-BA92-491EC32FEDFB@oracle.com> <49C28201.1020301@panasas.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:41406 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760218AbZCSSOL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2009 14:14:11 -0400
In-Reply-To: <49C28201.1020301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 19, 2009, at Mar 19, 2009, 1:33 PM, Benny Halevy wrote:
> On Mar. 19, 2009, 18:43 +0200, Chuck Lever <chuck.lever@oracle.com>  
> wrote:
>> On Mar 19, 2009, at Mar 19, 2009, 12:34 PM, Muntz, Daniel wrote:
>>>> -----Original Message-----
>>>> From: Steve Dickson [mailto:SteveD@redhat.com]
>>>> Sent: Thursday, March 19, 2009 9:18 AM
>>>> To: linux NFS Mailing list
>>>> Subject: The next step: nfsvers=4
>>>>
>>>> As I see it, the next step to seamlessly move to V4 as the
>>>> default is to make 'mount -o nfsvers=4' actually do a v4 mount...
>>>>
>>>> There are two obvious place we can make this change.
>>>> In the kernel and/or in the mount command...
>>>>
>>>> Looking at the kernel, since v3 and v4 truly two different
>>>> file systems its seems a bit late for the nfs_get_sb() to all
>>>> of sudden have to change file system type. Meaning when
>>>> nfs_get_sb() sees the "nfsvers=4" somehow it would have to
>>>> back out and call nfs4_get_sb(), which obviously is a bit hacky....
>>>>
>>>> Now I guess we could have one nfs_get_sb() for both v3 and v4.
>>>> Where the nfs_get_sb() could peek into the options data to
>>>> see which version is needed. This would also mean the mount
>>>> command would always have to set a version so when the "nfsvers="
>>>> options is not set, the kernel would know which version to use.
>>>> Again, this feels a bit hacky as well but doable...
>>>>
>>>> At least to me, what seems like the best option is to have
>>>> the mount.nfs binary early on intercept "nfsvers=4" option
>>>> and then change the fs_type to "nfs4", which would allow
>>>> everything to "trickle down" as it does today... Again to me,
>>>> that seem like the least intrusive way to do it...
>>>>
>>>> Comments? Is there other ways?
>>
>> Having the mount.nfs command translate sounds like a pretty easy  
>> thing
>> to prototype.
>>
>>> Whichever way it's done, if v4 becomes the default, don't forget to
>>> also
>>> make the default behavior be that the system will fall back and try
>>> a v3
>>> mount if v4 isn't available.  Otherwise you'll break a huge  
>>> percentage
>>> of your user base.  Of course then you also have to deal with the
>>> semantics of how to specifify "only v4" vs. "try v4 first and fall
>>> back".
>>
>> Today, specifying vers=3 means "I want vers=3 or nothing".  Not
>> specifying any version means the mount command can choose which
>> version to use based on what both sides support.
>>
>> If no vers= option is specified, I don't think it would be difficult
>> for the text-based mount command to try a "nfs4" mount first, and if
>> that fails try an "nfs" mount.
>
> Agreed.
> That's pretty much what we planned to do in the future also
> for minorversion=1, after discussing this also with Trond.
> The principle was that the policy for choosing what versions
> to try and in which order should be determined by the
> user mode utilities since one can think of customers that would
> only want to use nfsv4.1 for its exactly once semantics,
> or others that would want to start with 4.0 and fall back
> to 3 and 2 since trying 4.1 might break their servers, etc.
>
> I think that if no version is specified all versions that
> the client supports should be tried, highest first.
> Otherwise mount.nfs should try only the specified version.

One nit is that the set of mount options supported by nfs4 is  
different than the set supported by nfs.  clientaddr= is supported by  
nfs4, but not by nfs, for example.  I believe that nocto is not  
supported by nfs4.  The mountproto option is only supported by nfs.

If no vers= is specified and only NFSv4 is available on the server,  
but something like "nocto" shows up on the command line mount options,  
do we:

a) fail the mount, or
b) ignore the nocto option

a) seems like the least surprising behavior.

What about "proto=udp" ?  Linux supports UDP for NFSv4, though other  
server implementations probably don't.  If that's specified on a mount  
command line without a vers= option, what version should we choose?

> For implementing more complex policies, maybe we can extend
> the command syntax to accept a range and/or an ordered list
> of versions to try.

Steve mentioned /etc/default/nfs on Solaris.  I could see /etc/ 
sysconfig/nfs on Linux containing a couple of lines defining the range  
of allowable NFS versions, if we think this is necessary.  This is a  
simple pre-existing file, and has little potential for introducing  
negative side-effects.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
