From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: 6 patches
Date: Tue, 18 Jan 2005 13:06:09 -0500
Message-ID: <1106070956.b175e53d.0@fieldses.org>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cqxjs-0003jG-Ci
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 10:06:00 -0800
Received: from dh173.citi.umich.edu
	([141.211.133.173] helo=puzzle.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cqxjq-0004i6-UU
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 10:06:00 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

This is a resend (with one minor gss fix) of the patches to fix the problem
with callback authentication that prevents e.g. client-side nlm from working
properly.  These have been posted twice before; the first time I got some
feedback which I've incorporated.  The second time I didn't hear anything back.
So I think it's time to just apply these.  We've been running with them for a
while with on ill effects.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
