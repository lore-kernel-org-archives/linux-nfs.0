From: Marc Eshel <eshel@almaden.ibm.com>
Subject: lockd recovery not working on RH with 2.6 kernel
Date: Thu, 11 Nov 2004 11:12:49 -0800
Message-ID: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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





The problem is that after the NFS sever machine reboots its statd sends a
notification to all NFS clients that had locking activity but the clients
fail to reclaim their locks.

I tried it with RedHat ES, 2.6.8 kernel, and nfs utils 1.0.6; and also with
RedHat Fedora, 2.6.5 kernel and nfs utils 1.0.6

It did work when I mount with '-o nfsvers=2' which used lockd version 1
instead of lockd version 4

Here is the debug messages on the NFS client:
      The debug messages with 'xxx' were added by me.
      as you can see in the 4th line the protocol and version are both 0
(p=0, v=0)
      in the following 2 lines you can see valid protocol and version
      but because the don't match with the input protocol and version the
host
      is not found and the client will not claim its locks.

Nov 11 11:35:03 hiper53 kernel: lockd: request from 7f000001
Nov 11 11:35:03 hiper53 kernel: lockd: nlmsvc_dispatch vers 4 proc 16
Nov 11 11:35:03 hiper53 kernel: lockd: SM_NOTIFY     called
Nov 11 11:35:03 hiper53 kernel: lockd: nlm_lookup_host(09018c42, p=0, v=0)
Nov 11 11:35:03 hiper53 kernel: lockd: xxx1 nlm_lookup_host(server 0 s=0
p=17, v=4)
Nov 11 11:35:03 hiper53 kernel: lockd: xxx2 nlm_lookup_host(server 0 s=0
p=17, v=1)
Nov 11 11:35:03 hiper53 kernel: lockd: creating host entry
Nov 11 11:35:03 hiper53 kernel: lockd: rebind host 9.1.140.66
Nov 11 11:35:03 hiper53 kernel: NLM: reclaiming locks for host 9.1.140.66
lockd: xxx2 nlmclnt_recovery h_reclaiming 1
Nov 11 11:35:03 hiper53 kernel: lockd: get host 9.1.140.66
Nov 11 11:35:03 hiper53 kernel: lockd: release host 9.1.140.66
Nov 11 11:35:03 hiper53 kernel: nlmsvc_retry_blocked(00000000, when=0)
Nov 11 11:35:03 hiper53 kernel: nlmsvc_retry_blocked(00000000, when=0)
Nov 11 11:35:03 hiper53 kernel: lockd: xxx3 reclaimer start
Nov 11 11:35:03 hiper53 kernel: lockd: xxx4 reclaimer magic 6969 6969
Nov 11 11:35:03 hiper53 kernel: lockd: xxx5 reclaimer host
f7d43d00(9.1.140.66) f744bb80(9.1.140.66)
Nov 11 11:35:04 hiper53 kernel: lockd: release host 9.1.140.66




-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
