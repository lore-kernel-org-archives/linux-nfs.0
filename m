From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Data coherency trouble with multiple clients on2.6.14-rc5
Date: Mon, 7 Nov 2005 08:47:35 -0800
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E5F2@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZAAR-0003M1-AB
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 08:48:23 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EZAAQ-00015w-78
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 08:48:23 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> On Mon, 2005-11-07 at 08:08 -0800, Lever, Charles wrote:
>=20
> > in the case of "noac", OTW writes are always synchronous.  thus you
> > should never have the problem where concurrent async writes=20
> will obscure
> > server-side changes on "noac" mounts.
>=20
> However reads are not synchronous, nor are they ordered. You have no
> guarantee that the RPC READ call that filled the first page=20
> you read was
> handled by the server before the read that filled the next page.

yes, but the client can make use of WCC in the case where it's own
updates are always synchronous, right?


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
