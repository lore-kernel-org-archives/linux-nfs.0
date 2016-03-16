Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbcCPAQ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2016 20:16:29 -0400
Date: Tue, 15 Mar 2016 20:16:26 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: NeilBrown <nfbrown@novell.com>
cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] systemd: remove the nfs-config service
In-Reply-To: <87bn6fh0jh.fsf@notabene.neil.brown.name>
Message-ID: <alpine.OSX.2.19.9992.1603152015540.11199@planck>
References: <dfec4f0fe32d23aff0ed608b8f2931059060479a.1457784247.git.bcodding@redhat.com> <87h9g7h2ym.fsf@notabene.neil.brown.name> <alpine.OSX.2.19.9992.1603151706000.11199@planck> <87bn6fh0jh.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Wed, Mar 16 2016, Benjamin Coddington wrote:
>
> > On Wed, 16 Mar 2016, NeilBrown wrote:
> >
> >> On Sat, Mar 12 2016, Benjamin Coddington wrote:
> >>
> >> > The nfs-config service exists to translate distro-specific startup
> >> > configuration into the command line arguments used by systemd to start nfs
> >> > utilities.  Unfortunately, it is not clear to most users that this service
> >> > must be recycled every time startup configurations have been modified, as
> >> > this requirement is a change for at least one distro.
> >> >
> >> > We can get rid of nfs-config by generating the startup arguments in an
> >> > ExecStartPre option for each service that needs them.  We'll also have to
> >> > break out the EnvironmentFile into a separate file for each service to
> >> > avoid races overwriting this file.
> >> >
> >> > A distro taking this change should also modify their
> >> > /usr/lib/systemd/scripts/nfs-utils_env.sh script to include the new
> >> > EnvironmentFile location for each service.
> >> >
> >> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> >>
> >> I can't say I really like this, but it does make sense and solves a real
> >> problem.
> >> Maybe: I would never have written it myself, but I'm kind-a glad you did
> >> :-)
> >
> > Which bits are unlikeable?  I am guessing that all these little intermediate
> > files are the issue; that is what I hate.  I admit that it is a least-effort
> > approach to fixing the problem.  What does the ideal fix look like to you?
>
> I don't like having multiple intermediate config files that are all
> identical, and I don't like having to run the config script every time
> any daemon is (re)started.
>
> I'm not sure what "ideal" would be.
>
> One improvement would be if systemd could be given an executable in
> place of an environment file with the implication that it would run the
> executable and read environment variables from the stdout.
> That would remove the multiple config files.
> It would still mean the script is run every time, but I could be
> convinced that isn't so bad.
>
> An alternate idea is that maybe systemd could have a directive so that
> in any transaction were "this" unit is started, "that" unit will also be
> started.  Then we could replace "Wants=nfs-config.server" with
> "Prepare=nfs-config.service" so if systemd ever needed to start any
> nfs-related service, it would make preparations by first running
> nfs-config.service - only once per transaction.
>
> But unless you want to hack on systemd, I think what you have is good
> enough.
>
>
> .... hmmm.  I wonder what would happen if we just removed
> "RemainAfterExit=y" from nfs-config.service.  Would it cause things to
> fail, or would it cause nfs-config.service to be run every time.
>
> Hey, that looks like it works!  Can you double check for me?
> i.e. revert your patch, remove "RemainAfterExit=y" from
> nfs-config.service, and then see if nfs-config.service gets run any time
> any nfs server is started.

Yep.. that appears to work just fine.  Seems like a simpler solution than
this change.  It appears to me ( from systemd.service(5) ) that systemd's
state transitions for Type=Oneshot will avoid races that might overwrite the
environment file.  Nice find!

Ben
