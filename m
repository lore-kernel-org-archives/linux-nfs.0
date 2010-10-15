Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17490 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754301Ab0JONM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 09:12:27 -0400
Message-ID: <4CB8531B.60902@RedHat.com>
Date: Fri, 15 Oct 2010 09:11:55 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: whither NFS umount?
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>	<1286903046.24878.13.camel@heimdal.trondhjem.org>	<C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>	<20101012151826.76b75f52@corrin.poochiereds.net>	<1286912649.1956.19.camel@heimdal.trondhjem.org>	<4CB5EF15.5030003@RedHat.com>	<20101013141317.66f23906@corrin.poochiereds.net>	<4CB5FE65.3090409@RedHat.com> <20101013145601.468acc2a@corrin.poochiereds.net> <4CB6090F.60301@RedHat.com> <E22DAFE2-A677-4D91-8976-5F641141DD36@oracle.com> <4CB63E81.9010100@RedHat.com> <1BC33C94-1C91-42BE-8FC1-5F85E0D6FABD@oracle.com> <4CB74B90.1050403@RedHat.com> <0F7E614A-3450-48DE-BE44-E0D7CC170B66@oracle.com> <4CB77502.605@RedHat.com> <37D6F414-BDC5-475F-BCC6-27C891D327C0@oracle.com>
In-Reply-To: <37D6F414-BDC5-475F-BCC6-27C891D327C0@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Good Morning,

On 10/14/2010 06:22 PM, Chuck Lever wrote:
> 
> On Oct 14, 2010, at 5:24 PM, Steve Dickson wrote:
>
>>> The mount protocol information in /proc/mounts can be very very stale
>> Well the mount(8) man page seems to disagrees with you:
>>
>>    When  the  proc  filesystem is mounted (say at /proc), the files
>>    /etc/mtab and /proc/mounts have very similar contents. The  former  
>>    has  somewhat  more  information, such as the mount options used, but is not    
>>    necessarily  up-to-date  (cf.  the  -n  option below).  It is possible to replace  
>>    /etc/mtab by a symbolic link to /proc/mounts, and especially when you have
>>    very large number of mounts things will be much faster with that symlink,
>>    but some information is lost that way, and in particular using the "user"
>>    option will fail.
>>
>> They are basically say you should replace /etc/mtab with /proc/mounts.
> 
> Right, that text is not written with NFS in mind, unfortunately. 
> I thought it was common knowledge that replacing /etc/mtab with a link
> was bad for NFS.
> 
> Notice they call out support for the "user" mount option explicitly here.
> That seems to be an important feature for network file systems.
My point is staleness.... BOTH /etc/mtab and /proc/mounts "can be very very stale"

>> . 
>>> If the mount point is very long lived, as it is for static mount points on 
>>> server-class systems, the client may have been up for months, while the 
>>> NFS servers can have rebooted multiple times during that time span.  
>>> Each server reboot can result in the mount port changing, for example.
>>> /proc/mounts has the specific set of options that were the result of 
>>> negotiation during the mount process.  Those will work sometimes, but I 
>>> think those actually have a good chance of not working in some cases.
>>>
>>> If umount.nfs starts with /proc/mounts, how can it know which of "vers=" 
>>> and "proto=" and "port=" and "mountport=" were specified on the original 
>>> command line (and thus are required to make the mount work) and those which
>>> were negotiated by mount.nfs (and thus may have changed since the original mount)?
>> Well I don't believe either the proto= or vers= will change
>> over a server reboot since the values in /proc/mounts are the
>> were negotiated to...  I do agree both the "port=" and 
>> "mountport=" can go stale... So many be should just never use them... 
> 
> Vers= won't change, which is why we can trust /proc/mounts to tell us what 
> NFS version to use for the umount.
proto= will not go stale either... 

> 
> mountvers= may go stale, 
> mountproto= can go stale, 
I think these going stale would be highly unlikely, but recoverable... 

> mountport= can also go stale.  For umount, we don't care about port=.  
True any port value can easily go stale... 

> The problem is we can't tell whether mountproto and mountport in /proc/mounts
< was specified on the command line (say, to punch through a firewall) or 
< was negotiated by user space (and is thus safe to ignore and renegotiate).
We shouldn't care whether those options were specified or negotiated.
The values in /proc/mounts are the ones that worked! So at one point 
in time we know all the values in /proc/mounts were valid (since the
entry exists). This is something that cannot be said about options
specified on the command line.

> 
> The relationship between mounthost and mountaddr can also change over time.
> /proc/mounts has mountaddr.  We really want to look up mounthost again to be reliable.
Fine... Add that to the list that needs to be updated once the first call fails... 

> 
>>> So, preserving the original mount options somewhere and using that as the
>>> starting point for negotiation during the umount is the best way to ensure
>>> that a UMNT request will get to the server, in my opinion, not the least 
>>> because that's the intent of the code we have now.
>>>
>>> I think there are more cases when using /proc/mounts will be worse than 
>>> using /etc/mtab, and thus we'll get worse behavior on UMNT than we have
>>> today in some cases.  If this weren't true, I think we would have 
>>> embraced /proc/mounts already.  I consider a change to use /proc/mounts 
>>> as risky as a change to not send UMNT at all.
>> Can you outline these cases? The only thing I think can go stale
>> is the port numbers... Everything else should stay relatively 
>> valid... as I just stated... 
> 
> See above.  The options we care about for doing an umount reliably can go 
> stale, and there's no way to tell if the information in /proc/mounts 
> was specified on purpose or negotiated automatically.
My point is it really does not matter... the values in /proc/mounts
allowed the mount to succeed at one point and that's not a bad place
to start from... IMHO... 

> 
>>> So, I'm OK with keeping umount.nfs around for the time being, but
>>> maybe I have to put my foot down and say we mustn't use /proc/mounts
>>> for anything but deciding whether the mount point is an NFSv4 mount.  
>>> I'm happy to volunteer code, and also happy to collaborate with you on a fix.
>>> I've already spent a lot of time poking at this and coding prototypes, 
>>> so I'm "invested."
>> Well talking with the upstream maintainer of the mount command
>> as soon as the new libmount makes an appearance, there is 
>> a very really possibility /etc/mtab will be going away... He
>> says it will be replace with something like /var/run/mount/something
>>
>> So maybe we start looking into how to make /proc/mounts work.
> 
> I agree that we should work towards unlinking our mount subcommands from 
> relying on /etc/mtab.  I don't think the impending presence of 
> libmount mandates the use of /proc/mounts, though.
True... All I'm trying to point out is the information in /proc/mounts and 
/etc/mtab can be equally as good and equally as bad at any point
in time. 
 
Now that there is a real possibly that /etc/mtab could deprecated,
I think we should start looking into making the info in /proc/mounts 
work, since /proc/mounts not going anywhere... 

> 
>>> To summarize: instead of relying on /etc/mtab, also use an NFS-specific 
>>> place to record the same information.  umount.nfs can use that 
>>> instead of /etc/mtab.  And by the way, we don't touch this information
>>> during a remount... heh.  That guarantees that we preserve existing 
>>> good behaviors of umount.nfs, continue to update /etc/mtab as documented,
>>> until maybe it goes away, but eliminate our functional dependence on it.
>>>
>> If the info in /etc/mntab is not updated on remounts, then what is 
>> the issue we are talking about? Just curious, will the info in /proc/mounts
>> be updated on remounts?
> 
> /etc/mtab would still be updated on remounts, and would still have the 
> bug where "remount" would wipe the options.  But we would no longer depend
> on that destroyed information to perform the umount reliably.
The remount would wipe out the *original* options, basically overriding
them with the updated options... As long as we have a mechanism to
retry the UMNT if the first call fails, I don't see this a being a 
problem... 
 
> 
> This new stash of information I'm proposing would not be altered by a
> remount.  It sounds like we would need to store only the MNT protocol 
> related options, described above.
> 
> In /proc/mounts, the NFS-specific mount options aren't supposed to 
> change at all on a remount.  Only the generic mount options 
> ("sync", "ro", etc) should change.
Could you please point me to where the above rule is mandated...
I had know idea there were rules of what can and cannot be
changed in /proc/mounts... tia...

steved.

