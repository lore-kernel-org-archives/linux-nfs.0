Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45976 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752088AbcLGOTt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 09:19:49 -0500
Date: Wed, 7 Dec 2016 09:19:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 00/15] Enhance /etc/nfs.conf usage and remove
 nfs-config.service
Message-ID: <20161207141947.GD20652@fieldses.org>
References: <148065078775.28046.5506130555300891075.stgit@noble>
 <20161206172641.GA31197@fieldses.org>
 <87lgvs4qv2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87lgvs4qv2.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 07, 2016 at 09:47:29AM +1100, NeilBrown wrote:
> On Wed, Dec 07 2016, J. Bruce Fields wrote:
> > On Fri, Dec 02, 2016 at 02:58:27PM +1100, NeilBrown wrote:
> >> - nfs-config.service is removed, because it isn't really needed with
> >>   the above.
> >> - documentation for all the above is provided, including a new
> >>   nfs.systemd man page which gives the bigger picture.
> >
> > Still looks pretty good to me.
> >
> > I'm a little worried about user interface churn.  We're not done yet
> > explaining that people have to run nfs-config.service after changing
> > things, soon we'll start telling them oh, never mind about that and oh,
> > by the way, you may want to start migrating your configuration to
> > /etc/nfs.conf....
> 
> Did we tell people to run nfs-config.server?  The intention was that it
> wouldn't be needed.  Any systemd transaction that needed nfs
> configuration should run the command once.
> 
> Commit: c4940fad2a73 ("systemd: ensure nfs-config service is re-run as needed.")
> 
> should have made that happen.

D'oh, I totally forgot that you fixed that, thanks.

> Yes, some migration is needed.  I see distros as the primary target for
> that, and the 'include' and '$name' functionality is supposed to allow
> that to be transparent.  i.e. the configuration stays as it is, it just
> gets into nfs daemons by a different path.
> If people want to edit /etc/nfs.conf directly, then they are on their
> own, just like people who edited their systemd unit files directly,
> or created replacements in /etc.

Yep, sounds like a plan.

--b.
