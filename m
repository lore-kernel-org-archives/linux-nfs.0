From: Mike Waychison <michael.waychison@sun.com>
Subject: [PATCH 0/2] [RFC] Making mount operation soft + intr
Date: Thu, 9 Dec 2004 16:22:36 -0500
Message-ID: <11026273562@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcVkR-0008Id-3i
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:22:51 -0800
Received: from ip22-176.tor.istop.com
	([66.11.176.22] helo=crlf.tor.istop.com ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcVkN-00050p-LG
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:22:51 -0800
Received: from localhost (belle.christiehouse.net [127.0.0.1])
	by crlf.tor.istop.com (Postfix) with ESMTP id 4E3C4D379
	for <nfs@lists.sourceforge.net>; Thu,  9 Dec 2004 16:33:09 -0500 (EST)
Received: from crlf.tor.istop.com ([127.0.0.1])
	by localhost (belle [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 23560-01 for <nfs@lists.sourceforge.net>;
	Thu, 9 Dec 2004 16:33:04 -0500 (EST)
Received: from lapdance (unknown [192.168.4.103])
	by crlf.tor.istop.com (Postfix) with SMTP id A4C2FD36A
	for <nfs@lists.sourceforge.net>; Thu,  9 Dec 2004 16:33:04 -0500 (EST)
To: nfs@lists.sourceforge.net
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

While implementing and testing autofsng, I found myself getting frustrated at
NFS mounts that fail and stay hung.

A typical example is to try and mount from a bogus NFS port:

mount -o port=10000 host:/export /mnt

If the default is hard, the kernel will never time out trying to get initial
contact with the server.

If the default is nointr, then there is no way for userspace to kill the mount
process.

Both of these options make sense while the filesystem is mounted, but in the
case where the server will never respond with a live nfs export, can easily
hang processes and leave locked super_block's live in the system (impeding a
reboot).

The solution I am suggesting is to force the initial rpc calls used in setting
up a mount to be soft + intr, regardless of what the real options are.  We can
do this by passing RPC_TASK_SOFT to the rpc_calls for NFS3PROC_FSINFO,
NFS3PROC_GETATTR, NFSPROC_GETATTR and NFSPROC_STATFS.

To force 'intr' regardless of whether clnt->cl_intr is set or not, we use a
similar technique to the recently added RPC_TASK_NOINTR flag used for
transaction integrity.  We introduce RPC_TASK_FORCEINTR, which overrides
RPC_TASK_NOINTR (the latter is dependent on clnt->cl_intr).

AFAICT, making these ops soft+intr is safe because there is no data to be lost
in the event of a cancelled/timed-out operation.

The first patch following this message adds RPC_TASK_FORCEINTR and makes the
rootfh ops use it and RPC_TASK_SOFT.

The second patch adds a parameter to rpc_clnt_sigmask that takes an optional
set of task flags, of which only RPC_TASK_FORCEINTR is inspected for.  This
keeps the mount paths from blocking signals SIGINT and SIGQUIT.

mount(8) still needs to be taught not to block these signals if it doesn't care
whether the mount operation succeeded or not (in the case of it not being a
loop device and mtab isn't being updated).

(I haven't touched the nfsv4 stuff as I haven't yet wrapped my head around that
code.)

Comments?



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
