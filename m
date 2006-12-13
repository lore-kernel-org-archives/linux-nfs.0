From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 000 of 14] knfsd: Assorted nfsd patches for 2.6.20
 - prepare for IPv6 and more
Date: Wed, 13 Dec 2006 22:13:55 +1100
Message-ID: <17791.57459.23780.747689@cse.unsw.edu.au>
References: <20061213105528.21128.patches@notabene>
	<457F9243.9090701@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuS3T-0002Oj-6s
	for nfs@lists.sourceforge.net; Wed, 13 Dec 2006 03:13:43 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuS3T-0004dF-AX
	for nfs@lists.sourceforge.net; Wed, 13 Dec 2006 03:13:44 -0800
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: message from Jeff Garzik on Wednesday December 13
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

On Wednesday December 13, jeff@garzik.org wrote:
> NeilBrown wrote:
> > Following are 14 patches for knfsd that are suitable for inclusion in 2.6.20.
> > First 13 are from Chuck Lever and make preparations for IPv6 support (I think we've
> > get them right this time).
> > 
> > Last is from Peter Staubach and fixes and issue with exclusive create
> > interacting badly with some ACLs.
> 
> 
> Any word on this 2.6.19 oops?
> 
> http://lkml.org/lkml/2006/12/8/110

Not yet... I've been spending my spare time looking for an md oops :-)

A quick look suggests that it cannot possibly happen ...

cancel_rearming_delayed_workqueue appears to be being called with a
bad "struct workqueue_struct *".  But that really must have been
initialised when the first nfsd thread started...

It looks like cwq in flush_cpu_workqueue is 0x0000040000000100.  Is
that the sort of address you would expect?  Where do alloc_percpu 
data structures live?  The '4' wouldn't be a single-bit memory error,
would it? (that would be too easy).

So: no, no real progress.   Is it repeatable?

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
