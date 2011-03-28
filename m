From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull bugfixes for the NFS client
Date: Mon, 28 Mar 2011 09:04:33 +0200
Message-ID: <1301295873.32186.1.camel__2421.73968949846$1301295913$gmane$org@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Filesystem Development <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62002 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314Ab1C1HEu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 03:04:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/namespace.c       |    4 +++-
 fs/nfs/pagelist.c        |    4 ++--
 fs/nfs/write.c           |   13 +++----------
 include/linux/nfs_page.h |    1 -
 net/sunrpc/sched.c       |    4 +++-
 5 files changed, 11 insertions(+), 15 deletions(-)

commit a271c5a0dea418931b6a903ef85adc30ad4c54be
Author: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Date:   Sun Mar 27 17:48:57 2011 +0200

    NFS: Ensure that rpc_release_resources_task() can be called twice.
    
    BUG: atomic_dec_and_test(): -1: atomic counter underflow at:
    Pid: 2827, comm: mount.nfs Not tainted 2.6.38 #1
    Call Trace:
     [<ffffffffa02223a0>] ? put_rpccred+0x44/0x14e [sunrpc]
     [<ffffffffa021bbe9>] ? rpc_ping+0x4e/0x58 [sunrpc]
     [<ffffffffa021c4a5>] ? rpc_create+0x481/0x4fc [sunrpc]
     [<ffffffffa022298a>] ? rpcauth_lookup_credcache+0xab/0x22d [sunrpc]
     [<ffffffffa028be8c>] ? nfs_create_rpc_client+0xa6/0xeb [nfs]
     [<ffffffffa028c660>] ? nfs4_set_client+0xc2/0x1f9 [nfs]
     [<ffffffffa028cd3c>] ? nfs4_create_server+0xf2/0x2a6 [nfs]
     [<ffffffffa0295d07>] ? nfs4_remote_mount+0x4e/0x14a [nfs]
     [<ffffffff810dd570>] ? vfs_kern_mount+0x6e/0x133
     [<ffffffffa029605a>] ? nfs_do_root_mount+0x76/0x95 [nfs]
     [<ffffffffa029643d>] ? nfs4_try_mount+0x56/0xaf [nfs]
     [<ffffffffa0297434>] ? nfs_get_sb+0x435/0x73c [nfs]
     [<ffffffff810dd59b>] ? vfs_kern_mount+0x99/0x133
     [<ffffffff810dd693>] ? do_kern_mount+0x48/0xd8
     [<ffffffff810f5b75>] ? do_mount+0x6da/0x741
     [<ffffffff810f5c5f>] ? sys_mount+0x83/0xc0
     [<ffffffff8100293b>] ? system_call_fastpath+0x16/0x1b
    
    Well, so, I think this is real bug of nfs codes somewhere. With some
    review, the code
    
    rpc_call_sync()
        rpc_run_task
            rpc_execute()
                __rpc_execute()
                    rpc_release_task()
                        rpc_release_resources_task()
                            put_rpccred()                <= release cred
        rpc_put_task
            rpc_do_put_task()
                rpc_release_resources_task()
                    put_rpccred()                        <= release cred again
    
    seems to be release cred unintendedly.
    
    Signed-off-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a0e7e3cf7932d6c77de0dc79a40dbaeb8060b544
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sat Mar 26 02:24:35 2011 -0400

    NFS: Don't leak RPC clients in NFSv4 secinfo negotiation
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4d65c520fb4abed970069d18c119cfe85624f46d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Mar 25 14:15:11 2011 -0400

    NFS: Fix a hang in the writeback path
    
    Now that the inode scalability patches have been merged, it is no longer
    safe to call igrab() under the inode->i_lock.
    Now that we no longer call nfs_clear_request() until the nfs_page is
    being freed, we know that we are always holding a reference to the
    nfs_open_context, which again holds a reference to the path, and so
    the inode cannot be freed until the last nfs_page has been removed
    from the radix tree and freed.
    
    We can therefore skip the igrab()/iput() altogether.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

