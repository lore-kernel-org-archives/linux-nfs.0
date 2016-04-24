Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35106 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbcDXDYd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Apr 2016 23:24:33 -0400
Received: by mail-qk0-f172.google.com with SMTP id q76so37687712qke.2
        for <linux-nfs@vger.kernel.org>; Sat, 23 Apr 2016 20:24:32 -0700 (PDT)
Message-ID: <1461468267.12939.9.camel@poochiereds.net>
Subject: Re: [RFC PATCH v2 2/3] gssd: using syscalls directly to change
 thread's identity
From: Jeff Layton <jlayton@poochiereds.net>
To: Steve Dickson <SteveD@redhat.com>, Olga Kornievskaia <aglo@umich.edu>,
        Jeff Layton <layton@primarydata.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date: Sat, 23 Apr 2016 23:24:27 -0400
In-Reply-To: <571BE5B0.4050608@RedHat.com>
References: <1461186721-64008-1-git-send-email-kolga@netapp.com>
	 <1461186721-64008-3-git-send-email-kolga@netapp.com>
	 <571A6FB0.8080709@RedHat.com>
	 <CAN-5tyH-JqHTnm+j0XG277qVQVbocR-j6MRn0aq9A8PLh_iMRg@mail.gmail.com>
	 <571BE5B0.4050608@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-04-23 at 17:14 -0400, Steve Dickson wrote:
> 
> On 04/22/2016 04:41 PM, Olga Kornievskaia wrote:
> > 
> > On Fri, Apr 22, 2016 at 2:38 PM, Steve Dickson <SteveD@redhat.com>
> > wrote:
> > > 
> > > 
> > > 
> > > On 04/20/2016 05:12 PM, Olga Kornievskaia wrote:
> > > > 
> > > > For the threaded version we have to set uid,gid per thread
> > > > instead
> > > > of per process. glibc setresuid() when called from a thread,
> > > > it'll
> > > > send a signal to all other threads to synchronize the uid in
> > > > all
> > > > other threads. To bypass this, we have to call syscall()
> > > > directly.
> > > > 
> > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > Reviewed-by: Steve Dickson <steved@redhat.com>
> > > > ---
> > > >  utils/gssd/gssd_proc.c | 10 ++++++++--
> > > >  1 file changed, 8 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > > > index 581a125..5d9a6db 100644
> > > > --- a/utils/gssd/gssd_proc.c
> > > > +++ b/utils/gssd/gssd_proc.c
> > > > @@ -69,6 +69,7 @@
> > > >  #include <netdb.h>
> > > >  #include <sys/types.h>
> > > >  #include <sys/wait.h>
> > > > +#include <syscall.h>
> > > > 
> > > >  #include "gssd.h"
> > > >  #include "err_util.h"
> > > > @@ -457,7 +458,12 @@ change_identity(uid_t uid)
> > > >        * Switch the GIDs. Note that we leave the saved-set-gid
> > > > alone in an
> > > >        * attempt to prevent attacks via ptrace()
> > > >        */
> > > > -     if (setresgid(pw->pw_gid, pw->pw_gid, -1) != 0) {
> > > > +     /* For the threaded version we have to set uid,gid per
> > > > thread instead
> > > > +      * of per process. glibc setresuid() when called from a
> > > > thread, it'll
> > > > +      * send a signal to all other threads to synchronize the
> > > > uid in all
> > > > +      * other threads. To bypass this, we have to call
> > > > syscall() directly.
> > > > +      */
> > > > +     if (syscall(SYS_setresgid, pw->pw_gid) != 0) {
> > > >               printerr(0, "WARNING: failed to set gid to
> > > > %u!\n", pw->pw_gid);
> > > >               return errno;
> > > >       }
> > > > @@ -466,7 +472,7 @@ change_identity(uid_t uid)
> > > >        * Switch UIDs, but leave saved-set-uid alone to prevent
> > > > ptrace() by
> > > >        * other processes running with this uid.
> > > >        */
> > > > -     if (setresuid(uid, uid, -1) != 0) {
> > > > +     if (syscall(SYS_setresuid, uid) != 0) {
> > > >               printerr(0, "WARNING: Failed to setuid for user
> > > > with uid %u\n",
> > > >                               uid);
> > > >               return errno;
> > > > 
> > > We also have to do the same thing to the setgroups() call at the
> > > top of change_identity(). So add the following diff to this
> > > patch and we are good to go...
> > > 
> > > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > > index e651d71..2f9f8ab 100644
> > > --- a/utils/gssd/gssd_proc.c
> > > +++ b/utils/gssd/gssd_proc.c
> > > @@ -437,7 +437,7 @@ change_identity(uid_t uid)
> > >         struct passwd   *pw;
> > > 
> > >         /* drop list of supplimentary groups first */
> > > -       if (setgroups(0, NULL) != 0) {
> > > +       if (syscall(SYS_setgroups, 0) != 0) {
> > >                 printerr(0, "WARNING: unable to drop
> > > supplimentary groups!");
> > >                 return errno;
> > >         }
> > > 
> > Do you know why we do this before getting the passwd entry?
> It came in with commit 6b53fc9c which changed the way gssd
> changed the uid/gid from Jeff Layton...
> 
> Jeff, what was the thought behind dropping supplementary groups?
> I believe it was some type of security thing.
> 

We do that so that the child doesn't run with supplementary groups from
the main process.

As to why we do that before getting the passwd entry instead of after?
No real reason for the order that I can recall. If you need to do it
after the pw entry, I don't think it'll matter.

That said, since this has to run as root anyway, I guess you could drop
the supplementary groups in the main process. Then all of the children
should get a zeroed out grouplist, and it's one less syscall...

> > 
> > 
> > Doing as you suggest causes problems as in it it fails to drop the
> > supplementary groups.
> hmm... what are you seeing that I'm not?
> 
> steved.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jeff Layton <jlayton@poochiereds.net>

