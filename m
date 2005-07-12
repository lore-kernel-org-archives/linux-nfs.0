From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fill in rqstp->rq_daddr in svc_tcp_recvfrom
Date: Tue, 12 Jul 2005 12:31:46 -0400
Message-ID: <20050712163146.GC27938@fieldses.org>
References: <20050712090455.GA9243@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsNfr-0001W9-43
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:31:59 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DsNfo-0001Ro-RD
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:31:59 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050712090455.GA9243@suse.de>
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

On Tue, Jul 12, 2005 at 11:04:56AM +0200, Olaf Kirch wrote:
> Here's a patch we added to SLES in response to a customer bug report:
> 
> # Subject: Fill in rqstp->rq_daddr in svc_tcp_recvfrom
> #
> # This patch fills the daddr member of the rpc struct svc_rqst structure for  
> # TCP-based sockets in the recvfrom proceedure.  Currently, the field is 
> # not set thus leaving it with left over garbage from a previous allocation. 
> #
> # This makes the behavior consistent between UDP- and TCP-based RPC. 
> #
> # This patch enables HA software to failover TCP-based RPC services
> # such as TCP-based NFS.

Could you explain how this patch makes a difference?  I can only see the
value of rq_daddr used in one place, in svc_sendto:
        if (rqstp->rq_prot == IPPROTO_UDP) {
...
                pki->ipi_spec_dst.s_addr = rqstp->rq_daddr;

                if (sock_sendmsg(sock, &msg, 0) < 0)
                        goto out;
        }

So it doesn't seem to be used at all in the TCP case.  Am I confused?

--b.


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
