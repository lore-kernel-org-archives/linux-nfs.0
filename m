From: "Mark Hartwig" <hartwigm@BoulderCustomHomes.com>
Subject: nfs and xfs on 1.1T partition
Date: Tue, 14 Jan 2003 17:28:13 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4167.128.138.134.61.1042583293.squirrel@www.bouldercustomhomes.com>
Reply-To: hartwigm@BoulderCustomHomes.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.70.114.40] (helo=www.promopipe.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YZvw-0002cX-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 14:53:25 -0800
To: <nfs@lists.sourceforge.net>
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

Hello all, I'm having a problem with nfsd (from Mandrake 9.0 install 2.4.19
kernel) on xfs partitions.  I am running an IDE RAID5 with 3Ware's Escalade
7500 controller. The xfs partition as 1.1T.  I can transfer large ammounts
of small files on to the xfs partition without any problems, but as soon as
I try to transfer a large file to the partition, the entire server freezes
when about 200 megs have been transfered.  At this point, the server is
completely frozen and can only be restarted manually.  I can, however,
transfer large files to the same server, but on to a smaller 100G ext3
partition.  Ideally, I would like to find a work around the issue without
having to re-format the entire RAID.  Any help would be greatly appreciated.

-- 
Mark Hartwig
Boulder Custom Homes
720-530-4102
hartwigm@BoulderCustomHomes.com




-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
