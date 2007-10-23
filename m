From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH] svc: Fix the UDP address logic
Date: Tue, 23 Oct 2007 12:46:07 +1000
Message-ID: <20071023024607.GC6354@sgi.com>
References: <20071022210148.9997.94538.stgit@dell3.ogc.int>
	<20071023015329.GA6354@sgi.com>
	<471D58C0.1090707@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ik9j4-0003L5-QR
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 19:42:41 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ik9j9-0004yH-6W
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 19:42:44 -0700
In-Reply-To: <471D58C0.1090707@opengridcomputing.com>
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

On Mon, Oct 22, 2007 at 09:13:20PM -0500, Tom Tucker wrote:
> Greg Banks wrote:
> >On Mon, Oct 22, 2007 at 04:01:48PM -0500, Tom Tucker wrote:
> >  
> >This is useful text, any chance you can put it into a comment
> >or a text file describing the xprt switch interface?
> >
> >  
> I think it would be most useful if I wrote a document  describing the 
> transport switch and the requirements of a transport driver. The text 
> file would be for the Documentation directory. I'll try to get to it in 
> the next week.

Great!

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
