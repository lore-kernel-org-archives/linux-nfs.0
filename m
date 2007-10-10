From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 0/7] svc: Incremental svc patchset cleanup
Date: Tue, 09 Oct 2007 22:32:05 -0500
Message-ID: <1191987125.16714.49.camel@trinity.ogc.int>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
	<20071010022408.GA20690@sgi.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfSJz-0002XY-OA
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 20:33:19 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfSK3-0006Zm-S7
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 20:33:25 -0700
In-Reply-To: <20071010022408.GA20690@sgi.com>
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

On Wed, 2007-10-10 at 12:24 +1000, Greg Banks wrote:
> G'day,
> 
> Compendium reply.
> 
> On Tue, Oct 09, 2007 at 10:35:39AM -0500, Tom Tucker wrote:

> So what are the intended semantics of svc_find_xprt(,,0,2049) ?
> When called like that, it will reach into xprt->xpt_local assuming
> it's a sockaddr_in and match the passed port number against whatever
> it finds at bytes 2-3.

Sorry, I missed this question. My intent was that the filters were
hierarchical: class, af, port.

AF_UNSPEC, notwithstanding, a class of <null> never matches anything.

> 
> Perhaps this function could be pruned back to only do what it needs
> to do right now, which is match on transport name?
> 

Yes, it could.

> 
> > Subject: [RFC,PATCH 7/7] svc: Place type on same line for new API
> 
> ok
> 
> Greg.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
