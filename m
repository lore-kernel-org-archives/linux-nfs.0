From: Marian Eichholz <marian.eichholz@freenet-ag.de>
Subject: Re: Kernel freezes on "exportfs -a"
Date: Fri, 19 Nov 2004 15:46:21 +0100
Message-ID: <20041119144621.GC7039@urmel.freenet-ag.de>
References: <20041116112237.GQ20889@urmel.freenet-ag.de> <16794.47764.700862.428216@cse.unsw.edu.au>
Reply-To: marian.eichholz@freenet-ag.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CVA1t-0005SA-Fq
	for nfs@lists.sourceforge.net; Fri, 19 Nov 2004 06:46:29 -0800
Received: from mout2.freenet.de ([194.97.50.155])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CVA1p-0004Yd-Li
	for nfs@lists.sourceforge.net; Fri, 19 Nov 2004 06:46:29 -0800
Received: from [194.97.55.148] (helo=mx5.freenet.de)
	by mout2.freenet.de with esmtpa (Exim 4.43)
	id 1CVA1m-0004nh-CL
	for nfs@lists.sourceforge.net; Fri, 19 Nov 2004 15:46:22 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <16794.47764.700862.428216@cse.unsw.edu.au>
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

On Wed, Nov 17, 2004 at 01:42:28PM +1100, Neil Brown wrote:

> > 	rpc.nfsd 128
> > 	rpc.mountd
> > 	rpc.statd
> > 	exportfs -a
> 
> It doesn't address your core problem, but this order is wrong.
> The "exportfs -a" should be done *before* rpc.nfsd, otherwise there is
> a window where clients could be told that the filesystem they want
> isn't exported.

This makes sense. Too-many-generations-of-this-script problem.

> > We cannot reproduce it on a "normal" machine.
> 
> Just how abnormal is the machine where you *can* export it?

Smaller file systems (far much smaller), single processor,
completely different hardware, no clients and so on.

Although the size of the exported FS is of no interest,
because exportfs froze even when I did not mount it (to
save time on reboot-fsck).

> > The most recently tested kernel is a 2.6.9-rc1 (since each
> > test breaks the production service). exportfs is 1.0.6.

Interesting result: 2.6.10-rc2 appears to work perfectly.
Some racing condition anywhere in the kernel
infrastructure?

> > The particular server is the NFS file repository for a high
> > volume FTP cluster, thus beeing requested by the still
> > online 4 ftp backend servers *heavily*.
> > 
> > It has 2 Fast Ethernet ports in *bonding* mode (in peak hours they can
> > be filled with ease).
> > 
> > Probably it is this combinations that makes a problem.
> 
> So are you saying that the clients are hammering on the server while
> you are trying to bring up NFS service?  If this is the case, then
> maybe just moving the "exportfs -a" to the top will

I had no chance to go deep into detail, like Olaf mentioned
with the backtrace-NMI suggestion, because I had to bring
the machine back into production ASAP.

> 
> NeilBrown
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: InterSystems CACHE
> FREE OODBMS DOWNLOAD - A multidimensional database that combines
> robust object and relational technologies, making it a perfect match
> for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Mit freundlichen Gruessen / Yours sincerely

Marian Eichholz
Postmaster
freenet.de AG          Vorsitzender des Aufsichtsrates: Prof. Dr. Helmut Thoma
Deelbögenkamp 4c       Vorstand: Eckhard Spoerr (Vors.), Axel Krieger,
                                 Stephan Esch, Eric Berger
22297 Hamburg          Amtsgericht Hamburg, HRB 74048


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
