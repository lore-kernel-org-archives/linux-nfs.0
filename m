Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36626 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbbIILiX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Sep 2015 07:38:23 -0400
Subject: Re: [PATCH v1 9/8] copy_file_range.2: New page documenting
 copy_file_range()
To: "Darrick J. Wong" <darrick.wong@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1441397823-1203-10-git-send-email-Anna.Schumaker@Netapp.com>
 <20150904213856.GC10391@birch.djwong.org> <55EEF8E3.8030501@Netapp.com>
 <20150908203918.GB30681@birch.djwong.org>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        mtk.manpages@gmail.com, andros@netapp.com, hch@infradead.org
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <55F01A26.7070706@gmail.com>
Date: Wed, 9 Sep 2015 07:38:14 -0400
MIME-Version: 1.0
In-Reply-To: <20150908203918.GB30681@birch.djwong.org>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms050706050703090108040500"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms050706050703090108040500
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-09-08 16:39, Darrick J. Wong wrote:
> On Tue, Sep 08, 2015 at 11:04:03AM -0400, Anna Schumaker wrote:
>> On 09/04/2015 05:38 PM, Darrick J. Wong wrote:
>>> On Fri, Sep 04, 2015 at 04:17:03PM -0400, Anna Schumaker wrote:
>>>> copy_file_range() is a new system call for copying ranges of data
>>>> completely in the kernel.  This gives filesystems an opportunity to
>>>> implement some kind of "copy acceleration", such as reflinks or
>>>> server-side-copy (in the case of NFS).
>>>>
>>>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>>> ---
>>>>   man2/copy_file_range.2 | 168 +++++++++++++++++++++++++++++++++++++=
++++++++++++
>>>>   1 file changed, 168 insertions(+)
>>>>   create mode 100644 man2/copy_file_range.2
>>>>
>>>> diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
>>>> new file mode 100644
>>>> index 0000000..4a4cb73
>>>> --- /dev/null
>>>> +++ b/man2/copy_file_range.2
>>>> @@ -0,0 +1,168 @@
>>>> +.\"This manpage is Copyright (C) 2015 Anna Schumaker <Anna.Schumake=
r@Netapp.com>
>>>> +.TH COPY 2 2015-8-31 "Linux" "Linux Programmer's Manual"
>>>> +.SH NAME
>>>> +copy_file_range \- Copy a range of data from one file to another
>>>> +.SH SYNOPSIS
>>>> +.nf
>>>> +.B #include <linux/copy.h>
>>>> +.B #include <sys/syscall.h>
>>>> +.B #include <unistd.h>
>>>> +
>>>> +.BI "ssize_t syscall(__NR_copy_file_range, int " fd_in ", loff_t * =
" off_in ",
>>>> +.BI "                int " fd_out ", loff_t * " off_out ", size_t "=
 len ",
>>>> +.BI "                unsigned int " flags );
>>>> +.fi
>>>> +.SH DESCRIPTION
>>>> +The
>>>> +.BR copy_file_range ()
>>>> +system call performs an in-kernel copy between two file descriptors=

>>>> +without all that tedious mucking about in userspace.
>>>
>>> ;)
>>>
>>>> +It copies up to
>>>> +.I len
>>>> +bytes of data from file descriptor
>>>> +.I fd_in
>>>> +to file descriptor
>>>> +.I fd_out
>>>> +at
>>>> +.IR off_out .
>>>> +The file descriptors must not refer to the same file.
>>>
>>> Why?  btrfs (and XFS) reflink can handle the case of a file sharing b=
locks
>>> with itself.
>>
>> I've never really thought about it... Zach had that in his initial
>> submission, so mentioned it in the man page.  Should I remove that bit=
?
>
> Yes, please!
>
> I could be wrong, but I think btrfs only started supporting files that =
share
> blocks with themselves relatively recently(?)
>
> I'm not sure why zab added this; was hoping he'd speak up. ;)
>
>>
>>>
>>>> +
>>>> +The following semantics apply for
>>>> +.IR fd_in ,
>>>> +and similar statements apply to
>>>> +.IR off_out :
>>>> +.IP * 3
>>>> +If
>>>> +.I off_in
>>>> +is NULL, then bytes are read from
>>>> +.I fd_in
>>>> +starting from the current file offset and the current
>>>> +file offset is adjusted appropriately.
>>>> +.IP *
>>>> +If
>>>> +.I off_in
>>>> +is not NULL, then
>>>> +.I off_in
>>>> +must point to a buffer that specifies the starting
>>>> +offset where bytes from
>>>> +.I fd_in
>>>> +will be read.  The current file offset of
>>>> +.I fd_in
>>>> +is not changed, but
>>>> +.I off_in
>>>> +is adjusted appropriately.
>>>> +.PP
>>>> +The default behavior of
>>>> +.BR copy_file_range ()
>>>> +is filesystem specific, and might result in creating a
>>>> +copy-on-write reflink.
>>>> +In the event that a given filesystem does not implement
>>>> +any form of copy acceleration, the kernel will perform
>>>> +a deep copy of the requested range by reading bytes from
>>>
>>> I wonder if it's wise to allow deep copies -- what happens if len =3D=
=3D 1T?
>>> Will this syscall just block for a really long time?
>>
>> We use rw_verify_area(), (similar to read and write) so we won't allow=
 a
>> value of len that long.  I can mention this in an updated version of t=
his man
>> page!
>
> Ok.  I guess MAX_RW_COUNT limits us to about 4G at once, which for a sp=
lice
> copy is probably reasonable.
>
> The reason why I asked about len =3D=3D 1T specifically is that I can (=
with
> somewhat long delays) reflink about 260 million extents at a time on XF=
S,
> which is about 1TB.  Given that locks get held for the duration, it's p=
robably
> not a bad thing to limit userspace to 4G at a time.
I'd personally love to see that be tunable by a sysctl (kind of like how =

you can control the maximum number of AIO requests in flight), and for=20
that matter we might want to be able to limit the number of in-progress=20
copies going on.
>
> (But hey, it's fun to stress-test once in a while. :))
>
> --D
>
>>
>>
>>>
>>>> +.I fd_in
>>>> +and writing them to
>>>> +.IR fd_out .
>>>
>>> "...if COPY_REFLINK is not set in flags."
>>
>> Sure.
>>
>>>
>>>> +
>>>> +Currently, Linux only supports the following flag:
>>>> +.TP 1.9i
>>>> +.B COPY_REFLINK
>>>> +Only perform the copy if the filesystem can do it as a reflink.
>>>> +Do not fall back on performing a deep copy.
>>>> +.SH RETURN VALUE
>>>> +Upon successful completion,
>>>> +.BR copy_file_range ()
>>>> +will return the number of bytes copied between files.
>>>> +This could be less than the length originally requested.
>>>> +
>>>> +On error,
>>>> +.BR copy_file_range ()
>>>> +returns \-1 and
>>>> +.I errno
>>>> +is set to indicate the error.
>>>> +.SH ERRORS
>>>> +.TP
>>>> +.B EBADF
>>>> +One or more file descriptors are not valid,
>>>> +or do not have proper read-write mode.
>>>
>>> "or fd_out is not opened for writing"?
>>
>> I'll add that.
>>
>>>
>>>> +.TP
>>>> +.B EINVAL
>>>> +Requested range extends beyond the end of the file;
>>>> +.I flags
>>>> +argument is set to an invalid value.
>>>> +.TP
>>>> +.B EOPNOTSUPP
>>>> +.B COPY_REFLINK
>>>> +was specified in
>>>> +.IR flags ,
>>>> +but the target filesystem does not support reflinks.
>>>> +.TP
>>>> +.B EXDEV
>>>> +Target filesystem doesn't support cross-filesystem copies.
>>>> +.SH VERSIONS
>>>
>>> Perhaps this ought to list a few more errors (EIO, ENOSPC, ENOSYS, EP=
ERM...)
>>> that can be returned?  (I was looking at the fallocate manpage.)
>>
>> Okay.  I'll poke around for what else could be returned!
>>
>> Thanks,
>> Anna
>>
>>>
>>> --D
>>>
>>>> +The
>>>> +.BR copy_file_range ()
>>>> +system call first appeared in Linux 4.3.
>>>> +.SH CONFORMING TO
>>>> +The
>>>> +.BR copy_file_range ()
>>>> +system call is a nonstandard Linux extension.
>>>> +.SH EXAMPLE
>>>> +.nf
>>>> +
>>>> +#define _GNU_SOURCE
>>>> +#include <fcntl.h>
>>>> +#include <linux/copy.h>
>>>> +#include <stdio.h>
>>>> +#include <stdlib.h>
>>>> +#include <sys/stat.h>
>>>> +#include <sys/syscall.h>
>>>> +#include <unistd.h>
>>>> +
>>>> +
>>>> +int main(int argc, char **argv)
>>>> +{
>>>> +    int fd_in, fd_out;
>>>> +    struct stat stat;
>>>> +    loff_t len, ret;
>>>> +
>>>> +    if (argc !=3D 3) {
>>>> +        fprintf(stderr, "Usage: %s <pathname> <pathname>\n", argv[0=
]);
>>>> +        exit(EXIT_FAILURE);
>>>> +    }
>>>> +
>>>> +    fd_in =3D open(argv[1], O_RDONLY);
>>>> +    if (fd_in =3D=3D -1) {
>>>> +        perror("open (argv[1])");
>>>> +        exit(EXIT_FAILURE);
>>>> +    }
>>>> +
>>>> +    if (fstat(fd_in, &stat) =3D=3D -1) {
>>>> +        perror("fstat");
>>>> +        exit(EXIT_FAILURE);
>>>> +    }
>>>> +    len =3D stat.st_size;
>>>> +
>>>> +    fd_out =3D open(argv[2], O_WRONLY | O_CREAT, 0644);
>>>> +    if (fd_out =3D=3D -1) {
>>>> +        perror("open (argv[2])");
>>>> +        exit(EXIT_FAILURE);
>>>> +    }
>>>> +
>>>> +    do {
>>>> +        ret =3D syscall(__NR_copy_file_range, fd_in, NULL,
>>>> +                      fd_out, NULL, len, 0);
>>>> +        if (ret =3D=3D -1) {
>>>> +            perror("copy_file_range");
>>>> +            exit(EXIT_FAILURE);
>>>> +        }
>>>> +
>>>> +        len -=3D ret;
>>>> +    } while (len > 0);
>>>> +
>>>> +    close(fd_in);
>>>> +    close(fd_out);
>>>> +    exit(EXIT_SUCCESS);
>>>> +}
>>>> +.fi
>>>> +.SH SEE ALSO
>>>> +.BR splice (2)
>>>> --
>>>> 2.5.1
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-fsde=
vel" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-btrfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



--------------ms050706050703090108040500
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxBuVTANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwOTA5MTEzODE0WjBPBgkq
hkiG9w0BCQQxQgRA2VxJBDYFnwtFmHhQBYPliAuqtPfNDOso+lg0+vkBZrWL8XJJDH9yuwfY
JqNZXmzNo9jYLvC8CEqMo2OtvQkeJTBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxBuVTCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxBuVTAN
BgkqhkiG9w0BAQEFAASCAgCKD3bxoyHsI4+g8xyjHJJ1feR5RFRRY6OK1qRnxPKSWZyhIOEB
LVCGRaMP6OPRzQL57WqwIQoj5SQac3Is/S1LafTlbzqa7o9pyyBMruSXMsmqxoE/+LojocRF
/+qG4Gwa6G8IZO9wz0EFil3Raf272ZLeTOnj6BhJn0BuYSG4B50bEzzEcDVx3EvCcHNIicTs
r2SNLdSrd8bOzOcciQllUwKUp3aKTpeyvRpssMFe78gBXIeGsM78JOemga0RWlDKuJJySf1D
1wlcfIRa5MAiERIgBsE9E3773XEQemT9w5G9Auw3l1w1AQ+RlltFxdcbTFZgSHRQsx0o6HE4
JjBdxBq59gR9tk/3voSqckeQf0dUWCKQNaH60GMt/cJolDA5ylTO7rzoDK3tlb8FiSZ308te
3rUCj+70LLivycuF4XhDqvU+0b+vsfEf+c0e/z6pO27GZHCWO+zUh9cP2jHdbglZs1FpLLJx
yBhNa6hcvnI9CMihJeysvov9Xb7WMRz/ni8B4DuF+4DdPrTJMfHse8Z0D8zLz9fJYp1vGuub
KAboC2lR01qrfBiloWkCQXjmNghNN1VHvJHHsWHCFrN04s+tdIYc3FlEP34+GdzfyFijIMca
WVJByD3bOumM5rQE3IGW6aNoTA+YjdPbhiUcDwp6nkskpr+xRgNgpskjggAAAAAAAA==
--------------ms050706050703090108040500--
