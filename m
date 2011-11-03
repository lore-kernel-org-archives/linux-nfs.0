Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12304 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753267Ab1KCLPj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 07:15:39 -0400
Date: Thu, 3 Nov 2011 07:15:16 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-cifs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] freezer: revert 27920651fe "PM / Freezer: Make
 fake_signal_wake_up() wake TASK_KILLABLE tasks too"
Message-ID: <20111103071516.79fb42fa@tlielax.poochiereds.net>
In-Reply-To: <201111030011.24062.rjw@sisk.pl>
References: <20111101041337.39077229@tlielax.poochiereds.net>
	<20111101215710.GA13803@google.com>
	<20111102162331.GA31947@redhat.com>
	<201111030011.24062.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Nov 2011 00:11:23 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Wednesday, November 02, 2011, Oleg Nesterov wrote:
> > Hi,
> > 
> > On 11/01, Tejun Heo wrote:
> > >
> > > For now, let's go with the count/dont_count.  Can you please write up
> > > a patch for that?  Jeff, does this seem okay to you?
> > 
> > OK, will do in a minute. On top of
> > "[PATCH pm] freezer: fix wait_event_freezable/__thaw_task races"
> > you sent. (btw, thanks, I forgout about it ;)
> > 
> > Rafael, could you remind why freezer_do_not_count/freezer_count check
> > ->mm != NULL ?
> 
> You're asking difficult questions. ;-)
> 
> The intention was to prevent PF_FREEZER_SKIP from having any effect on
> kernel threads, IIRC.  Anyway, there are only two legitimate users of it
> (vfork and apm_ioctl) and in both cases the task in question is user space.
> 
> > The comment says "However, we don't want kernel threads to be frozen",
> > but it is not clear anyway. A kernel thread simply shouldn't use this
> > interface if it doesn't want to freeze.
> > 
> > And in any case, PF_KTHREAD looks better if we really need to filter
> > out the kernel threads.
> 
> PF_FREEZER_SKIP was introduced specifically with vfork in mind and I'm not
> sure if it's a good idea to re-use it for something else (at least not for
> something entirely obvious).
> 

FWIW, wrapping wait_event_killable in freezer_do_not_count/freezer_count
seems to work. The machine suspends consistently with it. It sounds
like Rafael has concerns about this scheme however, so I'll let you
guys argue this out :)

Once you tell me the right scheme to use, I'll be happy to fix up cifs
and nfs to use it.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
