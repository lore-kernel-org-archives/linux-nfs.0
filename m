Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ogre.sisk.pl ([217.79.144.158]:33977 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754948Ab1JKTMI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Oct 2011 15:12:08 -0400
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/4] freezer: make fake_signal_wake_up wake TASK_KILLABLE tasks too
Date: Tue, 11 Oct 2011 21:14:28 +0200
Cc: Pavel Machek <pavel@ucw.cz>, trond.myklebust@netapp.com,
        smfrench@gmail.com, linux-pm@lists.linux-foundation.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, john@calva.com,
        linux-kernel@vger.kernel.org
References: <1317210761-11518-1-git-send-email-jlayton@redhat.com> <20111011061847.GB1377@ucw.cz> <20111011061000.3a3a03fe@tlielax.poochiereds.net>
In-Reply-To: <20111011061000.3a3a03fe@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201110112114.28478.rjw@sisk.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday, October 11, 2011, Jeff Layton wrote:
> On Tue, 11 Oct 2011 08:18:48 +0200
> Pavel Machek <pavel@ucw.cz> wrote:
> 
> > 
> > Hi!
> > 
> > > TASK_KILLABLE is often used to put tasks to sleep for quite some time.
> > > One of the most common uses is to put tasks to sleep while waiting for
> > > replies from a server on a networked filesystem (such as CIFS or NFS).
> > > 
> > > Unfortunately, fake_signal_wake_up does not currently wake up tasks
> > > that are sleeping in TASK_KILLABLE state. This means that even if the
> > > code were in place to allow them to freeze while in this sleep, it
> > > wouldn't work anyway.
> > > 
> > > This patch changes this function to wake tasks in this state as well.
> > > This should be harmless -- if the code doing the sleeping doesn't have
> > > handling to deal with freezer events, it should just go back to sleep.
> > 
> > I'm pretty sure this will break something; but that does not mean it
> > is bad idea, just that it should be merged early and tested a lot.
> > 
> 
> FWIW, I looked at most of the places in the kernel that do
> TASK_KILLABLE sleeps and they look like they'll handle this correctly.
> The main one I wasn't sure about was mem_cgroup_handle_oom(), but I
> think it'll do the right thing too. I certainly could have missed
> something though...
> 
> In any case, would you mind merging this via the linux-pm tree for 3.2?

I will push it for 3.2.

Thanks,
Rafael
