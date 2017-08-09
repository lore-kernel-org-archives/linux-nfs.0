Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35637 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752815AbdHIMaw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Aug 2017 08:30:52 -0400
Received: by mail-qk0-f169.google.com with SMTP id d145so34993387qkc.2
        for <linux-nfs@vger.kernel.org>; Wed, 09 Aug 2017 05:30:51 -0700 (PDT)
Message-ID: <1502281848.12841.2.camel@redhat.com>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
From: Jeff Layton <jlayton@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>
Date: Wed, 09 Aug 2017 08:30:48 -0400
In-Reply-To: <20170807212355.29127-3-kolga@netapp.com>
References: <20170807212355.29127-1-kolga@netapp.com>
         <20170807212355.29127-3-kolga@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-08-07 at 17:23 -0400, Olga Kornievskaia wrote:
> destroy_creds() is a new system call for destroying file system
> credentials. This is usefulf for file systems that manage its
> own security contexts that were bootstrapped via some user land
> credentials (such as Kerberos).
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  man2/destroy_creds.2 | 130
> +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 130 insertions(+)
>  create mode 100644 man2/destroy_creds.2
> 
> diff --git a/man2/destroy_creds.2 b/man2/destroy_creds.2
> new file mode 100644
> index 0000000..7b41c9d
> --- /dev/null
> +++ b/man2/destroy_creds.2
> @@ -0,0 +1,130 @@
> +.\"This manpage is Copyright (C) 2015 Olga Kornievskaia <kolga@Netap
> p.com>
> +.\"
> +.\" %%%LICENSE_START(VERBATIM)
> +.\" Permission is granted to make and distribute verbatim copies of
> this
> +.\" manual provided the copyright notice and this permission notice
> are
> +.\" preserved on all copies.
> +.\"
> +.\" Permission is granted to copy and distribute modified versions
> of
> +.\" this manual under the conditions for verbatim copying, provided
> that
> +.\" the entire resulting derived work is distributed under the terms
> of
> +.\" a permission notice identical to this one.
> +.\"
> +.\" Since the Linux kernel and libraries are constantly changing,
> this
> +.\" manual page may be incorrect or out-of-date.  The author(s)
> assume
> +.\" no responsibility for errors or omissions, or for damages
> resulting
> +.\" from the use of the information contained herein.  The author(s)
> may
> +.\" not have taken the same level of care in the production of this
> +.\" manual, which is licensed free of charge, as they might when
> working
> +.\" professionally.
> +.\"
> +.\" Formatted or processed versions of this manual, if unaccompanied
> by
> +.\" the source, must acknowledge the copyright and authors of this
> work.
> +.\" %%%LICENSE_END
> +.\"
> +.TH COPY 2 2017-08-07 "Linux" "Linux Programmer's Manual"
> +.SH NAME
> +destroy_creds \- destroy current user's file system credentials for
> a mount point
> +.SH SYNOPSIS
> +.nf
> +.B #include <sys/syscall.h>
> +.B #include <unistd.h>
> +
> +.BI "int destroy_creds(int " fd ");
> +.fi
> +.SH DESCRIPTION
> +The
> +.BR destroy ()
> +system call performs destruction of file system credentials for the
> current
> +user. It identifies the file system by the supplied file descriptor
> in
> +.I fd
> +that represents a mount point.
> +
> +.SH RETURN VALUE
> +Upon successful completion,
> +.BR destroy_creds ()
> +will return 0.
> +
> +On error,
> +.BR destroy_creds ()
> +returns \-1 and
> +.I errno
> +is set to indicate the error.
> +.SH ERRORS
> +.TP
> +.B EBADF
> +.I fd
> +file descriptor is not valid
> +.TP
> +.B EINVAL
> +if the input file descriptor is not a directory
> +.TP
> +.B ENOENT
> +no credentials found
> +.TP
> +.B EACCES
> +unable to access credentials
> +.TP
> +.B ENOSYS
> +file system does not implement destroy_creds() functionality
> +.SH VERSIONS
> +The
> +.BR destroy_creds ()
> +system call first appeared in Linux 4.1?.
> +.SH CONFORMING TO
> +The
> +.BR destroy_creds ()
> +system call is a nonstandard Linux extension.
> +.SH NOTES
> +
> +.BR destroy_creds ()
> +gives filesystems an opportunity to destroy credentials. For
> instance,
> +NFS uses Kerberos credentials stored in Kerberos credential cache to
> +create its security contexts that then are stored and managed by the
> +kernel. Once the user logs out and destroys Kerberos credentials via
> +kdestroy, NFS security contexts associate with that user are valid 
> +until they expire. fslogout application such provided by the example
> +allows the user driven credential destruction in the file system.
> +
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
> +static int
> +destroy_creds(int fd)
> +{
> +    return syscall(__NR_destroy_creds, fd);
> +}
> +
> +int
> +main(int argc, char **argv)
> +{
> +    int fd, ret;
> +
> +    if (argc != 2) {
> +        fprintf(stderr, "Usage: %s <mount point>\\n", argv[0]);
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    fd = open(argv[1], O_DIRECTORY|O_RDONLY);
> +    if (fd == \-1) {
> +        perror("open (argv[1])");
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    ret = destroy_creds(fd);
> +    if (ret == \-1) {
> +        perror("destroy_creds");
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    close(fd);
> +    exit(EXIT_SUCCESS);
> +}
> +.fi

Thanks, that helps a bit. I'm less clear on what the higher-level
vision is here though:

Are we all going to be running scripts on logout that scrape
/proc/mounts and run fslogout on each? Will this be added to kdestroy?

Or are you aiming to have KCM do this on some trigger? (see:
https://fedoraproject.org/wiki/Changes/KerberosKCMCache)

Also, doing this per-mount seems wrong to me. Shouldn't this be done on
a per-net-namespace basis or maybe even globally?

It seems like we can afford to be rather cavalier about destroying
creds here. Even if we purge creds for a user that should have remained
valid, we just end up having to re-upcall for them, right?
-- 
Jeff Layton <jlayton@redhat.com>
