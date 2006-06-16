From: Neil Brown <neilb@suse.de>
Subject: Re: multiple mountds  (was: 2.4 vs 2.6)
Date: Fri, 16 Jun 2006 13:52:57 +1000
Message-ID: <17554.11033.204807.586772@cse.unsw.edu.au>
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
	<20060614021555.GA13425@fieldses.org>
	<1150251745.22282.1520.camel@hole.melbourne.sgi.com>
	<17551.36379.163043.483208@cse.unsw.edu.au>
	<1150259776.22282.1675.camel@hole.melbourne.sgi.com>
	<1150289285.22282.2202.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fr5OS-0001L2-Ru
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 20:53:12 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fr5OQ-00026F-NW
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 20:53:13 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Wednesday June 14
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

On Wednesday June 14, gnb@melbourne.sgi.com wrote:
> 
> How about the attached patch against nfs-utils tot?  It
> adds a -t option to set the number of forked workers.
> Default is 1 thread, i.e. the old behaviour.
> 

Looks perfect, thanks.
I've added it to the git at 
    http://linux-nfs.org/cgi-bin/gitweb.cgi?p=nfs-utils;a=summary
    git://linux-nfs.org/nfs-utils

Documentation and everything.  No Changelog though... I should do that
at some stage.

Thanks,

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
