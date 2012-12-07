Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:39113 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891Ab2LGJIr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Dec 2012 04:08:47 -0500
MIME-Version: 1.0
In-Reply-To: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru>
Date: Fri, 7 Dec 2012 13:08:46 +0400
Message-ID: <CAKywueQ3d=wdq2nw5f-QS-D9PY70Axa3Cn0gi5GRk4Xso+iquA@mail.gmail.com>
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-cifs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        wine-devel@winehq.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/12/6 Pavel Shilovsky <piastry@etersoft.ru>:
> Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags - this change can benefit cifs and nfs modules. While this change is ok for network filesystems, itsn't not targeted for local filesystems due security problems (e.g. when a user process can deny root to delete a file).
>
> Share flags are used by Windows applications and WINE have to deal with them too. While WINE can process open share flags itself on local filesystems, it can't do it if a file stored on a network share and is used by several clients. This patchset makes it possible for CIFS/SMB2.0/SMB3.0.
>
> Pavel Shilovsky (3):
>   fcntl: Introduce new O_DENY* open flags for network filesystems
>   CIFS: Add O_DENY* open flags support
>   CIFS: Use NT_CREATE_ANDX command for forcemand mounts
>
>  fs/cifs/cifsacl.c                |   10 ++++----
>  fs/cifs/cifsglob.h               |   11 ++++++++-
>  fs/cifs/cifsproto.h              |    9 ++++----
>  fs/cifs/cifssmb.c                |   47 ++++++++++++++++++++------------------
>  fs/cifs/dir.c                    |   14 ++++++++----
>  fs/cifs/file.c                   |   18 ++++++++++-----
>  fs/cifs/inode.c                  |   11 +++++----
>  fs/cifs/link.c                   |   10 ++++----
>  fs/cifs/readdir.c                |    2 +-
>  fs/cifs/smb1ops.c                |   15 ++++++------
>  fs/cifs/smb2file.c               |   10 ++++----
>  fs/cifs/smb2inode.c              |    4 ++--
>  fs/cifs/smb2ops.c                |   10 ++++----
>  fs/cifs/smb2pdu.c                |    6 ++---
>  fs/cifs/smb2proto.h              |   14 +++++++-----
>  fs/fcntl.c                       |    5 ++--
>  include/uapi/asm-generic/fcntl.h |   11 +++++++++
>  17 files changed, 125 insertions(+), 82 deletions(-)
>
> --
> 1.7.10.4
>

First of all, sorry for being unclear at this proposal.


I am not from Wine team but I am working on things related to
Wine+CIFS-client+Samba.

We (at Etersoft) need to organize the work of Wine applications
through cifs-client share mounted to Samba (or Windows server). They
are related to accounting (mostly Russian ones - e.g.
http://www.1c.ru/eng/title.htm). So, the problem is that such
applications use share flags to control the parallel access to the
same files of several clients on a remote share. Also, there can be a
situation where Windows (native) clients and Wine clients are working
together in the same time.

That's why we need such flags in the kernel (patch #1). With these
flags Wine can pass them to every open and they will be used by CIFS
(and probably NFS) file systems to pass to the Samba server. In the
same time if the file is on local filesystem - these flags will be
simply ignored (not implemented).

Now we have to make our own builds of cifs module for every kernel
that use these flags passed by our build of Wine - this scheme is
working but requires merging every time new kernel is released.
Getting things into mainline let Wine supports more applications.

As for the security layer, I don't think that we need any extra bits
to switch these flags on or off - it will be switched on/off by an
underlying filesystem. Since, this change is targeted for a network
purpose only, a tool, that shows us what process/user locks a file,
doesn't help a lot because the file can be locked remotely.

As was said above, this change let us give Wine application share
flags possibility for both Samba and Windows servers. Patch #2 enables
share flags support for cifs mounts of Windows servers or Samba
servers with nounix mount option. But we already have forcemand mount
option in cifs module that switches on mandatory byte-range locking
semantic for Samba without nounix. Since share flags capability is a
kind of 'mandatory' locking scheme, I suggest that this option should
switch on share flags for Samba without nounix too (by using
NTCreateAndX command for open rather than transaction2) - that is what
patch #3 does.

-- 
Best regards,
Pavel Shilovsky.
