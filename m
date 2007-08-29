From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 04/20] svc: xpt_has_wspace
Date: Wed, 29 Aug 2007 16:29:53 -0400
Message-ID: <20070829202953.GB4687@fieldses.org>
References: <20070820162000.15224.65524.stgit@dell3.ogc.int>
	<20070820162329.15224.29032.stgit@dell3.ogc.int>
	<20070829185323.GF23541@fieldses.org>
	<1188418276.7502.29.camel@trinity.ogc.int>
	<1188419193.7502.38.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQUAi-0002nn-K1
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 13:29:54 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQUAl-00022z-Qd
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 13:29:57 -0700
In-Reply-To: <1188419193.7502.38.camel@trinity.ogc.int>
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

On Wed, Aug 29, 2007 at 03:26:33PM -0500, Tom Tucker wrote:
> Oops, I didn't mean what I wrote. All the conditions will NOT be tested,
> but I think the side affects of the order are benign. 

Oops, OK.--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
