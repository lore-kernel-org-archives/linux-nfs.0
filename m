From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/3] SUNRPC: fill in remote address before
	checking	it's family
Date: Mon, 27 Aug 2007 10:29:57 -0400
Message-ID: <1188224997.6701.54.camel@heimdal.trondhjem.org>
References: <20070816200321.3831.65288.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPfbU-0004oD-NF
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 07:30:08 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPfbX-0002In-Kd
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 07:30:13 -0700
In-Reply-To: <20070816200321.3831.65288.stgit@monet.1015granger.net>
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

On Thu, 2007-08-16 at 16:03 -0400, Chuck Lever wrote:
> Recent IPv6 changes introduced a regression.  The address family of the
> remote address is checked before the address is actually filled in.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

I'm simply folding this one into the patch that adds IPv6 support. None
of that has been merged into 2.6.23-rc3.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
