Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51695 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740AbaLIUWt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 15:22:49 -0500
Received: from zeus.hardeman.nu (ppp-93-104-122-8.dynamic.mnet-online.de [93.104.122.8])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by vader.hardeman.nu (Postfix) with ESMTPSA id 3C4E491D
	for <linux-nfs@vger.kernel.org>; Tue,  9 Dec 2014 21:22:48 +0100 (CET)
Date: Tue, 9 Dec 2014 21:22:39 +0100
From: David =?iso-8859-1?Q?H=E4rdeman?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141209202239.GB31849@hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
 <548725DF.9000202@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <548725DF.9000202@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 09, 2014 at 11:39:59AM -0500, Steve Dickson wrote:
>Hello,
>
>On 12/09/2014 12:40 AM, David Härdeman wrote:
>> The following series converts gssd to use libevent and inotify instead
>> of a handrolled event loop and dnotify. Lots of cleanups in the process
>> (e.g. removing a lot of arbitrary limitations and fixed size buffers).
>> 
>> All in all a nice reduction in code size (what can I say, I was bored).
>
>I just have to asked... Does this patch set solve a problem? Fix a Bug?
>I know you said you were bored :-) but what was your motivation?

The starting point was/is that I already have a working nfs4/krb5 setup
and I want to add a couple of OpenELEC clients to my network. OpenELEC
doesn't support NFSv4 today and it doesn't support krb5 (both idmap and
gssd are unavailable). So I started mukcing about trying to provide an
OpenELEC nfs-utils package...as part of that I reviewed the gssd
code...and I just got caught up in the moment :)

>The reason I ask is this patch set just scream out to me were "fixing 
>something that is not broken".

It's not broken as far as I can tell (only things that appeared to be so
were: the TAILQ_* macros which have no safe version of TAILQ_FOREACH
which allows list manipulation, signals that might cause lots of -EINTR
from various syscalls and a general overreliance on fixed length buffers
(boo).

The TAILQ thing isn't solved by my patch but that's on my radar for the
future.

>Plus rewrites like this eliminate years 
>of testing and stability, so we can't take it lightly. gssd is now
>an important part of all nfs client mounts... 

Agreed. Though I believe regressions would be noticed rather
quickly...and the ensuing screams would be rather loud? I might be
mistaken though...

>That said, I did read through the set and there is definitely some
>good/needed cleanup as well some superfluous changes which is fine..

Yes, kinda hard to avoid the superfluous stuff when you're mucking about
with everything else...at least for me...

>Its obvious you do have a clue and you spent some time on them.. 

Starting to sound like a job posting :)

>So by no means I am against these patches. I guess I need a reason 
>to apply them... ;-) What do they fix? Are these patches leading use 
>down to a better place? Is there a noticeable performance gain?  

I don't have the big iron to test the scenarios where there might be a
performance gain. I guess the important things to note are:

a) The old code does a complete rescan on every single change; and
b) The old code keeps one fd open for each directory

And...on a more objective level...the new code is more readable and
understandable...the old code was....less so (IMHO).

>Finally, why the "change dnotify to inotify" a good thing? 

Supra.

>> I've even managed to mount NFS shares with the patched server :)
>Was that mount at least a secure mount? ;-)

Yep..

>Seriously was that all the testing that done?

Yep. It runs now in my network...but I have one server and maybe 2-3
clients on average...

>Again, thank you for your time!

NP...I understand your concerns :)

//David

