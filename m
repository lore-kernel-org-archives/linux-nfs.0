From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: 2.4 vs 2.6
Date: Wed, 14 Jun 2006 12:22:25 +1000
Message-ID: <1150251745.22282.1520.camel@hole.melbourne.sgi.com>
References: <17526.44653.228663.713864@cse.unsw.edu.au>
	<20060526081905.73641.qmail@web51609.mail.yahoo.com>
	<20060526193118.GB17761@fieldses.org>
	<17530.36039.227704.325645@cse.unsw.edu.au>
	<20060529160236.GC6832@fieldses.org> <20060530011208.GB12818@sgi.com>
	<20060530015918.GA27940@fieldses.org>
	<17550.12582.742528.454837@cse.unsw.edu.au>
	<20060613204225.GB26315@fieldses.org>
	<1150248571.22282.1450.camel@hole.melbourne.sgi.com>
	<20060614021555.GA13425@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	mehta kiran <kiranmehta1981@yahoo.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Vijay Chauhan <kernel.vijay@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FqL1g-0005Zq-49
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 19:22:36 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FqL1f-0004VW-3i
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 19:22:36 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060614021555.GA13425@fieldses.org>
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

On Wed, 2006-06-14 at 12:15, J. Bruce Fields wrote:
> On Wed, Jun 14, 2006 at 11:29:31AM +1000, Greg Banks wrote:

> This should be trivially fixable, shouldn't it?  (Actually, can you run
> multiple concurrent mountd's right now?)

I believe the kernel cache could can handle multiple readers
and writers (Neil?)  but there's only one portmap registration,
so all the client RPCs will go to the last mountd started.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
