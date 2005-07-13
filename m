From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Fill in rqstp->rq_daddr in svc_tcp_recvfrom
Date: Wed, 13 Jul 2005 07:17:50 +0200
Message-ID: <20050713051750.GA23673@suse.de>
References: <20050712090455.GA9243@suse.de> <20050712163146.GC27938@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsZda-0004Rg-S1
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 22:18:26 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DsZd5-0007dO-SQ
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 22:18:26 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050712163146.GC27938@fieldses.org>
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

Hi Bruce,

> Could you explain how this patch makes a difference?  I can only see the
> value of rq_daddr used in one place, in svc_sendto:

It doesn't make a difference for the existing RPC users, but the customer
had some kernel RPC code of their own (I think some HA capable nfsd)
that needed this information for migration/failover.

It's not strictly necessary, but it doesn't hurt either - and it makes
sense in the way that UDP and TCP now fill in the same set of information.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
