From: "Robert L. Millner" <rmillner@transmeta.com>
Subject: Re: NFS/UDP slow read, lost fragments
Date: Fri, 26 Sep 2003 22:02:05 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309261804400.28586-100000@localhost.localdomain>
References: <20030926170759.H787@muppet.kendall.corp.akamai.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A37UN-0003v3-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 22:19:27 -0700
Received: from neon-gw-l3.transmeta.com ([63.209.4.196] helo=neon-gw.transmeta.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A37UM-0000AG-Me
	for nfs@lists.sourceforge.net; Fri, 26 Sep 2003 22:19:26 -0700
Received: (from root@localhost)
	by neon-gw.transmeta.com (8.9.3/8.9.3) id WAA26958
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 22:02:16 -0700
Received: from draal.transmeta.com (draal.transmeta.com [10.10.26.54])
	by deepthought.transmeta.com (8.11.6/8.11.6) with ESMTP id h8R525g18146
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 22:02:05 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-Reply-To: <20030926170759.H787@muppet.kendall.corp.akamai.com>
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

> The following patch sets up a scheme of the form described by Brian,
> in combination with another fix to lengthen the window of time during
> which we accept updates to the RTO estimate (Karn's algorithm states
> that the window closes once you retransmit, whereas our current
> algorithm closes the window once a request times out).


Still seeing an inordinate number of retransmits (25% of the reads are
duplicates) with 2.4.23-pre5 and the patch on my test case (copy a 70MB
file from the server).

Its interesting to note that a dual P4 Xeon with an e1000 attached to the
same Foundry switch as the Netapp also has a similar retransmit rate
(20%).

If the same test is run against a different Netapp (running 6.3.1R1),
there's still a large number of retransmits but down to 17%.

Examining this problem further; if the server is Linux (stock Red Hat 7.3,
2.4.20-18.7smp, dual Xeon 2.4GhZ) then there are no retransmits and the
70MB copy takes its appropriate 6.4 sec with the client running either the
stock Red Hat kernel or a patched 2.4.23-pre5.

If the server is a Sun 880, running Solaris 8, then there are no
retransmits and the 70MB copy takes around 6.5 sec.

If the Netapp is placed under a heavy load (CPU at between 65% and 100% -
which traditionally kills Netapp performance), the 2.4.23-pre5+patch
client has roughly the same percentage of retransmits as it does against
an otherwise quiescent Netapp; however, the test takes 470 seconds instead
of 550 seconds.


As a sanity check against transient network problems, the problem still
consistently goes away if the client boots 2.2.19 and consistently repeats
if the client boots 2.4.23-pre5+patch.


I guess the next step is to go over packet dumps from both the client and
another host on a mirrored network port to see what's interesting about
the fragments being dropped.  That may point to why a heavily loaded
Netapp performs this test faster than a quiescent one.


	Rob




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
