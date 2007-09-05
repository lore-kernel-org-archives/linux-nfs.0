From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfs-utils crossmnt/fsid bug
Date: Wed, 5 Sep 2007 16:46:28 -0400
Message-ID: <20070905204628.GD29582@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IT1lc-0002Kx-UT
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 13:46:29 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IT1lf-0007OV-2d
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 13:46:32 -0700
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

With an exports entry like

	/exports *.citi.umich.edu(rw,crossmnt,fsid=0)

and some other stuff mounted under /exports, I get an odd situation
where listing /exports/submnt/ shows me the contents of /exports/.

I looks to me like what's happening is that the new code to
automatically export filesystems under crossmnt exports is exporting
those directories with the fsid option turned on, with the result that
the root of each of those subdirectories ends up with the same
filehandle as the root of /exports, and the hilarity ensues.  But I
haven't tried a patch yet.

Does that make sense?  I assume we should just clear the fsid flag on
submounts, as it's never going to make sense, and leave the logic
otherwise intact.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
