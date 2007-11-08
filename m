From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS Causing issues with Gimp XCF files?
Date: Thu, 08 Nov 2007 17:43:23 -0500
Message-ID: <1194561803.7655.108.camel@heimdal.trondhjem.org>
References: <20071108215404.GA8331@apocalyptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: CJ Kucera <pez@apocalyptech.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqG3M-0002EW-3g
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 14:40:48 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IqG3Q-0000RF-IL
	for nfs@lists.sourceforge.net; Thu, 08 Nov 2007 14:40:54 -0800
In-Reply-To: <20071108215404.GA8331@apocalyptech.com>
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


On Thu, 2007-11-08 at 15:54 -0600, CJ Kucera wrote:
> Both the NFS server and my client machine (where I'm running gimp) are
> running vanilla 2.6.23.1 kernels, and nfs-utils 1.1.0.  I'll upgrade to
> 1.1.1 in a little bit, but I was observing the same problems with an
> earlier version as well.  The kernel options are:

See
  http://bugzilla.kernel.org/show_bug.cgi?id=9315

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
