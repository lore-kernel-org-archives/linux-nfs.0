From: "Robert Williamson" <robbiew@us.ibm.com>
Subject: Re: mountd segmentation fault in nfs-utils-1.0.4 with 2.5.75-bk1
Date: Mon, 14 Jul 2003 17:08:12 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF039BB678.312D48E6-ON85256D63.0079739A-86256D63.0079BFA2@pok.ibm.com>
References: <16147.9756.934649.916082@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e6.ny.us.ibm.com ([32.97.182.106])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19cBTV-0003O8-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 15:07:14 -0700
In-Reply-To: <16147.9756.934649.916082@gargle.gargle.HOWL>
To: nfs@lists.sourceforge.net
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


Works!  Thanks for the quick response.  I saw that free(hp), and wonder=
ed
why it seemed a bit out of place, but figured I'd post first.


Robert V. Williamson <robbiew@us.ibm.com>
Linux Test Project
IBM Linux Technology Center
Web: http://ltp.sourceforge.net
IRC: #ltp on freenode.irc.net
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
"Only two things are infinite, the universe and human stupidity, and I'=
m
not sure about the former." -Albert Einstein


                                                                       =
                                                             =20
                      Neil Brown                                       =
                                                             =20
                      <neilb@cse.unsw.e        To:       Robert William=
son/Austin/IBM@IBMUS                                         =20
                      du.au>                   cc:       nfs-list@lists=
.sourceforge.net                                             =20
                                               Subject:  Re: mountd seg=
mentation fault in nfs-utils-1.0.4 with 2.5.75-bk1           =20
                      07/14/2003 04:52                                 =
                                                             =20
                      PM                                               =
                                                             =20
                                                                       =
                                                             =20




On Monday July 14, robbiew@us.ibm.com wrote:
>
> The mountd daemon segmentation faults after receiving a mount request=

from
> the client.  Checking /var/log/messages, I get some strange logs:
>
> Jul 14 16:17:25 vega rpc.mountd: authenticated mount request from
>
\200a^U@\200a^U@H=E9^F^HH=E9^F^H\220a^U@\220a^U@\230a^U@\230a^U@=A0a^U@=
=A0a^U@,=E8^F^H,=E8^F^H=B0a^U@=B0a^U@,a^U@,a^U@Aa^U@Aa^U@Ea^U@Ea^U@Da^U=
@Da^U@Oa^U@Oa^U@=E0a^U@=E0a^U@=E8a^U@=E8a^U@oa^U@oa^U@oa^U@oa^U@:793

>  for /nfsserver/reiserfs (/nfsserver/reiserfs)
> Jul 14 16:17:25 vega rpc.mountd: MNT1(/nfsserver/ext2) called
>
>
> I attached an strace of the rpc.mountd pid during an unsuccessful mou=
nt
> request.  I can re-test this on 2.6.0-test1 if needed.

Thanks.
There is a stray 'free(hp)' at line 169 in utils/mountd/auth.c,
in the middle of auth_authenticate.
Could you remove that and try again?

NeilBrown


=




-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
