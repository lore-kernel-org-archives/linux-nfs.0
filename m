From: Olaf Kirch <okir@suse.de>
Subject: Re: [RFC] implementing BSD style locks on NLM (flocks)
Date: Wed, 2 Mar 2005 16:56:35 +0100
Message-ID: <20050302155634.GE22736@suse.de>
References: <20050227192113.GA5778@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6WDR-0007cQ-GI
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 07:56:49 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D6WDK-0007QK-Gm
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 07:56:49 -0800
To: nhorman@redhat.com
In-Reply-To: <20050227192113.GA5778@localhost.localdomain>
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

> 	I was wondering, how much interest there might be in the addition of
> support for BSD style locks (flocks) over NLM.  I was thinking that a bit could
> be added to differentiate the two namespaces.  Any thoughts appreciated.  

I looked into this before, and it's not just two "name spaces".  The major
difference is that BSD flocks are associated with an open file handle,
while POSIX locks are associated with a PID.

You could possibly encode the notion of a struct file in the owner
handle that's passed in every lock request, and change the server side
lockd when comparing lock owners.

But I dimly remember there were other issues that could not be mapped
easily to the NLM protocol... don't remember the details: I'd have to
check my archives. These mails may even be in the nfs list archive.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
