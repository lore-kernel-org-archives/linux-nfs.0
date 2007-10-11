From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 0/3] svc: gnb review cleanup for transport switch
Date: Thu, 11 Oct 2007 17:04:42 -0500
Message-ID: <1192140282.7491.33.camel@trinity.ogc.int>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
	<20071011203029.GE22823@fieldses.org>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ig6AF-0000wr-LR
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 15:05:55 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ig6AJ-0004F1-O8
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 15:06:01 -0700
In-Reply-To: <20071011203029.GE22823@fieldses.org>
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

I think I found the problem. The patchset is not caching the auth data
properly. This causes the server to fail the setting of the client id
with a 10018 error.

I'll send a patch off tonight....sorry :-\

On Thu, 2007-10-11 at 16:30 -0400, J. Bruce Fields wrote:
> On Wed, Oct 10, 2007 at 09:23:56PM -0500, Tom Tucker wrote:
> > This patchset implements cleanup that is primarily driven by Greg Bank's 
> > review of the transport switch. A summary follows:
> 
> With your latest patches (and tronds, and mine), I'm getting a failure
> at the start of basic connectathon tests which I haven't tracked down
> yet.  One obvious oddity in the network trace, though, is that the
> server is retransmitting its reply to an open.  Is there any chance this
> could be a problem with the deferral code?
> 
> I'll keep investigating.
> 
> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
