Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:32806 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933455AbcDYUhd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 16:37:33 -0400
Received: by mail-qk0-f171.google.com with SMTP id n63so67295515qkf.0
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2016 13:37:33 -0700 (PDT)
Message-ID: <1461616649.4288.35.camel@poochiereds.net>
Subject: Re: [RFC PATCH v2 2/3] gssd: using syscalls directly to change
 thread's identity
From: Jeff Layton <jlayton@poochiereds.net>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Steve Dickson <SteveD@redhat.com>, Jeff Layton <layton@primarydata.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date: Mon, 25 Apr 2016 16:37:29 -0400
In-Reply-To: <CAN-5tyEbOQoCEB0EDCXAi2BTdH-VCwfyipAqtAb61P8WxRJ9NA@mail.gmail.com>
References: <1461186721-64008-1-git-send-email-kolga@netapp.com>
	 <1461186721-64008-3-git-send-email-kolga@netapp.com>
	 <571A6FB0.8080709@RedHat.com>
	 <CAN-5tyH-JqHTnm+j0XG277qVQVbocR-j6MRn0aq9A8PLh_iMRg@mail.gmail.com>
	 <571BE5B0.4050608@RedHat.com> <1461468267.12939.9.camel@poochiereds.net>
	 <CAN-5tyEbOQoCEB0EDCXAi2BTdH-VCwfyipAqtAb61P8WxRJ9NA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-04-25 at 12:56 -0400, Olga Kornievskaia wrote:
> On Sat, Apr 23, 2016 at 11:24 PM, Jeff Layton  wrote:
> > 
> > On Sat, 2016-04-23 at 17:14 -0400, Steve Dickson wrote:
> > > 
> > > 
> > > On 04/22/2016 04:41 PM, Olga Kornievskaia wrote:
> > > > 
> > > > 
> > > > On Fri, Apr 22, 2016 at 2:38 PM, Steve Dickson 
> > > > wrote:
> > > > > 
> > > > > 
> > > > > 
> > > > > 
> > > > > On 04/20/2016 05:12 PM, Olga Kornievskaia wrote:
> > > > > > 
> > > > > > 
> > > > > > For the threaded version we have to set uid,gid per thread
> > > > > > instead
> > > > > > of per process. glibc setresuid() when called from a thread,
> > > > > > it'll
> > > > > > send a signal to all other threads to synchronize the uid in
> > > > > > all
> > > > > > other threads. To bypass this, we have to call syscall()
> > > > > > directly.
> > > > > > 
> > > > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > > > Reviewed-by: Steve Dickson <steved@redhat.com>
> > > > > > ---
> > > > > >  utils/gssd/gssd_proc.c | 10 ++++++++--
> > > > > >  1 file changed, 8 insertions(+), 2 deletions(-)
> > > > > > 
> > > > > > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > > > > > index 581a125..5d9a6db 100644
> > > > > > --- a/utils/gssd/gssd_proc.c
> > > > > > +++ b/utils/gssd/gssd_proc.c
> > > > > > @@ -69,6 +69,7 @@
> > > > > >  #include 
> > > > > >  #include 
> > > > > >  #include 
> > > > > > +#include 
> > > > > > 
> > > > > >  #include "gssd.h"
> > > > > >  #include "err_util.h"
> > > > > > @@ -457,7 +458,12 @@ change_identity(uid_t uid)
> > > > > >        * Switch the GIDs. Note that we leave the saved-set-gid
> > > > > > alone in an
> > > > > >        * attempt to prevent attacks via ptrace()
> > > > > >        */
> > > > > > -     if (setresgid(pw->pw_gid, pw->pw_gid, -1) != 0) {
> > > > > > +     /* For the threaded version we have to set uid,gid per
> > > > > > thread instead
> > > > > > +      * of per process. glibc setresuid() when called from a
> > > > > > thread, it'll
> > > > > > +      * send a signal to all other threads to synchronize the
> > > > > > uid in all
> > > > > > +      * other threads. To bypass this, we have to call
> > > > > > syscall() directly.
> > > > > > +      */
> > > > > > +     if (syscall(SYS_setresgid, pw->pw_gid) != 0) {
> > > > > >               printerr(0, "WARNING: failed to set gid to
> > > > > > %u!\n", pw->pw_gid);
> > > > > >               return errno;
> > > > > >       }
> > > > > > @@ -466,7 +472,7 @@ change_identity(uid_t uid)
> > > > > >        * Switch UIDs, but leave saved-set-uid alone to prevent
> > > > > > ptrace() by
> > > > > >        * other processes running with this uid.
> > > > > >        */
> > > > > > -     if (setresuid(uid, uid, -1) != 0) {
> > > > > > +     if (syscall(SYS_setresuid, uid) != 0) {
> > > > > >               printerr(0, "WARNING: Failed to setuid for user
> > > > > > with uid %u\n",
> > > > > >                               uid);
> > > > > >               return errno;
> > > > > > 
> > > > > We also have to do the same thing to the setgroups() call at the
> > > > > top of change_identity(). So add the following diff to this
> > > > > patch and we are good to go...
> > > > > 
> > > > > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > > > > index e651d71..2f9f8ab 100644
> > > > > --- a/utils/gssd/gssd_proc.c
> > > > > +++ b/utils/gssd/gssd_proc.c
> > > > > @@ -437,7 +437,7 @@ change_identity(uid_t uid)
> > > > >         struct passwd   *pw;
> > > > > 
> > > > >         /* drop list of supplimentary groups first */
> > > > > -       if (setgroups(0, NULL) != 0) {
> > > > > +       if (syscall(SYS_setgroups, 0) != 0) {
> > > > >                 printerr(0, "WARNING: unable to drop
> > > > > supplimentary groups!");
> > > > >                 return errno;
> > > > >         }
> > > > > 
> > > > Do you know why we do this before getting the passwd entry?
> > > It came in with commit 6b53fc9c which changed the way gssd
> > > changed the uid/gid from Jeff Layton...
> > > 
> > > Jeff, what was the thought behind dropping supplementary groups?
> > > I believe it was some type of security thing.
> > > 
> > We do that so that the child doesn't run with supplementary groups from
> > the main process.
> > 
> > As to why we do that before getting the passwd entry instead of after?
> > No real reason for the order that I can recall. If you need to do it
> > after the pw entry, I don't think it'll matter.
> > 
> > That said, since this has to run as root anyway, I guess you could drop
> > the supplementary groups in the main process. Then all of the children
> > should get a zeroed out grouplist, and it's one less syscall...
> Thank Jeff, I thought that since we are setting the effective uid/gid
> of the process (or with the patches, thread), then the child process
> (thread) would have the supplementary groups associated with the given
> uid.
> 

No. Calling seteuid should have no effect on the supplementary groups
list, AFAIK. Oh, and yeah...the manpage says:

       setgroups()  sets  the supplementary group IDs for the calling process.
       Appropriate privileges (Linux: the CAP_SETGID capability) are required.

So you do need to clean out the groupslist and gids first and only
afterward set the uids.

> > > 
> > > > 
> > > > Doing as you suggest causes problems as in it it fails to drop the
> > > > supplementary groups.
> > > hmm... what are you seeing that I'm not?
> It was my bad. I decided to change the order of when the call is done
> (ie., doing it after the setting the uid and gid) and that causes an
> error. Perhaps it's becuase once the uid is changed to some user's
> uid, then that uid no longer has the ability to drop the supplementary
> groups.
> 
> Going to send a new version of patches...
> 
> > 
> > > 
> > > 
> > > steved.
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > > in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > Jeff Layton <jlayton@poochiereds.net>
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Jeff Layton <jlayton@poochiereds.net>
