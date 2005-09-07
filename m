From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Multiple mounts of the same filesystem
Date: Wed, 07 Sep 2005 16:12:36 -0700
Message-ID: <1126134757.16701.82.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ED96Q-0004Z6-2J
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 16:13:14 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ED96O-0005tI-BZ
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 16:13:14 -0700
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


As I was doing the previously-mentioned NFS+QFS+gigabit performance
testing, I got to thinking that it may be faster to sometimes have as
many as 3 NFS mounts of the filesystem: One with read speed optimized,
one with write speed optimized, and one with a balance of the two.

The client I'm working on this for isn't interested in the additional
complication for his users, but I hope someone who -does- have an
environment where every least ounce of performance is importance, might
interested in exploring the idea further.

I have a bit of a writeup of a few different mounting schemes included
at:

http://dcs.nac.uci.edu/~strombrg/nfs-test.html

HTH someone.





-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
