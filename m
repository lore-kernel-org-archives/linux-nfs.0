Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32170 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341Ab0IPLcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 07:32:14 -0400
Date: Thu, 16 Sep 2010 07:32:03 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #2)
Message-ID: <20100916073203.2c217bfc@barsoom.rdu.redhat.com>
In-Reply-To: <4C91FA2C.3090105@RedHat.com>
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com>
	<20100914092304.74c8aa34@corrin.poochiereds.net>
	<4C9127DE.8050003@RedHat.com>
	<20100915183110.7d075052@tlielax.poochiereds.net>
	<4C91FA2C.3090105@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 16 Sep 2010 07:06:20 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> >> +
> >> +	/*
> >> +	 * this call can return an error if modprobe is set up to automatically
> >> +	 * mount nfsdfs when nfsd.ko is plugged in. So, ignore the return
> >> +	 * code from it and just check for the "threads" file afterward.
> >> +	 */
> >> +	system("/bin/mount -t nfsd nfsd " NFSD_FS_DIR " >/dev/null 2>&1");
> >> +
> >> +	err = stat(NFSD_THREAD_FILE, &statbuf);
> >> +	if (err == 0)
> >> +		return;
> >> +
> >> +	xlog(L_ERROR, "Unable to access " NFSD_FS_DIR " errno %d (%m)." 
> >> +		"\nPlease try, as root, 'mount -t nfsd nfsd " NFSD_FS_DIR 
> >> +		"' and then restart %s to correct the problem", errno, progname);
> >> +
> > 
> > A few of problems with that log message...
> > 
> > First, it looks like something failed, but nfsd will probably end up
> > getting started anyway. We recommend starting nfsd to correct the
> > problem, but it's not clear what the problem actually is. nfsd got
> > started right?
> Hmm... I was thinking this part of the message
>     "Unable to access " NFSD_FS_DIR " errno %d (%m)."
> made it clear as to what the problem is. 
> 
> We are making note of a non fatal error... and since
> the message is being written to stderr, instead if 
> syslog()-ed, the actual message look more like a note 
> then an error since the 'ERROR' string is not be added.
> We could change the message to a L_WARNING... 
> 

L_WARNING would be more appropriate I think. But the typical user is
going to "huh?" with this error message. It says something about a
"problem" but we're not being clear as to what the problem is. After
all, nfsd got started so it's not likely to be immediately clear to the
uninitiated person.

> > 
> > Second, it says to restart nfsd to correct the problem, but restarting
> > nfsd isn't exactly straightforward (you need to run "nfsd 0" and then
> > nfsd <some positive int>).
> Well I'm making the assumption that people who do see this
> message did not use the normal init-script way of starting rpc.nfsd,
> because if they did they would not be seeing this message. So,
> again I'm assuming, that these same people are starting rpc.nfsd
> my hand, which means they know how to restart rpc.nfsd.
> 

That depends very much on the init script. We know that Fedora and
RHEL, and probably others too, will plug in nfsd.ko before running
rpc.nfsd. Based on the report by Tetsuo a couple of months ago, I think
it's safe to assume that at least some Debian userspace doesn't do
that. By extension, that probably means that Ubuntu doesn't either. It's
also quite plausible that many smaller, distros (OpenWRT, for instance)
won't. Personally, I expect that once we do this we're going to find
that a large number of distros will need to fix their init scripts.

> > 
> > Third, there could be other problems than just the fact that nfsdfs
> > didn't get mounted. Maybe there was some weird SELinux permissions
> > problem? In that case, trying to mount nfsdfs won't help anything and
> > that message will just confuse the issue.
> If its an SELinux error or some issue that causing either the stat()
> and mount() to fail, hopefully those type of issues will be logged. 
> Plus having them try the mount by hand could possibly lead them in the 
> right direction.
> 

Fair enough.

> > 
> > I think it's going to be really difficult to explain the problem and
> > solution in a terse xlog message. My expectation was mainly that we
> > should pop up a message to give the user a heads up that "something" is
> > wrong. I think it's tough to offer specific solutions in such a message
> > though.
> All I'm trying to is log an non-fatal error,  give a reason
> as to why the error happen and a possible resolution to that error.
> Since were are not logging the fact the system() call failed, I
> thought it was a fairly reasonable thing to do....
> 

It is. The main issue is that we have a somewhat complex situation here
if the mount ended up not working. I attempted to deal with it by being
somewhat vague. That said...we're getting into bikeshed paint colors
here. If it helps move things along, let's go with your version and
call it a day...

-- 
Jeff Layton <jlayton@redhat.com>
