Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33391 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754243AbdHIQos (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Aug 2017 12:44:48 -0400
MIME-Version: 1.0
In-Reply-To: <CALCETrXL2AkgMqHPonWJX-5Zckk1BELPtaikL-VkLqiPZ7Qf7A@mail.gmail.com>
References: <20170807212355.29127-1-kolga@netapp.com> <20170807212355.29127-3-kolga@netapp.com>
 <CALCETrXL2AkgMqHPonWJX-5Zckk1BELPtaikL-VkLqiPZ7Qf7A@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 9 Aug 2017 12:44:46 -0400
Message-ID: <CAN-5tyGz-duViqdLWrxfHYF+At9bqUSirdrbBMxrxh0aue8cDg@mail.gmail.com>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
To: Andy Lutomirski <luto@amacapital.net>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 9, 2017 at 12:08 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Mon, Aug 7, 2017 at 2:23 PM, Olga Kornievskaia <kolga@netapp.com> wrote:
>> destroy_creds() is a new system call for destroying file system
>> credentials. This is usefulf for file systems that manage its
>> own security contexts that were bootstrapped via some user land
>> credentials (such as Kerberos).
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  man2/destroy_creds.2 | 130 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 130 insertions(+)
>>  create mode 100644 man2/destroy_creds.2
>>
>> diff --git a/man2/destroy_creds.2 b/man2/destroy_creds.2
>> new file mode 100644
>> index 0000000..7b41c9d
>> --- /dev/null
>> +++ b/man2/destroy_creds.2
>> @@ -0,0 +1,130 @@
>> +.\"This manpage is Copyright (C) 2015 Olga Kornievskaia <kolga@Netapp.com>
>> +.\"
>> +.\" %%%LICENSE_START(VERBATIM)
>> +.\" Permission is granted to make and distribute verbatim copies of this
>> +.\" manual provided the copyright notice and this permission notice are
>> +.\" preserved on all copies.
>> +.\"
>> +.\" Permission is granted to copy and distribute modified versions of
>> +.\" this manual under the conditions for verbatim copying, provided that
>> +.\" the entire resulting derived work is distributed under the terms of
>> +.\" a permission notice identical to this one.
>> +.\"
>> +.\" Since the Linux kernel and libraries are constantly changing, this
>> +.\" manual page may be incorrect or out-of-date.  The author(s) assume
>> +.\" no responsibility for errors or omissions, or for damages resulting
>> +.\" from the use of the information contained herein.  The author(s) may
>> +.\" not have taken the same level of care in the production of this
>> +.\" manual, which is licensed free of charge, as they might when working
>> +.\" professionally.
>> +.\"
>> +.\" Formatted or processed versions of this manual, if unaccompanied by
>> +.\" the source, must acknowledge the copyright and authors of this work.
>> +.\" %%%LICENSE_END
>> +.\"
>> +.TH COPY 2 2017-08-07 "Linux" "Linux Programmer's Manual"
>> +.SH NAME
>> +destroy_creds \- destroy current user's file system credentials for a mount point
>> +.SH SYNOPSIS
>> +.nf
>> +.B #include <sys/syscall.h>
>> +.B #include <unistd.h>
>> +
>> +.BI "int destroy_creds(int " fd ");
>> +.fi
>> +.SH DESCRIPTION
>> +The
>> +.BR destroy ()
>> +system call performs destruction of file system credentials for the current
>> +user. It identifies the file system by the supplied file descriptor in
>> +.I fd
>> +that represents a mount point.
>
> Does this mean that whatever credentials are used for the current
> *fsuid* are destroyed?

It allows a filesystem to remove in-kernel credentials associated with
the current user (fluid). File system like NFS bootstraps its
in-kernel credentials with credentials stored in the Kerberos ticket
cache. Running example "fslogout" will not remove the Kerberos ticket
cache (which is typically done by running kdestroy).  Running fslogout
without running kdestroy invalidate current in-kernel credentials, but
NFS will acquire new ones using the still existing Kerberos ticket
cache.

> Are there actually per-uid credentials in the first place?

For something like NFS yes. AFS and CIFS too. Since no system call
like this was available, AFS has its own mechanism of removing
credentials (unlog). Linux CIFS security is based on Kerberos too but
is not currently implemented. It could benefit from a system call of
this sort.

> What privileges, if any, are needed to call this?

No privileges. A file system implementing destroy_creds() should
remove credentials associated with the credentials of the running user
context (fsuid).

> What if fd points to a bind mount?

It's just like the original mount. Removing credentials on either
(original or mount) of the mount points will remove credentials for
the user.
