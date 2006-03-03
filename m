From: Marco Gaiarin <gaio@sv.lnf.it>
Subject: ACL on NFS, how make it work?
Date: Fri, 3 Mar 2006 11:38:06 +0100
Message-ID: <20060303103806.GB8038@sv.lnf.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>,
	"J. Bruce Fields" <bfields@umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FF7fw-0007Uu-PC
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 02:38:20 -0800
Received: from mta065b.interbusiness.it ([85.37.17.65])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FF7fv-0006Ah-BH
	for nfs@lists.sourceforge.net; Fri, 03 Mar 2006 02:38:20 -0800
To: Andreas Gruenbacher <agruen@suse.de>
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


Sorry for this mail, directly to (as source said ;) nfs3 and nfs4
kernel developers, but i'm completely stopped trying to make acl work
via nfs.

For a little nonprofit organization i've setup a little network, with a
server (debian sarge, with samba3 and nfs), a windows client (some
legacy app...) and two ubuntu client.

The windows client and the ubuntu client share the same files, one via
samba (and ACL), the other via nfs.


I've tried all the options (there's only an ``noacl'' options, not an
``acl'' one...), i've verified with nfsstat that i was using nfs3, i've
done all i think is useful with no luck.


There's at least some kernel options, programs, mount switch ... with i
can debug this?


Please, help me. ;)

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
