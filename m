From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH] svc: Fix the UDP address logic
Date: Tue, 23 Oct 2007 11:53:29 +1000
Message-ID: <20071023015329.GA6354@sgi.com>
References: <20071022210148.9997.94538.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ik8uE-0006zA-L3
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 18:50:07 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX19eA9fJu+MCC7PLgHLWGNk8TPYinkimt3s=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ik8uJ-0005aT-03
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 18:50:12 -0700
In-Reply-To: <20071022210148.9997.94538.stgit@dell3.ogc.int>
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

On Mon, Oct 22, 2007 at 04:01:48PM -0500, Tom Tucker wrote:
> 
> When the address information was moved to the svc_xprt structure, a bug
> was introduced to UDP that caused an incorrect address to be used
> when responding to RPC on the UDP transport. This was the result of
> failing to completely implement the generic address logic for the UDP 
> transport.

ok.

> Since I confused myself, it's probably a good idea to describe how 
> this is supposed to work. [...]

This is useful text, any chance you can put it into a comment
or a text file describing the xprt switch interface?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
