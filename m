From: Philippe Troin <phil@fifi.org>
Subject: Wierd NFS hangs
Date: 25 Jan 2005 18:07:24 -0800
Message-ID: <87is5lkko3.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ctcab-0005JL-IG
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 18:07:25 -0800
Received: from dsl081-251-130.sfo1.dsl.speakeasy.net
	([64.81.251.130] helo=tantale.fifi.org ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ctcaa-0001W9-Uh
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 18:07:25 -0800
Received: from ceramic.fifi.org (Debian-exim@ceramic.fifi.org [64.81.251.131])
	by tantale.fifi.org (8.9.3p2/8.9.3/Debian 8.9.3-21) with ESMTP id SAA22988
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 18:07:24 -0800
Received: from phil by ceramic.fifi.org with local (Exim 4.34)
	id 1Ctcaa-0004b9-3R
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 18:07:24 -0800
To: linux-nfs <nfs@lists.sourceforge.net>
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

I have two machines A and B on the same ethernet segment.

  A is an opteron running 32-bit linux with a Gig-E adapter.

  B is a laptop with a 100Mbit PCMCIA adapter.

  Between A and B is a GigE switch.

I mount on B an exported ZIP drive from A with these options (from
/proc/mounts):

  A:/zip /zip nfs rw,nosuid,nodev,v3,rsize=8192,wsize=8192,hard,intr,tcp,lock,addr=A 0 0

  (note: tcp is used)

/zip is exported in A with these options:

  /zip a.b.c.d/e(rw,async,no_root_squash,no_subtree_check,mp)

Sometimes, when I read files on the remote filesystem (on B), NFS
hangs from long periods of time.

A's kernel log does not say anything.

B's kernel log says:

  nfs: server A not responding, still trying

I've generated a tcpdump on A and B and no packets are lost.  The TCP
stream just stops.  Here's a tcpdump dump:

1106647558.418501 B.4258126176 > A.nfs: 108 read fh Unknown/1 8192 bytes @ 0x0001d2000 (DF) (ttl 64, id 6286, len 160)
1106647558.418529 A.nfs > B.4258126176: reply ok 1448 read REG 100644 ids 0/0 sz 0x0003e5e9d nlink 1 rdev 0/0 fsid 0x000000000 nod
eid 0x000000000 a/m/ctime 1106647558.000000 1105472897.000000 1105472897.000000 8192 bytes (DF) (ttl 64, id 19495, len 1500)
1106647558.418535 A.nfs > B.2161186422: reply ERR 1448 (DF) (ttl 64, id 19496, len 1500)
1106647558.418544 A.nfs > B.297611537: reply ERR 1448 (DF) (ttl 64, id 19497, len 1500)
1106647558.418550 A.nfs > B.2550353087: reply ERR 1448 (DF) (ttl 64, id 19498, len 1500)
1106647558.418556 A.nfs > B.3372875739: reply ERR 1448 (DF) (ttl 64, id 19499, len 1500)
1106647558.418561 A.nfs > B.2953689187: reply ERR 1084 (DF) (ttl 64, id 19500, len 1136)
1106647558.424390 B.798 > A.2049: . [tcp sum ok] 1404:1404(0) ack 116537 win 63712 <nop,nop,timestamp 332654 358262> (DF) (ttl 64,
 id 6287, len 52)
1106647558.424555 B.798 > A.2049: . [tcp sum ok] 1404:1404(0) ack 119433 win 63712 <nop,nop,timestamp 332654 358262> (DF) (ttl 64,
 id 6288, len 52)
1106647558.424722 B.798 > A.2049: . [tcp sum ok] 1404:1404(0) ack 121965 win 63712 <nop,nop,timestamp 332654 358262> (DF) (ttl 64,
 id 6289, len 52)
1106647558.428504 B.4274903392 > A.nfs: 108 read fh Unknown/1 8192 bytes @ 0x0001d4000 (DF) (ttl 64, id 6290, len 160)
1106647558.428532 A.nfs > B.4274903392: reply ok 1448 read REG 100644 ids 0/0 sz 0x0003e5e9d nlink 1 rdev 0/0 fsid 0x000000000 nod
eid 0x000000000 a/m/ctime 1106647558.000000 1105472897.000000 1105472897.000000 8192 bytes (DF) (ttl 64, id 19501, len 1500)
1106647558.428538 A.nfs > B.1973115079: reply ERR 1448 (DF) (ttl 64, id 19502, len 1500)
1106647558.428544 A.nfs > B.2655303445: reply ERR 1448 (DF) (ttl 64, id 19503, len 1500)
1106647558.428550 A.nfs > B.1784565653: reply ERR 1448 (DF) (ttl 64, id 19504, len 1500)
1106647558.428555 A.nfs > B.484233141: reply ERR 1448 (DF) (ttl 64, id 19505, len 1500)
1106647558.428560 A.nfs > B.2214495492: reply ERR 1084 (DF) (ttl 64, id 19506, len 1136)
1106647558.434392 B.798 > A.2049: . [tcp sum ok] 1512:1512(0) ack 124861 win 63712 <nop,nop,timestamp 332655 358263> (DF) (ttl 64,
 id 6291, len 52)
1106647558.434558 B.798 > A.2049: . [tcp sum ok] 1512:1512(0) ack 127757 win 63712 <nop,nop,timestamp 332655 358263> (DF) (ttl 64,
 id 6292, len 52)
1106647558.434724 B.798 > A.2049: . [tcp sum ok] 1512:1512(0) ack 130289 win 63712 <nop,nop,timestamp 332655 358263> (DF) (ttl 64,
 id 6293, len 52)
1106647564.269053 B.1913389056 > A.nfs: 40 null (DF) (ttl 64, id 0, len 68)
1106647564.269077 A.nfs > B.1913389056: reply ok 24 null (DF) (ttl 64, id 0, len 52)
1106647594.771696 B.2450259968 > A.nfs: 40 null (DF) (ttl 64, id 0, len 68)
1106647594.771721 A.nfs > B.2450259968: reply ok 24 null (DF) (ttl 64, id 0, len 52)
1106647624.774217 B.2987130880 > A.nfs: 40 null (DF) (ttl 64, id 0, len 68)
1106647624.774240 A.nfs > B.2987130880: reply ok 24 null (DF) (ttl 64, id 0, len 52)
1106647654.776828 B.3524001792 > A.nfs: 40 null (DF) (ttl 64, id 0, len 68)
1106647654.776856 A.nfs > B.3524001792: reply ok 24 null (DF) (ttl 64, id 0, len 52)
1106647684.779271 B.4060872704 > A.nfs: 40 null (DF) (ttl 64, id 0, len 68)
1106647684.779306 A.nfs > B.4060872704: reply ok 24 null (DF) (ttl 64, id 0, len 52)
1106647714.781907 B.302841856 > A.nfs: 40 null (DF) (ttl 64, id 0, len 68)
1106647714.781952 A.nfs > B.302841856: reply ok 24 null (DF) (ttl 64, id 0, len 52)
1106647737.473919 B.4023245152 > A.nfs: 108 read fh Unknown/1 8192 bytes @ 0x0001b6000 (DF) (ttl 64, id 6294, len 160)
1106647737.474019 A.nfs > B.4023245152: reply ok 1448 read REG 100644 ids 0/0 sz 0x0003e5e9d nlink 1 rdev 0/0 fsid 0x000000000 nod
eid 0x000000000 a/m/ctime 1106647737.000000 1105472897.000000 1105472897.000000 8192 bytes (DF) (ttl 64, id 19507, len 1500)
1106647737.474025 A.nfs > B.1512933099: reply ERR 1448 (DF) (ttl 64, id 19508, len 1500)
1106647737.474029 A.nfs > B.306287254: reply ERR 1448 (DF) (ttl 64, id 19509, len 1500)
1106647737.474132 B.4040022368 > A.nfs: 108 read fh Unknown/1 8192 bytes @ 0x0001b8000 (DF) (ttl 64, id 6295, len 160)
1106647737.477286 B.798 > A.2049: . [tcp sum ok] 1728:1728(0) ack 133185 win 63712 <nop,nop,timestamp 350558 376166> (DF) (ttl 64,
 id 6296, len 52)
1106647737.477292 A.nfs > B.2302085595: reply ERR 1448 (DF) (ttl 64, id 19510, len 1500)
1106647737.477295 A.nfs > B.940755939: reply ERR 1448 (DF) (ttl 64, id 19511, len 1500)
1106647737.477298 A.nfs > B.463730422: reply ERR 1448 (DF) (ttl 64, id 19512, len 1500)
1106647737.480502 B.798 > A.2049: . [tcp sum ok] 1728:1728(0) ack 136081 win 63712 <nop,nop,timestamp 350558 376166> (DF) (ttl 64,
 id 6297, len 52)
1106647737.480506 A.nfs > B.343065405: reply ERR 1448 (DF) (ttl 64, id 19513, len 1500)
1106647737.480509 A.nfs > B.2382731467: reply ERR 1448 (DF) (ttl 64, id 19514, len 1500)
1106647737.480513 A.nfs > B.3483552453: reply ERR 1448 (DF) (ttl 64, id 19515, len 1500)
1106647737.480671 B.798 > A.2049: . [tcp sum ok] 1728:1728(0) ack 138977 win 63712 <nop,nop,timestamp 350558 376167> (DF) (ttl 64,
 id 6298, len 52)
1106647737.480675 A.nfs > B.3984834728: reply ERR 1448 (DF) (ttl 64, id 19516, len 1500)
1106647737.480678 A.nfs > B.1230666333: reply ERR 1448 (DF) (ttl 64, id 19517, len 1500)
1106647737.480681 A.nfs > B.2201104454: reply ERR 720 (DF) (ttl 64, id 19518, len 772)
1106647737.486208 B.798 > A.2049: . [tcp sum ok] 1728:1728(0) ack 141873 win 63712 <nop,nop,timestamp 350559 376167> (DF) (ttl 64,
 id 6299, len 52)
1106647737.486374 B.798 > A.2049: . [tcp sum ok] 1728:1728(0) ack 144769 win 63712 <nop,nop,timestamp 350559 376167> (DF) (ttl 64,
 id 6300, len 52)
1106647737.486539 B.798 > A.2049: . [tcp sum ok] 1728:1728(0) ack 146937 win 63712 <nop,nop,timestamp 350559 376167> (DF) (ttl 64,
 id 6301, len 52)

Note how the NFS READ traffic are stop between time 1106647558.434724
and 1106647737.473919.  There are some extra UDP NULL requests in
between these two times sent by the amd automounter, and the server
honors them.

Tcpdump file available upon request.

Phil.


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
