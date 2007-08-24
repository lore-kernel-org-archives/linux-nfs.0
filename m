From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/9] mount.nfs: Don't allow the user to
	specify	addr= or clientaddr=.
Date: Fri, 24 Aug 2007 13:25:29 -0400
Message-ID: <20070824172529.GA6690@fieldses.org>
References: <20070824171116.10418.56059.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOcua-0005TJ-9S
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:25:32 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IOcud-0006d1-Gm
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:25:36 -0700
In-Reply-To: <20070824171116.10418.56059.stgit@monet.1015granger.net>
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

On Fri, Aug 24, 2007 at 01:11:16PM -0400, Chuck Lever wrote:
> The current mount.nfs implementation doesn't allow users to specify their
> own addr= or clientaddr= option.

Don't we need clientaddr= in some cases to get the callback channel
working?

> The new string-based interface does allow this, even though nfs(5)
> does not document 'addr=' and specifically forbids adding
> 'clientaddr='.

It says that it's currently ignored, which isn't the same as forbidding
it.

I'm probably missing the point of the patch.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
