From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Using mmap result in data corruption
Date: Tue, 16 Nov 2004 11:20:23 -0500
Message-ID: <1100622023.10975.46.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0411161206440.26094@ihme.ihme.org>
	 <Pine.LNX.4.60.0411160817350.20803@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Miika Pekkarinen <miipekk@ihme.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CU64L-0008CE-Ct
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 08:20:37 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CU64J-0005hu-Ln
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 08:20:37 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0411160817350.20803@harp.ngdc.noaa.gov>
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

ty den 16.11.2004 Klokka 08:21 (-0700) skreiv Ara.T.Howard:

> i think the man page is badly written.  it has confused me too.  i think it
> should probably say
> 
>    "msync  flushes  changes  made  to  the in-core copy of a file that was
>    mapped into memory using mmap(2) back to disk. Without use of this call
>    there is no guarantee that changes have been written WHEN munmap(2) is
>    called and the map is released."

Yep. That would indeed be more consistent with the actual behaviour of
munmap(). There have been no guarantees that munmap() would cause any
data to be flushed to disk either in Linux 2.4.x or with the 2.6.x
kernels.

This is BTW true of *all* filesystems, including local block based
filesystems. It is not behaviour that is specific to NFS only.

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
