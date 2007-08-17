From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [PATCH] nfsstat: without option nfsstat always output the
 statistics of Client NFS v4( though sometimes they are all zero)
Date: Fri, 17 Aug 2007 11:04:29 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708171056030.32037@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuli <chul@cn.fujitsu.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IM3NE-0005wi-0c
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 08:04:28 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IM3NH-0006Rl-3L
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 08:04:32 -0700
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

> Hi,
> 
>    There is a bug when using nfsstat without options, the Client NFS 
> v4's statistics always are output.
>     Actually it should be output when they are all zero.
>     I looked up into the code and found it says "NFSv4 call counts ([0] 
> == 32)", but it is 35 in "/proc/net/rpc/nfs".

	hello,

	good eyes -- those extra calls are getacl, setacl, and 
fs_locations counts.  it's already been fixed in the git tree at 
git://linux-nfs.org/nfs-utils.


	cheers,

	d
	.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
