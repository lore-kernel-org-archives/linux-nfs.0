Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755772Ab1KBPSY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 11:18:24 -0400
Date: Wed, 2 Nov 2011 16:13:54 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-cifs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] freezer: revert 27920651fe "PM / Freezer: Make
	fake_signal_wake_up() wake TASK_KILLABLE tasks too"
Message-ID: <20111102151354.GA28527@redhat.com>
References: <20111101065958.50addab5@tlielax.poochiereds.net> <20111101163059.GR18855@google.com> <20111101175953.GB5358@redhat.com> <20111101180601.GV18855@google.com> <20111101181329.GA6739@redhat.com> <20111101182753.GW18855@google.com> <20111101193923.GA9444@redhat.com> <20111101194601.GB9444@redhat.com> <20111101215710.GA13803@google.com> <20111102074257.7174691c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111102074257.7174691c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/02, Jeff Layton wrote:
>
> On Tue, 1 Nov 2011 14:57:10 -0700
> Tejun Heo <tj@kernel.org> wrote:
>
> > For now, let's go with the count/dont_count.  Can you please write up
> > a patch for that?  Jeff, does this seem okay to you?
> >
>
> Let me make sure I understand since I don't have a great grasp of the
> freezer internals...
>
> This will set the PF_FREEZER_SKIP flag on the task, which prevents
> try_to_freeze_tasks from incrementing the "todo" var for this process
> and should let the suspend proceed.
>
> So this really makes try_to_freeze_tasks set PF_FREEZING on the task,
> but not get upset that it doesn't actually call try_to_freeze().

Yes. PF_FREEZER_SKIP means, "please count me as frozen". This task can
do nothing except refrigerator() after wakeup.

> Is that sufficient for a process that's just sleeping here?

I think this should work... but this is the question to you ;)

Oleg.

