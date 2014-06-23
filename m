Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529AbaFWMpo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 08:45:44 -0400
Message-ID: <53A8214F.8050505@redhat.com>
Date: Mon, 23 Jun 2014 13:45:03 +0100
From: Steven Whitehouse <swhiteho@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@elte.hu>
CC: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>,
        Steve French <sfrench@samba.org>, David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/2] Update wait_on_bit functions
References: <20140623004945.21714.26253.stgit@notabene.brown>
In-Reply-To: <20140623004945.21714.26253.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On 23/06/14 01:52, NeilBrown wrote:
> These patches were in 'tip' for a while, but caused conflicts
> with other changes - both NFS and CIFS added new uses of
> wait_on_bit functions.
>
> So here they are again against 3.16-rc2.  Hopefully no new users will
> be added before -rc3 or -rc4...
>
> (I hoped to submit this in the rc1 -> rc2 window, but that happened
> while I was on leave...)
>
> Thanks,
> NeilBrown
Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Steve.

> ---
>
> NeilBrown (2):
>        SCHED: remove proliferation of wait_on_bit action functions.
>        SCHED: allow wait_on_bit_action functions to support a timeout.
>
>
>   Documentation/filesystems/caching/operations.txt |    2
>   drivers/md/dm-bufio.c                            |   41 ++-----
>   drivers/md/dm-snap.c                             |   10 --
>   drivers/media/usb/dvb-usb-v2/dvb_usb_core.c      |   12 --
>   fs/btrfs/extent_io.c                             |   10 --
>   fs/buffer.c                                      |   11 --
>   fs/cifs/connect.c                                |   10 --
>   fs/cifs/file.c                                   |    9 --
>   fs/cifs/inode.c                                  |    6 +
>   fs/cifs/misc.c                                   |    2
>   fs/fs-writeback.c                                |    3 -
>   fs/fscache/cookie.c                              |    7 +
>   fs/fscache/internal.h                            |    2
>   fs/fscache/main.c                                |   18 ---
>   fs/fscache/page.c                                |    4 -
>   fs/gfs2/glock.c                                  |   25 ----
>   fs/gfs2/lock_dlm.c                               |    8 -
>   fs/gfs2/ops_fstype.c                             |   11 --
>   fs/gfs2/recovery.c                               |    8 -
>   fs/gfs2/super.c                                  |    8 -
>   fs/inode.c                                       |    7 -
>   fs/jbd2/transaction.c                            |   10 --
>   fs/nfs/file.c                                    |    4 -
>   fs/nfs/filelayout/filelayoutdev.c                |    4 -
>   fs/nfs/inode.c                                   |    6 +
>   fs/nfs/internal.h                                |    2
>   fs/nfs/nfs4state.c                               |    4 -
>   fs/nfs/pagelist.c                                |   14 +-
>   fs/nfs/pnfs.c                                    |    2
>   fs/nfs/write.c                                   |    4 -
>   include/linux/sunrpc/sched.h                     |    2
>   include/linux/wait.h                             |  125 +++++++++++++++++++++-
>   include/linux/writeback.h                        |    3 -
>   kernel/ptrace.c                                  |    8 -
>   kernel/sched/wait.c                              |   30 ++++-
>   mm/filemap.c                                     |   20 +---
>   mm/ksm.c                                         |    8 -
>   net/bluetooth/hci_core.c                         |    8 -
>   net/sunrpc/sched.c                               |    4 -
>   security/keys/gc.c                               |   11 --
>   security/keys/request_key.c                      |   23 ----
>   41 files changed, 214 insertions(+), 292 deletions(-)
>

