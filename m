From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Stale NFS file handle
Date: Wed, 23 Mar 2005 10:59:25 -0800
Message-ID: <482A3FA0050D21419C269D13989C6113085398F4@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DEB4m-0001M6-UH
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 10:59:32 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DEB4m-00063Y-Co
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 10:59:32 -0800
To: "Filipe Brandenburger" <branden@terra.com.br>
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

filipe-

in general the kernel patches i referred to earlier will prevent most
issues when using rsync and serving web pages.  an occassional ESTALE is
unavoidable because no NFS client can recover from an ESTALE during a
read operation.  however, the patches do allow a subsequent open(2)
operation on that pathname to find the new file.


> -----Original Message-----
> From: Filipe Brandenburger [mailto:branden@terra.com.br]=20
> Sent: Wednesday, March 23, 2005 12:15 PM
> To: Trond Myklebust
> Cc: Steve Dickson; nfs@lists.sourceforge.net
> Subject: Re: [NFS] Stale NFS file handle
>=20
>=20
> * Wed, 23 Mar 2005 08:57:15 -0500, Trond Myklebust=20
> <trond.myklebust@fys.uio.no>:
> > He was running
> >=20
> > while :; do cat test.txt; done >/dev/null
> >=20
> > on a client, then deleting the file on the server. Even if=20
> the call to
> > open() is successful, you both can and will get ESTALEs on the=20
> > subsequent call to read().
>=20
> Ok,
>=20
> But then, how do you suggest I should change applications to=20
> do it? The applications that publish content to the NFS run=20
> on one host and are based on rsync, the applications that=20
> deliver content are web servers
> (Apache) reading from this same NFS on another pool of hosts=20
> (these are the ones that get the ESTALE error).
>=20
> Where is the problem? On the applications that publish?=20
> Should they open the file and update it in-place instead of=20
> creating a new one and renaming? I don't think so! This would=20
> lead to content that is a mix of the old and the new, that is corrupt.
>=20
> Or is the webserver? Should the application protect itself=20
> from ESTALE errors and retry? Somehow that seems wrong to me=20
> also. Then I would have to change all applications that read=20
> this content to do it. Why doesn't the NFS client recover=20
> from this kind of errors?
>=20
> If it's really not possible to change it on the NFS client=20
> (the kernel), what workaround would you suggest me to use?
>=20
> Thanks,
> Filipe
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by Microsoft Mobile & Embedded=20
> DevCon 2005 Attend MEDC 2005 May 9-12 in Vegas. Learn more=20
> about the latest Windows
> Embedded(r) & Windows Mobile(tm) platforms, applications &=20
> content.  Register by 3/29 & save $300=20
> http://ads.osdn.com/?ad_id=3D6883&alloc_id=3D15149&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.net email is sponsored by Microsoft Mobile & Embedded DevCon 2005
Attend MEDC 2005 May 9-12 in Vegas. Learn more about the latest Windows
Embedded(r) & Windows Mobile(tm) platforms, applications & content.  Register
by 3/29 & save $300 http://ads.osdn.com/?ad_id=6883&alloc_id=15149&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
