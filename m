From: Edward Roper <eroper@wanfear.com>
Subject: RE: close() / nfs commit performance
Date: 30 Jun 2003 16:18:53 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1057015133.21354.44.camel@themachine.sanera.net>
References: <482A3FA0050D21419C269D13989C6113D069EA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.sanera.net ([208.253.254.10] helo=sentinel)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19X7vT-0007Uy-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Jun 2003 16:19:11 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113D069EA@lavender-fe.eng.netapp.com>
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

Fair enough, I've read the faq and understand your argument. However I
would really be curious as to why local write benchmarks (on the server
itself) with calling close() and using a test-file of 2GB (twice my ram)
and a record size of 8192 I obtain a write throughput of 24,739KB/Second
whereas over NFS I obtain only 4,924KB/Second on a 500mb file with 8192
record size?

I realize that plopping a pci-nvramish device (http://www.umem.com/) and
setting data=journal with my ext3 journal residing on the nvram would
indeed offer a performance increase. I don't see where it's going to be
a 5x increase however when I don't seem to be bottle necking at
direct-attach-disk-i/o.

Perhaps local close() calls don't actually commit to disk?

Watching the machines leds (albeit a very primitive method) doesn't show
constant harddisk action while I'm supposedly waiting on a physical disk
commit. I get a brief flash of activity once every 30 seconds or so
instead across the array.

I plan on purchasing the nvram but I'm just making sure it's really
going to make the difference that I'm looking for. 

On Mon, 2003-06-30 at 15:39, Lever, Charles wrote:
> ed-
> 
> read the FAQ:  http://nfs.sourceforge.net/
> 
> close(2) on an NFS file means flush all outstanding
> writes.  benchmarking without the close() means you're
> measuring essentially client memory bandwidth.
> 
> the filer doesn't need v3 COMMITs because of its NVRAM
> facility -- whether the client asks for UNSTABLE or
> FILE_SYNC writes, it will always return a FILE_SYNC
> result.  so writes to a filer are always fast, and
> v3 writes to a filer are simpler than a pure disk-based
> server.
> 
> > -----Original Message-----
> > From: Edward Roper [mailto:eroper@wanfear.com]
> > Sent: Monday, June 30, 2003 4:28 PM
> > To: nfs@lists.sourceforge.net
> > Cc: neilb@cse.unsw.edu.au
> > Subject: [NFS] close() / nfs commit performance
> > 
> > 
> > I have a system that I've been running some NFS benchmarks 
> > on. I've also
> > been running the benchmarks on a Netapp F880. I have been using iozone
> > as the testing tool. I am quite impressed with the linux 
> > system in every
> > regard excepting it's close() / nfs commit performance (iozone -Rac).
> > The following URL contains some graphs and spreadsheet data.
> > 
> > http://www.wanfear.com/~eroper/nfs/
> > 
> > Both the netapp and the linux system take a significant 
> > performance hit
> > when close() is involved. However the Linux system drops to an almost
> > unbelievably pathetic level.
> > 
> > The graphs may also be of interest as they compare various 
> > block sizes,
> > transport protos, sync/async options on the same linux server. I also
> > have data for tcp,sync,32768 block sizes although it hasn't made it up
> > there yet. All nfs data is v3.
> > 
> > I'm hoping someone can tell me why there is such a huge write
> > performance drop when close() is involved, and why it is such a more
> > substantial drop than experienced with the netapp. I've also got data
> > for two local iozone runs on the filesystem both with and without the
> > close() option in iozone.
> > 
> > Just in case anyone is interested in the specs (mordor == 
> > linux server):
> > 
> > 2.4.20-18.7-nfsserv (redhat(7.3) kernel with tcp-nfs built in)
> > Pentium III 1.0ghz
> > 1gb ram
> > Intel(R) PRO/1000
> > 3ware Storage Controller (Escalade 7500-8)(raid-5, 7 ata disks)
> > The filesystem is ext3
> > 
> > Thanks,
> > Edward
> > 
> > 
> > 
> > 
> > -------------------------------------------------------
> > This SF.Net email sponsored by: Free pre-built ASP.NET sites including
> > Data Reports, E-commerce, Portals, and Forums are available now.
> > Download today and enter to win an XBOX or Visual Studio .NET.
> > http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_06
> 1203_01/01
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
