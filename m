From: Olaf Kirch <okir@suse.de>
Subject: Re: deadlock in lockd
Date: Thu, 10 Mar 2005 23:42:44 +0100
Message-ID: <20050310224244.GA17183@suse.de>
References: <20050310204416.GC3424@suse.de> <20050310154944.A14369@rda07.lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Sebastian Hetze <s.hetze@linux-ag.de>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9WMi-0003vg-Os
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 14:42:48 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D9WMh-00040Z-2V
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 14:42:48 -0800
To: Daniel Forrest <forrest@lmcg.wisc.edu>
In-Reply-To: <20050310154944.A14369@rda07.lmcg.wisc.edu>
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

On Thu, Mar 10, 2005 at 03:49:44PM -0600, Daniel Forrest wrote:
> Subject: [NFS] [PATCH] kNFSd - 3 of 6 - Fix deadlock problem in lockd.

I see... I would have been surprised if I had been the first one
to run into this.

Still I think it's cleaner to move the nlm_gc_hosts calls out of
nlm_lookup_host.

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
