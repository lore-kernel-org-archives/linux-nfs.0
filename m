From: Marten Lehmann <lehmann@cnm.de>
Subject: RPC Error: 15 ( Program not registered )
Date: Tue, 14 Jun 2005 22:50:09 +0200
Message-ID: <42AF4301.9020208@cnm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiIMH-0006w8-R7
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 13:50:05 -0700
Received: from relay1.mail.vrmd.de ([81.28.232.18])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DiIMH-00005v-46
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 13:50:05 -0700
Received: from [84.59.51.139] (helo=[192.168.33.66])
	by vm8.bln2.vrmd.de with asmtp (Exim 4.41)
	id 1DiIMH-0000y5-C4
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 22:50:05 +0200
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

Hello,

I'm experiencing exactly the problem as described at 
http://nfs.sourceforge.net/nfs-howto/troubleshooting.html

7.3b:  RPC: Program Not Registered: (or another "RPC" error)

The nfs server is running with version 3, the client has version 4.

rpcinfo -p on the server gives:

    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100011    1   udp    604  rquotad
     100011    2   udp    604  rquotad
     100011    1   tcp    607  rquotad
     100011    2   tcp    607  rquotad
     100021    1   udp  32770  nlockmgr
     100021    3   udp  32770  nlockmgr
     100021    4   udp  32770  nlockmgr
     100021    1   tcp  33302  nlockmgr
     100021    3   tcp  33302  nlockmgr
     100021    4   tcp  33302  nlockmgr
     100005    1   udp    620  mountd
     100005    1   tcp    623  mountd
     100005    2   udp    620  mountd
     100005    2   tcp    623  mountd
     100005    3   udp    620  mountd
     100005    3   tcp    623  mountd

rpcinfo -p 192.168.33.53 from the client gives:

    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100011    1   udp    604  rquotad
     100011    2   udp    604  rquotad
     100011    1   tcp    607  rquotad
     100011    2   tcp    607  rquotad
     100021    1   udp  32770  nlockmgr
     100021    3   udp  32770  nlockmgr
     100021    4   udp  32770  nlockmgr
     100021    1   tcp  33302  nlockmgr
     100021    3   tcp  33302  nlockmgr
     100021    4   tcp  33302  nlockmgr
     100005    1   udp    620  mountd
     100005    1   tcp    623  mountd
     100005    2   udp    620  mountd
     100005    2   tcp    623  mountd
     100005    3   udp    620  mountd
     100005    3   tcp    623  mountd

For debugging, I disabled all firewalls. However, mounting is not 
successful:

# mount -t nfs 192.168.33.53:/vrmd/rhel4 /mnt -v
mount to NFS server '192.168.33.53' failed.
RPC Error: 15 ( Program not registered )

# mount -t nfs -o vers=3 192.168.33.53:/vrmd/rhel4 /mnt -v
mount to NFS server '192.168.33.53' failed.
RPC Error: 15 ( Program not registered )

What can I do? The Troubleshooting-Page reports the problem, but does 
explain how to solve the issue. Any ideas, what causes this problem?

Regards
Marten


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
