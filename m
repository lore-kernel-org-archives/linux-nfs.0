From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [autofs] Server/client mismatch over status of a mount ...
Date: Mon, 17 Feb 2003 07:20:36 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030217152036.GA23116@terminus.zytor.com>
References: <3E50EC51.6022D3A7@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from terminus.zytor.com ([63.209.29.3] ident=root)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18kn4X-0008Lf-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 07:20:45 -0800
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3E50EC51.6022D3A7@moving-picture.com>
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

>=20
> The clients mount the NFS disks using autofs
>=20
[...]
>=20
> I'm using a 2.4.18 based kernels on the client and server. The server i=
s
> using nfs-utils 0.3.3 and the client autofs 4.0.0pre10
>=20
> Could there be a case where automount tells the server it's umounting a
> mount, but then finds it can't actually do the umount?
>=20

Automount doesn't tell the server anything.  It's possible that
/bin/umount has this bug, however.

	-hpa
=20
--=20
PGP public key available - finger hpa@zytor.com
Key fingerprint: 2047/2A960705 BA 03 D3 2C 14 A8 A8 BD  1E DF FE 69 EE 35=
 BD 74
"The earth is but one country, and mankind its citizens."  --  Bah=E1'u'l=
l=E1h
Just Say No to Morden * The Shadows were defeated -- Babylon 5 is renewed=
!!


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
