Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:35656 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbbIVRJ3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Sep 2015 13:09:29 -0400
Received: by qgt47 with SMTP id 47so121972399qgt.2
        for <linux-nfs@vger.kernel.org>; Tue, 22 Sep 2015 10:09:28 -0700 (PDT)
Date: Tue, 22 Sep 2015 13:09:23 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] GSSD: clean up machine credentials
Message-ID: <20150922130923.25cb96ca@synchrony.poochiereds.net>
In-Reply-To: <0ED1A1D2-B73A-436E-9DBF-472D6049A6E4@netapp.com>
References: <1442868609-1812-1-git-send-email-andros@netapp.com>
	<1442868609-1812-5-git-send-email-andros@netapp.com>
	<20150922072419.5d9df0d3@synchrony.poochiereds.net>
	<0ED1A1D2-B73A-436E-9DBF-472D6049A6E4@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 22 Sep 2015 16:38:41 +0000
"Adamson, Andy" <William.Adamson@netapp.com> wrote:

> 
> > On Sep 22, 2015, at 7:24 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> > 
> > On Mon, 21 Sep 2015 16:50:09 -0400
> > <andros@netapp.com> wrote:
> > 
> >> From: Andy Adamson <andros@netapp.com>
> >> 
> >> Since we no longer fork for uid 0, gssd_atexit() is only called when uid != 0,
> >> and fails as permissions on the /tmp/krb5ccmachine_REALM file prohibit
> >> the clean up of machine credentials (as it should).
> >> 
> >> Move the reaping of machine credentials back into a SIGINT sighandler so that
> >> <Ctrl C> destroyes machine credentials.
> >> 
> >> Signed-off-by: Andy Adamson <andros@netapp.com>
> >> ---
> >> utils/gssd/gssd.c | 10 ++++------
> >> 1 file changed, 4 insertions(+), 6 deletions(-)
> >> 
> >> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> >> index 2a768ea..ebff860 100644
> >> --- a/utils/gssd/gssd.c
> >> +++ b/utils/gssd/gssd.c
> >> @@ -729,10 +729,12 @@ found:
> >> }
> >> 
> >> static void
> >> -gssd_atexit(void)
> >> +sig_die(int signal)
> >> {
> >> 	if (root_uses_machine_creds)
> >> 		gssd_destroy_krb5_machine_creds();
> >> +	printerr(1, "exiting on signal %d\n", signal);
> >> +	exit(0);
> >> }
> >> 
> >> static void
> >> @@ -892,17 +894,13 @@ main(int argc, char *argv[])
> >> 		exit(EXIT_FAILURE);
> >> 	}
> >> 
> >> -	if (atexit(gssd_atexit)) {
> >> -		printerr(1, "ERROR: atexit failed: %s\n", strerror(errno));
> >> -		exit(EXIT_FAILURE);
> >> -	}
> >> -
> >> 	inotify_fd = inotify_init1(IN_NONBLOCK);
> >> 	if (inotify_fd == -1) {
> >> 		printerr(1, "ERROR: inotify_init1 failed: %s\n", strerror(errno));
> >> 		exit(EXIT_FAILURE);
> >> 	}
> >> 
> >> +	signal(SIGINT, sig_die);
> >> 	signal_set(&sighup_ev, SIGHUP, gssd_scan_cb, NULL);
> >> 	signal_add(&sighup_ev, NULL);
> >> 	event_set(&inotify_ev, inotify_fd, EV_READ | EV_PERSIST, gssd_inotify_cb, NULL);
> > 
> > 
> > Hmm, I don't know about this one. What if you die due to SIGTERM or
> > something (which is what systemd generally sends processes). They won't
> > get cleaned up in that case.
> 
> Yes - the code prior to gssd_atexit() called the sig_die for SIGTERM as well.
> > 
> > What may be better is to just keep the atexit handler but have it do a
> > getpid() and only do the cleanup if its the original pid of the daemon.
> > Just do a getpid early during gssd startup and store it in a global
> > variable somewhere.
> 
> I tried that before submitting this patch - gssd_atexit is not called when systemctl stop rpc-gssd.service stops rpc.gssd. Nor is it called on SIGINT, SIGKILL, or SIGTERM. AFAICS, it is never called.
> > 

Ahh, right:

       The atexit() function registers the given function to be called at nor‐
       mal process termination, either via exit(3) or via return from the pro‐
       gram's main().

...signals don't qualify as normal process termination.

> > That said, maybe I should take a step back and ask -- why does gssd
> > clean up this credcache in the first place? Is there some attack
> > vector that this prevents, or is it just to prevent a ton of
> > credcaches piling up in /tmp?
> 
> Yeah, it’s not a big problem - cred caches piling up in /tmp. Mostly
> it’s due to admin’s thinking that if the user of kerberos credentials
> is not running, then the kerberos credentials should not be present.
> The same reason kdestroy is used. Note that
> the /tmp/krb5ccmachine_REALM file survives reboot ….
> 
> I think I should simply use sig_die for SIGTERM and SIGKILL as well
> as SIGINT. Note that with the sig_die() approach, I do not need to
> check the pid.
> 


If signals are the only way to take the daemon down then that should be OK.

> WIth the addition of SIGTERM and SIGKILL, the machine credential file
> is ‘kdestroyed’ upon rpc.gssd exit.
> 

FWIW, you can't override SIGKILL. SIGTERM should be doable though.
-- 
Jeff Layton <jlayton@poochiereds.net>
