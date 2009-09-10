From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH v2 0/12] nfsd41 backchannel patches for 2.6.32
Date: Thu, 10 Sep 2009 12:28:08 -0400
Message-ID: <20090910162808.GG11858@fieldses.org>
References: <4AA13DE3.8020800@panasas.com> <4AA8C597.8080809@panasas.com> <4AA90F26.6010704@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60077 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048AbZIJQ2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Sep 2009 12:28:05 -0400
In-Reply-To: <4AA90F26.6010704@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 10, 2009 at 05:37:26PM +0300, Benny Halevy wrote:
> Bruce, I've updated patches 2 and 3 based on Trond's comment to
> PATCH v2 02/12 and squashed Alexandros fix for it.

Thanks!  Trond, did you have any more comments?

--b.

> 
> Here's the latest list of patches:
> [PATCH v2 01/12] nfsd41: sunrpc: move struct rpc_buffer def into sunrpc.h
> [PATCH v3 02/12] nfsd41: sunrpc: Added rpc server-side backchannel handling
> [PATCH v3 03/12] nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel
> [PATCH v2 04/12] nfsd4: fix whitespace in NFSPROC4_CLNT_CB_NULL definition
> [PATCH v2 05/12] nfsd41: Backchannel: callback infrastructure
> [PATCH v2 06/12] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
> [PATCH v2 07/12] nfsd41: Backchannel: Server backchannel RPC wait queue
> [PATCH v2 08/12] nfsd41: Backchannel: Setup sequence information
> [PATCH v2 09/12] nfsd41: Backchannel: cb_sequence callback
> [PATCH v2 10/12] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
> [PATCH v2 11/12] nfsd41:  modify nfsd4.1 backchannel to use new xprt class
> [PATCH v2 12/12] nfsd41: Refactor create_client()
> 
> Thanks,
> 
> Benny
> 
> On Sep. 10, 2009, 12:23 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> > Bruce,
> > 
> > This version incorporates the latest fixes from Alexandros
> > that address Trond's comments:
> > http://linux-nfs.org/pipermail/pnfs/2009-September/009052.html
> > http://linux-nfs.org/pipermail/pnfs/2009-September/009053.html
> > http://linux-nfs.org/pipermail/pnfs/2009-September/009059.html
> > 
> > This version introduces a new xprt class for the nfsv4.1 backchannel
> > with its own setup routine to keep xs_setup_tcp clean.
> > 
> > I also cleaned up the patches a little further by removing
> > a bit of dead code and fixing checkpatch whitespace related
> > warnings in Alexandros squashme patches.
> > 
> > Benny
> > 
> > On Sep. 04, 2009, 19:18 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> >> Bruce,
> >>
> >> Here's the updated patchset implementing the nfs41 backchannel
> >> for the nfs server.
> >>
> >> Changes from previous version:
> >> - Rebase onto git://git.linux-nfs.org/~bfields/linux.git for-2.6.32
> >>
> >> - bc_send_request does not block on the xpt_mutex
> >>   but rather uses the rpc_sleep_on to wait on it.
> >>
> >> - nfsd4_create_session initializes unconf->cl_cb_conn.cb_addr.
> >>
> >> - cosmetic-only changes cleaned up.
> >>
> >> [PATCH 01/10] nfsd41: sunrpc: move struct rpc_buffer def into sunrpc.h
> >> [PATCH 02/10] nfsd41: sunrpc: Added rpc server-side backchannel handling
> >> [PATCH 03/10] nfsd4: fix whitespace in NFSPROC4_CLNT_CB_NULL definition
> >> [PATCH 04/10] nfsd41: Backchannel: callback infrastructure
> >> [PATCH 05/10] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
> >> [PATCH 06/10] nfsd41: Backchannel: Server backchannel RPC wait queue
> >> [PATCH 07/10] nfsd41: Backchannel: Setup sequence information
> >> [PATCH 08/10] nfsd41: Backchannel: cb_sequence callback
> >> [PATCH 09/10] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
> >> [PATCH 10/10] nfsd41: Refactor create_client()
> >>
> >> Benny
> >> _______________________________________________
> >> pNFS mailing list
> >> pNFS@linux-nfs.org
> >> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> > _______________________________________________
> > pNFS mailing list
> > pNFS@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> 
