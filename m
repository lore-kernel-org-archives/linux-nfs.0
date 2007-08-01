From: "david m. richter" <richterd@citi.umich.edu>
Subject: nfsstat: include counts for GETACL, SETACL, FS_LOCATIONS?
Date: Wed, 1 Aug 2007 17:43:37 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708011727030.18305@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGLyj-0007n6-0i
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 14:43:37 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGLyk-0001C5-RM
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 14:43:41 -0700
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

	hello, neil,

	in fixing the has_stats()'s-false-positives bug, i've come across 
some existing assumptions in the code about the number of elements in a 
given stat type -- e.g., the number of NFSv4 client "operations" being 
tallied.

	in that specific case, three new counts in /proc/net/rpc/nfs have 
been added that nfsstat doesn't currently acknowledge: GETACL, SETACL, and 
FS_LOCATIONS, i believe.  

	the manner in which i fix the has_stats() bug depends on how 
closely nfsstat is intended to stay synchronized with the data in 
/proc/net/rpc/nfs.  since these aren't actual NFSv4 procedures, i'm not 
quite sure what folks expect.

	please let me know what you think.


	thanks,

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
