From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Autodir and nfs
Date: Sun, 14 Nov 2004 11:59:10 -0500
Message-ID: <1100451550.11340.4.camel@lade.trondhjem.org>
References: <4196DB26.9040207@intraperson.com>
	 <1100451447.11340.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTNik-000242-2j
	for nfs@lists.sourceforge.net; Sun, 14 Nov 2004 08:59:22 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CTNij-0008At-4f
	for nfs@lists.sourceforge.net; Sun, 14 Nov 2004 08:59:22 -0800
To: ramana <ramana@intraperson.com>
In-Reply-To: <1100451447.11340.2.camel@lade.trondhjem.org>
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

su den 14.11.2004 Klokka 11:57 (-0500) skreiv Trond Myklebust:
> su den 14.11.2004 Klokka 09:42 (+0530) skreiv ramana:
> > But when NFS is used to mount Autodir maintained directories, NFS 
> > mounting them perfectly but it is not allowing to enter into those nfs 
> > mounted directories -- Permission denied.
> 
> "man 5 nfs". Read all about the "no_root_squash" export option.

Sorry. Should be "man 5 exports"...

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
