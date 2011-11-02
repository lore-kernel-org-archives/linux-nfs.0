Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ogre.sisk.pl ([217.79.144.158]:46995 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077Ab1KBXIt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 19:08:49 -0400
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH] freezer: revert 27920651fe "PM / Freezer: Make fake_signal_wake_up() wake TASK_KILLABLE tasks too"
Date: Thu, 3 Nov 2011 00:11:23 +0100
Cc: Tejun Heo <tj@kernel.org>, Jeff Layton <jlayton@redhat.com>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-cifs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
References: <20111101041337.39077229@tlielax.poochiereds.net> <20111101215710.GA13803@google.com> <20111102162331.GA31947@redhat.com>
In-Reply-To: <20111102162331.GA31947@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201111030011.24062.rjw@sisk.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday, November 02, 2011, Oleg Nesterov wrote:
> Hi,
> 
> On 11/01, Tejun Heo wrote:
> >
> > For now, let's go with the count/dont_count.  Can you please write up
> > a patch for that?  Jeff, does this seem okay to you?
> 
> OK, will do in a minute. On top of
> "[PATCH pm] freezer: fix wait_event_freezable/__thaw_task races"
> you sent. (btw, thanks, I forgout about it ;)
> 
> Rafael, could you remind why freezer_do_not_count/freezer_count check
> ->mm != NULL ?

You're asking difficult questions. ;-)

The intention was to prevent PF_FREEZER_SKIP from having any effect on
kernel threads, IIRC.  Anyway, there are only two legitimate users of it
(vfork and apm_ioctl) and in both cases the task in question is user space.

> The comment says "However, we don't want kernel threads to be frozen",
> but it is not clear anyway. A kernel thread simply shouldn't use this
> interface if it doesn't want to freeze.
> 
> And in any case, PF_KTHREAD looks better if we really need to filter
> out the kernel threads.

PF_FREEZER_SKIP was introduced specifically with vfork in mind and I'm not
sure if it's a good idea to re-use it for something else (at least not for
something entirely obvious).

Thanks,
Rafael
