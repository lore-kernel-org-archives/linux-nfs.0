Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42328 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbbI1Sll (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Sep 2015 14:41:41 -0400
Date: Mon, 28 Sep 2015 11:40:34 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        mtk.manpages@gmail.com, andros@netapp.com, hch@infradead.org
Subject: Re: [PATCH v3 10/9] copy_file_range.2: New page documenting
 copy_file_range()
Message-ID: <20150928184034.GC850@birch.djwong.org>
References: <1443214096-12769-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443214096-12769-11-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443214096-12769-11-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 25, 2015 at 04:48:16PM -0400, Anna Schumaker wrote:
> copy_file_range() is a new system call for copying ranges of data
> completely in the kernel.  This gives filesystems an opportunity to
> implement some kind of "copy acceleration", such as reflinks or
> server-side-copy (in the case of NFS).
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> ---
> v3:
> - Added license information
> - Updated splice(2)
> - Various other edits after mailing list discussion
> ---
>  man2/copy_file_range.2 | 211 +++++++++++++++++++++++++++++++++++++++++++++++++
>  man2/splice.2          |   1 +
>  2 files changed, 212 insertions(+)
>  create mode 100644 man2/copy_file_range.2
> 
> diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
> new file mode 100644
> index 0000000..6d66d4a
> --- /dev/null
> +++ b/man2/copy_file_range.2
> @@ -0,0 +1,211 @@
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
> +.\" manual page may be incorrect or out-of-date.  The author(s) assume.
> +.\" no responsibility for errors or omissions, or for damages resulting.
> +.\" from the use of the information contained herein.  The author(s) may.
> +.\" not have taken the same level of care in the production of this.
> +.\" manual, which is licensed free of charge, as they might when working.
> +.\" professionally.
> +.\"
> +.\" Formatted or processed versions of this manual, if unaccompanied by
> +.\" the source, must acknowledge the copyright and authors of this work.
> +.\" %%%LICENSE_END
> +.\"
> +.TH COPY 2 2015-08-31 "Linux" "Linux Programmer's Manual"
> +.SH NAME
> +copy_file_range \- Copy a range of data from one file to another
> +.SH SYNOPSIS
> +.nf
> +.B #include <linux/copy.h>
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
> +argument can have one of the following flags set:
> +.TP 1.9i
> +.B COPY_FR_COPY
> +Copy all the file data in the requested range.
> +Some filesystems might be able to accelerate this copy
> +to avoid unnecessary data transfers.
> +.TP
> +.B COPY_FR_REFLINK
> +Create a lightweight "reflink", where data is not copied until
> +one of the files is modified.

.TP
.B COPY_FR_DEDUPE
Create a lightweight "reflink" with the same operational behavior as
COPY_FR_REFLINK, but only perform the reflink if the contents of both files'
byte ranges are identical.  This flag cannot be specified with COPY_FR_COPY or
COPY_FR_REFLINK.  If the ranges do not match, EILSEQ will be returned.

> +.PP
> +The default behavior
> +.RI ( flags
> +== 0) is to try creating a reflink,
> +and if reflinking fails
> +.BR copy_file_range ()
> +will fall back to performing a full data copy.
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
> +is not open for writing.
> +.TP
> +.B EINVAL
> +Requested range extends beyond the end of the source file; or the
> +.I flags
> +argument is set to an invalid value.

.TP
.B EILSEQ
The contents of both files' byte ranges did not match.

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
> +.B EOPNOTSUPP
> +.B COPY_REFLINK

.B COPY_FR_REFLINK
or
.B COPY_FR_DEDUPE

> +was specified in
> +.IR flags ,
> +but the target filesystem does not support reflinks.

"does not support the given operation."

Otherwise you can add,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> +.TP
> +.B EXDEV
> +Target filesystem doesn't support cross-filesystem copies.
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
> +#include <linux/copy.h>
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
> +        ret = copy_file_range(fd_in, NULL, fd_out, NULL, len, COPY_FR_COPY);
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
> -- 
> 2.5.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
