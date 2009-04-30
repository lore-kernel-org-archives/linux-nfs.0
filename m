From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 0/39] nfs41 client backchannel for 2.6.31
Date: Fri, 01 May 2009 02:17:20 +0300
Message-ID: <49FA3180.5030404@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32333 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752005AbZD3XR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:17:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

Please review the following patchset and consider for 2.6.31.

It is also available on
git://linux-nfs.org/~bhalevy/linux-pnfs.git nfs41-for-2.6.31
which is based onto
git://git.linux-nfs.org/~trondmy/nfs-2.6.git nfsv41

Thanks,

Benny

[RFC 01/39] nfs41: Add ability to read RPC call direction on TCP stream.
[RFC 02/39] nfs41: Skip past the RPC call direction
[RFC 03/39] nfs41: Refactor nfs4_{init,destroy}_callback for nfs4.0
[RFC 04/39] nfs41: minorversion support for nfs4_{init,destroy}_callback
[RFC 05/39] nfs41: client callback structures
[RFC 06/39] nfs41: Initialize new rpc_xprt callback related fields
[RFC 07/39] nfs41: New backchannel helper routines
[RFC 08/39] nfs41: New include/linux/sunrpc/bc_xprt.h
[RFC 09/39] nfs41: New xs_tcp_read_data()
[RFC 10/39] nfs41: Add backchannel processing support to RPC state machine
[RFC 11/39] nfs41: Backchannel callback service helper routines
[RFC 12/39] nfs41: Refactor svc_process()
[RFC 13/39] nfs41: Backchannel bc_svc_process()
[RFC 14/39] nfs41: Implement NFSv4.1 callback service process.
[RFC 15/39] nfs41: sunrpc: provide functions to create and destroy a svc_xprt for backchannel use
[RFC 16/39] nfs41: sunrpc: add a struct svc_xprt pointer to struct svc_serv for backchannel use
[RFC 17/39] nfs41: create a svc_xprt for nfs41 callback thread and use for incoming callbacks
[RFC 18/39] nfs41: save svc_serv in nfs_callback_info
[RFC 19/39] nfs41: Allow NFSv4 and NFSv4.1 callback services to coexist
[RFC 20/39] nfs41: Setup the backchannel
[RFC 21/39] nfs41: Client indicates presence of NFSv4.1 callback channel.
[RFC 22/39] nfs41: Get the rpc_xprt * from the rpc_rqst instead of the rpc_clnt.
[RFC 23/39] nfs41: Release backchannel resources associated with session
[RFC 24/39] nfs41: store minorversion in cb_compound_hdr_arg
[RFC 25/39] nfs41: decode minorversion 1 cb_compound header
[RFC 26/39] nfs41: callback numbers definitions
[RFC 27/39] nfs41: consider minorversion in callback_xdr:process_op
[RFC 28/39] nfs41: define CB_NOTIFY_DEVICEID as not supported
[RFC 29/39] nfs41: cb_sequence protocol level data structures
[RFC 30/39] nfs41: cb_sequence proc implementation
[RFC 31/39] nfs41: cb_sequence xdr implementation
[RFC 32/39] nfs41: verify CB_SEQUENCE position in callback compound
[RFC 33/39] nfs41: Rename rq_received to rq_reply_bytes_recvd
[RFC 34/39] nfs41: Backchannel: update cb_sequence args and results
[RFC 35/39] nfs41: Backchannel: Refactor nfs4_reset_slot_table()
[RFC 36/39] nfs41: Backchannel: Refactor nfs4_init_slot_table()
[RFC 37/39] nfs41: Backchannel: Add a backchannel slot table to the session
[RFC 38/39] nfs41: Backchannel: New find_client_with_session()
[RFC 39/39] nfs41: Backchannel: CB_SEQUENCE validation
