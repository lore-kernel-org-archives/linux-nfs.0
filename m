From: "Thomas, Dave" <Dave.Thomas@savvis.net>
Subject: RE: NFS inconsistencies experienced between server and client.
Date: Mon, 14 Nov 2005 15:25:34 -0000
Message-ID: <51E1B8DFD9EE6747889DB802751770B90700F7@S229378RGEW08.apptix-01.savvis.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EbgDJ-0002kw-6b
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 07:25:45 -0800
Received: from out001.uk.email.savvis.net ([213.174.205.44])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EbgDI-0005Sl-RR
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 07:25:45 -0800
To: "Neil Horman" <nhorman@redhat.com>
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

I've tried client with AS3.0U5, but still experiencing issues. Not able
to update the server easily.
Also have tried to mount with data caching disabled by adding=20

options nfs nfs_uncached_io=3D1

to the /etc/modules.conf file, but get following error on reboot.

insmod: Warning: ignoring nfs_uncached_io=3D1, no such parameter in this
module


> Hi,
>=20
> =20
>=20
> I currently a web site consisting of one NFS server and 2 clients
> running RedHat AS3.0 (kernel 2.4.21-9.0.1.ELsmp)
>=20
Have you tried this with the latest RHEL3 kernel?  I remember a simmilar
problem
being addressed some time ago.
Neil

> =20
>=20
> Clients run:-
>=20
> Apache/2.0.52
>=20
> jakarta-tomcat-5.5.4
>=20
> nfs-utils-1.0.6-33EL
>=20
> =20
>=20
> Server runs:-
>=20
> mysql  Ver 14.7 Distrib 4.1.13, for pc-linux-gnu (i686) using readline
> 4.3
>=20
> nfs-utils-1.0.6-33EL
>=20
> =20
>=20
> The server shares out a directory /data01/www, mounted as /www on the
> clients, which contains the DocumentRoot used by apache.
>=20
> =20
>=20
> New content is uploaded to the server at /data01/www, several times a
> day.
>=20
> =20
>=20
> I am seeing inconsistencies between some files on the server, and the
> same files on the client, index.shtml files in particular.
>=20
> When I run a checksum on certain files on the clients and server,
> different results are obtained. The checksums, and the files, only
> become identical if the file is deleted before being uploaded onto the
> server, but this is not an option.
>=20
> If the file is not deleted, before being uploaded, they remain
different
> indefinitely.=20
>=20
> =20
>=20
> The filesystem is exported with the options (rw,async), and mounted
with
> following (rsize=3D8192,wsize=3D8192,timeo=3D15,rw,hard,intr).
>=20
> We have tested by changing several mount options, including:-
>=20
> Server export with ro, client mount with ro, client mount with noac.
We
> have increased the number of nfs threads on the server from 8 to 16.
>=20
> =20
>=20
> But the problem is still being experienced, and is becoming a critical
> issue, as the website shows different data, depending upon which
client
> you connect to.
>=20
> =20
>=20
> =20
>=20
> Any thoughts would be welcome.
>=20
> =20
>=20
> Thanks,
>=20
> =20
>=20
> Dave.
>=20
> =20
>=20

--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
