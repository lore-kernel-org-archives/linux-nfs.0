From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd recovery not working on RH with 2.6 kernel
Date: Fri, 19 Nov 2004 15:27:45 -0500
Message-ID: <1100896065.11209.38.camel@lade.trondhjem.org>
References: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>
	 <419CD343.4000600@RedHat.com> <1100882099.11209.8.camel@lade.trondhjem.org>
	 <419E3252.3040602@RedHat.com>
	 <1100895853.11209.35.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <1100895853.11209.35.camel@lade.trondhjem.org>
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

fr den 19.11.2004 Klokka 15:24 (-0500) skreiv Trond Myklebust:
> Just out of curiosity, though... Does this mean that knfsd is now
> sometimes returning NFS3ERR_JUKEBOX to NFSv2 clients?

Ah... No... Looks like it is just dropping those requests. That is going
to REALLY SUCK on NFSv2 over TCP...


Oh well...

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
