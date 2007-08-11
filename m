From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 20/20] SUNRPC: Split xs_reclassify_socket into an
	IPv4	and IPv6 version
Date: Sat, 11 Aug 2007 11:11:24 -0400
Message-ID: <1186845084.17941.25.camel@heimdal.trondhjem.org>
References: <20070806155803.31233.30721.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJscn-00080z-VG
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 08:11:34 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19VpMTESfcG34vpIZOLrZGTu317EpVy2Hk=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IJscr-0004hO-Pw
	for nfs@lists.sourceforge.net; Sat, 11 Aug 2007 08:11:38 -0700
In-Reply-To: <20070806155803.31233.30721.stgit@manray.1015granger.net>
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

Series applied (aside from the ones involving unnecessary type casts).

Thanks Chuck!
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
