From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Unmount in case of unreachable NFS server
Date: Mon, 5 May 2003 08:48:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127475@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19CiDT-0004bb-00
	for <nfs@lists.sourceforge.net>; Mon, 05 May 2003 08:49:23 -0700
To: "Deepa Chacko Pillai" <deepa.chacko@wipro.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

hi deepa-

when an application has any files open on a file system,
you cannot unmount it.  this is true of ext3, xfs, or
whatever.

mounting node B over the original node A mount point
means the applications that were accessing files on
node A are now stuck.  if they were writing to the
files, that data is lost.

there are some failover products around that may do what
you need on NFS.  take a spin on google.

> Can I unmount a file system, mounted from server 'A', if the=20
> server 'A' is down and the client has open files on it? If=20
> there are no open references to the filesystem, I saw it=20
> could be unmounted if I soft mount the FS.
>=20
> I will explain my requirement with an example. Suppose I have=20
> 3 nodes A, B and C. I mount a filesystem from node A onto=20
> node C. The device containing the filesystem is accessible=20
> from node B also (shared disk). If node A fails, I want to=20
> migrate the FS to node B. Once the FS is migrated, I have to=20
> remount the FS on node C. On client C, I am unable to unmount=20
> the FS as it has some files open. Even force unmount failed.=20
> I can however mount the FS from node B onto the same mount=20
> point again (overlay mount). This would mean I need to keep=20
> track of the number of such mounts. I would like to know if=20
> there is any other way to do this.
>=20
> Another possibility I thought of is IP failover. However, it=20
> will confuse locking I guess.
> I am using Red Hat Linux 2.4.19.
>=20
> Any help would be much appreciated.
>=20
> Thanks
> Deepa
>=20
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
