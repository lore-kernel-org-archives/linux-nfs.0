Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:34605 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751800AbdHGPxM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Aug 2017 11:53:12 -0400
MIME-Version: 1.0
In-Reply-To: <1502101657.4811.1.camel@redhat.com>
References: <20170804144939.25374-1-kolga@netapp.com> <1502101657.4811.1.camel@redhat.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 7 Aug 2017 17:53:11 +0200
Message-ID: <CAOQ4uxh11MjNiom8frunCTB+Qw0mfR7HLpU4pZsyN-sC=ZBtkQ@mail.gmail.com>
Subject: Re: [RFC v2 0/3] VFS/NFS support to destroy FS credentials
To: Jeff Layton <jlayton@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 7, 2017 at 12:27 PM, Jeff Layton <jlayton@redhat.com> wrote:
> On Fri, 2017-08-04 at 10:49 -0400, Olga Kornievskaia wrote:
>> Allow a user to call into the file system and ask to destroy FS
>> credentials. For instance, when the user logs out after using
>> a kerberized NFS share, he destroys Kerberos credentials but NFS
>> credentials remain valid until the gss context expires. Allow
>> the user (or things like pam) to trigger destruction of such
>> credentials.
>>
>> A userland application would do:
>>
>> fd = open("/mnt", O_DIRECTORY|O_RDONLY);
>> syscall(_NR_destroy_creds, fd);
>>
>> v2: fixing a hasty IS_DIR check, definition of __NR_destroy_creds
>> and order of the patches
>>
>> Olga Kornievskaia (3):
>>   VFS adding destroy_creds call
>>   SUNRPC mark user credentials destroyed
>>   NFS define vfs destroy_creds functions
>>
>>  arch/x86/entry/syscalls/syscall_32.tbl |  1 +
>>  arch/x86/entry/syscalls/syscall_64.tbl |  1 +
>>  fs/nfs/dir.c                           |  8 ++++++++
>>  fs/read_write.c                        | 22 ++++++++++++++++++++++
>>  include/linux/fs.h                     |  2 ++
>>  include/linux/sunrpc/auth.h            |  5 +++++
>>  include/linux/syscalls.h               |  2 +-
>>  include/uapi/asm-generic/unistd.h      |  4 +++-
>>  kernel/sys_ni.c                        |  1 +
>>  net/sunrpc/auth.c                      |  9 +++++++++
>>  net/sunrpc/auth_generic.c              | 15 +++++++++++++++
>>  net/sunrpc/auth_gss/auth_gss.c         |  3 +++
>>  12 files changed, 71 insertions(+), 2 deletions(-)
>>
>
> I think I'd like to see a proposed manpage for this syscall.
>

And better CC linux-api...

> How do you expect this syscall to be used by userland? What will call it
> and under what circumstances?
>
> Also, this looks at first glance like a single-purpose, single-
> filesystem call. Would this have any purpose at all outside of NFS?
> Would this be usable with CIFS or Ceph in some fashion?
>
> --
> Jeff Layton <jlayton@redhat.com>
