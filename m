From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS server restarted, clients hang forever. Why?
Date: Mon, 04 Apr 2005 16:10:05 -0400
Message-ID: <1112645405.10602.136.camel@lade.trondhjem.org>
References: <20050404195156.31610.qmail@web25607.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIXts-0006Z7-8e
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 13:10:20 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DIXtq-0007WK-O7
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 13:10:20 -0700
To: Anders Andersson <molntapp@yahoo.se>
In-Reply-To: <20050404195156.31610.qmail@web25607.mail.ukl.yahoo.com>
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

m=C3=A5 den 04.04.2005 Klokka 21:51 (+0200) skreiv Anders Andersson:
> Hi all,
>=20
> Recently nfsd was stopped on one of our servers due to
> some maintenance issues on the underlying filesystem.
> The clients hung, wating for it to come back. But when
> nfsd et al. (portmapper, statd etc.) was back up
> again, the clients never recovered. In fact, nothing
> we could do would let us recover. Eventually, we
> resorted to reboot -f on some 100 clients.
>=20
> I'd greatly appreciate any input on
>=20
> - why non-recoverable NFS client hangs happens
> - how to avoid them, even if the server reboots

To summarize, the rule is that the clients should be able to recover
from anything that doesn't involve changing the underlying filesystem,
changing the file inode numbers (particularly not on the root
directory), or change the fsid (as reported by statfs or as overridden
by the "fsid" option in the /etc/exports file).

Note that certain filesystems are unable to store permanent inode
numbers, and so may not recover at all. See
  http://nfs.sourceforge.net/#faq_c6

Another good source of non-recoverable NFS client hangs is, of course,
poorly configures firewalls/port filters... See
  http://nfs.sourceforge.net/nfs-howto/security.html#FIREWALLS

Cheers,
 Tronds

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
