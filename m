From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: mountd segmentation fault in nfs-utils-1.0.4 with 2.5.75-bk1
Date: Tue, 15 Jul 2003 07:52:28 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16147.9756.934649.916082@gargle.gargle.HOWL>
References: <OFB4201672.BB0C12E7-ON85256D63.00760144-86256D63.0077C456@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19cC2P-0006TE-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 15:43:17 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Tue, 15 Jul 2003 08:43:14 +1000
Received: from neilb by notabene with local (Exim 3.36 #1 (Debian))
	id 19cC2E-0007EB-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Jul 2003 08:43:06 +1000
To: "Robert Williamson" <robbiew@us.ibm.com>
Resent-Message-ID: <16147.12793.99236.954744@gargle.gargle.HOWL>
In-Reply-To: message from Robert Williamson on Monday July 14
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

On Monday July 14, robbiew@us.ibm.com wrote:
>=20
> The mountd daemon segmentation faults after receiving a mount request=
 from
> the client.  Checking /var/log/messages, I get some strange logs:
>=20
> Jul 14 16:17:25 vega rpc.mountd: authenticated mount request from
> \200a^U@\200a^U@H=E9^F^HH=E9^F^H\220a^U@\220a^U@\230a^U@\230a^U@=A0a^=
U@=A0a^U@,=E8^F^H,=E8^F^H=B0a^U@=B0a^U@,a^U@,a^U@Aa^U@Aa^U@Ea^U@Ea^U@Da=
^U@Da^U@Oa^U@Oa^U@=E0a^U@=E0a^U@=E8a^U@=E8a^U@oa^U@oa^U@oa^U@oa^U@:793
>  for /nfsserver/reiserfs (/nfsserver/reiserfs)
> Jul 14 16:17:25 vega rpc.mountd: MNT1(/nfsserver/ext2) called
>=20
>=20
> I attached an strace of the rpc.mountd pid during an unsuccessful mou=
nt
> request.  I can re-test this on 2.6.0-test1 if needed.

Thanks.
There is a stray 'free(hp)' at line 169 in utils/mountd/auth.c,
in the middle of auth_authenticate.
Could you remove that and try again? =20

NeilBrown



-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
