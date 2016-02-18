Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:40827 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947971AbcBRUyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 15:54:44 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: Ian Kent <raven@themaw.net>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
        Oleg Nesterov <oleg@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bfields@fieldses.org,
        bharrosh@panasas.com,
        Linux Containers <containers@lists.linux-foundation.org>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	<20131112004703.GB15377@kroah.com>
	<20131112061201.04cf25ab@tlielax.poochiereds.net>
	<528226EC.4050701@parallels.com>
	<20131112083043.0ab78e67@tlielax.poochiereds.net>
	<5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
	<20131118172844.GA10005@redhat.com>
	<1455149857.2903.9.camel@themaw.net>
	<8737sq4teb.fsf@x220.int.ebiederm.org>
	<56C53DE3.1070108@jp.fujitsu.com>
	<1455777387.3188.24.camel@themaw.net>
	<1455781033.2908.5.camel@themaw.net>
Date: Thu, 18 Feb 2016 14:45:03 -0600
In-Reply-To: <1455781033.2908.5.camel@themaw.net> (Ian Kent's message of "Thu,
	18 Feb 2016 15:37:13 +0800")
Message-ID: <87r3g9ychc.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: call_usermodehelper in containers
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ian Kent <raven@themaw.net> writes:

> On Thu, 2016-02-18 at 14:36 +0800, Ian Kent wrote:
>> On Thu, 2016-02-18 at 12:43 +0900, Kamezawa Hiroyuki wrote:
>> > On 2016/02/18 11:57, Eric W. Biederman wrote:
>> > > 
>> > > Ccing The containers list because a related discussion is
>> > > happening
>> > > there
>> > > and somehow this thread has never made it there.
>> > > 
>> > > Ian Kent <raven@themaw.net> writes:
>> > > 
>> > > > On Mon, 2013-11-18 at 18:28 +0100, Oleg Nesterov wrote:
>> > > > > On 11/15, Eric W. Biederman wrote:
>> > > > > > 
>> > > > > > I don't understand that one.  Having a preforked thread with
>> > > > > > the
>> > > > > > proper
>> > > > > > environment that can act like kthreadd in terms of spawning
>> > > > > > user
>> > > > > > mode
>> > > > > > helpers works and is simple.
>> > > > 
>> > > > Forgive me replying to such an old thread but ...
>> > > > 
>> > > > After realizing workqueues can't be used to pre-create threads
>> > > > to
>> > > > run
>> > > > usermode helpers I've returned to look at this.
>> > > 
>> > > If someone can wind up with a good implementation I will be happy.
>> > > 
>> > > > > Can't we ask ->child_reaper to create the non-daemonized
>> > > > > kernel
>> > > > > thread
>> > > > > with the "right" ->nsproxy, ->fs, etc?
>> > > > 
>> > > > Eric, do you think this approach would be sufficient too?
>> > > > 
>> > > > Probably wouldn't be quite right for user namespaces but should
>> > > > provide
>> > > > what's needed for other cases?
>> > > > 
>> > > > It certainly has the advantage of not having to maintain a
>> > > > plague
>> > > > of
>> > > > processes waiting around to execute helpers.
>> > > 
>> > > That certainly sounds attractive.  Especially for the case of
>> > > everyone
>> > > who wants to set a core pattern in a container.
>> > > 
>> > > I am fuzzy on all of the details right now, but what I do remember
>> > > is
>> > > that in the kernel the user mode helper concepts when they
>> > > attempted
>> > > to
>> > > scrub a processes environment were quite error prone until we
>> > > managed to
>> > > get kthreadd(pid 2) on the scene which always had a clean
>> > > environment.
>> > > 
>> > > If we are going to tie this kind of thing to the pid namespace I
>> > > recommend simplying denying it if you are in a user namespace
>> > > without
>> > > an approrpriate pid namespace.  AKA simply not allowing thigns to
>> > > be
>> > > setup
>> > > if current->pid_ns->user_ns != current->user_ns.
>> > > 
>> > Can't be handled by simple capability like CAP_SYS_USERMODEHELPER ?

I wasn't talking about a capability I was talking about how to identify
where the user mode helper lives.

>> > User_ns check seems not to allow core-dump-cather in host will not
>> > work if user_ns is used.

The bottom line is all of this approaches non-sense if user namespaces
are not used.  If you just have a pid namespace or a mount namespace (or
perhaps both) and your fire off a new fangled user mode helper you get a
deep problem.  The user space process started to handle your core dump or
your nfs callback will have a full set of capabilities (because it is
still in the root user namespace).  With a full set of capabilities
and perhaps a little luck there is no containment.

The imperfect solution that currently exists for the core dump helper
is to provide enough information to the user space application that
it can query and find out the context of the core dumping application
and keep everything in that application sandbox if it so desires.
I expect something similar could be done for other user mode helper
style callbacks.

To make starting the user space application other than how we do today
needs a good argument that you are you can allow a lesser privileged
process set things up and that it can be exploited to gain privielge.

>> I don't think so but I'm not sure.
>> 
>> The approach I was talking about assumes the init process of the
>> caller
>> (say within a container, corresponding to ->child_reaper) is an
>> appropriate template for umh thread execution.
>> 
>> But I don't think that covers the case where unshare has created
>> different namespaces, like a mount namespace for example.
>> 
>> The current workqueue sub system can't be used to pre-create a thread
>> to
>> be used for umh execution so, either is needs changes or yet another
>> mechanism needs to be implemented.
>> 
>> For uses other than core dumping capturing a reference to the struct
>> pid
>> of the environment init process and using that as an execution
>> template
>> should be sufficient and takes care of environment existence problems
>> with some extra checks, not to mention eliminating the need for a
>> potentially huge number of kernel threads needing to be created to
>> provide execution templates.
>> 
>> Where to store this and how to access it when needed is another
>> problem.
>> 
>> Not sure a usermode helper capability is the right thing either as I
>> thought one important use of user namespaces was to allow unprivileged
>> users to perform operations they otherwise can't.
>> 
>> Maybe a CAP_SYS_USERNSCOREDUMP or similar would be sensible ....
>> 
>> Still an appropriate execution template would be needed and IIUC we
>> can't trust getting that from within a user created namespace
>> environment.
>
> Perhaps, if a struct cred could be captured at some appropriate time
> that could be used to cater for user namespaces.
>
> Eric, do you think that would be possible to do without allowing users
> to circumvent security?

The general problem with capturing less than a full process is that
we always mess it up and forget to capture something important.

In a lot of ways this is a very simpilar problem to setting up an at job
or a cron job.  You build a script you test it then you tell at to run
it at a certain time and it fails, because your working environment did
not include something important that was in your actuall environment.

Unfortunately in this case the failures we are talking about are
container escapes and privilege escalation, so we do need to tread
carefully.

We might be able to safely define the context as the context of the
currently running init process (Which we can identifiy with a struct
pid).  Justifying that looks a little trickier but doable.

After a mechanism is picked it simply becomes a case of making certain
your permission checks for starting something are in sync with your
mechanism.

Personally I am a fan of the don't be clever and capture a kernel thread
approach as it is very easy to see you what if any exploitation
opportunities there are.  The justifications for something more clever
is trickier.  Of course we do something that from this perspective would
be considered ``clever'' today with kthreadd and user mode helpers.

Eric
