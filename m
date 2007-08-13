From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] [279/2many] MAINTAINERS - KERNEL NFSD
Date: Mon, 13 Aug 2007 11:22:27 -0400
Message-ID: <20070813152227.GD3122@fieldses.org>
References: <46bffa95.aPjsc88tjaey80vh%joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: joe@perches.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKbkR-0000II-TA
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 08:22:28 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKbkU-0002np-TP
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 08:22:32 -0700
In-Reply-To: <46bffa95.aPjsc88tjaey80vh%joe@perches.com>
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

Dropping any address that got cc'd all 500 patches in the vain hope of
avoiding drowning them in 500+ threads.

On Sun, Aug 12, 2007 at 11:30:45PM -0700, joe@perches.com wrote:
> +F:	fs/nfsd/
> +F:	include/linux/nfsd/

Also some stuff under include/linux/sunrpc/ and net/sunrpc/.  At a
minimum, include/linux/sunrpc/svc* and net/sunrpc/svc*, though actually
it might be better to err on the side of overlapping and add the whole
of both directories to both the client and server entries.

Some common sense may have to be applied at times to figure out what's
relevant to whom.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
