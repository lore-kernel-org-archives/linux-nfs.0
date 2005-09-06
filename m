From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Some code, and a question
Date: Tue, 06 Sep 2005 15:39:57 -0700
Message-ID: <1126046397.3000.188.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ECm7B-0007G3-Ra
	for nfs@lists.sourceforge.net; Tue, 06 Sep 2005 15:40:29 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ECm7A-0004GL-Nj
	for nfs@lists.sourceforge.net; Tue, 06 Sep 2005 15:40:29 -0700
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


OK, I know NFS isn't usually thought of as the fastest protocol under
the sun, but still, there are times when making NFS move along a little
faster can be worthwhile.

I've written a sort of NFS benchmark that I'm calling nfs-test.  It
tries a largish number of rsize's, wsize's, tcp vs udp, and version 2
or 3 (4 would be very easy to add), to see what gives the best
performance.  You can find it at
http://dcs.nac.uci.edu/~strombrg/nfs-test.html

My question is, before diving into trying to determine this empirically,
is there any theoretical reason why it would be better to have
rsize==wsize, or should it be better to just pick whatever rsize gives
the best read performance and pick whatever wsize gives the best write
performance, and not worry about if rsize!=wsize?

Thanks!




-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
