From: "Edward Hibbert" <Edward.Hibbert@dataconnection.com>
Subject: Flushing of cached data on NFS server
Date: Tue, 14 Jun 2005 11:35:03 +0100
Message-ID: <9E621559095AA746B22B21CD4FAF99A521A642@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Di8lG-0008Sp-0E
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 03:35:14 -0700
Received: from smtp.dataconnection.com ([192.91.191.4])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Di8lE-00072Y-Gm
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 03:35:13 -0700
To: <nfs@lists.sourceforge.net>
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

We're running against a Linux-based NFS server (actually a SNAP filer).  =
What we see is that when its cache gets full, it flushes out the data =
using bdflush, as you'd expect.  This may take several seconds, and =
during this time responsiveness dives - NFS operations take several =
seconds, RPC retransmissions start happening, and so on.

What I'd like is a way of tuning the server to remain responsive at all =
times (e.g. by more regular flushing).  I've had a play with bdflush =
parameters, but it's kind of stabbing in the dark and I'm not, erm, =
drawing blood.

Does anyone have any experience at tuning NFS servers for consistently =
low latency?

Regards,

Edward.


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
