From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: (no subject)
Date: Mon, 10 Mar 2003 08:32:28 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55371@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sQCd-0000Nh-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Mar 2003 08:32:39 -0800
To: "Steve Salazar" <eagsalazar@hotmail.com>
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

hi steve-

the limitation you point out below is real, and would be
addressed by Kerberos authentication.  however...

Linux NFS does not support RPCSEC mechanisms in the stable
kernel at the moment.  that support is going into the
development kernel (2.5) over the next few months, and
will be available in a stable kernel when 2.6 appears, at
least for NFSv4.  if we're all very very good, RPCSEC may
also be supported for the older versions of NFS too.

> -----Original Message-----
> From: Steve Salazar [mailto:eagsalazar@hotmail.com]
> Sent: Sunday, March 09, 2003 2:58 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] (no subject)
>=20
>=20
> I have been reading the nfs documentation and mailing lists=20
> and it is not=20
> clear to me whether the current nfs implementation supports kerberos=20
> authentication or not.  There is nothing about that in the=20
> howto but in the=20
> mailing list I see repeated references to "NFS using=20
> RPCSEC_GSS".  However,=20
> I haven't found any documentation on this either.
>=20
> This issue mentioned in the howto:
>=20
> "But the root user on the client can still use su to become=20
> any other user=20
> and access and change that users files!" say you. To which=20
> the answer is:=20
> Yes, and that's the way it is, and has to be with Unix and=20
> NFS. This has one=20
> important implication: All important binaries and files=20
> should be owned by=20
> root, and not bin or other non-root account, since the only=20
> account the=20
> clients root user cannot access is the servers root account.
>=20
> will not work for for our setup.  We have kerberos in place=20
> for logins on=20
> our linux/solaris/windows network and a kerberized samba but=20
> so far we have=20
> no good solution for nfs since we will definitely need to=20
> allow local root=20
> on the linux workstations on our network.
>=20
> Could anyone point me at some good documentation on how to=20
> deploy nfs using=20
> kerberos?  Thanks in advance for any info.
>=20
>=20
>=20
> _________________________________________________________________
> The new MSN 8: advanced junk mail protection and 2 months FREE* =20
> http://join.msn.com/?page=3Dfeatures/junkmail
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: Etnus, makers of=20
> TotalView, The debugger=20
> for complex code. Debugging C/C++ programs can leave you=20
> feeling lost and=20
> disoriented. TotalView can help you find your way. Available=20
> on major UNIX=20
> and Linux platforms. Try it free. www.etnus.com
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
