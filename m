From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: max number of NFS mounts
Date: Tue, 8 Apr 2003 06:28:38 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D554CA@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 192t9n-0004Zr-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Apr 2003 06:28:59 -0700
To: "Robin Humble" <rjh@cita.utoronto.ca>
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

hi robin-

> We have a large linux cluster with 256 backend nodes, 10 development
> nodes, plus a few other mounts/machines of various sorts.
>=20
> When using autofs in an attempt to mount all backend disks at once we
> hit the 256 mounts limitation and only get to about 246 backend disks
> mounted - this is a pain :-/
>=20
> so yes, your message (that I eventually found via Neil Brown) was most
> helpful and please add it to the FAQ and also into=20
> linux/Documentation/*
> somewhere.
>   http://sourceforge.net/mailarchive/message.php?msg_id=3D4215392

a new FAQ is planned to address this issue.  thanks for the
suggestion!


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
