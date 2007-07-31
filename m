From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Tue, 31 Jul 2007 17:38:50 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzQX-0001Mg-RJ
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:38:50 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzQa-0007He-M3
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:38:53 -0700
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

	This set of patches adds -D/--diff-stat to nfsstat.  When this 
flag is used, instead of printing out the current total statistics and 
exiting, nfsstat takes a snapshot of the current statistics and pauses 
until the user types ^C, at which point a second snapshot is taken and 
only the difference between the two is printed; i.e., only the statistics 
gathered during the pause.

- patches 1 and 2 just pull out existing shared code into separate 
functions.

- patches 3 and 4 standardize existing variable names to make it easier to 
declare and use --diff-stat's set of temporary variables.

- patch 5 changes the existing declarations of the struct statinfos by 
using macros (again, to make adding --diff-stat's vars easier).

- patch 6 just declares the extra --diff-stat variables.

- patch 7 adds the rest of --diff-stat.


	The patches have been individually compile- and run-tested on 
2.6.19-rc5 and 2.6.22-rc5, and are based off of your current nfs-utils git 
tree.  The patches contain code written by people at CITI:

	Andrew Richardson <chardson@umich.edu>
	David M. Richter <richterd@citi.umich.edu>
	Alex Soule <soule@umich.edu>


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
