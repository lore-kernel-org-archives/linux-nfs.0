From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: async vs. sync
Date: Tue, 16 Nov 2004 10:48:12 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Olaf Kirch" <okir@suse.de>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CU8NJ-0008Ij-Ta
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 10:48:21 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CU8NG-0005m1-Co
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 10:48:21 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> ty den 16.11.2004 Klokka 08:15 (-0800) skreiv Lever, Charles:
> > is the effect of the "sync" export option limited to NFSv3=20
> COMMIT, or is
> > it limited to both NFSv3 COMMIT and NFSv3 FILE_SYNC/DATA_SYNC WRITE?
> >=20
> > what are the effects on NFSv4 writes and commits?
>=20
> No! It is clearly not just limited to writes and commits.
>=20
> Look at the code in fs/nfs/vfs.c: there are EX_ISSYNC()=20
> exceptions that
> wrap calls to nfsd_sync_dir() in nfsd*_create(), nfsd_symlink(),
> nfsd_link(), nfsd_rename(), and nfsd_unlink().

ulp.  wow.  this clearly affects all versions of NFS on the Linux
server, then.

i'm just looking for clarification so i can provide a good explanation
in the Linux NFS FAQ about the evils of using "async."  i'll cruise
through the server code.



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
