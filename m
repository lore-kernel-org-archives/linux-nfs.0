Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:33931 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752613AbdHIQI6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Aug 2017 12:08:58 -0400
Received: by mail-vk0-f42.google.com with SMTP id n125so27410435vke.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Aug 2017 09:08:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170807212355.29127-3-kolga@netapp.com>
References: <20170807212355.29127-1-kolga@netapp.com> <20170807212355.29127-3-kolga@netapp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 9 Aug 2017 09:08:36 -0700
Message-ID: <CALCETrXL2AkgMqHPonWJX-5Zckk1BELPtaikL-VkLqiPZ7Qf7A@mail.gmail.com>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 7, 2017 at 2:23 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
> destroy_creds() is a new system call for destroying file system
> credentials. This is usefulf for file systems that manage its
> own security contexts that were bootstrapped via some user land
> credentials (such as Kerberos).
>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  man2/destroy_creds.2 | 130 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 130 insertions(+)
>  create mode 100644 man2/destroy_creds.2
>
> diff --git a/man2/destroy_creds.2 b/man2/destroy_creds.2
> new file mode 100644
> index 0000000..7b41c9d
> --- /dev/null
> +++ b/man2/destroy_creds.2
> @@ -0,0 +1,130 @@
> +.\"This manpage is Copyright (C) 2015 Olga Kornievskaia <kolga@Netapp.com>
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
> +.TH COPY 2 2017-08-07 "Linux" "Linux Programmer's Manual"
> +.SH NAME
> +destroy_creds \- destroy current user's file system credentials for a mount point
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
> +system call performs destruction of file system credentials for the current
> +user. It identifies the file system by the supplied file descriptor in
> +.I fd
> +that represents a mount point.

Does this mean that whatever credentials are used for the current
*fsuid* are destroyed?  Are there actually per-uid credentials in the
first place?

What privileges, if any, are needed to call this?

What if fd points to a bind mount?
