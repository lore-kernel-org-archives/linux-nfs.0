From: David Jeffery <david_jeffery@adaptec.com>
Subject: nfs client process/rpciod deadlock
Date: 24 Sep 2003 07:40:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1064403611.620.168.camel@blackmagic>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A27yu-0005vv-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 04:38:52 -0700
Received: from magic-mail.adaptec.com ([216.52.22.10] helo=magic.adaptec.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A27yt-000523-RN
	for nfs@lists.sourceforge.net; Wed, 24 Sep 2003 04:38:51 -0700
Received: from redfish.adaptec.com (redfish.adaptec.com [162.62.50.11])
	by magic.adaptec.com (8.11.6/8.11.6) with ESMTP id h8OBcLR10823
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 04:38:21 -0700
Received: from rtpexc01.adaptec.com (rtpexc01.adaptec.com [10.110.12.22])
	by redfish.adaptec.com (8.8.8p2+Sun/8.8.8) with ESMTP id EAA15799
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 04:38:20 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

Please CC: me as I am not subscribed to this list.

I have a problem with processes hanging in D state on a linux nfs
client.  Both linux client and server are stock kernel.org 2.4.22
kernels with no extra drivers or patches.  This problem is not new and
exists on older kernel.org and red hat kernels I have used.

The full setup is a smp linux nfs server, linux nfs client, and a few
other unix clients.  Both linux systems have kernels without highmem. 
The problem occurs with both SMP and UP kernels on the client.  When
placed under load, the linux client will periodically get processes
stuck in D state.  The processes stuck in D state will be one or more 
work processes and rpciod.

Using sysrq-T to show state shows the deadlocked processes to be waiting
on a locked page in ___wait_on_page. (I have the full show state if
someone wants to see it.)


rpciod        D F7FBF0A0  4468   749 1           777   750 (L-TLB)
Call Trace:    
[___wait_on_page+158/192]
[truncate_list_pages+387/464]
[e100:e100_manage_adaptive_ifs+753/816]
[truncate_inode_pages+94/112]
[iput+201/544]
[nfs3_xdr_commitres+173/224]
[nfs_commit_done+550/1072]
[nfs3_xdr_commitres+0/224]
[__rpc_execute+554/688]
[schedule+756/800]
[__rpc_schedule+179/288]
[rpciod+184/496]
[arch_kernel_thread+38/64]
[rpciod+0/496]


javac         D F33D5D40     0  3830   3829  3833               (NOTLB)
Call Trace:    
[___wait_on_page+158/192]
[do_generic_file_read+756/1088]
[generic_file_read+137/352]
[file_read_actor+0/176]
[nfs_file_read+146/160]
[sys_read+152/240]
[system_call+51/64]

cp            D F33D5DC0     0  3915   3525                     (NOTLB)
Call Trace:    
[___wait_on_page+158/192]
[do_generic_file_read+756/1088]
[generic_file_read+137/352]
[file_read_actor+0/176]
[nfs_file_read+146/160]
[sys_read+152/240]
[system_call+51/64]

Is this related to the comment in fs/nfs/write.c or is this a different
race condition?

/*
 * Update attributes as result of writeback.
 * FIXME: There is an inherent race with invalidate_inode_pages and
 *        writebacks since the page->count is kept > 1 for as long
 *        as the page has a write request pending.
 */

I'd be happy to test patches.  It can take up to a week for the problem
to occur but it has become more frequent with the loads we're putting on
the machine.

David Jeffery



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
