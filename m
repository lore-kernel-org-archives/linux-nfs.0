From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: NULL pointer dereference when a process is exited while
	holding	delegations
Date: Fri, 02 Mar 2007 15:50:35 -0800
Message-ID: <1172879435.19257.1.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HNHWZ-0007AM-RI
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 15:50:56 -0800
Received: from e4.ny.us.ibm.com ([32.97.182.144])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HNHWa-0002t2-Iv
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 15:50:57 -0800
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l22NntB5004761
	for <nfs@lists.sourceforge.net>; Fri, 2 Mar 2007 18:49:55 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l22NmtkL287828
	for <nfs@lists.sourceforge.net>; Fri, 2 Mar 2007 18:48:55 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l22Nmtl9009913
	for <nfs@lists.sourceforge.net>; Fri, 2 Mar 2007 18:48:55 -0500
Received: from [9.47.22.153] (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	l22Nmslj009900
	for <nfs@lists.sourceforge.net>; Fri, 2 Mar 2007 18:48:55 -0500
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

I am seeing an exception with a NULL pointer with the following stack
(on a 2.6.9 kernel):

Stack:
_spin_lock_irq+0x28/0x8c
sigprocmask+0x44/0xe8
rpc_save_sigmask+0x3c/0x50 [sunrpc]
rpc_call_sync+0x74/0xf0 [sunrpc]
_nfs4_proc_getattr+0x9c/0xc0 [nfs]
nfs4_proc_getattr+0x40/0x7c [nfs]
__nfs_revalidate_inode+0x190/0x354 [nfs]
nfs_do_return_delegation+0x34/0x74 [nfs]
__nfs_inode_return_delegation+0x1cc/0x210 [nfs]
nfs_dentry_iput+0x3c/0x100 [nfs]
prune_dcache+0x490/0x5c0
shrink_dcache_parent+0x20/0x44
proc_pid_flush+0x40/0x68
release_task+0x160/0x1d4
exit_notify+0x394/0x3c4
do_exit+0x6fc/0x748
next_thread+0x0/0x50
syscall_exit+0x0/0x18

What seems to be happening is that release_task has done
__exit_sighand(p), which sets current->sighand to NULL. Then the dcache
is pruned, and eventually a delegation is to be returned. This makes an
RPC call which then ends up calling sigprocmask, which calls
spin_lock_irq(&current->sighand->siglock), resulting in the NULL pointer
dereference.

Has this problem been seen before? If not, any ideas on how to make sure
no RPC calls get made after the sighand is set to NULL?

Thanks for any thoughts,

Frank Filz



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
