Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33994 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287AbcD0ON3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2016 10:13:29 -0400
Received: by mail-qk0-f177.google.com with SMTP id r184so18801943qkc.1
        for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2016 07:13:29 -0700 (PDT)
Message-ID: <1461766405.4403.3.camel@poochiereds.net>
Subject: Re: [PATCH v4 2/3] gssd: using syscalls directly to change thread's
 identity
From: Jeff Layton <jlayton@poochiereds.net>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>, Steve Dickson <steved@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Date: Wed, 27 Apr 2016 10:13:25 -0400
In-Reply-To: <CAN-5tyH_yHoRhkXegP4gQ0FS-C+Rmx7ziEiRd4+d7NkBDuR7Qw@mail.gmail.com>
References: <1461677655-68294-1-git-send-email-kolga@netapp.com>
	 <1461677655-68294-3-git-send-email-kolga@netapp.com>
	 <1461689470.4200.7.camel@poochiereds.net>
	 <CAN-5tyH_yHoRhkXegP4gQ0FS-C+Rmx7ziEiRd4+d7NkBDuR7Qw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-04-27 at 10:09 -0400, Olga Kornievskaia wrote:
> On Tue, Apr 26, 2016 at 12:51 PM, Jeff Layton <jlayton@poochiereds.ne
> t> wrote:
> > On Tue, 2016-04-26 at 09:34 -0400, Olga Kornievskaia wrote:
> > > For the threaded version we have to set uid,gid per thread
> > > instead
> > > of per process. glibc setresuid() when called from a thread,
> > > it'll
> > > send a signal to all other threads to synchronize the uid in all
> > > other threads. To bypass this, we have to call syscall()
> > > directly.
> > > 
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > Reviewed-by: Steve Dickson <steved@redhat.com>
> > > ---
> > >  utils/gssd/gssd_proc.c | 12 +++++++++---
> > >  1 file changed, 9 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > > index e2e95dc..39c4b17 100644
> > > --- a/utils/gssd/gssd_proc.c
> > > +++ b/utils/gssd/gssd_proc.c
> > > @@ -69,6 +69,7 @@
> > >  #include
> > >  #include
> > >  #include
> > > +#include
> > > 
> > >  #include "gssd.h"
> > >  #include "err_util.h"
> > > @@ -436,7 +437,7 @@ change_identity(uid_t uid)
> > >       struct passwd   *pw;
> > > 
> > >       /* drop list of supplimentary groups first */
> > > -     if (setgroups(0, NULL) != 0) {
> > > +     if (syscall(SYS_setgroups, 0, 0) != 0) {
> > >               printerr(0, "WARNING: unable to drop supplimentary
> > > groups!");
> > >               return errno;
> > >       }
> > > @@ -457,7 +458,12 @@ change_identity(uid_t uid)
> > >        * Switch the GIDs. Note that we leave the saved-set-gid
> > > alone in an
> > >        * attempt to prevent attacks via ptrace()
> > >        */
> > > -     if (setresgid(pw->pw_gid, pw->pw_gid, -1) != 0) {
> > > +     /* For the threaded version we have to set uid,gid per
> > > thread instead
> > > +      * of per process. glibc setresuid() when called from a
> > > thread, it'll
> > > +      * send a signal to all other threads to synchronize the
> > > uid in all
> > > +      * other threads. To bypass this, we have to call syscall()
> > > directly.
> > > +      */
> > > +     if (syscall(SYS_setresgid, pw->pw_gid, -1, -1) != 0) {
> > >               printerr(0, "WARNING: failed to set gid to %u!\n",
> > > pw->pw_gid);
> > >               return errno;
> > >       }
> > > @@ -466,7 +472,7 @@ change_identity(uid_t uid)
> > >        * Switch UIDs, but leave saved-set-uid alone to prevent
> > > ptrace() by
> > >        * other processes running with this uid.
> > >        */
> > > -     if (setresuid(uid, uid, -1) != 0) {
> > > +     if (syscall(SYS_setresuid, uid, -1, -1) != 0) {
> > >               printerr(0, "WARNING: Failed to setuid for user
> > > with uid %u\n",
> > >                               uid);
> > >               return errno;
> > 
> > Note that the old code set both real and effective uid/gid. Here
> > you're
> > changing it to just set the real uid. Is that change deliberate? I
> > think you probably want to set the euid/egid as well.
> 
> It was a typo (cthon tests ran fine though which is confusing since
> kerberos code does geteuid()). Now I'm thinking that given that we
> don't touch saved uid, perhaps the code should call SYS_setreuid
> instead of SYS_setresuid?
> 

Yes, good point. Either that or just set all 3 to "uid", I'd think.

-- 
Jeff Layton <jlayton@poochiereds.net>
