From: Andrew Ryan <andrewr@nam-shub.com>
Subject: v3/tcp mounts occasionally hang for 10+ minutes
Date: Tue, 02 Apr 2002 00:09:41 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20020401235131.0285bb00@pop.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Received: from moe.sfrn.dnai.com ([208.59.199.25])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16sJLh-0003ik-00
	for <nfs@lists.sourceforge.net>; Tue, 02 Apr 2002 00:09:01 -0800
Received: from sideshow-mel.sfrn.dnai.com (sideshow-mel.sfrn.dnai.com [208.59.199.19])
	by moe.sfrn.dnai.com (8.11.2/8.11.2) with ESMTP id g3286Ww19728
	for <nfs@lists.sourceforge.net>; Tue, 2 Apr 2002 00:06:32 -0800 (PST)
Received: from wangchung.nam-shub.com (208-59-198-138.s138.tnt1.dsfr.ca.dialup.rcn.com [208.59.198.138])
	by sideshow-mel.sfrn.dnai.com (8.11.3/8.11.3) with ESMTP id g3283od70439
	for <nfs@lists.sourceforge.net>; Tue, 2 Apr 2002 00:03:50 -0800 (PST)
	(envelope-from andrewr@nam-shub.com)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Linux client running 2.4.17+NFS_ALL patch set mounting a netapp server (via 
switched 100FDx ethernet) with the following mount opts:
rw,tcp,nfsvers=3,rsize=32768,wsize=32768,intr,hard

Works great, but occasionally (every few days) the mount hangs, for about 
10 minutes each time. I am not exactly sure what causes the hung mounts but 
at times it has seemed to correlate with the machine running very low on 
virtual memory and the kernel interceding to kill processes. Other times 
this has not seemed to be the case. Either way, it doesn't seem like 
something which should be happening.

Eventually, after ~10 minutes, the mount does come back, but in the 
meantime this causes some havoc. Several of the following messages are 
written to console:
nfs_statfs: statfs error = 512

Interestingly enough, during the time when the hang occurs, other NFS 
mounts on this client from the same server work just fine. And 
rpcinfo/showmount/etc against the server from the client all work just fine 
during the time when the mount is hung.

My questions:
1) Anyone know what the hung mount behavior could be triggered and/or how 
to prevent it?
2) If the hung mount behavior couldn't be prevented, could it at least be 
mitigated somehow by lowering some timeout to a time less than 10 minutes? 
Clients can forgive 30 seconds. But a hang of 10 minutes is sure to 
generate help desk calls.


andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
