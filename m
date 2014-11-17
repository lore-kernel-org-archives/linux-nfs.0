Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:33576 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbaKQQyf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 11:54:35 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2] nfsidmap: keyctl_invalidate kernel compatibility
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <46A4BDBA-C8B6-47CB-BA19-4D459944EA01@oracle.com>
Date: Mon, 17 Nov 2014 11:54:29 -0500
Cc: Steve Dickson <SteveD@redhat.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5CB17B23-69BB-4680-9EF6-E09F46D382DE@oracle.com>
References: <eee96450255a3407517dd1ed4ce9991ba9f2dbd1.1415034378.git.bcodding@redhat.com> <54592B0E.5050201@RedHat.com> <46A4BDBA-C8B6-47CB-BA19-4D459944EA01@oracle.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff-

On Nov 4, 2014, at 3:44 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> On Nov 4, 2014, at 2:37 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
>> On 11/03/2014 12:12 PM, Benjamin Coddington wrote:
>>> Change the keyctl_invalidate call to use the syscall interface directly so
>>> that when building with libkeyutils missing keyctl_invalidate the build succeeds.
>>> Attempt to use _invalidate and fall back to _revoke if the current kernel is
>>> missing _invalidate.
>>> 
>>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> Committed... 
>> 
>> This does get by the nfsidmap compile error when 
>> compiling on RHEL6, but not the ones in nfsdcltrack/sqlite.c
>> (http://ur1.ca/ioyfs)
>> 
>> Chuck, how are you getting around them?
> 
> Short answer: I’m not.
> 
> The nfsdcltrack build fails after nfsidmap is built. I just
> installed the nfsidmap binary for testing, and ignored the
> rest of upstream nfs-utils.

OK, here’s a detailed bug report.

I’m trying to build the current upstream nfs-utils on one
of my EL6-based systems (see previous items in this thread).

In my copy of /usr/include/sqlite3.h (EL6):

#define SQLITE_VERSION        "3.6.20"
#define SQLITE_VERSION_NUMBER 3006020
#define SQLITE_SOURCE_ID      "2009-11-04 13:30:02 eb7a544fe49d1626bacecfe53ddc03fe082e3243”

aclocal/libsqlite3.h has this check:

 13   AC_CACHE_VAL([libsqlite3_cv_is_recent],
 14    [
 15     saved_LIBS="$LIBS"
 16     LIBS=-lsqlite3
 17     AC_TRY_RUN([
 18         #include <stdio.h>
 19         #include <sqlite3.h>
 20         int main()
 21         {
 22                 int vers = sqlite3_libversion_number();
 23 
 24                 return vers != SQLITE_VERSION_NUMBER ||
 25                         vers < 3003000;
 26         }
 27        ], [libsqlite3_cv_is_recent=yes], [libsqlite3_cv_is_recent=no],
 28        [libsqlite3_cv_is_recent=unknown])
 29     LIBS="$saved_LIBS"])

But the build fails during the link step:

libtool: link: gcc -Wall -Wextra -Wstrict-prototypes -pipe -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wp,-D_FORTIFY_SOURCE=2 -Os -Wall -Wextra -pedantic -std=c99 -Wformat=2 -Wmissing-include-dirs -Wunused -Wconversion -Wlogical-op -Wmissing-prototypes -Wmissing-declarations -Wstrict-prototypes -Wmissing-noreturn -Wshadow -Wunreachable-code -Winline -Wdisabled-optimization -Wstrict-aliasing=2 -Wstrict-overflow=4 -Wstack-protector -fstrict-aliasing -fstrict-overflow -fexceptions -fstack-protector -fasynchronous-unwind-tables -fpie -pie -o nfsdcltrack nfsdcltrack.o sqlite.o  ../../support/nfs/libnfs.a -lsqlite3
sqlite.o: In function `sqlite_query_reclaiming':
sqlite.c:(.text+0x3b): undefined reference to `sqlite3_errstr'
sqlite.c:(.text+0x6e): undefined reference to `sqlite3_errstr'
sqlite.c:(.text+0x9a): undefined reference to `sqlite3_errstr'
sqlite.o: In function `sqlite_query_schema_version':
sqlite.c:(.text+0x12b): undefined reference to `sqlite3_errstr'
sqlite.c:(.text+0x15a): undefined reference to `sqlite3_errstr'
sqlite.o:sqlite.c:(.text+0x97a): more undefined references to `sqlite3_errstr' follow
sqlite.o: In function `sqlite_prepare_dbh':
sqlite.c:(.text+0xb95): undefined reference to `sqlite3_close_v2'
collect2: ld returned 1 exit status
make[2]: *** [nfsdcltrack] Error 1

The release of libsqlite3 on this system passes the
existing aclocal test in nfs-utils, but does not appear
to have either sqlite3_errstr() or sqlite3_close_v2().

Some sqlite3_errstr() callsites data back to 2012.
sqlite3_close_v2() was added by commit 3548dd1563d5 in
September 2014. The vintage of libsqlite3 here appears
to be 2009.

I do not need nfsdcltrack on this system, but am merely
noting that nfs-utils does not build on EL6 systems.

There seem to be some alternatives for addressing this,
but I need a little guidance on which is the appropriate
choice. Fixing the aclocal test is most obvious; then
change my configure options to add —disable-nfsdcltrack.

Thoughts?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



