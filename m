From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: fsstress : bug with new patches.
Date: Tue, 8 Mar 2005 15:52:08 +0100
Message-ID: <200503081552.08168.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8fyy-0001Yv-KC
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 06:46:48 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8fyw-0000IV-9X
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 06:46:48 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id C1A0719D91A
	for <nfs@lists.sourceforge.net>; Tue,  8 Mar 2005 15:46:12 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 10612-05 for <nfs@lists.sourceforge.net>;
 Tue,  8 Mar 2005 15:46:10 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id AC77419D913
	for <nfs@lists.sourceforge.net>; Tue,  8 Mar 2005 15:46:10 +0100 (CET)
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

Hello all,


Running nfs_stress during half hour.
-With 2 process, 1000 operation list lenght
-> All is OK (great, better than last week)

With 10 process, 1000 operation list lenght
After 20minutes I got this message (server):
Mar  8 15:30:54 fastboot kernel: NFSD: Failed to remove expired client state 
directory 0803d019e0740dee6ad38414c44805c4 from /var/lib/nfs/v4recovery

fs_stress client are blocked (I can not kill it)

I note that some operation are going slower while fs_stress is running and 
path lenght is growing.
-open_path
-creat_f
-creat_path

After 20 minutes fs_stress is blocked on one of this operations.
The last symlink name is 8 carater lenth and point to a 2732 lenth path.
That maybe caused the bug I see  by a buffer overflow?

Some files named .nfsxxxxxxxxxxxxx (for ex. .nfs0028b8b10000060d) are 
remaining on the server.

kernel is 2.6.11-CITI_NFS4_ALL-1 (Client and server)


Vincent


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
