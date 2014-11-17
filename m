Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:58941 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbaKQRsa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 12:48:30 -0500
Received: by mail-qa0-f50.google.com with SMTP id w8so5535209qac.23
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2014 09:48:29 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 17 Nov 2014 12:48:27 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsidmap: keyctl_invalidate kernel compatibility
Message-ID: <20141117124827.31f2fd12@tlielax.poochiereds.net>
In-Reply-To: <F451643C-9490-426A-BCFB-7B9DA8408A3F@oracle.com>
References: <eee96450255a3407517dd1ed4ce9991ba9f2dbd1.1415034378.git.bcodding@redhat.com>
	<54592B0E.5050201@RedHat.com>
	<46A4BDBA-C8B6-47CB-BA19-4D459944EA01@oracle.com>
	<5CB17B23-69BB-4680-9EF6-E09F46D382DE@oracle.com>
	<20141117121156.7db89956@tlielax.poochiereds.net>
	<F451643C-9490-426A-BCFB-7B9DA8408A3F@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 17 Nov 2014 12:28:59 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Nov 17, 2014, at 12:11 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> 
> > On Mon, 17 Nov 2014 11:54:29 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> Hi Jeff-
> >> 
> >> On Nov 4, 2014, at 3:44 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >> 
> >>> On Nov 4, 2014, at 2:37 PM, Steve Dickson <SteveD@redhat.com> wrote:
> >>> 
> >>>> On 11/03/2014 12:12 PM, Benjamin Coddington wrote:
> >>>>> Change the keyctl_invalidate call to use the syscall interface directly so
> >>>>> that when building with libkeyutils missing keyctl_invalidate the build succeeds.
> >>>>> Attempt to use _invalidate and fall back to _revoke if the current kernel is
> >>>>> missing _invalidate.
> >>>>> 
> >>>>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> >>>> Committed... 
> >>>> 
> >>>> This does get by the nfsidmap compile error when 
> >>>> compiling on RHEL6, but not the ones in nfsdcltrack/sqlite.c
> >>>> (http://ur1.ca/ioyfs)
> >>>> 
> >>>> Chuck, how are you getting around them?
> >>> 
> >>> Short answer: I’m not.
> >>> 
> >>> The nfsdcltrack build fails after nfsidmap is built. I just
> >>> installed the nfsidmap binary for testing, and ignored the
> >>> rest of upstream nfs-utils.
> >> 
> >> OK, here’s a detailed bug report.
> >> 
> >> I’m trying to build the current upstream nfs-utils on one
> >> of my EL6-based systems (see previous items in this thread).
> >> 
> >> In my copy of /usr/include/sqlite3.h (EL6):
> >> 
> >> #define SQLITE_VERSION        "3.6.20"
> >> #define SQLITE_VERSION_NUMBER 3006020
> >> #define SQLITE_SOURCE_ID      "2009-11-04 13:30:02 eb7a544fe49d1626bacecfe53ddc03fe082e3243”
> >> 
> >> aclocal/libsqlite3.h has this check:
> >> 
> >> 13   AC_CACHE_VAL([libsqlite3_cv_is_recent],
> >> 14    [
> >> 15     saved_LIBS="$LIBS"
> >> 16     LIBS=-lsqlite3
> >> 17     AC_TRY_RUN([
> >> 18         #include <stdio.h>
> >> 19         #include <sqlite3.h>
> >> 20         int main()
> >> 21         {
> >> 22                 int vers = sqlite3_libversion_number();
> >> 23 
> >> 24                 return vers != SQLITE_VERSION_NUMBER ||
> >> 25                         vers < 3003000;
> >> 26         }
> >> 27        ], [libsqlite3_cv_is_recent=yes], [libsqlite3_cv_is_recent=no],
> >> 28        [libsqlite3_cv_is_recent=unknown])
> >> 29     LIBS="$saved_LIBS"])
> >> 
> >> But the build fails during the link step:
> >> 
> >> libtool: link: gcc -Wall -Wextra -Wstrict-prototypes -pipe -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wp,-D_FORTIFY_SOURCE=2 -Os -Wall -Wextra -pedantic -std=c99 -Wformat=2 -Wmissing-include-dirs -Wunused -Wconversion -Wlogical-op -Wmissing-prototypes -Wmissing-declarations -Wstrict-prototypes -Wmissing-noreturn -Wshadow -Wunreachable-code -Winline -Wdisabled-optimization -Wstrict-aliasing=2 -Wstrict-overflow=4 -Wstack-protector -fstrict-aliasing -fstrict-overflow -fexceptions -fstack-protector -fasynchronous-unwind-tables -fpie -pie -o nfsdcltrack nfsdcltrack.o sqlite.o  ../../support/nfs/libnfs.a -lsqlite3
> >> sqlite.o: In function `sqlite_query_reclaiming':
> >> sqlite.c:(.text+0x3b): undefined reference to `sqlite3_errstr'
> >> sqlite.c:(.text+0x6e): undefined reference to `sqlite3_errstr'
> >> sqlite.c:(.text+0x9a): undefined reference to `sqlite3_errstr'
> >> sqlite.o: In function `sqlite_query_schema_version':
> >> sqlite.c:(.text+0x12b): undefined reference to `sqlite3_errstr'
> >> sqlite.c:(.text+0x15a): undefined reference to `sqlite3_errstr'
> >> sqlite.o:sqlite.c:(.text+0x97a): more undefined references to `sqlite3_errstr' follow
> >> sqlite.o: In function `sqlite_prepare_dbh':
> >> sqlite.c:(.text+0xb95): undefined reference to `'
> >> collect2: ld returned 1 exit status
> >> make[2]: *** [nfsdcltrack] Error 1
> >> 
> >> The release of libsqlite3 on this system passes the
> >> existing aclocal test in nfs-utils, but does not appear
> >> to have either sqlite3_errstr() or sqlite3_close_v2().
> >> 
> >> Some sqlite3_errstr() callsites data back to 2012.
> >> sqlite3_close_v2() was added by commit 3548dd1563d5 in
> >> September 2014. The vintage of libsqlite3 here appears
> >> to be 2009.
> >> 
> >> I do not need nfsdcltrack on this system, but am merely
> >> noting that nfs-utils does not build on EL6 systems.
> >> 
> >> There seem to be some alternatives for addressing this,
> >> but I need a little guidance on which is the appropriate
> >> choice. Fixing the aclocal test is most obvious; then
> >> change my configure options to add —disable-nfsdcltrack.
> >> 
> >> Thoughts?
> >> 
> >> --
> >> Chuck Lever
> >> chuck[dot]lever[at]oracle[dot]com
> >> 
> >> 
> >> 
> > 
> > Ok, good catch...
> > 
> > Probably we just need to change the "vers < 3003000" check in
> > libsqlite3.m4 to require a more recent version. Unfortunately, it's a
> > little difficult to tell what version we should require.
> > 
> > According to this page, sqlite3_close_v2 got added in 3.7.14 and
> > sqlite3_errstr got added in 3.7.15. So I guess we should change that to
> > read:
> > 
> >    vers < 3007015
> > 
> > Can you test and see whether that helps? I don't have a RHEL6 box handy
> > at the moment.
> 
> checking sys/inotify.h presence... yes
> checking for sys/inotify.h... yes
> configure: error: nfsdcltrack requires sqlite-devel
> make: *** No rule to make target `all'.  Stop.
> 
> So, ./configure is stopped at this point, which is what
> we want. But the error message is deceptive:
> 
> [cel@manet nfs-utils]$ sudo su -
> [root@manet ~]# yum install sqlite-devel
> Loaded plugins: security
> Setting up Install Process
> Package sqlite-devel-3.6.20-1.el6.x86_64 already installed and latest version
> Nothing to do
> [root@manet ~]#
> 

Yeah, we probably ought to fix the error message there. Looks like the
$libsqlite3_cv_is_recent logic in configure.ac is borked. I'll also note
that inotify.h isn't required for it. That was a holdover from when we
had this thing as a daemon. I'll see if I can spin up a patch to fix it
when I get some time, unless you or someone else beats me to it...

> And, adding —disable-nfsdcltrack skips the sqlite3
> version check and my builds runs to completion. Also
> good.
> 

Yes. I suppose we could also consider autodisabling nfsdcltrack in this
situation, but maybe a hard failure is better there so that it has to
be explicitly disabled.

> > Alternately we could try to detect whether these functions are present
> > using standard autoconf checks, but I'm not sure I care enough to go to
> > that level of effort. ;)
> 
> Looks like aclocal/libsqlite3 goes to some pain to avoid
> adding libsqlite3 to LIBS. I suspect adding AC_CHECK_FUNC
> would alter LIBS, but don’t recall exactly how this plays
> out.
> 
> We’d have to find substitutes for these functions, in that
> case. Do you remember why you chose to use close_v2() over
> close() ?
> 
> https://www.sqlite.org/c3ref/close.html says:
> 
> > If sqlite3_close_v2() is called with unfinalized prepared statements and/or unfinished sqlite3_backups, then the database connection becomes an unusable "zombie" which will automatically be deallocated when the last prepared statement is finalized or the last sqlite3_backup is finished. The sqlite3_close_v2() interface is intended for use with host languages that are garbage collected, and where the order in which destructors are called is arbitrary.
> 
> 
> C isn’t considered “a garbage-collected” language, is it?
> And nfsdcltrack is kind of a one-shot (like nfsidmap) so
> the close order should matter, it’s not a long-running
> program, unless I missed something.
> 
> That might be worth the trouble if we expect nfsdcltrack
> to be used on 2.6.3x era systems. Otherwise, probably not.
> 

I don't recall why I used _v2.

Switching it to sqlite3_close is probably fine. These programs are
short-lived so a little bit of "leakage" and such is not really a big
deal should it return SQLITE_BUSY.

And yes, I don't see much reason to build this for any system that's
this old. I expect most people running such hosts will want to use the
legacy tracker anyway.

-- 
Jeff Layton <jlayton@primarydata.com>
