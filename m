From: Ian Kent <raven@themaw.net>
Subject: Re: mounting NFS with TCP option
Date: Mon, 13 Mar 2006 11:42:30 +0800 (WST)
Message-ID: <Pine.LNX.4.64.0603131142050.2349@eagle.themaw.net>
References: <a9ed420f0603070703x7a864804h9e6e2786b6dcdd19@mail.gmail.com>
 <200603071614.26647.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="822748769-190459245-1142221350=:2349"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FIdwr-00071c-E8
	for nfs@lists.sourceforge.net; Sun, 12 Mar 2006 19:42:21 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FIdwq-0006e0-S5
	for nfs@lists.sourceforge.net; Sun, 12 Mar 2006 19:42:21 -0800
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200603071614.26647.vincent.roqueta@ext.bull.net>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--822748769-190459245-1142221350=:2349
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 7 Mar 2006, Vincent Roqueta wrote:

> Le Mardi 7 Mars 2006 16:03, Vijay Chauhan a =E9crit=A0:
> > Hi,
> > im mounting a remote file system like this:
> > while [ "a" =3D=3D "a" ];
> > do
> > mount -t nfs -o tcp server:/file-system-path /mnt-point
> > umount -at nfs
> > done
> >
> > after few mounts it stop mounting the file system.
> >
> > Can anyone give any hints/suggestion
> > Also does tcp have any effect in this case?
> >
> > TIA,
> > Vijay
>=20
> Sorry... I haven't seen you where unmounting between each mount/umount.
> TCP port need a few seconds to be freed and reusable so :

60 seconds.

>=20
> Try this :
> while [ "a" =3D=3D "a" ];
>  do
>  mount -t nfs -o tcp server:/file-system-path /mnt-point
> sleep 2
>  umount -at nfs
>  done
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
> that extends applications into web and mobile media. Attend the live webc=
ast
> and join the prime developer group breaking into this new coding territor=
y!
> http://sel.as-us.falkag.net/sel?cmd______________________________________=
_________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--822748769-190459245-1142221350=:2349--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
