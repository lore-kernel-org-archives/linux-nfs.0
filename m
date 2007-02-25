From: M A Young <m.a.young@durham.ac.uk>
Subject: Re: NFS client fcntl locks going missing on FC6
Date: Sun, 25 Feb 2007 00:32:01 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.0702250017400.18669@vega3.dur.ac.uk>
References: <Pine.LNX.4.58.0702232223170.24593@vega3.dur.ac.uk>
	<45E073AB.2040005@RedHat.com>
	<Pine.LNX.4.58.0702241754030.21958@vega4.dur.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HL7JQ-0003n2-5n
	for nfs@lists.sourceforge.net; Sat, 24 Feb 2007 16:32:24 -0800
Received: from hermes2.dur.ac.uk ([129.234.8.21])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HL7JQ-0001EG-Pj
	for nfs@lists.sourceforge.net; Sat, 24 Feb 2007 16:32:26 -0800
In-Reply-To: <Pine.LNX.4.58.0702241754030.21958@vega4.dur.ac.uk>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

It seems I have mistaken the problem somewhat. The problem isn't as I
first thought that the lock isn't being created, as further checking shows
that the lock is created on both the client and the server. What goes
wrong in the case I have been seeing is that the unlock request sent to
the server has a new svid and so it doesn't remove the lock.

My new theory is that the problem occurs when a lock on a file fails the
first time (because the lock is blocked, and the system call subsequently
interrupted), but a subsequent locking attempt on the same file succeeds,
however somehow the system sees traces of the initial failure and as a
result the svid isn't recorded correctly.

	Michael Young

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
