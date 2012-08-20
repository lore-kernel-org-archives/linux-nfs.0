Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:49819 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756822Ab2HTPLE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Aug 2012 11:11:04 -0400
Message-ID: <50325384.9070506@parallels.com>
Date: Mon, 20 Aug 2012 19:11:00 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>, "neilb@suse.de" <neilb@suse.de>
Subject: Re: [PATCH v3] SUNRPC: protect service sockets lists during per-net
 shutdown
References: <20120703125851.3850.86782.stgit@localhost.localdomain> <20120724194036.GK8570@fieldses.org> <20120816192902.GB4385@fieldses.org> <50321A0D.1020904@parallels.com> <20120820145656.GB1411@fieldses.org>
In-Reply-To: <20120820145656.GB1411@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

20.08.2012 18:56, J. Bruce Fields пишет:
> On Mon, Aug 20, 2012 at 03:05:49PM +0400, Stanislav Kinsbursky wrote:
>> 16.08.2012 23:29, J. Bruce Fields пишет:
>>> Looking back at this:
>>>
>>> 	- adding the sv_lock looks like the right thing to do anyway
>>> 	  independent of containers, because svc_age_temp_xprts may
>>> 	  still be running.
>>>
>>> 	- I'm increasingly unhappy about sharing rpc servers between
>>> 	  network namespaces.  Everything would be easier to understand
>>> 	  if they were independent.  Can we figure out how to do that?
>>>
>>
>> Could you, please, elaborate on your your unhappiness?
>
> It seems like you're having to do a lot of work on each individual rpc
> server (callback server, lockd, etc.) to make per-net startup/shutdown
> work.  And then we still don't have it quite right (see the shutdown
> races).)
>
> In general whenever we have the opportunity to have entirely separate
> data structures, I'd expect that to simplify things: it should eliminate
> some locking and reference-counting issues.
>

Agreed. But current solution still looks like the easies way to me to implement 
desired functionality.

>> I.e. I don't like it too. But the problem here, is that rpc server
>> is tied with kernel threads creation and destruction. And these
>> threads can be only a part of initial pid namespace (because we have
>> only one kthreadd). And we decided do not create new kernel thread
>> per container when were discussing the problem last time.
>
> There really should be some way to create a kernel thread in a specific
> namespace, shouldn't there?
>


Kthreads support in a container is rather a "political" problem, than an 
implementation problem.

Currently, when you call kthread_create(), you add new job to kthreadd queue. 
Kthreadd is unique, starts right after init and lives in global initial 
environment. So, any kthread inherits namespaces from it.
Of course, we can start one kthread per environment and change it's root or even 
network namespace in kthread function. But pid namespace of this kthread will 
remain global.
It looks like not a big problem, when we shutdown kthread by some variable. But 
what about killable nfsd kthreads?
1) We can't kill them from nested pid namespace.
2) How we will differ nfsd kthreads in initial pid namespace?

In OpenVZ we have kthreadd per pid hamespace and it allows us to create kthreads 
(and thus services) per pid namespace.

> Until we have that, could the threads be taught to fix their namespace
> on startup?
>

Unfortunately, changing of pid namespace for kthreads doesn't look like an easy 
trick.

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
