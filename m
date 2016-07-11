Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:33559 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933671AbcGKMup (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2016 08:50:45 -0400
Received: by mail-oi0-f45.google.com with SMTP id u201so145505698oie.0
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2016 05:50:45 -0700 (PDT)
Date: Mon, 11 Jul 2016 07:50:41 -0500
From: Seth Forshee <seth.forshee@canonical.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
Message-ID: <20160711125041.GA3024@ubuntu-hedt>
References: <20160706174655.GD45215@ubuntu-hedt>
 <1467842838.2908.45.camel@redhat.com>
 <20160708122224.GA20200@dhcp22.suse.cz>
 <1467982314.13822.5.camel@redhat.com>
 <20160708142308.GA20133@dhcp22.suse.cz>
 <1467988058.13822.9.camel@redhat.com>
 <20160711072325.GC5284@dhcp22.suse.cz>
 <1468235011.2577.3.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1468235011.2577.3.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 11, 2016 at 07:03:31AM -0400, Jeff Layton wrote:
> On Mon, 2016-07-11 at 09:23 +0200, Michal Hocko wrote:
> > On Fri 08-07-16 10:27:38, Jeff Layton wrote:
> > > On Fri, 2016-07-08 at 16:23 +0200, Michal Hocko wrote:
> > > > On Fri 08-07-16 08:51:54, Jeff Layton wrote:
> > > > > 
> > > > > On Fri, 2016-07-08 at 14:22 +0200, Michal Hocko wrote:
> > > > [...]
> > > > > 
> > > > > > 
> > > > > > Apart from alternative Dave was mentioning in other email, what
> > > > > > is the
> > > > > > point to use freezable wait from this path in the first place?
> > > > > > 
> > > > > > nfs4_handle_exception does nfs4_wait_clnt_recover from the same
> > > > > > path and
> > > > > > that does wait_on_bit_action with TASK_KILLABLE so we are waiting
> > > > > > in two
> > > > > > different modes from the same path AFAICS. There do not seem to
> > > > > > be other
> > > > > > callers of nfs4_delay outside of nfs4_handle_exception. Sounds
> > > > > > like
> > > > > > something is not quite right here to me. If the nfs4_delay did
> > > > > > regular
> > > > > > wait then the freezing would fail as well but at least it would
> > > > > > be clear
> > > > > > who is the culrprit rather than having an indirect dependency.
> > > > > The codepaths involved there are a lot more complex than that
> > > > > unfortunately.
> > > > > 
> > > > > nfs4_delay is the function that we use to handle the case where the
> > > > > server returns NFS4ERR_DELAY. Basically telling us that it's too
> > > > > busy
> > > > > right now or has some transient error and the client should retry
> > > > > after
> > > > > a small, sliding delay.
> > > > > 
> > > > > That codepath could probably be made more freezer-safe. The typical
> > > > > case however, is that we've sent a call and just haven't gotten a
> > > > > reply. That's the trickier one to handle.
> > > > Why using a regular non-freezable wait would be a problem?
> > > 
> > > It has been a while since I looked at that code, but IIRC, that could
> > > block the freezer for up to 15s, which is a significant portion of the
> > > 20s that you get before the freezer gives up.
> > 
> > But how does that differ from the situation when the freezer has to give
> > up on the timeout because another task fails due to lock dependency.
> > 
> > As Trond and Dave have written in other emails. It is really danngerous
> > to freeze a task while it is holding locks and other resources.
> 
> It's not really dangerous if you're freezing every task on the host.
> Sure, you're freezing with locks held, but everything else is freezing
> too, so nothing will be contending for those locks.

Unless you have tasks either already waiting on those locks or that will
attaempt to lock them before calling try_to_freeze. That happens to be
the case in this cgroup freezer hang too, all the tasks stuck waiting on
the i_mutex are p being frozen.

> I'm not at all opposed to changing how all of that works. My only
> stipulation is that we not break the ability to reliably suspend a host
> that is actively using an NFS mount. If you can come up with a way to
> do that that also works for freezing cgroups, then I'm all for it.

The deadlock that we've seen should apply equally to suspend and to the
cgroup freezer. The only difference is that suspend will eventually time
out and abort the suspend whereas the cgroup freezer does not.

Seth
