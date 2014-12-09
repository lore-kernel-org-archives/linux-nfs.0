Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757058AbaLIPHJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2014 10:07:09 -0500
Date: Tue, 9 Dec 2014 10:07:00 -0500
From: Simo Sorce <simo@redhat.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: David =?UTF-8?B?SMOkcmRlbWFu?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
Message-ID: <20141209100700.73164edb@willson.usersys.redhat.com>
In-Reply-To: <20141209095813.163ac2bb@tlielax.poochiereds.net>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
	<20141209080923.2708eb4f@tlielax.poochiereds.net>
	<4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu>
	<20141209095813.163ac2bb@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Dec 2014 09:58:13 -0500
Jeff Layton <jeff.layton@primarydata.com> wrote:

> On Tue, 09 Dec 2014 14:52:56 +0100
> David Härdeman <david@hardeman.nu> wrote:
> 
> > On 2014-12-09 14:09, Jeff Layton wrote:
> > > On Tue, 09 Dec 2014 06:40:40 +0100
> > > David Härdeman <david@hardeman.nu> wrote:
> > > 
> > >> The following series converts gssd to use libevent and inotify
> > >> instead of a handrolled event loop and dnotify. Lots of cleanups
> > >> in the process
> > >> (e.g. removing a lot of arbitrary limitations and fixed size
> > >> buffers).
> > ...
> > > 
> > > Looks like a nice cleanup at first glance, but I haven't gone
> > > over it in detail.
> > > 
> > > One thing that _would_ be nice while you're in here though would
> > > be to help parallelize more of process_krb5_upcall. Currently it
> > > forks before changing its identity and then the parent waits on
> > > that to exit which keeps everything serialized.
> > > 
> > > I did it that way so that we didn't need change how we close the
> > > fds afterward. Now that you're already doing some surgery there,
> > > that might be easier to do and may help performance.
> > 
> > Thanks, the current patchset doesn't really touch upon that code.
> > After the patchset is applied, utils/gssd/gssd.c is basically
> > everything that happens up to the point where data is available to
> > read from the gss pipe but not after....
> > 
> > But it should certainly make it easier to add parallelism in the 
> > future...
> > 
> > BTW: when you say "how we close the fds"...what do you mean exactly?
> > 
> > 
> > //David
> 
> Ahh, now I remember. It's not the closing of the fds that's the
> problem, but you do need to have some way to reap the exit status from
> the processes that are being forked off (so you don't end up with
> zombies).
> 
> Probably not too hard to handle, but you would need to keep a count or
> list of forked children and wait() on them at some point.

Maybe you have a list of children in the main process and a SIGCHLD
handler that clears it up when children dies ?
I think libevent may even have helpers for that (libtevent does).

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
