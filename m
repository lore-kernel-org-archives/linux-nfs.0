From: Marco Gaiarin <gaio@sv.lnf.it>
Subject: Re: ACL on NFS, how make it work?
Date: Mon, 6 Mar 2006 10:05:57 +0100
Message-ID: <20060306090557.GD8429@sv.lnf.it>
References: <20060303103806.GB8038@sv.lnf.it> <20060303163535.GB32552@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGBfQ-0001iy-BI
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 01:06:12 -0800
Received: from mta077c.interbusiness.it ([85.37.17.77])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FGBfO-0000Kl-S1
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 01:06:12 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060303163535.GB32552@fieldses.org>
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

Mandi! J. Bruce Fields
  In chel di` si favelave...

> What filesystems are you exporting, and how are they mounted?  (You

Apart /home (via autofs), i export /srv to clients. Both, as you can
see, are XFS ACL-enabled filesystem:

 Mar  6 05:09:33 rita kernel: SGI XFS with ACLs, security attributes, no =
debug enabled
 Mar  6 05:09:33 rita kernel: SGI XFS Quota Management subsystem

As requested:

  rita:~# mount
  /dev/sda1 on / type ext3 (rw,noatime,errors=3Dremount-ro)
  proc on /proc type proc (rw)
  sysfs on /sys type sysfs (rw)
  devpts on /dev/pts type devpts (rw,gid=3D5,mode=3D620)
  tmpfs on /dev/shm type tmpfs (rw)
  /dev/sda2 on /usr type ext3 (ro)
  /dev/md2 on /var type xfs (rw)
  /dev/md5 on /home type xfs (rw,nosuid,nodev,usrquota)
  /dev/md4 on /srv type xfs (rw,noexec,nosuid,nodev,grpquota)
  none on /proc/bus/usb type usbfs (rw)
  rita:~# exportfs -v
  /home		mario.ac.concordia-pordenone.it(rw,wdelay,root_squash)
  /home		giovanni.ac.concordia-pordenone.it(rw,wdelay,root_squash)
  /srv		mario.ac.concordia-pordenone.it(rw,wdelay,root_squash)
  /srv		giovanni.ac.concordia-pordenone.it(rw,wdelay,root_squash)


> Which kernel are you using?

The last...

 rita:~# uname -a
 Linux rita 2.6.15.4 #1 SMP Tue Feb 28 19:16:58 CET 2006 i686 GNU/Linux


> If you're logged in to the server, can you succesfully get and set acls
> on the filesystem that you're exporting?

I usually set ACL only via windows, but...

 rita:/srv/users/Da Riordinare/VARIE# getfacl ViewReport.pdf
 # file: ViewReport.pdf
 # owner: root
 # group: root
 user::rwx
 group::---
 group:presidenza:rwx
 group:segreteria:rwx
 mask::rwx
 other::---
 rita:/srv/users/Da Riordinare/VARIE# setfacl -m u:gaio:r ViewReport.pdf
 rita:/srv/users/Da Riordinare/VARIE# getfacl ViewReport.pdf
 # file: ViewReport.pdf
 # owner: root
 # group: root
 user::rwx
 user:gaio:r--
 group::---
 group:presidenza:rwx
 group:segreteria:rwx
 mask::rwx
 other::---

yes, it works. ;)


Hope these helps. And many thanks.

--=20
dott. Marco Gaiarin				    GNUPG Key ID: 240A3D66
  Associazione ``La Nostra Famiglia''                http://www.sv.lnf.it=
/
  Polo FVG  -  Via della Bont=E0, 7 - 33078  -  San Vito al Tagliamento (=
PN)
  marco.gaiarin(at)sv.lnf.it	  tel +39-0434-842711  fax +39-0434-842797


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
