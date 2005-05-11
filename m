From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Simultaneous write performance
Date: Wed, 11 May 2005 15:10:17 -0400 (EDT)
Message-ID: <Pine.LNX.4.58.0505111459400.6834@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DVwbY-0002Dl-2t
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 12:10:48 -0700
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DVwbU-0005Zs-GW
	for nfs@lists.sourceforge.net; Wed, 11 May 2005 12:10:48 -0700
Received: from chaos.egr.duke.edu (localhost.localdomain [127.0.0.1])
	by chaos.egr.duke.edu (8.12.11/8.12.11) with ESMTP id j4BJAHM0009693
	for <nfs@lists.sourceforge.net>; Wed, 11 May 2005 15:10:27 -0400
Received: from localhost (jlb@localhost)
	by chaos.egr.duke.edu (8.12.11/8.12.11/Submit) with ESMTP id j4BJAHU7009689
	for <nfs@lists.sourceforge.net>; Wed, 11 May 2005 15:10:17 -0400
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

I'm in the midst of testing a new server -- dual 3ware 9500-12 boards 
(hardware RAID5 w/ a software RAID0 stripe across them) on a Supermicro 
X5DPE-G2 motherboard.  The server is running centos-4, and all clients are 
running centos-3.  The server is dual homed, with half the clients on each 
interface.  Gigabit everywhere (but not everywhere supports jumbo frames, 
unfortunately).  I've been playing with IOR 
<http://www.llnl.gov/asci/purple/benchmarks/limited/ior/>, 
<ftp://ftp.llnl.gov/pub/siop/ior/> for the past couple of days.  This is 
the output from a sample run across 10 clients (NFS over tcp, 
wsize=rsize=32768):

Command line used: /home/jlb/src/IOR-2.8.4/src/C/IOR -F -W -R -b 40m -t 4m -s 103 -e
Participating tasks: 10

Summary:
        api                = POSIX
        test filename      = testFile
        access             = file-per-process
        clients            = 10 (1 per node)
        repetitions        = 1
        xfersize           = 4 MiB
        blocksize          = 40 MiB
        aggregate filesize = 40.23 GiB
        Lustre stripe size = Use default
              stripe count = Use default

access    bw(MiB/s)  block(KiB) xfer(KiB)  open(s)    wr/rd(s)   close(s)  iter
------    ---------  ---------- ---------  --------   --------   --------  ----
write     25.92      40960      4096       0.067203   1589.32    78.92      0
read      208.72     40960      4096       0.093569   197.39     191.23     0

For that test, the underlying filesystem was XFS.  tiobench with 8 threads 
on the local FS got ~140MiB/s writing.  If I use ext3 as the underlying 
fs, the IOR write number is slightly higher (~30 MiB/s) and the read 
number slightly lower (~190MiB/s) despite the local tiobench numbers being 
lower for both reading and writing.  Also, if I run IOR with only 2 
clients, the write numbers are about the same as with 10.

Obviously, the read performance is as good as I could hope for.  I'm just 
curious if there's anything I can do to improve the write performance?

Thanks for any insight.

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
