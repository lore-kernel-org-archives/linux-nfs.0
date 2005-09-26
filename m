From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: NFS, cache coherency
Date: Mon, 26 Sep 2005 14:55:35 -0700
Message-ID: <1127771736.4984.21.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EK11t-0000jn-PO
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 15:00:57 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EK11s-0004tA-O1
	for nfs@lists.sourceforge.net; Mon, 26 Sep 2005 15:00:57 -0700
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


Where does NFS stand with cache coherency these days, across a variety
of NFS clients having a variety of distinct NFS implementations and
OS's?

Does flush/fflush still mean anything?

Do O_DSYNC, O_RSYNC, and O_SYNC work across platforms, and across NFS
versions, or are these more linux things?  What is their relationship?
(If it's in the open man page, just say so, and I'll happily RTFM, but
if the man page leaves some things out, I'd be very interested to hear
what)

What mount options are relevant?  actimeo?  What else?

If a file is created on NFS client A, and NFS client B needs to be able
to read it in short order, what general paths does the data traverse,
and what preconditions are necessary before B can see it?

Sorry if I've asked about subject matter for an essay :)  This stuff
came up in a meeting today, and I wanted to be sure I understand it
well.

Thanks!




-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
