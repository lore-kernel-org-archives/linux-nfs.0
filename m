From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [GIT] NFS client update for 2.6.16
Date: Wed, 22 Mar 2006 10:30:45 +0000
Message-ID: <20060322103044.GB7025@infradead.org>
References: <1142961077.7987.14.camel@lade.trondhjem.org> <20060321174634.GA15827@infradead.org> <1142964532.7987.61.camel@lade.trondhjem.org> <20060321185734.GB19125@infradead.org> <1142967981.7987.92.camel@lade.trondhjem.org> <44205003.8070702@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FM0c9-0003Iz-4N
	for nfs@lists.sourceforge.net; Wed, 22 Mar 2006 02:30:53 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FM0c7-00076i-ME
	for nfs@lists.sourceforge.net; Wed, 22 Mar 2006 02:30:53 -0800
To: Chuck Lever <cel@citi.umich.edu>
In-Reply-To: <44205003.8070702@citi.umich.edu>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, Mar 21, 2006 at 02:12:03PM -0500, Chuck Lever wrote:
> i have been watching the multi-segment iovec work since then, and fully 
> intended to add the support for readv/writev aio in the NFS direct path 
> when the generic support becomes available.


we agreed to not add another set of methods but rather consolidate the
existing two sets of aio and vectored methods into one.  So to merge the
core support all users including nfs need to be updated.  the last wip
patchset is posted in the at:

	http://marc.theaimsgroup.com/?l=linux-kernel&m=114177713027505&w=2
	http://marc.theaimsgroup.com/?l=linux-kernel&m=114177739515518&w=2
	http://marc.theaimsgroup.com/?l=linux-kernel&m=114177739313588&w=2
	http://marc.theaimsgroup.com/?l=linux-kernel&m=114177739407636&w=2

any nfs work should happen ontop of that.

I'm sill the opinion removing the iovec arguments isn't helpfull, but
it's your code and if you think it helps you move forwarg go ahead with
this.



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
