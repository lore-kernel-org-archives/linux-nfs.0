From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: extremely bad locking performance on 2.4.21-15.0.4.EL
Date: Mon, 16 Aug 2004 18:23:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092695033.11722.37.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0408161440170.4655@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bwpvq-0000qX-ES
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 15:26:22 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1Bwptx-0005Tv-0z
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 15:26:22 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0408161440170.4655@harp.ngdc.noaa.gov>
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

P=E5 m=E5 , 16/08/2004 klokka 17:17, skreiv Ara.T.Howard:

> in otherwords the nodes will get the lock at a very rapid rate and then
> experience a 30s timeout... is this normal?

30s is of the order of a soft timeout. I would guess it probably means
that something is going wrong with the GRANTED callback. Have you tried
turning on rpc_debug on the client? Use something like

sysctl -w sunrpc.rpc_debug=3D10
or
echo "10" >/proc/sys/sunrpc/rpc_debug

Note: thinking about this, I suspect that the 2.6 kernel is very likely
to have a similar problem due to the existance of the svcauth_unix.c
domain stuff. (That all belongs deep in the bowels of nfsd - not in the
RPC code). That can't be affecting the 2.4 kernel, though.

Cheers,
  Trond


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
