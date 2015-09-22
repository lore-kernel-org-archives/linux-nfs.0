Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:63915 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934214AbbIVUav (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 16:30:51 -0400
Subject: Re: [PATCH v2 10/9] copy_file_range.2: New page documenting
 copy_file_range()
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>,
        <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <andros@netapp.com>, <hch@infradead.org>
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1442003423-6884-11-git-send-email-Anna.Schumaker@Netapp.com>
 <55F52ABA.9070908@gmail.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <5601BA5F.6080400@Netapp.com>
Date: Tue, 22 Sep 2015 16:30:23 -0400
MIME-Version: 1.0
In-Reply-To: <55F52ABA.9070908@gmail.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Michael,

On 09/13/2015 03:50 AM, Michael Kerrisk (man-pages) wrote:
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

Sorry for the delay in responding, I'm cycling back around to copy stuff now.  I'll be more than happy to revise and resubmit!

> 
>> ---
>>  man2/copy_file_range.2 | 188 +++++++++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 188 insertions(+)
>>  create mode 100644 man2/copy_file_range.2
>>
>> diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
>> new file mode 100644
>> index 0000000..84912b5
>> --- /dev/null
>> +++ b/man2/copy_file_range.2
>> @@ -0,0 +1,188 @@
>> +.\"This manpage is Copyright (C) 2015 Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> We need a license for this page. Please see
> https://www.kernel.org/doc/man-pages/licenses.html

Sure.

> 
>> +.TH COPY 2 2015-8-31 "Linux" "Linux Programmer's Manual"
> 
> Make the month 2 digits (leading 0).

Okay.

> 
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
> 
> Remove spaces following "*" in the lines above. (man-pages convention for code)
> 
> I know that the copy_file_range() (obviously) doesn't yet have a wrapper
> in glibc, but in the man pages we document all system calls as though there
> is a wrapper. See, for example, gettid(2), for an axample of how this is done
> (a note in the SYNOPSIS and then some further details in NOTES).

Makes sense.  I'll change that!
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

Aww, I was hoping to sneak in a Hitchhiker's Guide reference...  I'll change the text.

> 
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
>> +== 0) is to try creating a reflink,
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

That could work.  I'll think on this before resubmitting anything.

> 
> What are the semantics with respect to signals, especially if data 
> copying a very large file range? This info should be included in the 
> man page, probably under NOTES.

I'm not sure offhand.  I need to look into this!

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
> => s/space/space on the target filesystem/
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
>> +    if (argc != 3) {
>> +        fprintf(stderr, "Usage: %s <source> <destination>\\n", argv[0]);
>> +        exit(EXIT_FAILURE);
>> +    }
>> +
>> +    fd_in = open(argv[1], O_RDONLY);
>> +    if (fd_in == -1) {
> 
> Please replace all "-" in code by "\-". (This is a groff
> detail.)

Sure.

> 
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
>> +    fd_out = creat(argv[2], 0644);
> 
> These days, I think we should discourage the use of creat(). Maybe 
> better to use open() instead here?

Sure, that's a simple enough switch.

> 
>> +    if (fd_out == -1) {
>> +        perror("creat (argv[2])");
>> +        exit(EXIT_FAILURE);
>> +    }
>> +
>> +    do {
>> +        ret = syscall(__NR_copy_file_range, fd_in, NULL,
>> +                      fd_out, NULL, len, 0);
> 
> I'd rather see this as:
> 
> int
> copy_file_range(int fd_in, loff_t *off_in,
>                 int fd_out, loff_t *off_out, size_t len,
>                 unsigned int flags)
> {
>     return(syscall(__NR_copy_file_range, fd_in, fd_out, off_out, len, flags);
> }
> 
> ...
> 
>     copy_file_range(fd_in, fd_out, off_out, len, flags);

Okay.

> 
>  
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
>>
> 
> In the next iteration of this patch, could you include a change to
> splice(2) so that copy_file_range(2) is added under SEE ALSO in
> that page. Also, are there any other pages that we should like
> to/from? (sendfile(2)?)

Sure, no problem.

Thanks for the feedback!
Anna

> 
> Thanks,
> 
> Michael
> 
> 

