From: Christian Hammers <ch@westend.com>
Subject: NFS+DRBD+Postfix => corrupted queue file and NFS error=-116
Date: Mon, 9 Feb 2004 17:05:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040209160506.GG1873@westend.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqLef-000730-Bb
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 16:21:33 -0800
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1AqDuI-0007Rk-U7
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 08:05:10 -0800
Received: from mail3a.westend.com ([212.117.79.77] helo=mail3a1.westend.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqDuI-0004Tp-1W
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 08:05:10 -0800
To: nfs@lists.sourceforge.net
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

Hello

Today the below quoted messages started to appear about every couple of
hours and scare me.=20

Can you give me any hint which one is the cause and which the result, is
NFS corrupting Postfix or Postfix broken and doing illegal NFS
operations? What could be the reason, badblocks? A kernel bug? What to do=
?

thanks in advance,

-christian-=20

kernel: fh_verify: no root_squashed access at 5/5A6C3428A7.
postfix/local[5137]: warning: active/5/5A6C3428A7: unexpected EOF in data=
, record type 78 length 76
postfix/local[5137]: warning: corrupted queue file: active/5/5A6C3428A7
kernel: nfs_notify_change: revalidate failed, error=3D-116
postfix/local[5137]: fatal: mark_corrupt: fchmod active/5/5A6C3428A7: Sta=
le NFS file handle
postfix/qmgr[17687]: warning: premature end-of-input on private/local soc=
ket while reading input attribute name
postfix/qmgr[17687]: warning: private/local socket: malformed response
postfix/qmgr[17687]: warning: transport local failure -- see a previous w=
arning/fatal/panic logfile record for the problem description
postfix/local pid 5137 exit status 1
postfix/local: bad command startup -- throttling
postfix/qmgr[17687]: C82AF428B0: to=3D<pop.10909@mail3a1.westend.com>, or=
ig_to=3D<Thomas_Waber@insideout.de>, relay=3Dnone, delay=3D0, status=3Dde=
ferred (unknown mail transport error)

P.S.: A short description of the system:
Two servers are connected via crosslink cable and intel etherexpress
gigabit cards. Both have a mail partition that is synced in realtime via =
DRBD.
One has a NFS server exporting this DRBD share. Both have mounted this
NFS share to write their Postfix' mail data in different directories.=20
(Rationale: If one server fails, the data itself is present on the other
server)

--=20
Christian Hammers             WESTEND GmbH  |  Internet-Business-Provider
Technik                       CISCO Systems Partner - Authorized Reseller
                              L=FCtticher Stra=DFe 10      Tel 0241/70133=
3-11
ch@westend.com                D-52064 Aachen              Fax 0241/911879



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
