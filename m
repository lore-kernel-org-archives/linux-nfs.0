From: Neil Brown <neilb@suse.de>
Subject: Re: stdio and nfs-utils
Date: Thu, 26 Jul 2007 14:10:15 +1000
Message-ID: <18088.7847.592861.408080@notabene.brown>
References: <20070725223723.GH7943@fieldses.org>
	<20070726000700.GK7943@fieldses.org>
	<18088.3581.647761.879253@notabene.brown>
	<20070726031755.GB19901@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDugJ-0007HN-KF
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 21:10:31 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDugM-0000oN-61
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 21:10:35 -0700
In-Reply-To: message from J. Bruce Fields on Wednesday July 25
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

On Wednesday July 25, bfields@fieldses.org wrote:
> On Thu, Jul 26, 2007 at 12:59:09PM +1000, Neil Brown wrote:
> > While I can see the value it avoiding the stdio code, I can also see
> > some in hanging on to it, so I would first like to see if we can make
> > the current code work with just minor modifications.
> > 
> > Could you check how calling 'clearerr' interacts with this code on the
> > two different systems?
> 
> I tried inserting a clearerr into the loop:
> 
> 	fprintf();
> 	fflush();
> 	clearerr();
> 
> No change in behavior.

Hmmm.... (reads man page)...

#include <stdio_ext.h>

...

	__fpurge(f)

seems to do the trick.

> 
> I see the advantage to doing just one step at a time--so if we can
> figure out a minimal fix for now, fine.  But surely we've got to replace
> the stdio stuff at some point.  We need precise control over the writes,
> so the buffering can only get in the way.

But we want to build a line up from multiple words, and so we need
buffering for that.
If we toss stdio, we will need to allocate a buffer, keep track of the
end point, and append to the buffer in various places.  It feels like
reinventing the wheel.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
