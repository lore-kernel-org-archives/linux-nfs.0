From: Narayan Desai <desai@mcs.anl.gov>
Subject: odd kernel-nfs-server messages
Date: Tue, 06 Nov 2007 22:21:25 -0600
Message-ID: <87fxzi1y9m.fsf@mcs.anl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpcPz-0005Se-Km
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 20:21:31 -0800
Received: from mailgw.mcs.anl.gov ([140.221.9.4])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpcQ3-0007mA-2c
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 20:21:37 -0800
Received: from localhost (localhost [127.0.0.1])
	by mailgw.mcs.anl.gov (Postfix) with ESMTP id 8A9F1348003
	for <nfs@lists.sourceforge.net>; Tue,  6 Nov 2007 22:21:28 -0600 (CST)
Received: from ubik.topaz.mcs.anl.gov (c-24-14-94-248.hsd1.il.comcast.net
	[24.14.94.248])
	by mailgw.mcs.anl.gov (Postfix) with ESMTP id 9982F348002
	for <nfs@lists.sourceforge.net>; Tue,  6 Nov 2007 22:21:25 -0600 (CST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

We are running into some kernel nfs server errors that we are having
trouble deciphering. 

We are running a x86_64 nfs server. The server is running ubuntu
feisty, with their 2.6.20-16-generic kernel. 

The clients are also running linux (2.6.15 kernel; we are waiting on
the system vendor to finish their port to a newer kernel) on mips64. 

Under fairly heavy load (400-800 clients, not a ton of reads and
writes) we get the following messages:

[1724467.119033] RPC: bad TCP reclen 0x337e08af (large)
[1738771.833213] RPC: bad TCP reclen 0x00000014 (non-terminal)
[1738801.224098] RPC: bad TCP reclen 0x6d346e31 (non-terminal)
[1738965.738860] RPC: bad TCP reclen 0x6d376e39 (non-terminal)
[1739183.459936] RPC: bad TCP reclen 0x342e7363 (non-terminal)
[1739295.006403] RPC: bad TCP reclen 0x73797374 (non-terminal)
[1739383.784788] RPC: bad TCP reclen 0x00000003 (non-terminal)
[1739554.244212] RPC: bad TCP reclen 0x00000001 (non-terminal)
[1740372.230510] RPC: bad TCP reclen 0x3f010080 (non-terminal)
[1740573.448297] RPC: bad TCP reclen 0x79737465 (non-terminal)
[1740692.060794] RPC: bad TCP reclen 0x08190080 (large)
[1740695.795910] RPC: bad TCP reclen 0x656d0000 (non-terminal)
[1741125.251753] RPC: bad TCP reclen 0x000186a3 (non-terminal)
[1741135.467912] RPC: bad TCP reclen 0x00000002 (non-terminal)
[1741138.612606] RPC: bad TCP reclen 0x3f010080 (non-terminal)
[1741170.087073] RPC: bad TCP reclen 0x00000000 (non-terminal)
[1741529.390769] RPC: bad TCP reclen 0x20202049 (non-terminal)
[1741765.178189] rpc-srv/tcp: nfsd: sent only 12420 when sending 32900 bytes - shutting down socket
[1741929.170146] rpc-srv/tcp: nfsd: sent only 4228 when sending 32900 bytes - shutting down socket
[1741929.170162] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1741929.172954] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1741929.172983] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1741993.882718] rpc-srv/tcp: nfsd: sent only 24708 when sending 32900 bytes - shutting down socket
[1741993.882733] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1741993.882750] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1743013.356969] rpc-srv/tcp: nfsd: sent only 20612 when sending 32900 bytes - shutting down socket
[1743013.356990] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1743013.357007] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1743132.799893] RPC: bad TCP reclen 0x20312e35 (non-terminal)
[1743156.085226] RPC: bad TCP reclen 0x302e3030 (non-terminal)
[1743178.527927] RPC: bad TCP reclen 0x30452b30 (non-terminal)
[1743302.061768] RPC: bad TCP reclen 0x30303030 (non-terminal)
[1743325.774782] rpc-srv/tcp: nfsd: sent only 25496 when sending 32900 bytes - shutting down socket
[1743325.776326] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1743332.191913] RPC: bad TCP reclen 0x30303020 (non-terminal)
[1743396.683214] rpc-srv/tcp: nfsd: sent only 16516 when sending 32900 bytes - shutting down socket
[1743400.329696] rpc-srv/tcp: nfsd: sent only 12420 when sending 32900 bytes - shutting down socket
[1743400.329715] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1743400.329741] rpc-srv/tcp: nfsd: got error -32 when sending 32900 bytes - shutting down socket
[1743415.486338] rpc-srv/tcp: nfsd: sent only 24708 when sending 32900 bytes - shutting down socket
[1743421.714057] svc: bad direction -2147483528, dropping request
[1743421.763703] RPC: bad TCP reclen 0x001a8000 (non-terminal)
[1743465.969286] rpc-srv/tcp: nfsd: sent only 20612 when sending 32900 bytes - shutting down socket
[1743470.886759] rpc-srv/tcp: nfsd: sent only 16516 when sending 32900 bytes - shutting down socket

The system is on the other side of a gigabit attached gateway, and we
are only seeing between 20-30 mbps of traffic through the
gateway. Also, we are mounting the filesystem with tcp,hard,intr.

Can anyone explain what is going on here? 
Thanks in advance.
 -nld

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
