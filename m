Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36625 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760730AbbIDWbV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 18:31:21 -0400
Received: by pacwi10 with SMTP id wi10so36216984pac.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2015 15:31:21 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH v1 9/8] copy_file_range.2: New page documenting copy_file_range()
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20150904213856.GC10391@birch.djwong.org>
Date: Fri, 4 Sep 2015 16:31:17 -0600
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Message-Id: <95674806-645C-410C-8A4B-A46F03AFFE20@dilger.ca>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com> <1441397823-1203-10-git-send-email-Anna.Schumaker@Netapp.com> <20150904213856.GC10391@birch.djwong.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 4, 2015, at 3:38 PM, Darrick J. Wong <darrick.wong@oracle.com> wrote:
> 
> On Fri, Sep 04, 2015 at 04:17:03PM -0400, Anna Schumaker wrote:
>> copy_file_range() is a new system call for copying ranges of data
>> completely in the kernel.  This gives filesystems an opportunity to
>> implement some kind of "copy acceleration", such as reflinks or
>> server-side-copy (in the case of NFS).
>> 
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>> ---
>> man2/copy_file_range.2 | 168 +++++++++++++++++++++++++++++++++++++++++++++++++
>> 1 file changed, 168 insertions(+)
>> create mode 100644 man2/copy_file_range.2
>> 
>> diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
>> new file mode 100644
>> index 0000000..4a4cb73
>> --- /dev/null
>> +++ b/man2/copy_file_range.2
>> @@ -0,0 +1,168 @@
>> +.\"This manpage is Copyright (C) 2015 Anna Schumaker <Anna.Schumaker@Netapp.com>
>> +.TH COPY 2 2015-8-31 "Linux" "Linux Programmer's Manual"
>> +.SH NAME
>> +copy_file_range \- Copy a range of data from one file to another
>> +.SH SYNOPSIS
>> +.nf
>> +.B #include <linux/copy.h>
>> +.B #include <sys/syscall.h>
>> +.B #include <unistd.h>
>> +
>> +.BI "ssize_t syscall(__NR_copy_file_range, int " fd_in ", loff_t * " off_in ",
>> +.BI "                int " fd_out ", loff_t * " off_out ", size_t " len ",
>> +.BI "                unsigned int " flags );
>> +.fi
>> +.SH DESCRIPTION
>> +The
>> +.BR copy_file_range ()
>> +system call performs an in-kernel copy between two file descriptors
>> +without all that tedious mucking about in userspace.
> 
> ;)
> 
>> +It copies up to
>> +.I len
>> +bytes of data from file descriptor
>> +.I fd_in
>> +to file descriptor
>> +.I fd_out
>> +at
>> +.IR off_out .
>> +The file descriptors must not refer to the same file.
> 
> Why?  btrfs (and XFS) reflink can handle the case of a file sharing blocks
> with itself.
> 
>> +
>> +The following semantics apply for
>> +.IR fd_in ,
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
>> +The default behavior of
>> +.BR copy_file_range ()
>> +is filesystem specific, and might result in creating a
>> +copy-on-write reflink.
>> +In the event that a given filesystem does not implement
>> +any form of copy acceleration, the kernel will perform
>> +a deep copy of the requested range by reading bytes from
> 
> I wonder if it's wise to allow deep copies -- what happens if
> len == 1T? Will this syscall just block for a really long time?

It should be interruptible, and return the length of the number of
bytes copied so far, just like read() and write().  That allows
the caller to continue where it left off, or abort and delete the
target file, or whatever it wants to do.

Cheers, Andreas

>> +.I fd_in
>> +and writing them to
>> +.IR fd_out .
> 
> "...if COPY_REFLINK is not set in flags."
> 
>> +
>> +Currently, Linux only supports the following flag:
>> +.TP 1.9i
>> +.B COPY_REFLINK
>> +Only perform the copy if the filesystem can do it as a reflink.
>> +Do not fall back on performing a deep copy.
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
>> +or do not have proper read-write mode.
> 
> "or fd_out is not opened for writing"?
> 
>> +.TP
>> +.B EINVAL
>> +Requested range extends beyond the end of the file;
>> +.I flags
>> +argument is set to an invalid value.
>> +.TP
>> +.B EOPNOTSUPP
>> +.B COPY_REFLINK
>> +was specified in
>> +.IR flags ,
>> +but the target filesystem does not support reflinks.
>> +.TP
>> +.B EXDEV
>> +Target filesystem doesn't support cross-filesystem copies.
>> +.SH VERSIONS
> 
> Perhaps this ought to list a few more errors (EIO, ENOSPC, ENOSYS, EPERM...)
> that can be returned?  (I was looking at the fallocate manpage.)
> 
> --D
> 
>> +The
>> +.BR copy_file_range ()
>> +system call first appeared in Linux 4.3.
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
>> +    if (argc != 3) {
>> +        fprintf(stderr, "Usage: %s <pathname> <pathname>\n", argv[0]);
>> +        exit(EXIT_FAILURE);
>> +    }
>> +
>> +    fd_in = open(argv[1], O_RDONLY);
>> +    if (fd_in == -1) {
>> +        perror("open (argv[1])");
>> +        exit(EXIT_FAILURE);
>> +    }
>> +
>> +    if (fstat(fd_in, &stat) == -1) {
>> +        perror("fstat");
>> +        exit(EXIT_FAILURE);
>> +    }
>> +    len = stat.st_size;
>> +
>> +    fd_out = open(argv[2], O_WRONLY | O_CREAT, 0644);
>> +    if (fd_out == -1) {
>> +        perror("open (argv[2])");
>> +        exit(EXIT_FAILURE);
>> +    }
>> +
>> +    do {
>> +        ret = syscall(__NR_copy_file_range, fd_in, NULL,
>> +                      fd_out, NULL, len, 0);
>> +        if (ret == -1) {
>> +            perror("copy_file_range");
>> +            exit(EXIT_FAILURE);
>> +        }
>> +
>> +        len -= ret;
>> +    } while (len > 0);
>> +
>> +    close(fd_in);
>> +    close(fd_out);
>> +    exit(EXIT_SUCCESS);
>> +}
>> +.fi
>> +.SH SEE ALSO
>> +.BR splice (2)
>> -- 
>> 2.5.1
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas





