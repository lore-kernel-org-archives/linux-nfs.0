Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33840 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555AbbINTCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 15:02:49 -0400
Subject: Re: [PATCH v2 10/9] copy_file_range.2: New page documenting
 copy_file_range()
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, andros@netapp.com,
        hch@infradead.org
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1442003423-6884-11-git-send-email-Anna.Schumaker@Netapp.com>
 <55F52ABA.9070908@gmail.com>
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Message-ID: <55F719D4.4080106@gmail.com>
Date: Mon, 14 Sep 2015 15:02:44 -0400
MIME-Version: 1.0
In-Reply-To: <55F52ABA.9070908@gmail.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-512; boundary="------------ms030600010405080805090601"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cryptographically signed message in MIME format.

--------------ms030600010405080805090601
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-09-13 03:50, Michael Kerrisk (man-pages) wrote:
> Hi Anna,
>
> On 09/11/2015 10:30 PM, Anna Schumaker wrote:
>> copy_file_range() is a new system call for copying ranges of data
>> completely in the kernel.  This gives filesystems an opportunity to
>> implement some kind of "copy acceleration", such as reflinks or
>> server-side-copy (in the case of NFS).
>>
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>
> Thanks for writing such a nice first draft man page! I have a few
> comments below. Would you be willing to revise and resubmit?
>
>> ---
>>   man2/copy_file_range.2 | 188 +++++++++++++++++++++++++++++++++++++++=
++++++++++
>>   1 file changed, 188 insertions(+)
>>   create mode 100644 man2/copy_file_range.2
>>
>> diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
>> new file mode 100644
>> index 0000000..84912b5
>> --- /dev/null
>> +++ b/man2/copy_file_range.2
>> @@ -0,0 +1,188 @@
>> +.\"This manpage is Copyright (C) 2015 Anna Schumaker <Anna.Schumaker@=
Netapp.com>
>
> We need a license for this page. Please see
> https://www.kernel.org/doc/man-pages/licenses.html
>
>> +.TH COPY 2 2015-8-31 "Linux" "Linux Programmer's Manual"
>
> Make the month 2 digits (leading 0).
>
>> +.SH NAME
>> +copy_file_range \- Copy a range of data from one file to another
>> +.SH SYNOPSIS
>> +.nf
>> +.B #include <linux/copy.h>
>> +.B #include <sys/syscall.h>
>> +.B #include <unistd.h>
>> +
>> +.BI "ssize_t syscall(__NR_copy_file_range, int " fd_in ", loff_t * " =
off_in ",
>> +.BI "                int " fd_out ", loff_t * " off_out ", size_t " l=
en ",
>> +.BI "                unsigned int " flags );
>
> Remove spaces following "*" in the lines above. (man-pages convention f=
or code)
>
> I know that the copy_file_range() (obviously) doesn't yet have a wrappe=
r
> in glibc, but in the man pages we document all system calls as though t=
here
> is a wrapper. See, for example, gettid(2), for an axample of how this i=
s done
> (a note in the SYNOPSIS and then some further details in NOTES).
>
>> +.fi
>> +.SH DESCRIPTION
>> +The
>> +.BR copy_file_range ()
>> +system call performs an in-kernel copy between two file descriptors
>> +without all that tedious mucking about in userspace.
>
> I'd write that last piece as:
>
> "without the cost of (a loop) transferring data from the kernel to a
> user-space buffer and then back to the kernel again.
>
Seconded, this will likely sound odd to someone who has only ever heard=20
American English, and while I hate to propagate stereotypes, there might =

be some less than intelligent speakers of American English who this=20
could confuse.  That, and it's better to be clear about what 'tedious=20
mucking about in userspace' it's avoiding.
>> +It copies up to
>> +.I len
>> +bytes of data from file descriptor
>> +.I fd_in
>> +to file descriptor
>> +.IR fd_out ,
>> +overwriting any data that exists within the requested range.
>
> s/.$/ of the target file./
>
>> +
>> +The following semantics apply for
>> +.IR off_in ,
>> +and similar statements apply to
>> +.IR off_out :
>> +.IP * 3
>> +If
>> +.I off_in
>> +is NULL, then bytes are read from
>> +.I fd_in
>> +starting from the current file offset and the current
>> +file offset is adjusted appropriately.
>> +.IP *
>> +If
>> +.I off_in
>> +is not NULL, then
>> +.I off_in
>> +must point to a buffer that specifies the starting
>> +offset where bytes from
>> +.I fd_in
>> +will be read.  The current file offset of
>> +.I fd_in
>> +is not changed, but
>> +.I off_in
>> +is adjusted appropriately.
>> +.PP
>> +
>> +The
>> +.I flags
>> +argument is a bit mask composed by OR-ing together zero
>> +or more of the following flags:
>> +.TP 1.9i
>> +.B COPY_FR_COPY
>> +Copy all the file data in the requested range.
>> +Some filesystems, like NFS, might be able to accelerate this copy
>> +to avoid unnecessary data transfers.
>> +.TP
>> +.B COPY_FR_REFLINK
>> +Create a lightweight "reflink", where data is not copied until
>> +one of the files is modified.
>> +.PP
>> +The default behavior
>> +.RI ( flags
>> +=3D=3D 0) is to try creating a reflink,
>> +and if reflinking fails
>> +.BR copy_file_range ()
>> +will fall back on performing a full data copy.
>
> s/back on/back to/
>
>> +This is equivalent to setting
>> +.I flags
>> +equal to
>> +.RB ( COPY_FR_COPY | COPY_FR_REFLINK ).
>
> So, from an API deign perspective, the interoperation of these two
> flags appears odd. Bit flags are commonly (not always) orthogonal.
> I think here it could be pointed out a little more explicitly that
> these two flags are not orthogonal. In particular, perhaps after the
> last sentence, you could add another sentence:
>
> [[
> (This contrasts with specifying
> .I flags
> as just
> .BR COPY_FR_REFLINK ,
> which causes the call to create a reflink,
> and fail if that is not possible,
> rather than falling back to a full data copy.)
> ]]
>
> Furthermore, I even wonder if explicitly specifying flags as
> COPY_FR_COPY | COPY_FR_REFLINK should just generate an EINVAL
> error. 0 already gives us the behavior described above,
> and allowing the combination COPY_FR_COPY | COPY_FR_REFLINK
> perhaps just contributes to misleading the user that these
> flags are orthogonal, when in reality they are not. What do
> you think?
>
> What are the semantics with respect to signals, especially if data
> copying a very large file range? This info should be included in the
> man page, probably under NOTES.
>
>> +.SH RETURN VALUE
>> +Upon successful completion,
>> +.BR copy_file_range ()
>> +will return the number of bytes copied between files.
>> +This could be less than the length originally requested.
>> +
>> +On error,
>> +.BR copy_file_range ()
>> +returns \-1 and
>> +.I errno
>> +is set to indicate the error.
>> +.SH ERRORS
>> +.TP
>> +.B EBADF
>> +One or more file descriptors are not valid,
>> +or do not have proper read-write mode;
>
> I think that last line can go. I mean, isn't this point (again)
> covered in the next few lines?
>
>> +.I fd_in
>> +is not open for reading; or
>> +.I fd_out
>> +is not open for writing.
>> +.TP
>> +.B EINVAL
>> +Requested range extends beyond the end of the file; or the
>
> s/file/source file/  (right?)
>
>> +.I flags
>> +argument is set to an invalid value.
>> +.TP
>> +.B EIO
>> +A low level I/O error occurred while copying.
>> +.TP
>> +.B ENOMEM
>> +Out of memory.
>> +.TP
>> +.B ENOSPC
>> +There is not enough space to complete the copy.
>
> Space where? On the filesystem?
> =3D> s/space/space on the target filesystem/
>
>> +.TP
>> +.B EOPNOTSUPP
>> +.B COPY_REFLINK
>> +was specified in
>> +.IR flags ,
>> +but the target filesystem does not support reflinks.
>> +.TP
>> +.B EXDEV
>> +Target filesystem doesn't support cross-filesystem copies.
>
> I'm curious. What are some examples of filesystems that produce this
> error?
>
>> +.SH VERSIONS
>> +The
>> +.BR copy_file_range ()
>> +system call first appeared in Linux 4.4.
>> +.SH CONFORMING TO
>> +The
>> +.BR copy_file_range ()
>> +system call is a nonstandard Linux extension.
>> +.SH EXAMPLE
>> +.nf
>> +
>> +#define _GNU_SOURCE
>> +#include <fcntl.h>
>> +#include <linux/copy.h>
>> +#include <stdio.h>
>> +#include <stdlib.h>
>> +#include <sys/stat.h>
>> +#include <sys/syscall.h>
>> +#include <unistd.h>
>> +
>> +
>> +int main(int argc, char **argv)
>> +{
>> +    int fd_in, fd_out;
>> +    struct stat stat;
>> +    loff_t len, ret;
>> +
>> +    if (argc !=3D 3) {
>> +        fprintf(stderr, "Usage: %s <source> <destination>\\n", argv[0=
]);
>> +        exit(EXIT_FAILURE);
>> +    }
>> +
>> +    fd_in =3D open(argv[1], O_RDONLY);
>> +    if (fd_in =3D=3D -1) {
>
> Please replace all "-" in code by "\-". (This is a groff
> detail.)
>
>> +        perror("open (argv[1])");
>> +        exit(EXIT_FAILURE);
>> +    }
>> +
>> +    if (fstat(fd_in, &stat) =3D=3D -1) {
>> +        perror("fstat");
>> +        exit(EXIT_FAILURE);
>> +    }
>> +    len =3D stat.st_size;
>> +
>> +    fd_out =3D creat(argv[2], 0644);
>
> These days, I think we should discourage the use of creat(). Maybe
> better to use open() instead here?
>
>> +    if (fd_out =3D=3D -1) {
>> +        perror("creat (argv[2])");
>> +        exit(EXIT_FAILURE);
>> +    }
>> +
>> +    do {
>> +        ret =3D syscall(__NR_copy_file_range, fd_in, NULL,
>> +                      fd_out, NULL, len, 0);
>
> I'd rather see this as:
>
> int
> copy_file_range(int fd_in, loff_t *off_in,
>                  int fd_out, loff_t *off_out, size_t len,
>                  unsigned int flags)
> {
>      return(syscall(__NR_copy_file_range, fd_in, fd_out, off_out, len, =
flags);
> }
>
> ...
>
>      copy_file_range(fd_in, fd_out, off_out, len, flags);
>
>
>> +        if (ret =3D=3D -1) {
>> +            perror("copy_file_range");
>> +            exit(EXIT_FAILURE);
>> +        }
>> +
>> +        len -=3D ret;
>> +    } while (len > 0);
>> +
>> +    close(fd_in);
>> +    close(fd_out);
>> +    exit(EXIT_SUCCESS);
>> +}
>> +.fi
>> +.SH SEE ALSO
>> +.BR splice (2)
>>
>
> In the next iteration of this patch, could you include a change to
> splice(2) so that copy_file_range(2) is added under SEE ALSO in
> that page. Also, are there any other pages that we should like
> to/from? (sendfile(2)?)
>
> Thanks,
>
> Michael
>
>



--------------ms030600010405080805090601
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

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
cnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcN
AQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxBuVTANBglghkgBZQMEAgMFAKCCAiEwGAYJKoZI
hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTUwOTE0MTkwMjQ0WjBPBgkq
hkiG9w0BCQQxQgRA9h7KmurX7SGYzyuyDgWDoCNSeNH4pTJh6Z6x5TziDWN3GJrA4ykVDxh5
QiSNu131F17rHhisRAawO6n2lCPpwjBsBgkqhkiG9w0BCQ8xXzBdMAsGCWCGSAFlAwQBKjAL
BglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFA
MAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMIGRBgkrBgEEAYI3EAQxgYMwgYAweTEQMA4GA1UE
ChMHUm9vdCBDQTEeMBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlD
QSBDZXJ0IFNpZ25pbmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2Vy
dC5vcmcCAxBuVTCBkwYLKoZIhvcNAQkQAgsxgYOggYAweTEQMA4GA1UEChMHUm9vdCBDQTEe
MBwGA1UECxMVaHR0cDovL3d3dy5jYWNlcnQub3JnMSIwIAYDVQQDExlDQSBDZXJ0IFNpZ25p
bmcgQXV0aG9yaXR5MSEwHwYJKoZIhvcNAQkBFhJzdXBwb3J0QGNhY2VydC5vcmcCAxBuVTAN
BgkqhkiG9w0BAQEFAASCAgCK2Tt92Em9iWHcv1HOgTZ+FPzU8hg7Lzopt8fVoViamwRIMYUw
f27hhxYb6y/dEB6sK8h8rToIQuDl5rPxARlpiv+ykRR4DkZwUX1sESVAsgjkm8CgW/Ej4SFG
VW4VI2jfywelkEayEwSxI8Swd34h8C9F0CJFgp0QM1D62Q5NkYXa4fUQxygcr40lmpPt0Fuk
vCIwCdqpOmTmmjCAZCrqciZIJUFnEZ6RrXTv3wd1ePDwYXlnH0EKoNXyTnGY2yGIeHhTYABS
aRd6HnePOxSdqpGJjO1IXdhQFL9fO5qptazPffpHUKSbnm2BDy77DvKuzVgShWRzLtDPwCY7
X2FKNk3J3Cod2fqhMZ+USSLxdPke6H6WecSER1Mc/DYfoiXG4Kmw0usb+KebnViu5quCRZBq
ElGwDSJTuCrPpJWGEE45TcNT6Qesy5yU9owdgEEfbrXROMiofDE/idT14lGKC4zl6tDzGYqf
QrXZsMmg/KD1dVi0krnkj5Ffnb0w1zz57fdpEZ/tDZBXiPi8mGf+gjCUROEfHONcUJc6DjuO
N8gunhD1GV1PpP8bEkVRnfkGHrVuBheLTm/oweEiaysNcNOm1I2pMpA+zWvp5o2M12xXoocg
Q1z6rcjaPwxMd3hRGBEW/JpvzhPc8xSjZbxI+Cw5isN8tv2EVbihtNJrowAAAAAAAA==
--------------ms030600010405080805090601--
