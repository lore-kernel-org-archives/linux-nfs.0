Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36031 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbdHGPfa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Aug 2017 11:35:30 -0400
MIME-Version: 1.0
In-Reply-To: <1502101657.4811.1.camel@redhat.com>
References: <20170804144939.25374-1-kolga@netapp.com> <1502101657.4811.1.camel@redhat.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 7 Aug 2017 11:35:29 -0400
Message-ID: <CAN-5tyHnNFGSUKj+-c+hGrCJpXSE5c6w=L7E0uiLRJcUgEnKhQ@mail.gmail.com>
Subject: Re: [RFC v2 0/3] VFS/NFS support to destroy FS credentials
To: Jeff Layton <jlayton@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 7, 2017 at 6:27 AM, Jeff Layton <jlayton@redhat.com> wrote:
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
>> fd =3D open("/mnt", O_DIRECTORY|O_RDONLY);
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

Ok.

> How do you expect this syscall to be used by userland? What will call it
> and under what circumstances?

I think we need to provide flexibility to the userland on how it would
be triggered. It could be that the user runs an application (fslogout
/mnt). AFS has =E2=80=9Cunlog=E2=80=9D for logout I think. But such an appl=
ication
could also be integrated by an administrated into the logout script
from the shell or it could be integrated into something like pam.

> Also, this looks at first glance like a single-purpose, single-
> filesystem call. Would this have any purpose at all outside of NFS?
> Would this be usable with CIFS or Ceph in some fashion?

NFS has proposed NFS-specific logout mechanism a while back
http://marc.info/?t=3D138245185000016&r=3D1&w=3D2 and at the time it was
suggested that instead of doing a specific mechanism that only NFS
would use why not do a syscall so that other filesystems would use it.
So=E2=80=A6.

That=E2=80=99s the idea that other filesystem could make use of this
functionality to get rid of their security contexts upon user logout.
In the linux kernel, I don=E2=80=99t see security implementation by CIFS so=
 if
it were to be implemented, I would imagine it would be useful. It=E2=80=99s
rather late for AFS now as it already has its own well established
mechanism.

What I=E2=80=99m not clear on is whether or not a mount point is enough to
specify what creds to get rid off for a generic file system,. CIFS is
Kerberos based so very similar to NFS. I think specifying a share
determines which creds need to go. While not proposing to convert it,
but for something like AFS, unlog takes a cell name so then fslog
could take /afs/cell.name to be specific.

I=E2=80=99m not familiar with Ceph security. According to
http://docs.ceph.com/docs/firefly/rados/operations/auth-intro/, under
the =E2=80=9Cceph limitations=E2=80=9D it says =E2=80=9CThe cephx protocol =
authenticates Ceph
clients and servers to each other. It is not intended to handle
authentication of human users or application programs run on their
behalf.=E2=80=9D If that is the case then there is no such thing as a user
logout and thus no need to destroy credentials. If there is
authentication of users where the user proves via some means his
identity via some login application. Then I imagine then there would
be a corresponding logout that the Ceph file system in the kernel
doesn=E2=80=99t know that the user have logged out and it would require use=
r
land driven trigger to get rid of such context. I have also read that
Ceph uses a keyring to store the secret key it is uses for securing
communication with the servers. Then if everything is integrated into
the keyring then again no need for a logout method.

I think this feature is useful for where the filesystem manages its
own security contexts that were bootstrapped via some user land
credentials (such Kerberos).
>
> --
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
