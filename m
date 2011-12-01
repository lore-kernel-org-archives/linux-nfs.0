Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ogre.sisk.pl ([217.79.144.158]:38017 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278Ab1LAVLA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 16:11:00 -0500
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Adam Williamson <awilliam@redhat.com>
Subject: Re: [PATCH v4 0/2] nfs/sunrpc: allow freezing of tasks with NFS calls in flight
Date: Thu, 1 Dec 2011 22:13:53 +0100
Cc: Tejun Heo <tj@kernel.org>, Jeff Layton <jlayton@redhat.com>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, john@calva.com, trond.myklebust@netapp.com,
        marek.belisko@gmail.com
References: <1322570215-8570-1-git-send-email-jlayton@redhat.com> <20111201184932.GB13173@google.com> <1322767925.1735.40.camel@adam>
In-Reply-To: <1322767925.1735.40.camel@adam>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201112012213.53381.rjw@sisk.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday, December 01, 2011, Adam Williamson wrote:
> On Thu, 2011-12-01 at 10:49 -0800, Tejun Heo wrote:
> > On Wed, Nov 30, 2011 at 08:43:13PM +0100, Rafael J. Wysocki wrote:
> > > On Tuesday, November 29, 2011, Jeff Layton wrote:
> > > > This patchset is the fourth attempt at fixing the issues with suspending
> > > > a machine that has an active NFS mount.
> > > > 
> > > > The bug reported against Fedora is here:
> > > > 
> > > >     https://bugzilla.redhat.com/show_bug.cgi?id=717735
> > > > 
> > > > The main difference from v3 is that I've fixed a stupid set of errors in
> > > > freezable_schedule_timeout_killable. The if condition was reversed from
> > > > what it should have been, and the code did not call freezer_count()
> > > > again when it was going to return early.
> > > > 
> > > > Tejun has mentioned that the extra try_to_freeze() calls are unnecessary
> > > > on top of the pm-freezer changes, but this set should work on as
> > > > expected on top of 3.2-ish kernels. In the meantime, I'll look over the
> > > > pm-freezer changes and see whether I need to make changes in this set
> > > > for 3.3.
> > > > 
> > > > Jeff Layton (2):
> > > >   sunrpc: make rpc_wait_bit_killable handle freeze events
> > > >   nfs: make TASK_KILLABLE sleeps attempt to freeze
> > > 
> > > Both patches applied to linux-pm/linux-next.  I'll move them to
> > > linux-pm/pm-freezer in a couple of days if there are no problems with
> > > them.
> > 
> > Rafael, I think the extra try_to_freeze() is actually incorrect on top
> > of pm-freezer.  Jeff, can you please remove that?
> 
> You might want to read two levels up: Jeff explicitly mentioned that
> already. :)

Well, that means I put those patches into linux-pm/linux-next too early,
since that branch already includes pm-freezer.  I'll drop them from there
temporarily until Jeff rebases them on top of pm-freezer (or
linux-pm/linux-next).

Thanks,
Rafael
