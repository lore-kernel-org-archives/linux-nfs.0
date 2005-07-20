From: Olaf Kirch <okir@suse.de>
Subject: nfsd: rewrite performance problem
Date: Wed, 20 Jul 2005 15:06:24 +0200
Message-ID: <20050720130623.GA12537@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DvEHP-0006RC-No
	for nfs@lists.sourceforge.net; Wed, 20 Jul 2005 06:06:31 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DvEHP-0003fj-80
	for nfs@lists.sourceforge.net; Wed, 20 Jul 2005 06:06:31 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 557B81D743
	for <nfs@lists.sourceforge.net>; Wed, 20 Jul 2005 15:06:24 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hi,

we've just been investigating a performance problem at a customer of ours.
On a machine of 4G RAM, they were running N iozone threads on one 1G file
each. For 3 threads, where the working set fits into RAM, the rewrite
numbers are reasonably, but when using 4 threads, rewrite performance is
horrible.

vmstat shows that in this case, the number of block reads roughly equals
the number of block writes. They reproduced this with our sles9 kernel as
well as 2.6.12 vanilly, with both reiser and ext3.

Chris Mason and I looked into this, and we believe we've nailed down
the problem, which is the use of writev in nfsd_write. nfsd receives
the WRITE request from the client, broken up into page sized chunks.
The default implementation of writev will simply call file->op->write
for each of the fragments it's given, but the first fragment is
PAGE_SIZE minus the RPC header and write_args. So we end up writing
less than a full block, causing the block to be read first. All
subsequent pages in the iovec are non block aligned either, so the
same happens for these as well.

Does that sound right?

In order to verify our theory, we've asked the customer to test with 8K
wsize and jumbograms enabled. I'll keep you posted.

Possible fixes that I can think of are to implement generic_file_writev
that avoids calling write() for each chunk, but rather grabs all
the pages, updates each and passes it to writepage. Another would be
to use a large linear buffer in svc_recvfrom rather than the iovec,
as the initial implementation used to do. Another (band-aid)
hack would be to check in nfsd_write whether we're re-writing a multiple
of PAGE_SIZE worth of data, and properly align the iovec in this case.

Any other suggestions?

Cheers,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
