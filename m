From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/4] NFS: Support multi-segment direct I/O
Date: Mon, 12 Nov 2007 14:02:11 -0500
Message-ID: <1194894131.7465.43.camel@heimdal.trondhjem.org>
References: <20071112171404.3053.3536.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IreXv-0000eZ-PB
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 11:02:07 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IreXy-0003jS-7O
	for nfs@lists.sourceforge.net; Mon, 12 Nov 2007 11:02:13 -0800
In-Reply-To: <20071112171404.3053.3536.stgit@localhost.localdomain>
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


On Mon, 2007-11-12 at 12:16 -0500, Chuck Lever wrote:
> Hi Trond-
> 
> Here are four patches that add support for multi-segment iovecs in the NFS
> client's direct I/O engine.  Would like to see these in 2.6.25.  Thanks!
> 
All 4 applied... Thanks!

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
