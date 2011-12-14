Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41640 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758038Ab1LNVU0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 16:20:26 -0500
Date: Wed, 14 Dec 2011 16:20:16 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/7] clstated: reattempt the pipe open if it fails on
 ENOENT
Message-ID: <20111214162016.31fbda92@tlielax.poochiereds.net>
In-Reply-To: <20111214211039.GB7623@fieldses.org>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
	<1323871032-3191-3-git-send-email-jlayton@redhat.com>
	<4EE8BC10.3010005@RedHat.com>
	<20111214101927.551e3883@tlielax.poochiereds.net>
	<4EE8C0ED.6090302@RedHat.com>
	<20111214103718.267b32fc@tlielax.poochiereds.net>
	<4EE8C73E.2050207@RedHat.com>
	<20111214110056.4832f52d@tlielax.poochiereds.net>
	<4EE8CEA6.7000001@RedHat.com>
	<20111214211039.GB7623@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Dec 2011 16:10:39 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Dec 14, 2011 at 11:28:22AM -0500, Steve Dickson wrote:
> > 
> > 
> > On 12/14/2011 11:00 AM, Jeff Layton wrote:
> > > On Wed, 14 Dec 2011 10:56:46 -0500
> > > Steve Dickson <SteveD@redhat.com> wrote:
> > > 
> > >>
> > >>
> > >> On 12/14/2011 10:37 AM, Jeff Layton wrote:
> > >>> On Wed, 14 Dec 2011 10:29:49 -0500
> > >>> Steve Dickson <SteveD@redhat.com> wrote:
> > >>>
> > >>>>
> > >>>>
> > >>>> On 12/14/2011 10:19 AM, Jeff Layton wrote:
> > >>>>> On Wed, 14 Dec 2011 10:09:04 -0500
> > >>>>> Steve Dickson <SteveD@redhat.com> wrote:
> > >>>>>
> > >>>>>>
> > >>>>>>
> > >>>>>> On 12/14/2011 08:57 AM, Jeff Layton wrote:
> > >>>>>>> Generally, we want this daemon started before nfsd starts. Deal with the
> > >>>>>>> situation where the pipe hasn't shown up yet.
> > >>>>>> This can be done with your systemd start up script. Plus I'm not sure its 
> > >>>>>> a good idea to steal cpu cycles waiting for an event that may never happen...
> > >>>>>>
> > >>>>>
> > >>>>> Presumably you just wouldn't start the daemon if you have no intent to
> > >>>>> use it.
> > >>>>>
> > >>>>> It does sleep 1s between each check, so the time is fairly minimal,
> > >>>>> but I'm definitely open to doing this differently. What may be
> > >>>>> reasonable is adding code to the daemon to check and see if the
> > >>>>> v4recoverydir is present. If it is, then just exit. Otherwise, wait for
> > >>>>> the pipe to show up.
> > >>>> Why just let the systemd scrips worry about the order of when to start
> > >>>> things up... To be honest, that is one thing systemd does do fairly well.
> > >>>>
> > >>>
> > >>> Because not everyone uses systemd, and we have to deal with the
> > >>> "legacy" case too for the transition phase.
> > >>>
> > >>> It's generally preferable not to start up nfsd until everything it
> > >>> needs is up. If we do what you suggest, then we're basically mandating
> > >>> that this daemon can't start until nfsd is up and running.
> > >> Order has ways been a part of how and when things are started which
> > >> have always been handled by initscripts. That's their job, to start
> > >> things in the correct order. 
> > >>
> > >> I understand you want to make the daemon bullet proof... but starting
> > >> things up in the wrong order is an error... IMHO... 
> > >>
> > >>>
> > >>> Could you give some details on how you think this ought to work?
> > >>>
> > >> I would think a error message stating unable to open whatever and then 
> > >> say something like please make sure the nfs server is up and running,
> > >> would work... It seems to me this is a pretty common way of handling 
> > >> this type of situation.... although I can not come up with a 
> > >> explicit example, atm. 
> > >>
> > > 
> > > That's doable simply by dropping this patch. I think it'll make this
> > > more fragile, but if that's the consensus, I'll go along with it.
> > > 
> > If that is the only fragile part then I you are in very good shape! ;-) 
> > 
> > Thanks again! 
> 
> Please patch section 3.1 of nfs-utils/README while you're at it.
> 
> The start-up order *is* rather complicated, though, and easy to get
> wrong.  And we'd rather not make nfsd wait unnecessarily for this dameon
> to start up....
> 
> Why not use directory notifications like idmapd and gssd always have?
> 

I suppose I could do that. I'll take a look at what they do.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
