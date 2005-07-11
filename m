From: mhaverkamp@kcp.com
Subject: Re: mount NFS take so long....
Date: Mon, 11 Jul 2005 10:29:33 -0500
Message-ID: <OF61440092.E711757E-ON8625703B.0054E484-8625703B.00551AA0@kcp.com>
References: <1120881745.16846.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Cc: NFS@lists.sourceforge.net, nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <1120881745.16846.2.camel@localhost.localdomain>
To: esqueleto@tusofona.com
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

I don't know about Ubuntu, but I have seen this problem before on Gentoo=20
if "portmap" wasn't running.

e.g.

 /etc/init.d/portmap start
mount ...

Michael Haverkamp

nfs-admin@lists.sourceforge.net wrote on 07/08/2005 11:02:25 PM:

> Hello
>=20
> I've try Fedora / Mandrake /Gentoo and now I have Ubuntu (for the 2=BA
> time).
>=20
> In every Distros to mount NFS mount point I had no problem and the
> operation was in a click.
>=20
> With Ubuntu, for each mount I have to wait, at least, 2 or 3 minutes.
> This is very odd and because of that I want to know if any one have the
> same problem and how did you resolve it.
>=20
> This is a Ubuntu of NFS version problem??
>=20
>=20
> tkx in advance
> Paulo Aboim Pinto
> Odivelas - Portugal
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by the 'Do More With Dual!' webinar=20
happening
> July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
> core and dual graphics technology at this free one hour event hosted by=20
HP,=20
> AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
> =5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=
=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F=5F
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
