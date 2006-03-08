From: Marco Gaiarin <gaio@sv.lnf.it>
Subject: Re: ACL on NFS, how make it work?
Date: Wed, 8 Mar 2006 18:04:25 +0100
Message-ID: <20060308170425.GS8060@sv.lnf.it>
References: <20060303103806.GB8038@sv.lnf.it> <20060303163535.GB32552@fieldses.org> <20060306090557.GD8429@sv.lnf.it> <20060306152340.GA31408@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Andreas Gruenbacher <agruen@suse.de>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FH25b-0006nI-8V
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 09:04:43 -0800
Received: from mta072d.interbusiness.it ([85.37.17.72])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FH25X-0007pQ-H3
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 09:04:43 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060306152340.GA31408@fieldses.org>
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

> Actually I got one other NFS/XFS ACL complaint recently, and confirmed
> that with current kernels I'm able to get and set ext3 ACL's over NFS,
> and get and set XFS ACL's locally, but I can't use XFS ACL's over NFS.
> Which is odd--on a first glance it looks like the two filesystems expor=
t
> posix acl's through the same interface, etc.  I haven't had the chance
> to figure out what's going on yet....

If i can do something to debug that, say me.

Eg, better to recompile the server kernel with *client* ACL NFSv3
support?=20

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
