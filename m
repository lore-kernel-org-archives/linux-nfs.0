Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55436 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751197AbdIOI0I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Sep 2017 04:26:08 -0400
From: NeilBrown <neilb@suse.com>
To: "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton\@kernel.org" <jlayton@kernel.org>
Date: Fri, 15 Sep 2017 18:25:53 +1000
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC PATCH manpages] write.2, fsync.2, close.2: update description of error codes
In-Reply-To: <28da8888-e8f9-31d5-a3dd-d3c2a5e9037a@gmail.com>
References: <20170720194227.7830-1-jlayton@kernel.org> <1503683981.22608.0.camel@redhat.com> <87h8wsiog4.fsf@notabene.neil.brown.name> <1503920855.4563.12.camel@redhat.com> <87pobfgo9q.fsf@notabene.neil.brown.name> <1504004058.4679.7.camel@redhat.com> <87efrjb2mn.fsf@notabene.neil.brown.name> <1504784132.4954.12.camel@redhat.com> <1504796087.3561.7.camel@primarydata.com> <874ls9diij.fsf@notabene.neil.brown.name> <1505126785.4916.7.camel@redhat.com> <87poawc390.fsf@notabene.neil.brown.name> <1505229616.28831.26.camel@redhat.com> <87efrbbne1.fsf@notabene.neil.brown.name> <1505305391.4822.13.camel@redhat.com> <87ingm9n04.fsf@notabene.neil.brown.name> <1505386139.4870.10.camel@redhat.com> <28da8888-e8f9-31d5-a3dd-d3c2a5e9037a@gmail.com>
Message-ID: <877ex08j1q.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


I'll do something, but maybe not for a few days (24 hour sardine
impersonation pending - Europe, here I come...)

NeilBrown

On Fri, Sep 15 2017, Michael Kerrisk (man-pages) wrote:

> Hi Neil,
>
> Will you revise this patch to incorporate Jeff's comments, or
> should I try manually editing them in. (I'd prefer the former.)
>
> Cheers,
>
> Michael
>
>
> On 09/14/2017 12:48 PM, Jeff Layton wrote:
>> On Thu, 2017-09-14 at 09:50 +1000, NeilBrown wrote:
>>> Since 4.13, errors from writeback are more reliably reported
>>> to all file descriptors that might be relevant.
>>>
>>> Add notes to this effect, and also add details about ENOSPC and EDQUOT
>>> which can be delayed in a similar manner to EIO - for NFS in particular.
>>>
>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>> ---
>>>
>>> This is my summary of recent changes, and details that have been made
>>> clear during the exploration of those changes.
>>>
>>> I haven't mentioned the fact that EPERM can be returned by
>>> write/fsync/close on NFS if the permissions on the server are changed.
>>> We probably should ... are there other errors that are worth mentioning
>>> along with EPERM, ENOSPC, EDQUOT ??
>>>
>>> Thanks,
>>> NeilBronw
>>>
>>=20
>> Many thanks for doing this! It was on my to-do list. Comments below:
>>=20
>>>
>>>  man2/close.2 |  9 +++++++++
>>>  man2/fsync.2 | 19 ++++++++++++++++++-
>>>  man2/write.2 | 20 +++++++++++++++++---
>>>  3 files changed, 44 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/man2/close.2 b/man2/close.2
>>> index 751ec322b1f1..9776c839b8b6 100644
>>> --- a/man2/close.2
>>> +++ b/man2/close.2
>>> @@ -82,6 +82,15 @@ call was interrupted by a signal; see
>>>  .TP
>>>  .B EIO
>>>  An I/O error occurred.
>>> +.TP
>>> +.BR ENOSPC ", " EDQUOT
>>> +On NFS, these errors are not normally reported against the first write
>>> +which exceeds the available storage space, but instead against a
>>> +subsequent
>>> +.BR write (2),
>>> +.BR fsync (2),
>>> +or
>>> +.BR close (2).
>>>  .PP
>>>  See NOTES for a discussion of why
>>>  .BR close ()
>>> diff --git a/man2/fsync.2 b/man2/fsync.2
>>> index f1a01301da0f..e706a08d360d 100644
>>> --- a/man2/fsync.2
>>> +++ b/man2/fsync.2
>>> @@ -120,12 +120,29 @@ is set appropriately.
>>>  is not a valid open file descriptor.
>>>  .TP
>>>  .B EIO
>>> -An error occurred during synchronization.
>>> +An error occurred during synchronization.  This error may relate
>>> +to data written to some other file descriptor on the same file.
>>> +.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
>>> +Since Linux 4.13 errors from write-back will be reported to
>>> +all file descriptors that might have written the data which triggered
>>> +the error, and which are still open.
>>=20
>> This is a little awkward. How could we report to a fd that was no longer
>> open? How about:
>>=20
>> "Since Linux 4.13, errors from write-back will be reported to all file
>> descriptors that were open at the time that the error was recorded."
>>=20
>>>   Some filesystems (e.g. NFS)
>>> +keep close track of which data came through which file descriptor,
>>> +and give more precise reporting.  Other filesystems (e.g. most local
>>> +filesystems) will report errors to all file descriptors on the same
>>> +file.
>>>  .TP
>>>  .BR EROFS ", " EINVAL
>>>  .I fd
>>>  is bound to a special file (e.g., a pipe, FIFO, or socket)
>>>  which does not support synchronization.
>>> +.TP
>>> +.BR ENOSPC ", " EDQUOT
>>> +.I fd
>>> +is bound to a file on NFS or another filesystem which does not allocate
>>> +space at the time of a
>>> +.BR write (2)
>>> +system call, and some previous write failed due to insufficient
>>> +storage space.
>>>  .SH CONFORMING TO
>>>  POSIX.1-2001, POSIX.1-2008, 4.3BSD.
>>>  .SH AVAILABILITY
>>> diff --git a/man2/write.2 b/man2/write.2
>>> index 6a39b5b5541d..1a9a86b03b04 100644
>>> --- a/man2/write.2
>>> +++ b/man2/write.2
>>> @@ -47,7 +47,7 @@ write \- write to a file descriptor
>>>  .BR write ()
>>>  writes up to
>>>  .I count
>>> -bytes from the buffer pointed
>>> +bytes from the buffer starting at
>>>  .I buf
>>>  to the file referred to by the file descriptor
>>>  .IR fd .
>>> @@ -181,6 +181,14 @@ or the file offset is not suitably aligned.
>>>  .TP
>>>  .B EIO
>>>  A low-level I/O error occurred while modifying the inode.
>>> +This error may relate to data written by an earlier
>>> +.BR write (2),
>>> +which may have been issued to a different file descriptor on
>>> +the same file.  Since Linux 4.13 errors from write-back will
>>> +be reported to all file descriptors that might have
>>> +written the data which triggered the error, and which are still
>>> +open.
>>=20
>>=20
>> This is where things get a little more vague.
>>=20
>> Some filesystems will return errors on a subsequent write(2) when
>> previous writeback has failed -- some don't. In either case though,
>> write(2) should never advance your errseq_t cursor, so only an fsync
>> will "clear" an earlier error.
>>=20
>> I'm not sure how best to convey that in the manpages though.
>>=20
>>> +.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
>>>  .TP
>>>  .B ENOSPC
>>>  The device containing the file referred to by
>>> @@ -222,8 +230,14 @@ unsigned and signed integer data types specified b=
y POSIX.1.
>>>  A successful return from
>>>  .BR write ()
>>>  does not make any guarantee that data has been committed to disk.
>>> -In fact, on some buggy implementations, it does not even guarantee
>>> -that space has successfully been reserved for the data.
>>> +On some filesystems, including NFS, it does not even guarantee
>>> +that space has successfully been reserved for the data.  In the case,
>>> +some errors might be delayed to a future
>>> +.BR write (2)
>>> +or to
>>> +.BR fsync (2)
>>> +or even
>>> +.BR close (2).
>>>  The only way to be sure is to call
>>>  .BR fsync (2)
>>>  after you are done writing all your data.
>>=20
>
>
> --=20
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlm7jpMACgkQOeye3VZi
gbmyXw//RKV05izT8NNCu2rWh8gS5Al9axKtbQpguJwTddZleHCKM7E9hd7pGA4N
KZ2t2ISs1NQZcWT5uG0CnCliwf98RapVqaVujOEYa1K4EC5bTMYctI+6lypM4VGi
ftxiZDhAC1Ifuqyh1ezgVy7a4PHVUmNp7lv+KHKLrrQVFb0Jflxgd/KLk+OsjKLk
ZNoHKwDEhbQMKacT/Xzh93y7LP7H+0eFS4zlzycZh1eVcTJiV2NuXbqiKNX9Yd7E
jSv4ZXdzd8+dC8rVozEtBxX587gIUTrLL6Ucc5of0qIhR3TBEsY3Kbna0BqTzulD
SpBwjHIjR6a2613PNiI/HokJHF+DtL6pFhIQHeAYkXIp8OTRlX1oE0GNlAY7XTZ1
kq5mGO27es17nJHnY2WOSj4Z2526vwVzs//JxWIq19XOs6+NOeetyt7x5IwNoScE
//DPC7xdCXYKwlv5Mw9dsCnVtcHD8UMd7oz/ctIjnpj5EL8glNJSmoAyaSgmThnF
sb5tX6QsJjZlNEl3nbXw27OQ5mqMEWlo6628wnp4x1IYr9+vWSnQODUPZkChtu3T
SRmdyOtdNbxRMamZ7pO7YcoprJRqvS8n6mthrRrMnaTyw+laE8+KZQGKhs2LiVWI
o28wyg7bSJIClX7XQdIFyiSghtzHOx3ZnmVgTuXnmii06tprdBU=
=mnsP
-----END PGP SIGNATURE-----
--=-=-=--
