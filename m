Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16252 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638AbaIWMpn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 08:45:43 -0400
Date: Tue, 23 Sep 2014 08:45:30 -0400
From: Simo Sorce <simo@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923084530.548a7f04@willson.usersys.redhat.com>
In-Reply-To: <20140923114229.0a9e294f@notabene.brown>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
	<1411413608-16462-2-git-send-email-steved@redhat.com>
	<20140922194057.GE26763@fieldses.org>
	<20140922154642.779189c8@willson.usersys.redhat.com>
	<54207E4A.7010300@RedHat.com>
	<20140922160050.0b85f044@willson.usersys.redhat.com>
	<20140923114229.0a9e294f@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 23 Sep 2014 11:42:29 +1000
NeilBrown <neilb@suse.de> wrote:

> On Mon, 22 Sep 2014 16:00:50 -0400 Simo Sorce <simo@redhat.com> wrote:
> 
> > On Mon, 22 Sep 2014 15:53:46 -0400
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> > > 
> > > 
> > > On 09/22/2014 03:46 PM, Simo Sorce wrote:
> > > > On Mon, 22 Sep 2014 15:40:57 -0400
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > >> On Mon, Sep 22, 2014 at 03:20:07PM -0400, Steve Dickson wrote:
> > > >>> Added the gssproxy.service to both the Wants= and
> > > >>> Atfers= lines, before the rpc-svcgssd.service. There
> > > >>> are  ConditionPathExists= lines in the rpc-svcgssd.service
> > > >>> unit which will stop the rpc.svcgssd daemon from
> > > >>> starting when the gssproxy daemon is already running.
> > > >>
> > > >> That should read "when the kernel supports gssproxy", not
> > > >> "when the gssproxy daemon is already running."
> > > > 
> > > > Actually the language is currently correct but it is another
> > > > bug, the systemd/rpc-svcgssd.service file still includes
> > > > "ConditionPathExists=|!/run/gssproxy.pid"
> > > > This line should be removed in this patch.
> > > 
> > > I left that on purpose because isn't that ConditionPathExists
> > > seeing if /run/gssproxy.pid exists and if it does 
> > > it means gssproxy is already running so rpc.svcgssd 
> > > should not start?
> > 
> > No.
> > First of all the fact gss-proxy is running does not mean it is
> > serving nfsd necessarily, it may be running on an older kernel
> > where it servers apache or some other process (remember gssproxy is
> > not just for nfsd).
> > Second you already have
> > "ConditionPathExists=|!/proc/net/rpc/use-gss-proxy" which is the
> > correct trigger to decide which of the two to use.
> > 
> 
> Surely gssproxy is only serving nfsd requests if
> both /run/gssproxy.pid exists and /proc/net/rpc/use-gss-proxy exists.
> If either of those files is missing, then rpc.svcgssd needs to run.
> In one case, the gssproxy daemon isn't available for some reason.  In
> the other case the kernel cannot make use of it.
> 
> Is that not correct?

At the moment it is not, as there is no ordering between the 2
starting /run/gssproxy.pid may simply not be available "yet", also if
it is available it doesn't mean rpc.svcgssd should not start.
GSS-Proxy may be running but /proc/net/rpc/use-gss-proxy may not be
present.
So in general gssproxy.pid is not an indication of whether rpc.svcgssd
should start or not.

> That is exactly the rule that I (tried to) encode in the service file
> with these two conditions.

Then you also need to add After: gssproxy.service to
rpc-svcgssd.service so you give it a chance to start and create the pid
file. But again the mere existence of the pid file is not enough if the
proc file is not there.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
