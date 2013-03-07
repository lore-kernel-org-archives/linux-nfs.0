Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hydra.sisk.pl ([212.160.235.94]:36603 "EHLO hydra.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200Ab3CGUsS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Mar 2013 15:48:18 -0500
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Tejun Heo <tj@kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Date: Thu, 07 Mar 2013 21:55:13 +0100
Message-ID: <1666707.98SRJWcGQW@vostro.rjw.lan>
In-Reply-To: <CA+55aFySyBP8q5AvPrt-s_ZPdgamfoX-dERw4EJ21EcsDLBjYA@mail.gmail.com>
References: <20130305174954.GG12795@htj.dyndns.org> <4FA345DA4F4AE44899BD2B03EEEC2FA9286B511E@sacexcmbx05-prd.hq.netapp.com> <CA+55aFySyBP8q5AvPrt-s_ZPdgamfoX-dERw4EJ21EcsDLBjYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday, March 07, 2013 08:25:10 AM Linus Torvalds wrote:
> On Thu, Mar 7, 2013 at 7:59 AM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
> >
> > It _shouldn't_ be an interruption unless the filesystem can't make
> > progress.
> 
> So how can we tell? Calling "freezable_schedule()" if you're not ready
> to be frozen is not good. And nobody but the NFS code can know.
> 
> You might want to introduce some counter that counts number of
> outstanding non-interruptible events, and only call the "freezable"
> version if that counter is zero.
> 
> A better alternative might be to *never* call the freezable version.
> Because those freezable_*() things are really quite disgusting, and
> are wrong - they don't actually freeze the process, they say "I don't
> care if you freeze me while I sleep", and you might actually wake up
> *while* the system is being frozen. I think the whole concept is
> broken. Rafaei - comments?

Well, the only comment I have is that the source of these functions was
commit d310310c (Freezer / sunrpc / NFS: don't allow TASK_KILLABLE sleeps to
block the freezer) and they were added because people were complaining that
they couldn't suspend while their NFS servers were not responding, IIRC.

I agree that they are not really nice.

Thanks,
Rafael


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
