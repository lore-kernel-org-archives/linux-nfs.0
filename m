From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Kernel freezes on "exportfs -a"
Date: Wed, 17 Nov 2004 13:42:28 +1100
Message-ID: <16794.47764.700862.428216@cse.unsw.edu.au>
References: <20041116112237.GQ20889@urmel.freenet-ag.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CUFhy-0007yG-7M
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 18:38:10 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CUFhx-0002jb-4n
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 18:38:10 -0800
To: marian.eichholz@freenet-ag.de
In-Reply-To: message from Marian Eichholz on Tuesday November 16
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

On Tuesday November 16, marian.eichholz@freenet-ag.de wrote:
> Hello all, hi Neil, hi Olaf,
> 
> we recently found a strange bug in the recent 2.6 kernels
> that freezes the whole kernel (down to even no response to
> the Magic SysRq keys). And in fact sticks us to the 2.4
> series we want to get rid of :)
> 
> This happens during "exportfs -a" when the following
> sequence commences (tested by manual command execution,
> with some seconds betweeen the commands):
> 
> 	rpc.nfsd 128
> 	rpc.mountd
> 	rpc.statd
> 	exportfs -a

It doesn't address your core problem, but this order is wrong.
The "exportfs -a" should be done *before* rpc.nfsd, otherwise there is
a window where clients could be told that the filesystem they want
isn't exported.

> 
> We cannot reproduce it on a "normal" machine.

Just how abnormal is the machine where you *can* export it?

> 
> The most recently tested kernel is a 2.6.9-rc1 (since each
> test breaks the production service). exportfs is 1.0.6.
> 
> The particular server is the NFS file repository for a high
> volume FTP cluster, thus beeing requested by the still
> online 4 ftp backend servers *heavily*.
> 
> It has 2 Fast Ethernet ports in *bonding* mode (in peak hours they can
> be filled with ease).
> 
> Probably it is this combinations that makes a problem.

So are you saying that the clients are hammering on the server while
you are trying to bring up NFS service?  If this is the case, then
maybe just moving the "exportfs -a" to the top will help.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
