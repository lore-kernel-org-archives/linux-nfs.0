From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfs server patches for review
Date: Mon, 27 Aug 2007 16:22:41 -0400
Message-ID: <11882461763072-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl6z-0004hR-Kj
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:01 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl71-0003N6-I9
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:06 -0700
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


These are some nfs server patches I intend to submit for 2.6.24.

I'm also keeping this sort of thing in the nfs-server-stable branch, at

	git://linux-nfs.org/~bfields/linux.git	nfs-server-stable

That repository has a bunch of random other (mainly nfs-related)
projects, but that particular branch is reserved for nfsd patches that I expect
to be ready in time for the next merge window.  If you have something
nfsd-related that I've overlooked, please let me know.

Nothing earth-shaking here right now, just minor cleanups, bugfixes, and
support from Peter Staubach for reporting 64 bit inode numbers.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
