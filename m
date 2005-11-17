From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] spinlock recursion on inode number mismatches
Date: Thu, 17 Nov 2005 14:34:32 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E2013327C0@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <NFS@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: "Steve Dickson" <SteveD@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> When compiling over NFS using a 2.6.14 kernel, the following
> spinlock recursion BUG popped:
>=20
> nfs_update_inode: inode number mismatch
> expected (0:16/0x1dee71a), got (0:16/0x100000000000000)
> nfs_update_inode: inode number mismatch
> expected (0:16/0x1dee71a), got (0:16/0x1dee719)
> nfs_update_inode: inode number mismatch
> expected (0:16/0x1dee71a), got (0:16/0x0)
> nfs_update_inode: inode number mismatch
> expected (0:16/0x1dee71a), got (0:16/0x1dee719)
> BUG: spinlock recursion on CPU#0, bhc/22635 (Not tainted)
>   lock: db7294e8, .magic: dead4ead, .owner: bhc/22635, .owner_cpu: 0
>   [<c01f53b3>] spin_bug+0xa3/0xd7
>   [<c01f551e>] _raw_spin_lock+0x68/0x6a
>   [<f8db1151>] nfs_zap_caches+0x1a/0xaa [nfs]
>   [<f8db2445>] nfs_update_inode+0x9f/0x618 [nfs]
>   [<c033be8c>] _spin_unlock_irq+0x5/0x7
>   [<f8db236b>] nfs_post_op_update_inode+0x2c/0x67 [nfs]
>   [<f8dba716>] nfs3_proc_remove+0x9e/0xd7 [nfs]
>   [<f8daed5a>] nfs_safe_remove+0x68/0xc4 [nfs]
>   [<f8daee5e>] nfs_unlink+0xa8/0x10e [nfs]
>   [<c017c8df>] vfs_unlink+0x19f/0x1a6
>   [<c017c9a3>] sys_unlink+0xbd/0x13e
>   [<c033cee2>] do_page_fault+0x262/0x650
>   [<c016cb1d>] do_sync_read+0x0/0x116
>   [<c01040a5>] syscall_call+0x7/0xb
> Kernel panic - not syncing: bad locking
>   [<c01250a8>] panic+0x45/0x1c5
>   [<c01f53e7>] __spin_lock_debug+0x0/0xcf
>   [<c01f551e>] _raw_spin_lock+0x68/0x6a
>   [<f8db1151>] nfs_zap_caches+0x1a/0xaa [nfs]
>   [<f8db2445>] nfs_update_inode+0x9f/0x618 [nfs]
>   [<c033be8c>] _spin_unlock_irq+0x5/0x7
>   [<f8db236b>] nfs_post_op_update_inode+0x2c/0x67 [nfs]
>   [<f8dba716>] nfs3_proc_remove+0x9e/0xd7 [nfs]
>   [<f8daed5a>] nfs_safe_remove+0x68/0xc4 [nfs]
>   [<f8daee5e>] nfs_unlink+0xa8/0x10e [nfs]
>   [<c017c8df>] vfs_unlink+0x19f/0x1a6
>   [<c017c9a3>] sys_unlink+0xbd/0x13e
>   [<c033cee2>] do_page_fault+0x262/0x650
>   [<c016cb1d>] do_sync_read+0x0/0x116
>   [<c01040a5>] syscall_call+0x7/0xb
>=20
> The attached patch solve the problem by the problem by moving
> the call to nfs_invalidate_inode() out of nfs_invalidate_inode().

steve-

can you send a diagram of the lock recursion you see?


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
