From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: 2.4 vs 2.6
Date: Wed, 14 Jun 2006 15:40:21 -0400
Message-ID: <20060614194021.BA8C51BDDE@citi.umich.edu>
References: <17526.44653.228663.713864@cse.unsw.edu.au>
	<20060526081905.73641.qmail@web51609.mail.yahoo.com>
	<20060526193118.GB17761@fieldses.org>
	<17530.36039.227704.325645@cse.unsw.edu.au>
	<20060529160236.GC6832@fieldses.org>
	<20060530011208.GB12818@sgi.com>
	<20060530015918.GA27940@fieldses.org>
	<17550.12582.742528.454837@cse.unsw.edu.au>
	<20060613204225.GB26315@fieldses.org>
	<1150248571.22282.1450.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: mehta kiran <kiranmehta1981@yahoo.com>,
	Vijay Chauhan <kernel.vijay@gmail.com>, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, andros@citi.umich.edu,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FqbEA-0004M1-If
	for nfs@lists.sourceforge.net; Wed, 14 Jun 2006 12:40:34 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FqbE9-0004pm-6n
	for nfs@lists.sourceforge.net; Wed, 14 Jun 2006 12:40:34 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-reply-to: <1150248571.22282.1450.camel@hole.melbourne.sgi.com> 
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


> There are only two criticisms I would make of Linux' upcall design.
> 
> First, Linux uses a wacky special-purpose filesystem.  Solaris and
> IRIX use a normal RPC to a special RPC program number implemented
> in mountd, using the existing RPC client code which is already needed
> in the server to initiate lockd callbacks.  This reduces code
> complexity in the kernel, and means you can watch the upcall traffic
> with wireshark (or whatever ethereal is called this week) or snoop
> instead of strace on mountd.  But whatever, it mostly works now.
> 

funny you should mention the RPC upcall. that was the origional design i 
coded, was working just fine, and was nixed!

-->Andy


> -- 
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.
> 
> 
> 
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
