From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Fill in rqstp->rq_daddr in svc_tcp_recvfrom
Date: Wed, 13 Jul 2005 15:36:10 +0100
Message-ID: <20050713143610.GA26025@infradead.org>
References: <20050712090455.GA9243@suse.de> <20050712163146.GC27938@fieldses.org> <20050713051750.GA23673@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsiLS-0004PK-Nf
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 07:36:18 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DsiLR-0003rw-Ea
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 07:36:18 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050713051750.GA23673@suse.de>
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

On Wed, Jul 13, 2005 at 07:17:50AM +0200, Olaf Kirch wrote:
> Hi Bruce,
> 
> > Could you explain how this patch makes a difference?  I can only see the
> > value of rq_daddr used in one place, in svc_sendto:
> 
> It doesn't make a difference for the existing RPC users, but the customer
> had some kernel RPC code of their own (I think some HA capable nfsd)
> that needed this information for migration/failover.

So let the customer post the patch, including the code that uses it,
as that might actually be useful for others aswell.



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
