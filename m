From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Random UDP port assignment for rpc.statd
Date: Sun, 20 Feb 2005 12:38:34 -0500
Message-ID: <1108921114.27120.51.camel@lade.trondhjem.org>
References: <20050220111312.GA3974@s>  <20050220172131.GA19800@s>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2v2f-0001CA-Nr
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 09:38:49 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D2v2d-00042t-Vg
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 09:38:49 -0800
Received: from mail-mx1.uio.no ([129.240.10.29] ident=[U2FsdGVkX1/TF4z5ypjkvXbQmh7PdsEDRWjRL3q/bqw=])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1D2v2Z-0005ov-Kq
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 18:38:43 +0100
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20050220172131.GA19800@s>
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

su den 20.02.2005 Klokka 18:21 (+0100) skreiv Haakon Riiser:
> > Btw, there's also a similar problem with nfsd:  In addition to
> > the standard listening port at 2049, it always opens a random
> > port in the high port range (32000-32768 or something like that).
> 
> I almost forgot this one.  Does nfsd's mystery UDP port have the
> same purpose as the one from statd, i.e. communication with the
> portmapper?

Which nfsd? knfsd or the userland server?

The nfsd also needs to register with the portmapper, but again, that
should close immediately after use. There should be no UDP ports kept
open other than 2049.

The lockd daemon needs an extra port, but you can control that (and this
control mechanism _should_ work) using the pseudofiles
in /proc/sys/fs/nfs, or the kernel parameters lockd.udpport and
lockd.tcpport.

Cheers,
 Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
