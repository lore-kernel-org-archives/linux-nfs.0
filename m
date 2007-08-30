From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] mount.nfs: Update description of clientaddr=
	in	nfs(5)
Date: Thu, 30 Aug 2007 17:37:16 -0400
Message-ID: <20070830213716.GE10808@fieldses.org>
References: <20070830194810.4524.58037.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQrhU-000314-Sz
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 14:37:16 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQrhX-0002Sj-6B
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 14:37:21 -0700
In-Reply-To: <20070830194810.4524.58037.stgit@monet.1015granger.net>
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

On Thu, Aug 30, 2007 at 03:48:10PM -0400, Chuck Lever wrote:
> +Specifies a single IPv4 address in dotted-quad form that the
> +NFS client should advertise to a server for performing NFSv4
> +callback requests for this mount point.
> +If not specified, the mount command attempts to discover an
> +appropriate callback address, then passes it to the NFS client.
> +However, in the presence of multiple client network interfaces,
> +special routing policies, or atypical network topologies, the
> +exact address to use for callbacks may be difficult for the
> +mount command to determine automatically.

Sounds good to me!

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
