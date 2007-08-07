From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 0/5] nfsstat: more --diff-stat/--sleep items
Date: Tue, 7 Aug 2007 19:52:24 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708071928330.26009@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIYqd-0006J2-FG
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:52:23 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIYqg-0005yC-Ah
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:52:27 -0700
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

	Hello, Neil, 

	This set of patches fills in some holes from the initial 
--diff-stat work.  The first patch maybe should be separate, but the third 
patch makes use of it (but could easily be reworked).


- patch 1 adds three counters to the client v4 ops display -- GETACL, 
SETACL, and FS_LOCATIONS, which are available in /proc/net/rpc/nfs but 
haven't been used.

- patch 2 adds, at your suggestion, a comment clarifying what has_stats() 
is actually doing.

- patch 3 fixes a bug in diff_stats() that causes false-positives in 
has_stats().

- patch 4, as Bruce Fields suggested, renames -D/--diff-stat to 
the (hopefully) more intuitive -Z/--sleep.

- patch 5 adds -Z/--sleep to the nfsstat manpage.


	thanks kindly,

	d
	.

_____
 david m. richter
 CITI -- Center for Information Technology Integration
 http://www.citi.umich.edu

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
