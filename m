From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,
	PATCH 0/3] svc: gnb review cleanup for transport switch
Date: Thu, 11 Oct 2007 16:30:29 -0400
Message-ID: <20071011203029.GE22823@fieldses.org>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ig4fv-0008Sn-Ml
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 13:31:03 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ig4fy-00087Z-Cu
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 13:30:35 -0700
In-Reply-To: <20071011022356.3501.63859.stgit@dell3.ogc.int>
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

On Wed, Oct 10, 2007 at 09:23:56PM -0500, Tom Tucker wrote:
> This patchset implements cleanup that is primarily driven by Greg Bank's 
> review of the transport switch. A summary follows:

With your latest patches (and tronds, and mine), I'm getting a failure
at the start of basic connectathon tests which I haven't tracked down
yet.  One obvious oddity in the network trace, though, is that the
server is retransmitting its reply to an open.  Is there any chance this
could be a problem with the deferral code?

I'll keep investigating.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
