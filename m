From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: async vs. sync
Date: Tue, 16 Nov 2004 13:08:18 -0500
Message-ID: <1100628498.7570.6.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EB6A@lavender-fe.eng.netapp.com>
	 <1100622780.10975.51.camel@lade.trondhjem.org>
	 <419A3672.8040305@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Charles Lever <Charles.Lever@netapp.com>,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CU7km-0005zU-NE
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 10:08:32 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CU7kl-0001VJ-Ur
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 10:08:32 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
In-Reply-To: <419A3672.8040305@int-evry.fr>
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

ty den 16.11.2004 Klokka 18:18 (+0100) skreiv jehan.procaccia:
> >
> By the way, I noticed on a performance factor of 30 (!) from an sync to 
> async nfs v3 export FS :
> 
> sync export:
> 
> $time tar xvfz linux-2.6.8.tar.gz
> real    64m18.618s
> user    0m5.742s
> sys     0m15.658s
> 
> async export:
> 
> $time tar xvfz linux-2.6.8.tar.gz
> real    2m0.552s
> user    0m5.838s
> sys     0m15.678s

What mount options are you using? I don't see a factor 30 difference
using my setup.

> Is it really dangerous to use async ? why recent OS uses sync by default 
> (My client is a Fedora Core 2 (kernel 2.6)  and server an RedHat 
> Entreprise server 3 (kernel 2.4))

"async" is bad because it lies to you about whether or not the data is
on disk or not. Type "sync", and it will happily return, and tell your
application that all is well but you will still lose your data if the
server crashes on you...

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
