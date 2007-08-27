From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/3] SUNRPC: Add support for formatted
	universal	addresses
Date: Mon, 27 Aug 2007 10:32:29 -0400
Message-ID: <1188225149.6701.58.camel@heimdal.trondhjem.org>
References: <20070816200326.3831.43473.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPfdr-00052g-HY
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 07:32:35 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPfdu-0003Zt-GP
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 07:32:40 -0700
In-Reply-To: <20070816200326.3831.43473.stgit@monet.1015granger.net>
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
> "Universal addresses" are a string representation of an IP address and
> port.  They are described fully in RFC 3530, section 2.2.  Add support
> for generating them in the RPC client's socket transport module.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---

This applies fine to the git tree, but not to 2.6.23-rc3. Given that
rpcbind v3/v4 is still marked as EXPERIMENTAL, I'm inclined to rather
let this and the next patch wait until the 2.6.24 merge window opens.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
