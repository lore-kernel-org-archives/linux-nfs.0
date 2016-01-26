Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33134 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964884AbcAZJuF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2016 04:50:05 -0500
Subject: Re: [PATCH v8 5/4] copy_file_range.2: New page documenting
 copy_file_range()
To: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, andros@netapp.com,
        hch@infradead.org
References: <1446844701-848-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1446844701-848-6-git-send-email-Anna.Schumaker@Netapp.com>
Cc: mtk.manpages@gmail.com
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <56A74147.8060807@gmail.com>
Date: Tue, 26 Jan 2016 10:49:59 +0100
MIME-Version: 1.0
In-Reply-To: <1446844701-848-6-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

Thanks for writing this page! I've merged it, and pushed to Git.
I made a few tweaks, which I think are all straightforward, 
but you might like to review my comments below.

On 11/06/2015 10:18 PM, Anna Schumaker wrote:
> copy_file_range() is a new system call for copying ranges of data
> completely in the kernel.  This gives filesystems an opportunity to
> implement some kind of "copy acceleration", such as reflinks or
> server-side-copy (in the case of NFS).
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
> v8:
> - Document that files can not be open with O_APPEND.
> ---
>  man2/copy_file_range.2 | 201 +++++++++++++++++++++++++++++++++++++++++++++++++
>  man2/splice.2          |   1 +
>  2 files changed, 202 insertions(+)
>  create mode 100644 man2/copy_file_range.2
> 
> diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
> new file mode 100644
> index 0000000..d9f76d1
> --- /dev/null
> +++ b/man2/copy_file_range.2
> @@ -0,0 +1,201 @@
> +.\"This manpage is Copyright (C) 2015 Anna Schumaker <Anna.Schumaker@Netapp.com>
> +.\"
> +.\" %%%LICENSE_START(VERBATIM)
> +.\" Permission is granted to make and distribute verbatim copies of this
> +.\" manual provided the copyright notice and this permission notice are
> +.\" preserved on all copies.
> +.\"
> +.\" Permission is granted to copy and distribute modified versions of
> +.\" this manual under the conditions for verbatim copying, provided that
> +.\" the entire resulting derived work is distributed under the terms of
> +.\" a permission notice identical to this one.
> +.\"
> +.\" Since the Linux kernel and libraries are constantly changing, this
> +.\" manual page may be incorrect or out-of-date.  The author(s) assume
> +.\" no responsibility for errors or omissions, or for damages resulting
> +.\" from the use of the information contained herein.  The author(s) may
> +.\" not have taken the same level of care in the production of this
> +.\" manual, which is licensed free of charge, as they might when working
> +.\" professionally.
> +.\"
> +.\" Formatted or processed versions of this manual, if unaccompanied by
> +.\" the source, must acknowledge the copyright and authors of this work.
> +.\" %%%LICENSE_END
> +.\"
> +.TH COPY 2 2015-11-06 "Linux" "Linux Programmer's Manual"
> +.SH NAME
> +copy_file_range \- Copy a range of data from one file to another
> +.SH SYNOPSIS
> +.nf
> +.B #include <sys/syscall.h>
> +.B #include <unistd.h>
> +
> +.BI "ssize_t copy_file_range(int " fd_in ", loff_t *" off_in ", int " fd_out ",
> +.BI "                        loff_t *" off_out ", size_t " len \
> +", unsigned int " flags );
> +.fi
> +.SH DESCRIPTION
> +The
> +.BR copy_file_range ()
> +system call performs an in-kernel copy between two file descriptors
> +without the additional cost of transferring data from the kernel to userspace
> +and then back into the kernel.
> +It copies up to
> +.I len
> +bytes of data from file descriptor
> +.I fd_in
> +to file descriptor
> +.IR fd_out ,
> +overwriting any data that exists within the requested range of the target file.
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
> +argument must be set to 0.
> +.SH RETURN VALUE
> +Upon successful completion,
> +.BR copy_file_range ()
> +will return the number of bytes copied between files.
> +This could be less than the length originally requested.
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
> +is not open for writing; or
> +.I fd_out
> +is open for appending.
> +.TP
> +.B EINVAL
> +Requested range extends beyond the end of the source file; or the
> +.I flags
> +argument is not 0.
> +.TP
> +.B EIO
> +A low level I/O error occurred while copying.
> +.TP
> +.B ENOMEM
> +Out of memory.
> +.TP
> +.B ENOSPC
> +There is not enough space on the target filesystem to complete the copy.
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
> +.SH NOTES
> +If
> +.I file_in
> +is a sparse file, then
> +.BR copy_file_range ()
> +may expand any holes existing in the requested range.
> +Users may benefit from calling
> +.BR copy_file_range ()
> +in a loop, and using
> +.BR lseek (2)
> +to find the locations of data segments.

Here, I explicitly added mention of SEEK_HOLE and SEEK_DATA. okay?

> +.SH EXAMPLE
> +.nf
> +#define _GNU_SOURCE
> +#include <fcntl.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <sys/stat.h>
> +#include <sys/syscall.h>
> +#include <unistd.h>
> +
> +loff_t copy_file_range(int fd_in, loff_t *off_in, int fd_out,
> +                       loff_t *off_out, size_t len, unsigned int flags)
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

'buf' is unused, so I removed it. I assume it was accidental cruft; this
is just a heads-up, in case some you meant have some code in the program
that would use that variable.

> +
> +    if (argc != 3) {
> +        fprintf(stderr, "Usage: %s <source> <destination>\\n", argv[0]);
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    fd_in = open(argv[1], O_RDONLY);
> +    if (fd_in == \-1) {
> +        perror("open (argv[1])");
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    if (fstat(fd_in, &stat) == \-1) {
> +        perror("fstat");
> +        exit(EXIT_FAILURE);
> +    }
> +    len = stat.st_size;
> +
> +    fd_out = open(argv[2], O_CREAT|O_WRONLY|O_TRUNC, 0644);
> +    if (fd_out == \-1) {
> +        perror("open (argv[2])");
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    do {
> +        ret = copy_file_range(fd_in, NULL, fd_out, NULL, len, 0);
> +        if (ret == \-1) {
> +            perror("copy_file_range");
> +            exit(EXIT_FAILURE);
> +        }
> +
> +        len \-= ret;
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
> @@ -238,6 +238,7 @@ only pointers are copied, not the pages of the buffer.
>  See
>  .BR tee (2).
>  .SH SEE ALSO
> +.BR copy_file_range (2),
>  .BR sendfile (2),
>  .BR tee (2),
>  .BR vmsplice (2)

Thanks, 

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
