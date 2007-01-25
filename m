From: Christian Robottom Reis <kiko@async.com.br>
Subject: Re: (More) NFS Performance woes
Date: Thu, 25 Jan 2007 17:37:05 -0200
Message-ID: <20070125193705.GB7267@anthem.async.com.br>
References: <45815427.8070805@nighthawkrad.net>
	<20061214160359.GA11876@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HAAPs-00038T-K2
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 11:37:48 -0800
Received: from frodo.hserus.net ([204.74.68.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HAAPu-0002QP-3a
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 11:37:50 -0800
In-Reply-To: <20061214160359.GA11876@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Dec 14, 2006 at 11:03:59AM -0500, J. Bruce Fields wrote:
> On Fri, Dec 15, 2006 at 12:39:51AM +1100, Christopher Smith wrote:
> > The first test is copying a single large file of about 700M from the 
> > (client) local disk to the NFS mount.
> > The second test is untarring a 700M tarfile from the (client) local disk 
> > to the NFS mount (~5000 files).
> > 
> > Test #1 consistently finishes in about 17 seconds, delivering about 40 
> > MiB/s.
> > Test #2 consistently finishes in about 85 seconds, delivering about 8 MiB/s
> 
> That's about 17ms per file?  Each of those 5000 file creations is a
> synchronous operation--the server doesn't respond until it's actually
> committed the operation to disk.  I don't really know what expected
> numbers are for your hardware, but given that for each file we have to
> wait for both the initial creation and the final flush of the data to
> disk on close, 17ms doesn't sound too far off.

I actually found the numbers that Christopher is seeing pretty good. If
I could get a 700MB write of 5000 files to an NFS mount in 85s I'd be
as happy as could be. I'm imagining that if this wasn't Gigabit this
would be a lot slower -- am I wrong?
-- 
Christian Robottom Reis | http://async.com.br/~kiko/ | [+55 16] 3376 0125

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
