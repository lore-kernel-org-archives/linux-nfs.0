From: Neil Brown <neilb@suse.de>
Subject: Re: 2.4 vs 2.6
Date: Wed, 14 Jun 2006 09:22:43 +1000
Message-ID: <17551.18627.173187.415226@cse.unsw.edu.au>
References: <17526.44653.228663.713864@cse.unsw.edu.au>
	<20060526081905.73641.qmail@web51609.mail.yahoo.com>
	<20060526193118.GB17761@fieldses.org>
	<17530.36039.227704.325645@cse.unsw.edu.au>
	<20060529160236.GC6832@fieldses.org>
	<20060530011208.GB12818@sgi.com>
	<20060530015918.GA27940@fieldses.org>
	<17550.12582.742528.454837@cse.unsw.edu.au>
	<20060613204225.GB26315@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: mehta kiran <kiranmehta1981@yahoo.com>,
	Vijay Chauhan <kernel.vijay@gmail.com>, nfs@lists.sourceforge.net,
	Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FqIDo-0007k7-3t
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 16:22:56 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FqIDn-0007Ox-Uo
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 16:22:55 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FqIDn-0001tT-DG
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 16:22:55 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Tuesday June 13
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

On Tuesday June 13, bfields@fieldses.org wrote:
> 
> Just to be clear--I'm definitely not on some crusade to change all this.
> I'm just curious about the motivation for the design; thanks for the
> explanation.

Not the caped crusader then :-)

Oh! you wanted the motivation?  I thought you wanted the justification!
Completely different things you know.....

The motivation was that I needed to do upcalls to remove the rmtab
problem, so it seemed 'obvious' to use upcalls for everything and
create a caching structure that could be use generally.  I cannot say
that I considered every cache and asked myself if it could be static
or not.  Had I thought more fully about such things I might not have
included the 'client' in the key for the fh -> path mapping.  But it
seemed like the right idea at the time, and I didn't have anyone
questioning my design decisions.  Looking back, I wish I had!


NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
