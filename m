Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35682 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758009Ab3CFMGv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Mar 2013 07:06:51 -0500
Date: Wed, 6 Mar 2013 07:06:31 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mandeep Singh Baines <msb@chromium.org>, Tejun Heo <tj@kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Oleg Nesterov <oleg@redhat.com>, Ming Lei <ming.lei@canonical.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Thomas Gleixner <tglx@linutronix.de>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130306070631.0f326014@tlielax.poochiereds.net>
In-Reply-To: <20130306090914.GA6030@gmail.com>
References: <20130304205307.GA13527@redhat.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
	<20130305082308.6607d4db@tlielax.poochiereds.net>
	<20130305174648.GF12795@htj.dyndns.org>
	<20130305174954.GG12795@htj.dyndns.org>
	<20130305231110.GK15816@fieldses.org>
	<CACBanvo+JDCFVRQeTQwnwRRxr8bdqxdsgeEr8fqgJhGQJEEQ-Q@mail.gmail.com>
	<20130306010507.GL15816@fieldses.org>
	<20130306011623.GG1227@htj.dyndns.org>
	<CACBanvqVpi45TVNGXgXXO0BCSRuPEDsiNuHj0OBsvgr2UXZfsg@mail.gmail.com>
	<20130306090914.GA6030@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 6 Mar 2013 10:09:14 +0100
Ingo Molnar <mingo@kernel.org> wrote:

> 
> * Mandeep Singh Baines <msb@chromium.org> wrote:
> 
> > On Tue, Mar 5, 2013 at 5:16 PM, Tejun Heo <tj@kernel.org> wrote:
> > > On Tue, Mar 05, 2013 at 08:05:07PM -0500, J. Bruce Fields wrote:
> > >> If it's really just a 2-line patch to try_to_freeze(), could it just be
> > >> carried out-of-tree by people that are specifically working on tracking
> > >> down these problems?
> > >>
> > >> But I don't have strong feelings about it--as long as it doesn't result
> > >> in the same known issues getting reported again and again....
> > >
> > > Agreed, I don't think a Kconfig option is justified for this.  If this
> > > is really important, annotate broken paths so that it doesn't trigger
> > > spuriously; otherwise, please just remove it.
> > >
> > 
> > Fair enough. Let's revert then. I'll rework to use a lockdep annotation.
> > 
> > Maybe, add a new lockdep API:
> > 
> > lockdep_set_held_during_freeze(lock);
> > 
> > Then when we do the check, ignore any locks that set this bit.
> > 
> > Ingo, does this seem like a reasonable design to you?
> 
> Am I reading the discussion correctly that the new warnings show REAL potential 
> deadlock scenarios, which can hit real users and can lock their box up in entirely 
> real usage scenarios?
> 
> If yes then guys we _really_ don't want to use lockdep annotation to _HIDE_ bugs.
> We typically use them to teach lockdep about things it does not know about.
> 
> How about fixing the deadlocks instead?
> 

I do see how the freezer might fail to suspend certain tasks, but I
don't see the deadlock scenario here in the NFS/RPC case. Can someone
outline a situation where this might end up deadlocking? If not, then
I'd be inclined to say that while this may be a problem, the warning is
excessive...

-- 
Jeff Layton <jlayton@redhat.com>
