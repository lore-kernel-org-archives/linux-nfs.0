From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 0/12] nfsd41 backchannel patches for 2.6.32
Date: Thu, 10 Sep 2009 12:23:35 +0300
Message-ID: <4AA8C597.8080809@panasas.com>
References: <4AA13DE3.8020800@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Alexandros Batsakis <batsakis@netapp.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:60041 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755267AbZIJJXH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 05:23:07 -0400
In-Reply-To: <4AA13DE3.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

This version incorporates the latest fixes from Alexandros
that address Trond's comments:
http://linux-nfs.org/pipermail/pnfs/2009-September/009052.html
http://linux-nfs.org/pipermail/pnfs/2009-September/009053.html
http://linux-nfs.org/pipermail/pnfs/2009-September/009059.html

This version introduces a new xprt class for the nfsv4.1 backchannel
with its own setup routine to keep xs_setup_tcp clean.

I also cleaned up the patches a little further by removing
a bit of dead code and fixing checkpatch whitespace related
warnings in Alexandros squashme patches.

Benny

On Sep. 04, 2009, 19:18 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> Bruce,
> 
> Here's the updated patchset implementing the nfs41 backchannel
> for the nfs server.
> 
> Changes from previous version:
> - Rebase onto git://git.linux-nfs.org/~bfields/linux.git for-2.6.32
> 
> - bc_send_request does not block on the xpt_mutex
>   but rather uses the rpc_sleep_on to wait on it.
> 
> - nfsd4_create_session initializes unconf->cl_cb_conn.cb_addr.
> 
> - cosmetic-only changes cleaned up.
> 
> [PATCH 01/10] nfsd41: sunrpc: move struct rpc_buffer def into sunrpc.h
> [PATCH 02/10] nfsd41: sunrpc: Added rpc server-side backchannel handling
> [PATCH 03/10] nfsd4: fix whitespace in NFSPROC4_CLNT_CB_NULL definition
> [PATCH 04/10] nfsd41: Backchannel: callback infrastructure
> [PATCH 05/10] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
> [PATCH 06/10] nfsd41: Backchannel: Server backchannel RPC wait queue
> [PATCH 07/10] nfsd41: Backchannel: Setup sequence information
> [PATCH 08/10] nfsd41: Backchannel: cb_sequence callback
> [PATCH 09/10] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
> [PATCH 10/10] nfsd41: Refactor create_client()
> 
> Benny
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
