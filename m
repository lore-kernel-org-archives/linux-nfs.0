From: "fj-shic" <shic@np.css.fujitsu.com>
Subject: Re: [Patch][NFSv4]: Kernel panic (handle kernel NULL
	pointer)occurred in NFSv4 by the nfs_update_inode()
Date: Mon, 29 Jan 2007 10:52:44 +0900
Message-ID: <01b401c74348$2b965fd0$adb1220a@shic>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: linux-kernel@vger.kernel.org
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBLhd-0003A9-31
	for nfs@lists.sourceforge.net; Sun, 28 Jan 2007 17:53:01 -0800
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBLhc-00059q-Pt
	for nfs@lists.sourceforge.net; Sun, 28 Jan 2007 17:53:03 -0800
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id
	l0T1qph1028934
	for <nfs@lists.sourceforge.net> (envelope-from shic@np.css.fujitsu.com);
	Mon, 29 Jan 2007 10:52:51 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A13121B801F
	for <nfs@lists.sourceforge.net>; Mon, 29 Jan 2007 10:52:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7564F2DC081
	for <nfs@lists.sourceforge.net>; Mon, 29 Jan 2007 10:52:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1 [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DE44133C01D
	for <nfs@lists.sourceforge.net>; Mon, 29 Jan 2007 10:52:51 +0900 (JST)
Received: from ml0a.s.css.fujitsu.com (ml0a.s.css.fujitsu.com [10.23.4.189])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E917D133C018
	for <nfs@lists.sourceforge.net>; Mon, 29 Jan 2007 10:52:50 +0900 (JST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi, all

   Is there any good idea about this issue?
   I really think this is a problem in the NFSv4, which should be resolved =

in the latest kernel.

   Thank you for any information on this issue.

> Hi, all
>
>  I have been working on trying to evaluate the robustness of the NFS.
>  When I run the files creating test on NFSv4, the kernel panic (handle
> kernel NULL pointer) happened during the test when
> the /proc/sys/sunrpc/nfs_debug was set to 65535.
>
> The test I run is:
>   Mount:
>       mount -t nfs4  192.168.0.21:/  /mnt
>   Test script:
>         A process creates and opens 1024 files on NFSv4
>         The process writes some test message to each file.
>         The process closes all the opening files and exit.
>         After the process exit, the test begins to umount the NFSv4
> immediately.
>
> In normal case, I haven't found the problem in the test; but when
> the /proc/sys/sunrpc/nfs_debug is set to debug mode(65535), the panic
> problem will usually happens.
>
> The kernel panic log is as follows:
>
> NFS: nfs_update_inode(0:18/2049980 ct=3D1 info=3D0xe)
> BUG: unable to handle kernel NULL pointer dereference at virtual address
> 0000000c
> printing eip: deb82605
> *pde =3D 001f3067
> Oops: 0000 [#1]
> SMP
> last sysfs file: /block/hda/removable
> Modules linked in: nfs fscache nfsd =A1=AD. =A1=AD=A1=AD.
> CPU:    0
> EIP:    0060:[<deb82605>]    Not tainted VLI
> EFLAGS: 00010246   (2.6.18-1.2747.el5 #1)
> EIP is at nfs_update_inode+0xb0/0x692 [nfs]
> =A1=ADskip=A1=AD.
> Process rpciod/0 (pid: 1865, ti=3Ddd3ac000 task=3Dddd47550 task.ti=3Ddd3a=
c000)
> Stack: deba0609 =A1=AD =A1=AD
> Call Trace:
> [<deb82c1f>] nfs_refresh_inode+0x38/0x1b0 [nfs]
> [<dea9f602>] rpc_exit_task+0x1e/0x6c [sunrpc]
> [<dea9f314>] __rpc_execute+0x82/0x1b3 [sunrpc]
> [<c0433899>] run_workqueue+0x83/0xc5
> [<c0434171>] worker_thread+0xd9/0x10c
> [<c0436620>] kthread+0xc0/0xec
> [<c0404d63>] kernel_thread_helper+0x7/0x10
> DWARF2 unwinder stuck at kernel_thread_helper+0x7/0x10
>
> I have investigated the problem, and found the cause was the NULL
> pointer i_sb->s_root in the "nfs_update_inode()" when the panic
> happened.
>
>  In the kernel, at the end of the file closing operation, the
> nfs_file_release() will be invoked.
>
>  I have found the operation process of the kernel is as follows:
>  nfs_file_release()
>       |-- NFS_PROTO(inode)->file_release ()
>             |
>           nfs_file_clear_open_context()
>             |
>            put_nfs_open_context()
>               | -- nfs4_close_state
>               |       | -- nfs4_close_ops
>               |                 |
>               |               nfs4_do_close()
>               |                  |
>               |                 nfs_update_inode()
>               |                        |-- inode =3D=3D inode->i_sb-
>>s_root->d_inode
>               |
>               | -- mntput(ctx_vfsmnt)
>                      |
>                     atomic_dec_and_lock(&mnt->mnt_count,
> &vfsmount_lock)
>
> After the asynchronous RPC call "nfs4_close_ops" is invoked in
> put_nfs_open_context(), the kernel invokes the mntput(), and the mnt-
>>mnt_count is decreased. In my test, after the file closing operation,
> the sys_umont() was executed immediately. In normal case, the
> asynchronous RPC call "nfs4_close_ops" can be completed quickly, and it
> rarely ever happens that the sys_umount() is invoked before the end of
> nfs_update_inode() operation. But when the sunrpc/nfs_debug is set to
> debug mode, a lot of printk operations will be invoked in NFS. Due to
> the lots of prink operations, the RPC call "nfs4_close_ops" will easily
> be delayed, then it is possible that the sys_umount() is invoked before
> the end of nfs_update_inode() operation. In the do_umont() (Because mnt-
>>mnt_count has been decreased, umount can be executed successfully), the
> sb->s_root will be set to NULL in the shrink_dcache_for_umount () which
> is invoked by the nfs_kill_super().
> Therefore, kernel panic occurred by the NULL pointer access when
> nfs_update_date() accessed inode->i_sb->s_root.
>
> Because there is a possibility that sb->s_root of a super_block is set
> to NULL with umount when nfs4_close_ops () is not finished in the NFS.
> It is really necessary to check an empty pointer for the inode->i_sb-
>>s_root in the nfs_update_date().
>
> This problem still exists in the latest linux kernel.
> To resolve this problem, I have made the patch below for the
> linux-2.6.19.2. After the patch is applied, the problem can be resolved.
> signed-off-by:ShiChao <shic@nanjing-fnst.com>
>
> --- old/fs/nfs/inode.c 2007-01-17 17:19:48.994020288 -0500
> +++ new/fs/nfs/inode.c 2007-01-17 17:20:26.570307824 -0500
> @@ -914,7 +914,7 @@
>
>  server =3D NFS_SERVER(inode);
>  /* Update the fsid if and only if this is the root directory */
> - if (inode =3D=3D inode->i_sb->s_root->d_inode
> + if ( inode->i_sb->s_root && inode =3D=3D inode->i_sb->s_root->d_inode
>  && !nfs_fsid_equal(&server->fsid, &fattr->fsid))
>  server->fsid =3D fattr->fsid;
>
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
