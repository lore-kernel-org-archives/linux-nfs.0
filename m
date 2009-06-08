From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 0/10] nfsd41 server backchannel for 2.6.31 (try 3)
Date: Mon, 08 Jun 2009 15:17:49 +0300
Message-ID: <4A2D016D.6090205@panasas.com>
References: <273FE88A07F5D445824060902F7003440612BB9D@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:22920
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754629AbZFHMRt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2009 08:17:49 -0400
In-Reply-To: <273FE88A07F5D445824060902F7003440612BB9D-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged onto the nfsd41-for-2.6.31 branch.

Thanks!

Benny

On Jun. 06, 2009, 5:48 +0300, "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com> wrote:
> Bruce, Trond,
> 
> The following patch set addresses your comments on the server v4.1
> backchannel RPC functionality previously submitted.  It also addresses
> Benny's comments on the implementation of the async RPC v4.1 callbacks.
> Please consider for 2.6.31.
> 
> [RFC 01/11] nfsd41: Backchannel: cleanup nfs4.0 callback encode routines
> [RFC 02/11] nfsd41: Backchannel: minorversion support for the back
> channel
> [RFC 03/11] nfsd41: sunrpc: svc_tcp_recv_record()
> [RFC 04/11] nfsd41: sunrpc: Added rpc server-side backchannel handling
> [RFC 05/11] nfsd41: Backchannel: callback infrastructure
> [RFC 06/11] nfsd41: Backchannel: Add sequence arguments to callback RPC
> arguments
> [RFC 07/11] nfsd41: Backchannel: Server backchannel RPC wait queue
> [RFC 08/11] nfsd41: Backchannel: Setup sequence information
> [RFC 09/11] nfsd41: Backchannel: cb_sequence callback
> [RFC 10/11] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
> [RFC 11/11] nfsd41: Refactor create_client()
> 
> 
> As requested, this patch set squashes the following patches recently
> submitted to the pnfs list by Alexandros, Benny, and myself.
> 
> nfsd41: sunrpc: Remove unused functions
> nfsd41: sunrpc: Don't auto close the server backchannel connection
> nfsd41: sunrpc: eliminate unneeded switch statement in xs_setup_tcp()
> nfsd41: sunrpc: remove bc_close and bc_init_auto_disconnect dummy fun
> nfsd41: sunrpc: Define xprt_server_backchannel()
> nfsd41: sunrpc: create common send routine for the fore and the back
> nfsd41: sunrpc: remove bc_connect_worker()
> nfsd41: sunrpc: Document server backchannel locking
> nfsd41: sunrpc: Use free_page() to free server backchannel pages
> nfsd41: sunrpc: New svc_process_calldir()
> nfsd41: sunrpc: svc_tcp_recv_record()
> nfsd41: decode_cb_sequence does not need to actually decode ignored
> fields
> 
> Thanks,
> 
> - ricardo
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
