From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Random UDP port assignment for rpc.statd
Date: Sun, 20 Feb 2005 12:13:12 +0100
Message-ID: <20050220111312.GA3974@s>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2p1j-0006zx-R3
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 03:13:27 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D2p1i-0004Bz-9A
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 03:13:27 -0800
Received: from mail-mx3.uio.no ([129.240.10.44] ident=[U2FsdGVkX1+N8TnNm6Bpg5CWjVW1xKZS4LKQY0RuoOo=])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1D2p1b-00065w-N2
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 12:13:19 +0100
Received: from 160.80-203-48.nextgentel.com ([80.203.48.160] helo=s.hn.org)
	by mail-mx3.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1D2p1a-0000Zp-9F
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 12:13:18 +0100
To: nfs@lists.sourceforge.net
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

Why isn't it possible to specify all of statd's listening ports
using the -p flag?  It works for the TCP port and one of the
UDP ports, but there is always one more listening UDP port that
is randomly assigned.  I googled around for information on this
problem, and came up with this Debian bug report:

  http://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg11985.html

The thread ends with "I think we may have a real bug", but this
was reported in 1.0.6, and the problem still persists in 1.0.7,
so I was wondering if this isn't a bug after all.

Btw, there's also a similar problem with nfsd:  In addition to
the standard listening port at 2049, it always opens a random
port in the high port range (32000-32768 or something like that).

In case it matters:  I'm using Linux 2.6.10 and Slackware 10.1.

-- 
 Haakon


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
