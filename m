From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 0/7] svc: Incremental svc patchset cleanup
Date: Wed, 10 Oct 2007 14:25:39 +1000
Message-ID: <20071010042539.GJ20690@sgi.com>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
	<20071010022408.GA20690@sgi.com>
	<1191983986.16714.21.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfT0L-0006db-Va
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 21:17:06 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+mTBK+4JODqn2QBpYErA3gLqNFzRyRKy4=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfT0P-0001q3-2S
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 21:17:11 -0700
In-Reply-To: <1191983986.16714.21.camel@trinity.ogc.int>
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

On Tue, Oct 09, 2007 at 09:39:46PM -0500, Tom Tucker wrote:
> On Wed, 2007-10-10 at 12:24 +1000, Greg Banks wrote:
> > 
> > Why have address family and port?  Do you need them?
> 
> Well, I think not based on the current user 'lockd'. But the additional
> logic is trivial and it allows services to discriminate between AF_INET,
> AF_INET6, port this, port that, etc.... when searching for existing
> transports.

Is it still trivial when implemented correctly?

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
