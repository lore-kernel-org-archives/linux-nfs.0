From: Edward Roper <eroper@wanfear.com>
Subject: close() / nfs commit performance
Date: 30 Jun 2003 13:28:12 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1057004892.21354.15.camel@themachine.sanera.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: neilb@cse.unsw.edu.au
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.sanera.net ([208.253.254.10] helo=sentinel)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19X5Ge-0008Ll-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Jun 2003 13:28:52 -0700
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

I have a system that I've been running some NFS benchmarks on. I've also
been running the benchmarks on a Netapp F880. I have been using iozone
as the testing tool. I am quite impressed with the linux system in every
regard excepting it's close() / nfs commit performance (iozone -Rac).
The following URL contains some graphs and spreadsheet data.

http://www.wanfear.com/~eroper/nfs/

Both the netapp and the linux system take a significant performance hit
when close() is involved. However the Linux system drops to an almost
unbelievably pathetic level.

The graphs may also be of interest as they compare various block sizes,
transport protos, sync/async options on the same linux server. I also
have data for tcp,sync,32768 block sizes although it hasn't made it up
there yet. All nfs data is v3.

I'm hoping someone can tell me why there is such a huge write
performance drop when close() is involved, and why it is such a more
substantial drop than experienced with the netapp. I've also got data
for two local iozone runs on the filesystem both with and without the
close() option in iozone.

Just in case anyone is interested in the specs (mordor == linux server):

2.4.20-18.7-nfsserv (redhat(7.3) kernel with tcp-nfs built in)
Pentium III 1.0ghz
1gb ram
Intel(R) PRO/1000
3ware Storage Controller (Escalade 7500-8)(raid-5, 7 ata disks)
The filesystem is ext3

Thanks,
Edward




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
