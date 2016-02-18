Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44661 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423890AbcBRD0x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2016 22:26:53 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: Ian Kent <raven@themaw.net>
Cc: skinsbursky@virtuozzo.com,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, oleg@redhat.com,
        bfields@fieldses.org, bharrosh@panasas.com,
        Linux Containers <containers@lists.linux-foundation.org>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	<20131112004703.GB15377@kroah.com>
	<20131112061201.04cf25ab@tlielax.poochiereds.net>
	<528226EC.4050701@parallels.com>
	<20131112083043.0ab78e67@tlielax.poochiereds.net>
	<5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
	<52860B6D.4090208@parallels.com> <1455320373.2890.5.camel@themaw.net>
	<56BF5511.6050606@virtuozzo.com> <1455495082.2941.32.camel@themaw.net>
Date: Wed, 17 Feb 2016 21:17:21 -0600
In-Reply-To: <1455495082.2941.32.camel@themaw.net> (Ian Kent's message of
	"Mon, 15 Feb 2016 08:11:22 +0800")
Message-ID: <874md63dxa.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: call_usermodehelper in containers
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ian Kent <raven@themaw.net> writes:

> AFAICS kernel/kmod.c used to use create_singlethread_workqueue() and
>  queue_work() to perform umh calls, now it uses only queue_work() and
> the system_unbound_wq workqueue.
>
> Looking at the workqueue sub system there doesn't appear to be a way to
> create a workqueue with a thread runner thread, created within the
> process context at the time of workqueue creation, that then waits to
> run work. So there's no way to create a workqueue to run umh calls
> within a specific process context, such as that of a container, by using
> the workqueue subsystem as it is now.
>
> The problem being that the process context of the caller requesting umh
> isn't necessarily (and shouldn't be used because it could allow the
> caller to hijack the environment) the process context that needs to be
> used for the request.
>
> It looks like the reply to this thread from Oleg that demonstrates using
> child_reaper for the run context could be used though. Capturing the
> struct pid of child_reaper and then using that to locate the appropriate
> task context later (if it still exists) at request time could be used.
>
> That doesn't take care of working out when this should be captured or
> where to put it so it can be obtained at request time (which seems
> difficult in itself).

It would be really really nice if the user namespace could be used
for the where do we look at case.  As every other namespace already
has a pointer to the user namespace, and fundamentally the user
namespace is the permission boundary (from a namespace perspective).

So for the equivalent of kthreadd in a user namespace we need a thread
that has a full set of namespaces owned by the user namespaces.

On one side this is very easy to obtain if we look at the process that
sets core_pattern or mounts one of the nfs filesystems (such as the
filesystem that when mounted starts nfsd), and just fork a kernel thread
from it.

On another side perhaps what we want is a syscall call it start_umhd
that says repurpose the caller of this thread to handle future user mode
helper calls.  That we could tie to a user namespace quite easily.

This definitely does not play particularly nice with queue work and
friends, but that is just infrastructure and we can update user mode
helper to use something else reasonable as long as we have a solid
design.

Perhaps there is a combination of the two ideas that could work.
Instead of a syscall use the invocation of a service that needs a user
mode helper as a trigger to create such a launcher thread.

Eric
