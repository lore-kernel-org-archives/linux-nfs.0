From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Authenticated NFS mounts
Date: Tue, 18 Oct 2005 08:26:52 -0700
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E56F@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERtMp-0007Iy-8N
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 08:27:07 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ERtMm-0000fn-Qx
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 08:27:07 -0700
To: "Sven Geggus" <sven@geggus.net>
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

> Section A5 of the Linux NFS FAQ (Can I use Kerberos=20
> authentication with NFS
> on Linux?) is somewhat confusing as it the Answer is not=20
> clearly yes or no.
>=20
> So whats the current Answer to this simple Question:
>=20
> Is ist possible to use RPCSEC GSSAPI in conjunction with=20
> NFSv3 on Linux
> Clients and Servers?

it depends on which client kernel you are using.

there are some GSS and NLM bugs that prevent Kerberos authentication
from working with NFSv3 in kernels earlier than 2.6.12.


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
