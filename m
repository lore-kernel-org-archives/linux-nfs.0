From: "Lever, Charles" <cel@netapp.com>
Subject: RE: File system cache corruptions?
Date: Wed, 6 Oct 2004 10:58:24 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E910@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFG3b-00058v-F4
	for nfs@lists.sourceforge.net; Wed, 06 Oct 2004 10:58:31 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CFG3a-0001oR-HW
	for nfs@lists.sourceforge.net; Wed, 06 Oct 2004 10:58:31 -0700
To: "James Pearson" <james-p@moving-picture.com>
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

are you using soft mounts?

> -----Original Message-----
> From: James Pearson [mailto:james-p@moving-picture.com]=20
> Sent: Wednesday, October 06, 2004 12:41 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] File system cache corruptions?
>=20
>=20
> Very occasionally we get problems where by an application on an NFS=20
> server fails to load on one NFS client - for example just had=20
> one which=20
> fails when you try to run it:
>=20
> /path/to/nfs/mounted/binary: relocation error:=20
> /path/to/nfs/mounted/shared/object.so: symbol , version GLIBC_2.0 not=20
> defined in file libpthread.so.0 with link time reference
>=20
> I 'fixed' the problem by running a simple tool on the client=20
> that just=20
> grabs memory - and hence flushes any cached files.
>=20
> The application in question hasn't changed in months.
>=20
> In this case, the client is running Fedora Core 1 with a 2.4.22 based=20
> kernel (with Trond's NFS client patches), but we've seen similar=20
> problems with Redhat 7.2 based machines with a variety of kernel.org=20
> 2.4.X based kernels.
>=20
> Any ideas on what may be causing this?
>=20
> James Pearson
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: IT Product Guide on=20
> ITManagersJournal Use IT products in your business? Tell us=20
> what you think of them. Give us Your Opinions, Get Free=20
> ThinkGeek Gift Certificates! Click to find out more=20
> http://productguide.itmanagersjournal.com/guid> epromo.tmpl
>=20
> _______________________________________________
>=20
> NFS maillist  -  NFS@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/n> fs
>=20


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
