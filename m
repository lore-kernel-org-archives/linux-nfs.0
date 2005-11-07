From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: Data coherency trouble with multiple clients on
	2.6.14-rc5
Date: Mon, 07 Nov 2005 11:24:52 -0500
Message-ID: <1131380693.9094.23.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E5F1@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZ9qJ-000276-HG
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 08:27:35 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZ9qI-0003nD-1c
	for nfs@lists.sourceforge.net; Mon, 07 Nov 2005 08:27:35 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <044B81DE141D7443BCE91E8F44B3C1E288E5F1@exsvl02.hq.netapp.com>
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

On Mon, 2005-11-07 at 08:08 -0800, Lever, Charles wrote:

> in the case of "noac", OTW writes are always synchronous.  thus you
> should never have the problem where concurrent async writes will obscure
> server-side changes on "noac" mounts.

However reads are not synchronous, nor are they ordered. You have no
guarantee that the RPC READ call that filled the first page you read was
handled by the server before the read that filled the next page.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
