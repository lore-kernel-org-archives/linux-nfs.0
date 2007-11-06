From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/15] Rewrite nfs(5) man page
Date: Mon, 05 Nov 2007 20:02:46 -0500
Message-ID: <20071106005731.5037.57716.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCqA-0004Yz-Df
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:02:50 -0800
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCqD-0005ex-Tj
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 17:02:56 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

As I was working on the new text-based mount.nfs command, I noticed a number
of inaccuracies in the nfs(5) man page.  I decided to update the section that
describes mount options to reflect what I believe to be implemented in the
current legacy mount.nfs ABI and in the new text-based implementation.

It also seemed prudent to provide some sections giving background about how
the mount options are used, and how the NFS client works in general.

This all ended up being a rather significant rewrite of nfs(5).

At this point I think we're ready for further review, and then to tuck it
into nfs-utils and have other people hack at it a bit more before the next
nfs-utils release.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
