From: Marco Gaiarin <gaio@sv.lnf.it>
Subject: Re: ACL on NFS, how make it work?
Date: Mon, 6 Mar 2006 11:31:04 +0100
Message-ID: <20060306103104.GH8429@sv.lnf.it>
References: <20060303103806.GB8038@sv.lnf.it> <20060303163535.GB32552@fieldses.org> <20060306090557.GD8429@sv.lnf.it> <200603061041.40841.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGD0B-0002Bd-LT
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 02:31:43 -0800
Received: from mta065b.interbusiness.it ([85.37.17.65])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FGD08-0008FU-9s
	for nfs@lists.sourceforge.net; Mon, 06 Mar 2006 02:31:43 -0800
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200603061041.40841.agruen@suse.de>
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

Mandi! Andreas Gruenbacher
  In chel di` si favelave...

> everything you reported so far looks fine. What do these give you on th=
e=20
> server and client?

I'm not using ``config on kernel'' options, but debian copy kernel
config file on boot, so on server:

 rita:~# grep V3_ACL /boot/config-2.6.15.4
 # CONFIG_NFS_V3_ACL is not set
 CONFIG_NFSD_V3_ACL=3Dy

and on client:

 root@giovanni:~# grep V3_ACL /boot/config-2.6.14
 CONFIG_NFS_V3_ACL=3Dy
 CONFIG_NFSD_V3_ACL=3Dy


> Can you set acls when mounting localhost:/srv locally on the server?

As you can see i've at least to rebuild kernel, install and reboot the
server to test this. ;(

But i've switched on a client, and do some tests here.

On server:

 rita:/srv/users# setfacl -m g:segreteria:rwx Webmaster
 rita:/srv/users# getfacl Webmaster
 # file: Webmaster
 # owner: gaio
 # group: webmaster
 user::rwx
 group::r-x
 group:segreteria:rwx
 mask::rwx
 other::r-x

on client, after the above:

 gaio@giovanni:/srv/users$ getfacl Webmaster
 # file: Webmaster
 # owner: gaio
 # group: webmaster
 user::rwx
 group::rwx
 other::r-x
 gaio@giovanni:/srv/users$ setfacl -m g:webmaster:rwx Webmaster
 setfacl: Webmaster: Operation not supported


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
