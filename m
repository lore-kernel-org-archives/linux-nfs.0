From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: wonky autotools question
Date: Fri, 27 Jul 2007 16:08:56 -0400
Message-ID: <20070727200856.GI13965@fieldses.org>
References: <46AA4BF6.6090002@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEW7M-0006wb-AP
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:08:58 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEW7P-0002Mn-0I
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 13:09:00 -0700
In-Reply-To: <46AA4BF6.6090002@oracle.com>
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

On Fri, Jul 27, 2007 at 03:48:06PM -0400, Chuck Lever wrote:
> Hi all-
>
> It would be nice to enable more static code checking in nfs-utils (I'm 
> especially interested in utils/mount/).  Is there a clean way to add 
> additional CFLAGS, like -Wall, to utils/mount/Makefile using the autotools 
> set up?  How about a lint or sparse target?

I don't know, sounds like a good idea.

Last I checked, though, I thought there were still a fair number of
warnings just with the current defaults.  Maybe we should fix those up
first?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
