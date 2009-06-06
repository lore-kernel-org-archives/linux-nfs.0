Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2429 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753058AbZFFCvI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2009 22:51:08 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: [RFC 0/10] nfsd41 server backchannel for 2.6.31 (try 3)
Date: Fri, 5 Jun 2009 19:48:21 -0700
Message-ID: <273FE88A07F5D445824060902F7003440612BB9D@SACMVEXC1-PRD.hq.netapp.com>
From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: <pnfs@linux-nfs.org>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Bruce, Trond,

The following patch set addresses your comments on the server v4.1
backchannel RPC functionality previously submitted.  It also addresses
Benny's comments on the implementation of the async RPC v4.1 callbacks.
Please consider for 2.6.31.

[RFC 01/11] nfsd41: Backchannel: cleanup nfs4.0 callback encode routines
[RFC 02/11] nfsd41: Backchannel: minorversion support for the back
channel
[RFC 03/11] nfsd41: sunrpc: svc_tcp_recv_record()
[RFC 04/11] nfsd41: sunrpc: Added rpc server-side backchannel handling
[RFC 05/11] nfsd41: Backchannel: callback infrastructure
[RFC 06/11] nfsd41: Backchannel: Add sequence arguments to callback RPC
arguments
[RFC 07/11] nfsd41: Backchannel: Server backchannel RPC wait queue
[RFC 08/11] nfsd41: Backchannel: Setup sequence information
[RFC 09/11] nfsd41: Backchannel: cb_sequence callback
[RFC 10/11] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
[RFC 11/11] nfsd41: Refactor create_client()


As requested, this patch set squashes the following patches recently
submitted to the pnfs list by Alexandros, Benny, and myself.

nfsd41: sunrpc: Remove unused functions
nfsd41: sunrpc: Don't auto close the server backchannel connection
nfsd41: sunrpc: eliminate unneeded switch statement in xs_setup_tcp()
nfsd41: sunrpc: remove bc_close and bc_init_auto_disconnect dummy fun
nfsd41: sunrpc: Define xprt_server_backchannel()
nfsd41: sunrpc: create common send routine for the fore and the back
nfsd41: sunrpc: remove bc_connect_worker()
nfsd41: sunrpc: Document server backchannel locking
nfsd41: sunrpc: Use free_page() to free server backchannel pages
nfsd41: sunrpc: New svc_process_calldir()
nfsd41: sunrpc: svc_tcp_recv_record()
nfsd41: decode_cb_sequence does not need to actually decode ignored
fields

Thanks,

- ricardo
