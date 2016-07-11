Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33880 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758362AbcGKLDf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2016 07:03:35 -0400
Received: by mail-qk0-f177.google.com with SMTP id o67so23292077qke.1
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2016 04:03:35 -0700 (PDT)
Message-ID: <1468235011.2577.3.camel@redhat.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
From: Jeff Layton <jlayton@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Seth Forshee <seth.forshee@canonical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Date: Mon, 11 Jul 2016 07:03:31 -0400
In-Reply-To: <20160711072325.GC5284@dhcp22.suse.cz>
References: <20160706174655.GD45215@ubuntu-hedt>
 <1467842838.2908.45.camel@redhat.com>
 <20160708122224.GA20200@dhcp22.suse.cz>
 <1467982314.13822.5.camel@redhat.com>
 <20160708142308.GA20133@dhcp22.suse.cz>
 <1467988058.13822.9.camel@redhat.com>
	 <20160711072325.GC5284@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-07-11 at 09:23 +0200, Michal Hocko wrote:
> On Fri 08-07-16 10:27:38, Jeff Layton wrote:
> > On Fri, 2016-07-08 at 16:23 +0200, Michal Hocko wrote:
> > > On Fri 08-07-16 08:51:54, Jeff Layton wrote:
> > > > 
> > > > On Fri, 2016-07-08 at 14:22 +0200, Michal Hocko wrote:
> > > [...]
> > > > 
> > > > > 
> > > > > Apart from alternative Dave was mentioning in other email, what
> > > > > is the
> > > > > point to use freezable wait from this path in the first place?
> > > > > 
> > > > > nfs4_handle_exception does nfs4_wait_clnt_recover from the same
> > > > > path and
> > > > > that does wait_on_bit_action with TASK_KILLABLE so we are waiting
> > > > > in two
> > > > > different modes from the same path AFAICS. There do not seem to
> > > > > be other
> > > > > callers of nfs4_delay outside of nfs4_handle_exception. Sounds
> > > > > like
> > > > > something is not quite right here to me. If the nfs4_delay did
> > > > > regular
> > > > > wait then the freezing would fail as well but at least it would
> > > > > be clear
> > > > > who is the culrprit rather than having an indirect dependency.
> > > > The codepaths involved there are a lot more complex than that
> > > > unfortunately.
> > > > 
> > > > nfs4_delay is the function that we use to handle the case where the
> > > > server returns NFS4ERR_DELAY. Basically telling us that it's too
> > > > busy
> > > > right now or has some transient error and the client should retry
> > > > after
> > > > a small, sliding delay.
> > > > 
> > > > That codepath could probably be made more freezer-safe. The typical
> > > > case however, is that we've sent a call and just haven't gotten a
> > > > reply. That's the trickier one to handle.
> > > Why using a regular non-freezable wait would be a problem?
> > 
> > It has been a while since I looked at that code, but IIRC, that could
> > block the freezer for up to 15s, which is a significant portion of the
> > 20s that you get before the freezer gives up.
> 
> But how does that differ from the situation when the freezer has to give
> up on the timeout because another task fails due to lock dependency.
> 
> As Trond and Dave have written in other emails. It is really danngerous
> to freeze a task while it is holding locks and other resources.

It's not really dangerous if you're freezing every task on the host.
Sure, you're freezing with locks held, but everything else is freezing
too, so nothing will be contending for those locks.

I'm not at all opposed to changing how all of that works. My only
stipulation is that we not break the ability to reliably suspend a host
that is actively using an NFS mount. If you can come up with a way to
do that that also works for freezing cgroups, then I'm all for it.

-- 

Jeff Layton <jlayton@redhat.com>
