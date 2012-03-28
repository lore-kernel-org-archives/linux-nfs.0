Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:35764 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932293Ab2C1VnF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 17:43:05 -0400
Message-ID: <4F7385AC.1070605@panasas.com>
Date: Wed, 28 Mar 2012 14:42:04 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        <linux-security-module@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg Kroah-Hartman <gregkh@suse.de>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        "keyrings@linux-nfs.org" <keyrings@linux-nfs.org>
Subject: Re: [PATCHSET 0/6 version 2] kmod: Optional timeout on the wait in
 call_usermodehelper_exec
References: <4F691059.30405@panasas.com> <4F711EA2.4030608@panasas.com> <20120327140709.60ab7bda.akpm@linux-foundation.org> <20120328201904.GA4517@redhat.com>
In-Reply-To: <20120328201904.GA4517@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On 03/27, Andrew Morton wrote:

>>
>> IOW, please explain at some length why you need this.  Do you think
>> that there are existing call sites which can usefully use this feature?
>> Do you expect that new callers are likely to need this?  etcetera.
> 


Andrew Hi.

Yes all these explanations were on the other thread which started
this one. sorry.

On my next attempt I will also add a user for this API as a last
Patch. So you can see exactly how it makes sense, and why I do
need it. When I started this the user was not in the Kernel
yet, but now it's in for the 3.4-rc1, and it can make things clearer.

But in (very) short. The call is made in some special cases at
the read/write path of NFS. I have a very clean way out if
the call fails for any reason, not only timeout, it can fail
and properly handled in many other cases as well.

So early failure does not scare me, what does scare me a lot is
if it will get stuck (deadlocked) forever. This will eventually do
very bad things to the NFS client.

So the very easy thing to do is just add the proper timeout parameter
to existing wait_for_completion calls. If it means some cleanups and code
reorganization met on the way I don't mind.

And yes, I expect that a lot of users that now use UMH_WAIT_PROC
which need to sync with the app, will enjoy the timeout, just as I do.
And all users should be revisited and perhaps enhanced with the extra
robustness this gives.

BTW: Currently the script ran - "osd_login", as submitted
to the nfs-utils package maintainer, has a user-mode "watchdog"
sub-process that will kill the parent after a timeout. But I would not
like to rely on user-mode for this. There are plenty of other things
that can go wrong. I'd like the Kernel to be independent. Also in light
that the script may slightly change from distro to distro and is not
totally in my control.

On 03/28/2012 01:19 PM, Oleg Nesterov wrote:
> Cough. Can't resist... Could you also explain why
> http://marc.info/?l=linux-nfs&m=133252084301205 can't work?
> 


Because it's another thread and another wait object and all bunch of
other allocations, where I already have 3 forks now. I don't do that
because the Politics to get new code in the Kernel is hard.

I'm utilizing all the current resources and am just exposing currently
hard coded constants to upper API's but in effect I'm not degrading
the hot path *at all*. I'll never do what you suggest it's a total waist
when the right way is just doing what is done today, only cleaned and
exposed.

> To clarify, I am just curious, I am not arguing. I am asking because

> if UMH_WAIT_PROC(timeout) fails with -ETIMEDOUT, then perhaps it makes
> sense to not "leak" the user-space process servicing the kernel request
> we were waiting for.
> 


Hopefully it is not leaked, right? It will eventually return and de-allocate.
Do you mean that I should kill it? that's an additional mess in kmod.c.

But it's a good point I'll make it killable, and an admin can kill it if it's
really deadlocked forever.

> Oleg.
> 


Thanks
Boaz
