From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs client process/rpciod deadlock
Date: Thu, 25 Sep 2003 09:24:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113D06D2D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2Yvb-0001Dj-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 09:25:15 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2Yva-000636-Fl
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 09:25:14 -0700
To: "David Jeffery" <david_jeffery@adaptec.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

these processes are not deadlocked; they are merely waiting
for I/O to complete.  there may be a deadlock elsewhere, or
they may be waiting for a reply that never arrived.

what are your NFS mount options?  output from "nfsstat"?
as an experiment, if you use the "soft" mount option, does
the problem go away?



> Please CC: me as I am not subscribed to this list.
>=20
> I have a problem with processes hanging in D state on a linux nfs
> client.  Both linux client and server are stock kernel.org 2.4.22
> kernels with no extra drivers or patches.  This problem is not new and
> exists on older kernel.org and red hat kernels I have used.
>=20
> The full setup is a smp linux nfs server, linux nfs client, and a few
> other unix clients.  Both linux systems have kernels without highmem.=20
> The problem occurs with both SMP and UP kernels on the client.  When
> placed under load, the linux client will periodically get processes
> stuck in D state.  The processes stuck in D state will be one or more=20
> work processes and rpciod.
>=20
> Using sysrq-T to show state shows the deadlocked processes to=20
> be waiting
> on a locked page in ___wait_on_page. (I have the full show state if
> someone wants to see it.)
>=20
>=20
> rpciod        D F7FBF0A0  4468   749 1           777   750 (L-TLB)
> Call Trace:   =20
> [___wait_on_page+158/192]
> [truncate_list_pages+387/464]
> [e100:e100_manage_adaptive_ifs+753/816]
> [truncate_inode_pages+94/112]
> [iput+201/544]
> [nfs3_xdr_commitres+173/224]
> [nfs_commit_done+550/1072]
> [nfs3_xdr_commitres+0/224]
> [__rpc_execute+554/688]
> [schedule+756/800]
> [__rpc_schedule+179/288]
> [rpciod+184/496]
> [arch_kernel_thread+38/64]
> [rpciod+0/496]
>=20
>=20
> javac         D F33D5D40     0  3830   3829  3833            =20
>   (NOTLB)
> Call Trace:   =20
> [___wait_on_page+158/192]
> [do_generic_file_read+756/1088]
> [generic_file_read+137/352]
> [file_read_actor+0/176]
> [nfs_file_read+146/160]
> [sys_read+152/240]
> [system_call+51/64]
>=20
> cp            D F33D5DC0     0  3915   3525                  =20
>   (NOTLB)
> Call Trace:   =20
> [___wait_on_page+158/192]
> [do_generic_file_read+756/1088]
> [generic_file_read+137/352]
> [file_read_actor+0/176]
> [nfs_file_read+146/160]
> [sys_read+152/240]
> [system_call+51/64]
>=20
> Is this related to the comment in fs/nfs/write.c or is this a=20
> different
> race condition?
>=20
> /*
>  * Update attributes as result of writeback.
>  * FIXME: There is an inherent race with invalidate_inode_pages and
>  *        writebacks since the page->count is kept > 1 for as long
>  *        as the page has a write request pending.
>  */
>=20
> I'd be happy to test patches.  It can take up to a week for=20
> the problem
> to occur but it has become more frequent with the loads we're=20
> putting on
> the machine.
>=20
> David Jeffery
>=20
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
