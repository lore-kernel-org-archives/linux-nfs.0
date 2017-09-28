Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42294 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752602AbdI1DBQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Sep 2017 23:01:16 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton\@kernel.org" <jlayton@kernel.org>
Date: Thu, 28 Sep 2017 13:01:04 +1000
Cc: linux-man@vger.kernel.org,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC PATCH manpages] write.2, fsync.2, close.2: update description of error codes
In-Reply-To: <1505386139.4870.10.camel@redhat.com>
References: <20170720194227.7830-1-jlayton@kernel.org> <1503683981.22608.0.camel@redhat.com> <87h8wsiog4.fsf@notabene.neil.brown.name> <1503920855.4563.12.camel@redhat.com> <87pobfgo9q.fsf@notabene.neil.brown.name> <1504004058.4679.7.camel@redhat.com> <87efrjb2mn.fsf@notabene.neil.brown.name> <1504784132.4954.12.camel@redhat.com> <1504796087.3561.7.camel@primarydata.com> <874ls9diij.fsf@notabene.neil.brown.name> <1505126785.4916.7.camel@redhat.com> <87poawc390.fsf@notabene.neil.brown.name> <1505229616.28831.26.camel@redhat.com> <87efrbbne1.fsf@notabene.neil.brown.name> <1505305391.4822.13.camel@redhat.com> <87ingm9n04.fsf@notabene.neil.brown.name> <1505386139.4870.10.camel@redhat.com>
Message-ID: <87fub75xxr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 14 2017, Jeff Layton wrote:

>>  .TP
>>  .B EIO
>> -An error occurred during synchronization.
>> +An error occurred during synchronization.  This error may relate
>> +to data written to some other file descriptor on the same file.
>> +.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
>> +Since Linux 4.13 errors from write-back will be reported to
>> +all file descriptors that might have written the data which triggered
>> +the error, and which are still open.
>
> This is a little awkward. How could we report to a fd that was no longer
> open? How about:
>
> "Since Linux 4.13, errors from write-back will be reported to all file
> descriptors that were open at the time that the error was recorded."

That might be simpler, but it is less correct.  As I go on to say, NFS
*doesn't* report on all file descriptors that were open at that time.

I've changed it to

=2D------------------
Since Linux 4.13, errors from write-back will be reported to
all file descriptors that might have written the data which triggered
the error.  Some filesystems (e.g. NFS) keep close track of which data
came through which file descriptor, and give precise reporting.
Other filesystems (e.g. most local filesystems) will report errors to
all file descriptors that where open on the file when the error was recorde=
d.
=2D-----------------

which includes some of your text, and removes the "that are still open"
which probably doesn't help.

>>  .TP
>>  .B EIO
>>  A low-level I/O error occurred while modifying the inode.
>> +This error may relate to data written by an earlier
>> +.BR write (2),
>> +which may have been issued to a different file descriptor on
>> +the same file.  Since Linux 4.13 errors from write-back will
>> +be reported to all file descriptors that might have
>> +written the data which triggered the error, and which are still
>> +open.
>
>
> This is where things get a little more vague.
>
> Some filesystems will return errors on a subsequent write(2) when
> previous writeback has failed -- some don't. In either case though,
> write(2) should never advance your errseq_t cursor, so only an fsync
> will "clear" an earlier error.
>
> I'm not sure how best to convey that in the manpages though.

How about:

=2D------------
This error may relate to the write-back of data written by an
earlier
.BR write (2),
which may have been issued to a different file descriptor on
the same file.  Since Linux 4.13, errors from write-back come
with a promise that they
.I may
be reported by subsequent.
.BR write (2)
requests, and
.I will
be reported by a subsequent
.BR fsync (2)
(whether or not they were also reported by
.BR write (2)).
=2D-----------
??

Those changes are included in the following.

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Sep 2017 09:44:43 +1000
Subject: [PATCH] write.2, fsync.2, close.2: update description of error cod=
es

Since 4.13, errors from writeback are more reliably reported
to all file descriptors that might be relevant.

Add notes to this effect, and also add detail about ENOSPC and EDQUOT
which can be delayed in a similar many to EIO - for NFS in particular.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 man2/close.2 |  9 +++++++++
 man2/fsync.2 | 18 +++++++++++++++++-
 man2/write.2 | 28 +++++++++++++++++++++++++---
 3 files changed, 51 insertions(+), 4 deletions(-)

diff --git a/man2/close.2 b/man2/close.2
index 55d89ed3dbc7..136bd0be3f67 100644
=2D-- a/man2/close.2
+++ b/man2/close.2
@@ -82,6 +82,15 @@ call was interrupted by a signal; see
 .TP
 .B EIO
 An I/O error occurred.
+.TP
+.BR ENOSPC ", " EDQUOT
+On NFS, these errors are not normally reported against the first write
+which exceeds the available storage space, but instead against a
+subsequent
+.BR write (2),
+.BR fsync (2),
+or
+.BR close (2).
 .PP
 See NOTES for a discussion of why
 .BR close ()
diff --git a/man2/fsync.2 b/man2/fsync.2
index eed3c460bea9..c7878bf3496f 100644
=2D-- a/man2/fsync.2
+++ b/man2/fsync.2
@@ -121,7 +121,15 @@ is set appropriately.
 is not a valid open file descriptor.
 .TP
 .B EIO
=2DAn error occurred during synchronization.
+An error occurred during synchronization.  This error may relate
+to data written to some other file descriptor on the same file.
+.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
+Since Linux 4.13, errors from write-back will be reported to
+all file descriptors that might have written the data which triggered
+the error.  Some filesystems (e.g. NFS) keep close track of which data
+came through which file descriptor, and give more precise reporting.
+Other filesystems (e.g. most local filesystems) will report errors to
+all file descriptors that where open on the file when the error was record=
ed.
 .TP
 .B ENOSPC
 Disk space was exhausted while synchronizing.
@@ -130,6 +138,14 @@ Disk space was exhausted while synchronizing.
 .I fd
 is bound to a special file (e.g., a pipe, FIFO, or socket)
 which does not support synchronization.
+.TP
+.BR ENOSPC ", " EDQUOT
+.I fd
+is bound to a file on NFS or another filesystem which does not allocate
+space at the time of a
+.BR write (2)
+system call, and some previous write failed due to insufficient
+storage space.
 .SH CONFORMING TO
 POSIX.1-2001, POSIX.1-2008, 4.3BSD.
 .SH AVAILABILITY
diff --git a/man2/write.2 b/man2/write.2
index 061aa70cf590..b1cc3a2cfb17 100644
=2D-- a/man2/write.2
+++ b/man2/write.2
@@ -47,7 +47,7 @@ write \- write to a file descriptor
 .BR write ()
 writes up to
 .I count
=2Dbytes from the buffer pointed
+bytes from the buffer starting at
 .I buf
 to the file referred to by the file descriptor
 .IR fd .
@@ -181,6 +181,22 @@ or the file offset is not suitably aligned.
 .TP
 .B EIO
 A low-level I/O error occurred while modifying the inode.
+This error may relate to the write-back of data written by an
+earlier
+.BR write (2),
+which may have been issued to a different file descriptor on
+the same file.  Since Linux 4.13, errors from write-back come
+with a promise that they
+.I may
+be reported by subsequent.
+.BR write (2)
+requests, and
+.I will
+be reported by a subsequent
+.BR fsync (2)
+(whether or not they were also reported by
+.BR write (2)).
+.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
 .TP
 .B ENOSPC
 The device containing the file referred to by
@@ -222,8 +238,14 @@ unsigned and signed integer data types specified by PO=
SIX.1.
 A successful return from
 .BR write ()
 does not make any guarantee that data has been committed to disk.
=2DIn fact, on some buggy implementations, it does not even guarantee
=2Dthat space has successfully been reserved for the data.
+On some filesystems, including NFS, it does not even guarantee
+that space has successfully been reserved for the data.  In the case,
+some errors might be delayed to a future
+.BR write (2)
+or to
+.BR fsync (2)
+or even
+.BR close (2).
 The only way to be sure is to call
 .BR fsync (2)
 after you are done writing all your data.
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlnMZfIACgkQOeye3VZi
gbnOWw//WkAgS5vPMU4k/eeY+84G/RmjkWFbQ3ogk4FyCBjDrGm9mh2awSRZge83
KngZ5QJZwePHEM/4jFeM/7AylExxUr3apI57TPVRqhZ+yQXy5tJJiQRsflI4g7dd
ZRiX6sOl+4CQbV9xSMNAGvyYzOICXTRHEb6pgSnkZfd9Vef1vbwOYX0tiyyxO7ss
2AmwIuomrTSlbmRK7OZkY2wS+bP6w78TYs99Lj1xKqsC8gse2PbzXPSM2CA/hGwC
yWrMVpvMsRo9uqYqPL43sX5L33zoH7vD4J4RGxguhc2znNUf02Z2CqriMvDdbDvD
cNfCBt/n2aR4eKZsZJuUmy3DxNr4tYCZwJDTOkf3/svEcRlRmTR1i59+CetlkdP0
GByF1Fr5W9UTnARvNJmhrHjl65Iiz+3BoMu47/XDoU9o+iU1OVuz0uAeV0mnUfzO
lPoY5V3XmwdqiU60FitAwjtruZZrSz3UTkjPoKSCBd0DdLXuGKegolb5KCYeJ27l
q+VS7CIfNyWCLfjsAfNF41moQOqfcI698n4xGSm2Q8Nt6M4V6FyseDk5c8JckMlE
9PYor4B3HeK8gPDp3ZzIVCLxNLq1BCYHrqH6P3H94i/m2W80cC10ZOTqPgznxVTI
sS6+8hLVHG5Bw016pi6GjR5Im3USE1D9TBUREdton31+Og7DgNg=
=/DBv
-----END PGP SIGNATURE-----
--=-=-=--
