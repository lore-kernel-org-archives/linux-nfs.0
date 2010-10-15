Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:27086 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756013Ab0JOQBs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Oct 2010 12:01:48 -0400
Subject: Re: whither NFS umount?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CB8531B.60902@RedHat.com>
Date: Fri, 15 Oct 2010 12:00:44 -0400
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <80B45DC6-C650-4660-BE52-CD7DA3951FAC@oracle.com>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>	<1286903046.24878.13.camel@heimdal.trondhjem.org>	<C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>	<20101012151826.76b75f52@corrin.poochiereds.net>	<1286912649.1956.19.camel@heimdal.trondhjem.org>	<4CB5EF15.5030003@RedHat.com>	<20101013141317.66f23906@corrin.poochiereds.net>	<4CB5FE65.3090409@RedHat.com> <20101013145601.468acc2a@corrin.poochiereds.net> <4CB6090F.60301@RedHat.com> <E22DAFE2-A677-4D91-8976-5F641141DD36@oracle.com> <4CB63E81.9010100@RedHat.com> <1BC33C94-1C91-42BE-8FC1-5F85E0D6FABD@oracle.com> <4CB74B90.1050403@RedHat.com> <0F7E614A-3450-48DE-BE44-E0D7CC170B66@oracle.com> <4CB77502.605@RedHat.com> <37D6F414-BDC5-475F-BCC6-27C891D327C0@oracle.com> <4CB8531B.60902@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve -

On Oct 15, 2010, at 9:11 AM, Steve Dickson wrote:

> Good Morning,
> 
> On 10/14/2010 06:22 PM, Chuck Lever wrote:
>> 
>> On Oct 14, 2010, at 5:24 PM, Steve Dickson wrote:
>> 
>>>> The mount protocol information in /proc/mounts can be very very stale
>>> Well the mount(8) man page seems to disagrees with you:
>>> 
>>>   When  the  proc  filesystem is mounted (say at /proc), the files
>>>   /etc/mtab and /proc/mounts have very similar contents. The  former  
>>>   has  somewhat  more  information, such as the mount options used, but is not    
>>>   necessarily  up-to-date  (cf.  the  -n  option below).  It is possible to replace  
>>>   /etc/mtab by a symbolic link to /proc/mounts, and especially when you have
>>>   very large number of mounts things will be much faster with that symlink,
>>>   but some information is lost that way, and in particular using the "user"
>>>   option will fail.
>>> 
>>> They are basically say you should replace /etc/mtab with /proc/mounts.
>> 
>> Right, that text is not written with NFS in mind, unfortunately. 
>> I thought it was common knowledge that replacing /etc/mtab with a link
>> was bad for NFS.
>> 
>> Notice they call out support for the "user" mount option explicitly here.
>> That seems to be an important feature for network file systems.
> My point is staleness.... BOTH /etc/mtab and /proc/mounts "can be very very stale"
> 
>>> . 
>>>> If the mount point is very long lived, as it is for static mount points on 
>>>> server-class systems, the client may have been up for months, while the 
>>>> NFS servers can have rebooted multiple times during that time span.  
>>>> Each server reboot can result in the mount port changing, for example.
>>>> /proc/mounts has the specific set of options that were the result of 
>>>> negotiation during the mount process.  Those will work sometimes, but I 
>>>> think those actually have a good chance of not working in some cases.
>>>> 
>>>> If umount.nfs starts with /proc/mounts, how can it know which of "vers=" 
>>>> and "proto=" and "port=" and "mountport=" were specified on the original 
>>>> command line (and thus are required to make the mount work) and those which
>>>> were negotiated by mount.nfs (and thus may have changed since the original mount)?
>>> Well I don't believe either the proto= or vers= will change
>>> over a server reboot since the values in /proc/mounts are the
>>> were negotiated to...  I do agree both the "port=" and 
>>> "mountport=" can go stale... So many be should just never use them... 
>> 
>> Vers= won't change, which is why we can trust /proc/mounts to tell us what 
>> NFS version to use for the umount.
> proto= will not go stale either... 

That's not trivial.  Remember that proto= controls both the NFS protocol and the mount protocol.

The NFS protocol will not go stale, but the server can easily change the mount protocols it serves, and the clients are none-the-wiser until they attempt another mount operation.

>> mountvers= may go stale, 
>> mountproto= can go stale, 
> I think these going stale would be highly unlikely, but recoverable... 
> 
>> mountport= can also go stale.  For umount, we don't care about port=.  
> True any port value can easily go stale... 
> 
>> The problem is we can't tell whether mountproto and mountport in /proc/mounts
> < was specified on the command line (say, to punch through a firewall) or 
> < was negotiated by user space (and is thus safe to ignore and renegotiate).
> We shouldn't care whether those options were specified or negotiated.

I disagree.

If these options were specified options, it's likely that they were used to get through a firewall.  In that case, we can use these settings and expect the UMNT to work as well as the MNT did.

On the other hand, if these were negotiated options, there are some common cases where the /proc/mounts options won't work.  Your "workaround," if these don't work, is to fall back and retry the UMNT by negotiating.  So: what mount options do you use to start the negotiation with?

We don't need to try and fall back.  Start with the original command line options and negotiate as you did for the original MNT request.  That means you perform a single UMNT try.  My way is less complicated on the wire in these cases, and has more consistent results.  What's more, it's what the code already does today.

> The values in /proc/mounts are the ones that worked! So at one point 
> in time we know all the values in /proc/mounts were valid (since the
> entry exists). This is something that cannot be said about options
> specified on the command line.

Dude, that makes no sense.  The options in /proc/mounts were derived from the options on the command line.  So if the options in /proc/mounts worked, BY DEFINITION the command line options in /etc/mtab worked.

We really must start the negotiation from the original command line options.  Going with the options in /proc/mounts first and then renegotiating if they fail is ass-backwards.

I should also point out that older kernels did not display this information.  Before the kernel groked MNT (2.6.22?) none of this information appears in /proc/mounts.  I'm guessing that using /proc/mounts simply won't work on older kernels the way you want it to.

>> The relationship between mounthost and mountaddr can also change over time.
>> /proc/mounts has mountaddr.  We really want to look up mounthost again to be reliable.
> Fine... Add that to the list that needs to be updated once the first call fails... 

We don't need a "first call" and a "second call."  One call, done with the correct starting options, is all that is necessary, if you start with the original command line options.  Retrying UMNT here is new (and unnecessary) behavior.  The client has everything it needs to negotiate the correct settings the first time.

> 
>>>> So, I'm OK with keeping umount.nfs around for the time being, but
>>>> maybe I have to put my foot down and say we mustn't use /proc/mounts
>>>> for anything but deciding whether the mount point is an NFSv4 mount.  
>>>> I'm happy to volunteer code, and also happy to collaborate with you on a fix.
>>>> I've already spent a lot of time poking at this and coding prototypes, 
>>>> so I'm "invested."
>>> Well talking with the upstream maintainer of the mount command
>>> as soon as the new libmount makes an appearance, there is 
>>> a very really possibility /etc/mtab will be going away... He
>>> says it will be replace with something like /var/run/mount/something
>>> 
>>> So maybe we start looking into how to make /proc/mounts work.
>> 
>> I agree that we should work towards unlinking our mount subcommands from 
>> relying on /etc/mtab.  I don't think the impending presence of 
>> libmount mandates the use of /proc/mounts, though.
> True... All I'm trying to point out is the information in /proc/mounts and 
> /etc/mtab can be equally as good and equally as bad at any point
> in time. 

These are not equivalent pieces of information.

/etc/mtab can contain something like "vers=3" and /proc/mounts might contain "vers=3,mountport=4545,mountproto=tcp,mountaddr=192.168.1.77".  During a UMNT, the latter three of the options might be completely wrong.  Which one do you try first to negotiate?  With the /etc/mtab options, you have a clear starting point from which to re-derive the /proc/mounts options, and a clear method (the same one MNT uses) to derive fresh options.

In utils/mount/stropts.c:nfs_do_mount_v3v2(), the extra_opts string, which is eventually planted in /etc/mtab, is generated _before_ the specific mount options are negotiated by nfs_rewrite_pmap_mount_options() and sent to mount(2).  This is on purpose: we want to record the original mount options here so that umount.nfs can use them to figure out how to do the UMNT in exactly the same way the MNT was negotiated.

On unmount, umount.nfs reads those options from /etc/mtab, and then calls nfs_probe_mntport() to negotiate the settings it needs to do the UMNT.  This already does a negotiation based on the original mount options.  I'm saying: let's be conservative, and not change this logic, because this has the best chance of working.

The options in /proc/mounts worked at one point in time, but /etc/mtab has the options that are probably used every time you do the mount.  They are basically copied from /etc/fstab or the command line.  So we know that, no matter what the server does, the /etc/mtab options are tested and known to allow the client to negotiate the correct settings.

> Now that there is a real possibly that /etc/mtab could deprecated,
> I think we should start looking into making the info in /proc/mounts 
> work, since /proc/mounts not going anywhere... 

Again, I agree /etc/mtab should be deprecated, but we must not use /proc/mounts for this purpose.  Save the original mount options and use them for the umount.  That way the negotiation behavior of the MNT and the behavior of the UMNT follow exactly the same rules.

Let's just write these options to another place besides /etc/mtab, and read them from that place during unmount.  The only change I'm talking about is putting a second copy of these options on disk somewhere.

> 
>> 
>>>> To summarize: instead of relying on /etc/mtab, also use an NFS-specific 
>>>> place to record the same information.  umount.nfs can use that 
>>>> instead of /etc/mtab.  And by the way, we don't touch this information
>>>> during a remount... heh.  That guarantees that we preserve existing 
>>>> good behaviors of umount.nfs, continue to update /etc/mtab as documented,
>>>> until maybe it goes away, but eliminate our functional dependence on it.
>>>> 
>>> If the info in /etc/mntab is not updated on remounts, then what is 
>>> the issue we are talking about? Just curious, will the info in /proc/mounts
>>> be updated on remounts?
>> 
>> /etc/mtab would still be updated on remounts, and would still have the 
>> bug where "remount" would wipe the options.  But we would no longer depend
>> on that destroyed information to perform the umount reliably.
> The remount would wipe out the *original* options, basically overriding
> them with the updated options... As long as we have a mechanism to
> retry the UMNT if the first call fails, I don't see this a being a 
> problem... 

The "problem" is where do you start the renegotiation?  You need the original mount options to do that reliably.

> 
>> This new stash of information I'm proposing would not be altered by a
>> remount.  It sounds like we would need to store only the MNT protocol 
>> related options, described above.
>> 
>> In /proc/mounts, the NFS-specific mount options aren't supposed to 
>> change at all on a remount.  Only the generic mount options 
>> ("sync", "ro", etc) should change.
> Could you please point me to where the above rule is mandated...
> I had know idea there were rules of what can and cannot be
> changed in /proc/mounts... tia...

Go look at the kernel mount code in fs/nfs/super.c, and you will see that we don't allow any NFS options save a select few to change on a remount.  nfs_compare_remount_data() requires that most all the important options like rsize and transport and server address are not allowed to change.  But that's a red herring, I think.

We've relented on getting rid of umount.nfs, and we've relented on not performing UMNT.  You won both of those.  I think it's time for you to concede and do this little tiny piece my way, not the least because my way results in less change in behavior than using /proc/mounts, is more efficient on the wire, on average, is backwards compatible with older kernels (unlike using /proc/mounts), and will result in more reliable UMNT results in all cases.

-- 
chuck[dot]lever[at]oracle[dot]com




