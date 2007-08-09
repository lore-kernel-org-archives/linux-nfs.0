From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 5/5] mount.nfs: Enable mount.nfs to do
	text-based	mount support
Date: Thu, 09 Aug 2007 18:49:27 -0400
Message-ID: <1186699767.6699.221.camel@heimdal.trondhjem.org>
References: <20070809213711.16767.30201.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJGp8-0006oU-4O
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 15:49:47 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJGpB-0000oR-0i
	for nfs@lists.sourceforge.net; Thu, 09 Aug 2007 15:49:50 -0700
In-Reply-To: <20070809213711.16767.30201.stgit@monet.1015granger.net>
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

On Thu, 2007-08-09 at 17:37 -0400, Chuck Lever wrote:
> A new command line option, "-i", is added to mount.nfs to force the use of
> the string interface for testing purposes.  "-s", "-t", and "-r" are
> already taken or have legacy meaning so I picked "-i".
> 
> At some later point, when everyone is comfortable with the string mount
> option parsing implementation, we will add a switch based on kernel
> version, and remove the "-i" command line option.  For now, I am more
> comfortable enabling it by hand instead.

Please could we at least disable the '-i' option for kernel versions
prior to 2.6.23. No need to introduce possible security problems: after
all, 'mount.nfs' is usually installed setuid.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
