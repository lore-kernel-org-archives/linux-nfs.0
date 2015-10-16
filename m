Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34325 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbbJPVV2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 17:21:28 -0400
Received: by pabws5 with SMTP id ws5so508872pab.1
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2015 14:21:27 -0700 (PDT)
Subject: Re: [PATCH v6 5/4] copy_file_range.2: New page documenting copy_file_range()
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: multipart/signed; boundary="Apple-Mail=_F5E005D4-66F4-4ECF-AFBF-AC96871A8538"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <1445029707-31549-6-git-send-email-Anna.Schumaker@Netapp.com>
Date: Fri, 16 Oct 2015 15:21:18 -0600
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Message-Id: <EE48C3EC-07B2-4338-B2BF-F9B4B95A2F72@dilger.ca>
References: <1445029707-31549-1-git-send-email-Anna.Schumaker@Netapp.com> <1445029707-31549-6-git-send-email-Anna.Schumaker@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_F5E005D4-66F4-4ECF-AFBF-AC96871A8538
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Oct 16, 2015, at 3:08 PM, Anna Schumaker =
<Anna.Schumaker@netapp.com> wrote:
>=20
> copy_file_range() is a new system call for copying ranges of data
> completely in the kernel.  This gives filesystems an opportunity to
> implement some kind of "copy acceleration", such as reflinks or
> server-side-copy (in the case of NFS).
>=20
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
> v6:
> - Updates for removing most flags
> ---
> man2/copy_file_range.2 | 204 =
+++++++++++++++++++++++++++++++++++++++++++++++++
> man2/splice.2          |   1 +
> 2 files changed, 205 insertions(+)
> create mode 100644 man2/copy_file_range.2
>=20
> diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
> new file mode 100644
> index 0000000..6c52c85
> --- /dev/null
> +++ b/man2/copy_file_range.2
> @@ -0,0 +1,204 @@
> +.\"This manpage is Copyright (C) 2015 Anna Schumaker =
<Anna.Schumaker@Netapp.com>
> +.\"
> +.\" %%%LICENSE_START(VERBATIM)
> +.\" Permission is granted to make and distribute verbatim copies of =
this
> +.\" manual provided the copyright notice and this permission notice =
are
> +.\" preserved on all copies.
> +.\"
> +.\" Permission is granted to copy and distribute modified versions of
> +.\" this manual under the conditions for verbatim copying, provided =
that
> +.\" the entire resulting derived work is distributed under the terms =
of
> +.\" a permission notice identical to this one.
> +.\"
> +.\" Since the Linux kernel and libraries are constantly changing, =
this
> +.\" manual page may be incorrect or out-of-date.  The author(s) =
assume.
> +.\" no responsibility for errors or omissions, or for damages =
resulting.
> +.\" from the use of the information contained herein.  The author(s) =
may.
> +.\" not have taken the same level of care in the production of this.
> +.\" manual, which is licensed free of charge, as they might when =
working.

Is there a reason why every. one. of. those. lines. ends. in. a. period?
I don't think that is needed for nroff, and other paragraphs would =
support
that conclusion.

> +.\" professionally.
> +.\"
> +.\" Formatted or processed versions of this manual, if unaccompanied =
by
> +.\" the source, must acknowledge the copyright and authors of this =
work.
> +.\" %%%LICENSE_END
> +.\"
> +.TH COPY 2 2015-10-16 "Linux" "Linux Programmer's Manual"
> +.SH NAME
> +copy_file_range \- Copy a range of data from one file to another
> +.SH SYNOPSIS
> +.nf
> +.B #include <linux/fs.h>
> +.B #include <sys/syscall.h>
> +.B #include <unistd.h>
> +
> +.BI "ssize_t copy_file_range(int " fd_in ", loff_t *" off_in ", int " =
fd_out ",
> +.BI "                        loff_t *" off_out ", size_t " len \
> +", unsigned int " flags );
> +.fi
> +.SH DESCRIPTION
> +The
> +.BR copy_file_range ()
> +system call performs an in-kernel copy between two file descriptors
> +without the additional cost of transferring data from the kernel to =
userspace
> +and then back into the kernel.
> +It copies up to
> +.I len
> +bytes of data from file descriptor
> +.I fd_in
> +to file descriptor
> +.IR fd_out ,
> +overwriting any data that exists within the requested range of the =
target file.
> +
> +The following semantics apply for
> +.IR off_in ,
> +and similar statements apply to
> +.IR off_out :
> +.IP * 3
> +If
> +.I off_in
> +is NULL, then bytes are read from
> +.I fd_in
> +starting from the current file offset, and the offset is
> +adjusted by the number of bytes copied.
> +.IP *
> +If
> +.I off_in
> +is not NULL, then
> +.I off_in
> +must point to a buffer that specifies the starting
> +offset where bytes from
> +.I fd_in
> +will be read.  The current file offset of
> +.I fd_in
> +is not changed, but
> +.I off_in
> +is adjusted appropriately.
> +.PP
> +
> +The
> +.I flags
> +argument can have the following flag set:
> +.TP 1.9i
> +.B COPY_FR_REFLINK
> +Create a lightweight "reflink", where data is not copied until
> +one of the files is modified.

This is a circular definition.  Something like:

     Create a lightweight reference to the data blocks in the original
     file, where data is not copied until one of the files is modified.

although I'm not sure if "lightweight" is really valuable there.

> +.PP
> +The default behavior
> +.RI ( flags
> +=3D=3D 0) is to perform a full data copy of the requested range.
> +.SH RETURN VALUE
> +Upon successful completion,
> +.BR copy_file_range ()
> +will return the number of bytes copied between files.
> +This could be less than the length originally requested.

This is a bit vague.  When COPY_FR_REFLINK is used, no data is "copied",
per se, but I doubt that "0" would be returned in that case either.  It
probably makes sense to write something like:

   ... return the number of bytes accessible in the target file.

or maybe (s/accessible/transferred/) or

   ... return the number of bytes added to the target file.

or similar.

> +
> +On error,
> +.BR copy_file_range ()
> +returns \-1 and
> +.I errno
> +is set to indicate the error.
> +.SH ERRORS
> +.TP
> +.B EBADF
> +One or more file descriptors are not valid; or
> +.I fd_in
> +is not open for reading; or
> +.I fd_out
> +is not open for writing.
> +.TP
> +.B EINVAL
> +Requested range extends beyond the end of the source file; or the
> +.I flags
> +argument is set to an invalid value.

Is it possible to return EINTR as well?

Cheers, Andreas

> +.TP
> +.B EIO
> +A low level I/O error occurred while copying.
> +.TP
> +.B ENOMEM
> +Out of memory.
> +.TP
> +.B ENOSPC
> +There is not enough space on the target filesystem to complete the =
copy.
> +.TP
> +.B EOPNOTSUPP
> +.B COPY_REFLINK
> +was specified in
> +.IR flags ,
> +but the target filesystem does not support reflinks.
> +.TP
> +.B EXDEV
> +.IR file_in " and " file_out
> +are not on the same mounted filesystem.
> +.SH VERSIONS
> +The
> +.BR copy_file_range ()
> +system call first appeared in Linux 4.4.
> +.SH CONFORMING TO
> +The
> +.BR copy_file_range ()
> +system call is a nonstandard Linux extension.
> +.SH EXAMPLE
> +.nf
> +#define _GNU_SOURCE
> +#include <fcntl.h>
> +#include <linux/fs.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <sys/stat.h>
> +#include <sys/syscall.h>
> +#include <unistd.h>
> +
> +loff_t copy_file_range(int fd_in, loff_t *off_in, int fd_out,
> +                       loff_t *off_out, size_t len, unsigned int =
flags)
> +{
> +    return syscall(__NR_copy_file_range, fd_in, off_in, fd_out,
> +                   off_out, len, flags);
> +}
> +
> +int main(int argc, char **argv)
> +{
> +    int fd_in, fd_out;
> +    struct stat stat;
> +    loff_t len, ret;
> +    char buf[2];
> +
> +    if (argc !=3D 3) {
> +        fprintf(stderr, "Usage: %s <source> <destination>\\n", =
argv[0]);
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    fd_in =3D open(argv[1], O_RDONLY);
> +    if (fd_in =3D=3D \-1) {
> +        perror("open (argv[1])");
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    if (fstat(fd_in, &stat) =3D=3D \-1) {
> +        perror("fstat");
> +        exit(EXIT_FAILURE);
> +    }
> +    len =3D stat.st_size;
> +
> +    fd_out =3D open(argv[2], O_CREAT|O_WRONLY|O_TRUNC, 0644);
> +    if (fd_out =3D=3D \-1) {
> +        perror("open (argv[2])");
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    do {
> +        ret =3D copy_file_range(fd_in, NULL, fd_out, NULL, len, 0);
> +        if (ret =3D=3D \-1) {
> +            perror("copy_file_range");
> +            exit(EXIT_FAILURE);
> +        }
> +
> +        len \-=3D ret;
> +    } while (len > 0);
> +
> +    close(fd_in);
> +    close(fd_out);
> +    exit(EXIT_SUCCESS);
> +}
> +.fi
> +.SH SEE ALSO
> +.BR splice (2)
> diff --git a/man2/splice.2 b/man2/splice.2
> index b9b4f42..5c162e0 100644
> --- a/man2/splice.2
> +++ b/man2/splice.2
> @@ -238,6 +238,7 @@ only pointers are copied, not the pages of the =
buffer.
> See
> .BR tee (2).
> .SH SEE ALSO
> +.BR copy_file_range (2),
> .BR sendfile (2),
> .BR tee (2),
> .BR vmsplice (2)
> --
> 2.6.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe =
linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_F5E005D4-66F4-4ECF-AFBF-AC96871A8538
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBViFqUHKl2rkXzB/gAQgmzA/+MMlxvc7YRzh1GE6xMjCuBGJMmZHpZoRx
x+lNZdKjFo1+GKWdaJO3rsQsc9INOAti8MW6+RCQwy2m7s4r58Wfps1UmM8kJaVV
uyW3FhxkmDX6/T5WAIuRLNYYgrWreDE5dAE/RWTRMToSiQ1+wlyoBPXX9WaRNpN/
bFdZEDdlk5mjH9XZUKzvBNfV4sC/S5ZyLAiTAztFUH1kaeoDt92SfmO2diawyUXX
QinSCubFCUQsMs0gfXB4el4gSeLPM3NKAG8INNW4XMFABF11K1b+tM4W+8GkY1FW
u3kiqLuyOm5+rJIAo0BUHxSUI0zXroFkANwXt8BSU2AZZPfHJJJbnfewcC/4npRK
NOPsU9DlGuuYHOLNXtA9EkWym7PT4R075qjzdwcPPPZzoz6itzGEUaYJsI+gPchd
XRn0BA3oI4Qaw+iYnDvb8uJGwGV5cTZQhOoE80tnZX8k5mOiauglWqgigVitFVLr
KgHlUubJw/QMDKFzgad8nROxBJ3k480fTHK0BKT0xNOwXUOTYBrX/ghuSnx4y3Tg
vfsU0rLSzT6iu9RqdwzG9RU+pEpK9TGdU9rxgpvU5guVr9nVtxPd+6bpeZKTSKKg
hkuTHblKqIu5AgZuJ1zWCr4IDJKeHDV2yxh1o3uBuBJNpyC/IjoMDbyLFVmNWGQo
fhr4MJP9iGo=
=CPrd
-----END PGP SIGNATURE-----

--Apple-Mail=_F5E005D4-66F4-4ECF-AFBF-AC96871A8538--
