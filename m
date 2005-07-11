From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: FYI: readdirplus responsiveness problem after 2.4 -> 2.6 client upgrade
Date: Mon, 11 Jul 2005 18:51:47 +0200
Message-ID: <20050711165147.GB20471@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ds1Vc-0003Is-K0
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 09:51:56 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Ds1Vc-0004Sj-7y
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 09:51:56 -0700
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
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

Server is tru64 (OSF1 server V5.1 1885 alpha) using advfs.

client:
After replacing a 2.4.29 kernel by a 2.6 (.11) we started to notice
unresponsiveness in bash command- and name completion once in a while.
This still persists in 2.6.12.2.

A few quick investigations pointed to the readdir -> readdirplus
change. The following tcpdump snippets illustrates this (first column
is differential time in usec with previous packet):

example 1:
------
000093 ip 230: client.3377456114 > server.nfs: 188 readdirplus fh 4079,976512/13921 512 bytes @ 0x000000000 (DF)
645029 ip 1514: server.nfs > client.3377456114: reply ok 1472 readdirplus (frag 19592:1480@0+)
000058 ip 778: server > client: udp (frag 19592:744@1480)
------

example 2:
------
000094 ip 230: client.743433202 > server.nfs: 188 readdirplus fh 4079,976512/404 512 bytes @ 0x000000000 (DF)
102655 ip 230: client.743433202 > server.nfs: 188 readdirplus fh 4079,976512/404 512 bytes @ 0x000000000 (DF)
205974 ip 230: client.743433202 > server.nfs: 188 readdirplus fh 4079,976512/404 512 bytes @ 0x000000000 (DF)
248905 ip 1514: server.nfs > client.743433202: reply ok 1472 readdirplus (frag 58739:1480@0+)
000085 ip 1106: server > client: udp (frag 58739:1072@1480)

000128 ip 1514: server.nfs > client.743433202: reply ok 1472 readdirplus (frag 58740:1480@0+)
000057 ip 230: client.760210418 > server.nfs: 188 readdirplus fh 4079,976512/404 512 bytes @ 0x0000001e4 (DF)
000028 ip 1106: server > client: udp (frag 58740:1072@1480)

000125 ip 1514: server.nfs > client.743433202: reply ok 1472 readdirplus (frag 58741:1480@0+)
000088 ip 1106: server > client: udp (frag 58741:1072@1480)

022016 ip 506: server.nfs > client.760210418: reply ok 464 readdirplus
------

AFAICS this only shows a (sometimes) slow responding server. In the second
example the client appears to be retransmitting much sooner than in the
first example. Don't know if this can be true or that the differential
timestamps are fooling me.

In practice there are a significant number of cases without retransmission
when the server appears unresponsive to the user with readdirplus. Since
it is induced by bash name completion it is very visible to the user:
occasionally command-completion takes 3..10 seconds now to give an idea.
Name completion for arguments is hurt too sometimes.

A quick peek into the source suggested:

-	reduce NFS_LIMIT_READDIRPLUS?
-	"recognize" name-completion kind of use and revert
	NFS_INO_ADVISE_RDPLUS?

Other options (except replacing the server)?

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
