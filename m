From: Laurent HENRY <laurent.henry@ehess.fr>
Subject: quotas over NFS
Date: Mon, 16 Feb 2004 15:58:26 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402161511.41331.laurent.henry@ehess.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AskGC-0005q1-Jh
	for nfs@lists.sourceforge.net; Mon, 16 Feb 2004 07:02:12 -0800
Received: from atacama.ehess.fr ([193.48.45.1])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AskCb-00068K-DW
	for nfs@lists.sourceforge.net; Mon, 16 Feb 2004 06:58:29 -0800
Received: from phebus (phebus.annexus.ehess.fr [193.48.47.225])
          by atacama.ehess.fr (8.12.6/jtpda-5.4) with ESMTP id i1GEwQMn021680
          for <nfs@lists.sourceforge.net>; Mon, 16 Feb 2004 15:58:26 +0100
To: nfs@lists.sourceforge.net
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

Hi

 i'm coming here with a question i think you've heard a lot before.
I didn't find any documentation about it anywhere about setting up quotas over 
NFS

On my Suse 8.1 (kernel 2.4.21168) system with 3-10 pre1 quota-tools
All local quotas works well but i can't use it through NFS

s a test, i'm accessing the /home (the one with quota) partition mounting it 
locally by NFS

#mount -t nfs aa.bb.cc.dd:/home/ /mnt/

#quota laurent
Disk quotas for user laurent (uid 504): 
     Filesystem  blocks   quota   limit   grace   files   quota   limit   
grace
      /dev/sdb1  155813*  20000   25000             505       0       0        
aa.bb.cc.dd::/home
                 155813*  20000   25000             505       0       0  

And i still can't write while in local partition(normal behavior because i'm 
over quota)
#cd /home
#cp big-file big-file2
sd(8,17): write failed, user block limit reached.
                                                 
But on the NFS mounted partition
#cd /mnt
#cp big-file big-file2
all is Ok and the file is written

Can anybody give me a clue ? Or at least the URL toward some explanation of 
the correct use

PS:
the quota_v2 module is loaded
The portmapper is running well
rpcinfo -p give me: portmapper,rquotad,mountd,nfs,nlockmgr running
   




-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
