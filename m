From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [PATCH 10/10] mount.nfs: Fix background mounts
Date: Tue, 7 Aug 2007 00:31:52 +0200
Message-ID: <20070806223152.GA7917@uio.no>
References: <20070803172415.3357.91411.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIB7J-0000ya-6b
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 15:32:01 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIB7M-0006Tx-0h
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 15:32:05 -0700
In-Reply-To: <20070803172415.3357.91411.stgit@monet.1015granger.net>
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

On Fri, Aug 03, 2007 at 01:24:15PM -0400, Chuck Lever wrote:
> The new mount.nfs helper does not support background mounts.  Add support
> for background mounts.

I've now pushed the current git (which includes these patches) into Debian,
which will hopefully give us some experience with "bg" again. It seems to
have fixed some bugs of the old bg implementation, but this one still
remains:

  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=144185

Any chance mount.nfs could simply ignore HUPs?

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
