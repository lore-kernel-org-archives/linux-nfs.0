From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: async vs. sync
Date: Tue, 16 Nov 2004 11:32:59 -0500
Message-ID: <1100622780.10975.51.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EB6A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CU6GW-0000gp-PR
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 08:33:12 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CU6GT-0007Hj-TT
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 08:33:12 -0800
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435EB6A@lavender-fe.eng.netapp.com>
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

ty den 16.11.2004 Klokka 08:15 (-0800) skreiv Lever, Charles:
> is the effect of the "sync" export option limited to NFSv3 COMMIT, or is
> it limited to both NFSv3 COMMIT and NFSv3 FILE_SYNC/DATA_SYNC WRITE?
> 
> what are the effects on NFSv4 writes and commits?

No! It is clearly not just limited to writes and commits.

Look at the code in fs/nfs/vfs.c: there are EX_ISSYNC() exceptions that
wrap calls to nfsd_sync_dir() in nfsd*_create(), nfsd_symlink(),
nfsd_link(), nfsd_rename(), and nfsd_unlink().

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
