Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756871Ab0JOUIs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 16:08:48 -0400
Message-ID: <4CB8B4BC.7070800@RedHat.com>
Date: Fri, 15 Oct 2010 16:08:28 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: whither NFS umount?
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>	<1286903046.24878.13.camel@heimdal.trondhjem.org>	<C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>	<20101012151826.76b75f52@corrin.poochiereds.net>	<1286912649.1956.19.camel@heimdal.trondhjem.org>	<4CB5EF15.5030003@RedHat.com>	<20101013141317.66f23906@corrin.poochiereds.net>	<4CB5FE65.3090409@RedHat.com> <20101013145601.468acc2a@corrin.poochiereds.net> <4CB6090F.60301@RedHat.com> <E22DAFE2-A677-4D91-8976-5F641141DD36@oracle.com> <4CB63E81.9010100@RedHat.com> <1BC33C94-1C91-42BE-8FC1-5F85E0D6FABD@oracle.com> <4CB74B90.1050403@RedHat.com> <0F7E614A-3450-48DE-BE44-E0D7CC170B66@oracle.com> <4CB77502.605@RedHat.com> <37D6F414-BDC5-475F-BCC6-27C891D327C0@oracle.com> <4CB8531B.60902@RedHat.com> <80B45DC6-C650-4660-BE52-CD7DA3951FAC@oracle.com>
In-Reply-To: <80B45DC6-C650-4660-BE52-CD7DA3951FAC@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10/15/2010 12:00 PM, Chuck Lever wrote:
> On Oct 15, 2010, at 9:11 AM, Steve Dickson wrote:
>>>> . 
>>>>> If the mount point is very long lived, as it is for static mount points on 
>>>>> server-class systems, the client may have been up for months, while the 
>>>>> NFS servers can have rebooted multiple times during that time span.  
>>>>> Each server reboot can result in the mount port changing, for example.
>>>>> /proc/mounts has the specific set of options that were the result of 
>>>>> negotiation during the mount process.  Those will work sometimes, but I 
>>>>> think those actually have a good chance of not working in some cases.
>>>>>
>>>>> If umount.nfs starts with /proc/mounts, how can it know which of "vers=" 
>>>>> and "proto=" and "port=" and "mountport=" were specified on the original 
>>>>> command line (and thus are required to make the mount work) and those which
>>>>> were negotiated by mount.nfs (and thus may have changed since the original mount)?
>>>> Well I don't believe either the proto= or vers= will change
>>>> over a server reboot since the values in /proc/mounts are the
>>>> were negotiated to...  I do agree both the "port=" and 
>>>> "mountport=" can go stale... So many be should just never use them... 
>>>
>>> Vers= won't change, which is why we can trust /proc/mounts to tell us what 
>>> NFS version to use for the umount.
>> proto= will not go stale either... 
> 
> That's not trivial.  Remember that proto= controls both the NFS protocol and 
> the mount protocol.
> 
> The NFS protocol will not go stale, but the server can easily change the 
> mount protocols it serves, and the clients are none-the-wiser until they 
> attempt another mount operation.
That was my point the NFS protocol (which is the proto=) in /proc/mounts
will not go stale and the mountproto= can go stale but is very unlikely.

>>
>>> The problem is we can't tell whether mountproto and mountport in /proc/mounts
>> < was specified on the command line (say, to punch through a firewall) or 
>> < was negotiated by user space (and is thus safe to ignore and renegotiate).
>> We shouldn't care whether those options were specified or negotiated.
> 
> I disagree.
> 
> If these options were specified options, it's likely that they were used to get 
> through a firewall.  In that case, we can use these settings and expect 
> the UMNT to work as well as the MNT did.
And those specified options will be the ones found in /proc/mounts.

> 
> On the other hand, if these were negotiated options, there are some 
> common cases where the /proc/mounts options won't work. 
I agree they will not only if the server is rebooted and
the server daemons are not listening on the same port.. 

> Your "workaround," if these don't work, is to fall back and retry the UMNT 
> by negotiating.  So: what mount options do you use to start the negotiation with?
I guess I was thinking just blindly try the options in /proc/mounts first,
since those will work unless the server has been reboot and are listening
on different port. If that fails I guess we start negotiation scratch.. 
 
> 
> We don't need to try and fall back.  Start with the original command line 
> options and negotiate as you did for the original MNT request.  That means 
> you perform a single UMNT try.  My way is less complicated on the wire in 
> these cases, and has more consistent results.  What's more, it's what the 
> code already does today.
> 
>> The values in /proc/mounts are the ones that worked! So at one point 
>> in time we know all the values in /proc/mounts were valid (since the
>> entry exists). This is something that cannot be said about options
>> specified on the command line.
> 
> Dude, that makes no sense.  The options in /proc/mounts were derived from 
> the options on the command line.  So if the options in /proc/mounts worked,
> BY DEFINITION the command line options in /etc/mtab worked.
> 
> We really must start the negotiation from the original command line options.
> Going with the options in /proc/mounts first and then renegotiating if they
> fail is ass-backwards.
Well it turn out that using /proc/mounts is not quite that "ass-backwards"
or senses... 8-) because the current code uses /proc/mounts when /etc/mtab 
does not exist... and work just as expected... So I'm happy with that..

>>
>>>>> So, I'm OK with keeping umount.nfs around for the time being, but
>>>>> maybe I have to put my foot down and say we mustn't use /proc/mounts
>>>>> for anything but deciding whether the mount point is an NFSv4 mount.  
>>>>> I'm happy to volunteer code, and also happy to collaborate with you on a fix.
>>>>> I've already spent a lot of time poking at this and coding prototypes, 
>>>>> so I'm "invested."
>>>> Well talking with the upstream maintainer of the mount command
>>>> as soon as the new libmount makes an appearance, there is 
>>>> a very really possibility /etc/mtab will be going away... He
>>>> says it will be replace with something like /var/run/mount/something
>>>>
>>>> So maybe we start looking into how to make /proc/mounts work.
>>>
>>> I agree that we should work towards unlinking our mount subcommands from 
>>> relying on /etc/mtab.  I don't think the impending presence of 
>>> libmount mandates the use of /proc/mounts, though.
>> True... All I'm trying to point out is the information in /proc/mounts and 
>> /etc/mtab can be equally as good and equally as bad at any point
>> in time. 
> 
> These are not equivalent pieces of information.
I think we can agree to disagree... ;-) Given the fact we are
currently using /proc/mounts in a back up makes me feel 
confident we could use it when /etc/mtab goes away.. 

> 
> The options in /proc/mounts worked at one point in time, but /etc/mtab 
> has the options that are probably used every time you do the mount.  
> They are basically copied from /etc/fstab or the command line.  So we know
> that, no matter what the server does, the /etc/mtab options are tested and
> known to allow the client to negotiate the correct settings.
> 
>> Now that there is a real possibly that /etc/mtab could deprecated,
>> I think we should start looking into making the info in /proc/mounts 
>> work, since /proc/mounts not going anywhere... 
> 
> Again, I agree /etc/mtab should be deprecated, but we must not use 
> /proc/mounts for this purpose.  Save the original mount options and 
> use them for the umount.  That way the negotiation behavior of the MNT 
> and the behavior of the UMNT follow exactly the same rules.
As I've said, we already do use /proc/mounts which is fine.. IMHO.. 

> 
> Let's just write these options to another place besides /etc/mtab, 
> and read them from that place during unmount.  The only change I'm 
> talking about is putting a second copy of these options on disk somewhere.
> 
I don't think I'm a fan of creating yet another non-scalable
list we need to maintain.. but that's for another day.. if/when
/etc/mtab goes away.. 

For now, I agree with you, lets keep using /etc/mtab to 
maintain the original options...  

>>> In /proc/mounts, the NFS-specific mount options aren't supposed to 
>>> change at all on a remount.  Only the generic mount options 
>>> ("sync", "ro", etc) should change.
>> Could you please point me to where the above rule is mandated...
>> I had know idea there were rules of what can and cannot be
>> changed in /proc/mounts... tia...
> 
> Go look at the kernel mount code in fs/nfs/super.c, and you will see that
> we don't allow any NFS options save a select few to change on a remount.
> nfs_compare_remount_data() requires that most all the important
> options like rsize and transport and server address are not allowed to change. 
> But that's a red herring, I think.
Thanks for pointing this out...I'll take a look..

steved.

