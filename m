From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils: sm-notify does not remove its pid file.
Date: Tue, 11 Dec 2007 14:28:32 +1100
Message-ID: <18270.992.262485.318331@notabene.brown>
References: <475D91B9.4070405@RedHat.com>
	<18269.49269.575546.943037@notabene.brown>
	<475DE62D.7020305@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38378 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbXLKD2g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 22:28:36 -0500
In-Reply-To: message from Steve Dickson on Monday December 10
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday December 10, SteveD@redhat.com wrote:
> Neil Brown wrote:
> > I was under the impression that /var/run was always cleaned out on
> > reboot, so this shouldn't be a problem.  Is my impression wrong?
> I don't think there are any guarantees about this. I was under
> the impression that the individual init scripts were suppose 
> to clean those up and I know I fixed a few bugs in that area. ;-)

Debian has /etc/init.d/bootclean which contains:

	cd /var/run ; .....
	....
        find . ! -xtype d ! -name utmp ! -name innd.pid \
                -print0 | xargs -0r rm -f -- \
		|| ....

so any files except a select few are removed.

SLES has /etc/init.d/boot.cleanup which has
            find /var/run /var/lock -type f -print0 | xargs -0 -r rm -f 2>/dev/null

so again, all files get removed.

You seem to be saying that Redhat requires everything in /var/run to
be explicitly cleaned up ???  Aren't standards wonderful :-)


> 
> > 
> > And I think the point of the lock file was the sm-notify would only
> > run once per reboot.  
> Why impose a limit? Why not recover lock at any point?

You only want to recover locks when they have been lost.  Boot time is
that time.

The particular situation I wanted to handle was that I wanted it to be
OK to start statd at any time.   And I wanted sm-notify to run at boot
time if possible, but also to be run when statd was started if it
hadn't run already.
An 'I have run already' file in /var/run seemed the obvious solution.

> 
> > But I think that removing the lock file when sm-notify completes is
> > wrong.
> A side effect of all this is if rpc.statd is restarted and that
> file is not cleaned up the client will never even try to recover any locks. 
> That's definitely not a good thing... imho... 

There is no need for a client to recover locks if statd is restarted
(is there).  I think statd now stores all state in /var/lib/nfs/* so
if it is killed and restarted, it should pick up exactly where it left
off.

The time that you need to notify clients is when *lockd* is
restarted.  Or more significantly, when lockd arbitrarily drops it's
locks. 
i.e. if you "kill -9" lockd, then you need to do something with
sm-notify and I acknowledge that isn't well documented nor is there an
automatic procedure to make it happen.  So there is room for
improvement, but I don't think that running sm-notify every time that
statd is started is an improvement.

> 
> > 
> > Note the comment in sm-notify.c:
> > 
> > /*
> >  * Record pid in /var/run/sm-notify.pid
> >  * This file should remain until a reboot, even if the
> >  * program exits.
> >  * If file already exists, fail.
> >  */
> I guess I just don't understand why a pid file need to exist after a 
> process is gone. Especially if its going to cause the next existence 
> to imminently exit (potentially causing data corruption). 
> That just does not seem very robust... 

Maybe making look like a pid file was a mistake.  I'd be OK with
changing the name to /var/run/sm-notify-has-run or similar.  If we
could store in the file some reflection of the state of lockd, that
would be even better, but I don't think such a value is available at
the moment.

What potential for data corruption do you see?

NeilBrown
