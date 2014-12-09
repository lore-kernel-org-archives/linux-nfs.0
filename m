Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752109AbaLIVOA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 16:14:00 -0500
Message-ID: <54876612.50503@RedHat.com>
Date: Tue, 09 Dec 2014 16:13:54 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?windows-1252?Q?David_H=E4rdeman?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/19] gssd improvements
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu> <548725DF.9000202@RedHat.com> <20141209202239.GB31849@hardeman.nu>
In-Reply-To: <20141209202239.GB31849@hardeman.nu>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 12/09/2014 03:22 PM, David Härdeman wrote:
> On Tue, Dec 09, 2014 at 11:39:59AM -0500, Steve Dickson wrote:
>> Hello,
>>
>> On 12/09/2014 12:40 AM, David Härdeman wrote:
>>> The following series converts gssd to use libevent and inotify instead
>>> of a handrolled event loop and dnotify. Lots of cleanups in the process
>>> (e.g. removing a lot of arbitrary limitations and fixed size buffers).
>>>
>>> All in all a nice reduction in code size (what can I say, I was bored).
>>
>> I just have to asked... Does this patch set solve a problem? Fix a Bug?
>> I know you said you were bored :-) but what was your motivation?
> 
> The starting point was/is that I already have a working nfs4/krb5 setup
> and I want to add a couple of OpenELEC clients to my network. OpenELEC
> doesn't support NFSv4 today and it doesn't support krb5 (both idmap and
> gssd are unavailable). So I started mukcing about trying to provide an
> OpenELEC nfs-utils package...as part of that I reviewed the gssd
> code...and I just got caught up in the moment :)
Fair enough... 

> 
>> The reason I ask is this patch set just scream out to me were "fixing 
>> something that is not broken".
> 
> It's not broken as far as I can tell (only things that appeared to be so
> were: the TAILQ_* macros which have no safe version of TAILQ_FOREACH
> which allows list manipulation, signals that might cause lots of -EINTR
> from various syscalls and a general overreliance on fixed length buffers
> (boo).
> 
> The TAILQ thing isn't solved by my patch but that's on my radar for the
> future.
I have not taken that close of a look.. but I will...

> 
>> Plus rewrites like this eliminate years 
>> of testing and stability, so we can't take it lightly. gssd is now
>> an important part of all nfs client mounts... 
> 
> Agreed. Though I believe regressions would be noticed rather
> quickly...and the ensuing screams would be rather loud? I might be
> mistaken though...
Yeah... They will be screaming at me! not you... 8-)

> 
>> That said, I did read through the set and there is definitely some
>> good/needed cleanup as well some superfluous changes which is fine..
> 
> Yes, kinda hard to avoid the superfluous stuff when you're mucking about
> with everything else...at least for me...
again fair enough...

> 
>> Its obvious you do have a clue and you spent some time on them.. 
> 
> Starting to sound like a job posting :)
It isn't... Just a complement...
 
> 
>> So by no means I am against these patches. I guess I need a reason 
>> to apply them... ;-) What do they fix? Are these patches leading use 
>> down to a better place? Is there a noticeable performance gain?  
> 
> I don't have the big iron to test the scenarios where there might be a
> performance gain. I guess the important things to note are:
> 
> a) The old code does a complete rescan on every single change; and
> b) The old code keeps one fd open for each directory
I did see that... 

> 
> And...on a more objective level...the new code is more readable and
> understandable...the old code was....less so (IMHO).
I did see a lot of code removal... but time will tell... 

> 
>> Finally, why the "change dnotify to inotify" a good thing? 
> 
> Supra.
??

> 
>>> I've even managed to mount NFS shares with the patched server :)
>> Was that mount at least a secure mount? ;-)
> 
> Yep..
> 
>> Seriously was that all the testing that done?
> 
> Yep. It runs now in my network...but I have one server and maybe 2-3
> clients on average...
OK.. 

steved.
