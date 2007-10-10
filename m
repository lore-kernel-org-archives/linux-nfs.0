From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 0/7] svc: Incremental svc patchset cleanup
Date: Wed, 10 Oct 2007 14:26:18 +1000
Message-ID: <20071010042618.GK20690@sgi.com>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
	<20071010022408.GA20690@sgi.com>
	<1191987125.16714.49.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfT0t-0006eK-OJ
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 21:17:39 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/SdrH8yLLBnVCRtRTI6eKIZ0sd66dqysE=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfT0y-0003n9-SJ
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 21:17:45 -0700
In-Reply-To: <1191987125.16714.49.camel@trinity.ogc.int>
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

On Tue, Oct 09, 2007 at 10:32:05PM -0500, Tom Tucker wrote:
> On Wed, 2007-10-10 at 12:24 +1000, Greg Banks wrote:
> > G'day,
> > 
> > Compendium reply.
> > 
> > On Tue, Oct 09, 2007 at 10:35:39AM -0500, Tom Tucker wrote:
> 
> > So what are the intended semantics of svc_find_xprt(,,0,2049) ?
> > When called like that, it will reach into xprt->xpt_local assuming
> > it's a sockaddr_in and match the passed port number against whatever
> > it finds at bytes 2-3.
> 
> Sorry, I missed this question. My intent was that the filters were
> hierarchical: class, af, port.

Ah.  Perhaps the comment should say that, and the code enforce it.

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
