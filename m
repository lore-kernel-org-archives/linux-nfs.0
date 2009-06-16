From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: What's in nfsd41-for-2.6.31
Date: Mon, 15 Jun 2009 21:16:55 -0400
Message-ID: <7225594ED4A1304C9E43D030A886D221F4C559@daytona.int.panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <pnfs@linux-nfs.org>, <linux-nfs@vger.kernel.org>
To: <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2551
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752010AbZFPBRc convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2009 21:17:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

The following patches are currently queued up in my nfsd41-for-2.6.31 branch:

[PATCH 01/44] nfsd41: move channel attributes from nfsd4_session to a nfsd4_channel_attr struct
[PATCH 02/44] nfsd41: slots are freed with session
[PATCH 03/44] nfsd41: change check_slot_seqid parameters
[PATCH 04/44] nfsd41: turn off create session caching
[PATCH 05/44] nfsd41: separate clientid slot from session slot
[PATCH 06/44] nfsd41: encode create_session result into cache
[PATCH 07/44] nfsd41: create_session check replay first
[PATCH 08/44] nfsd41: replay solo and embedded create session
[PATCH 09/44] nfsd41: sanity check client drc maxreqs
[PATCH 10/44] nfsd41: change from page to memory based drc limits
[PATCH 11/44] nfsd41: use globals for DRC memory use management
[PATCH 12/44] nfsd41: set the session maximum response size cached
[PATCH 13/44] nfsd41: use static buffers for sessions DRC
[PATCH 14/44] nfsd41: replace ce_cachethis with nfsd4_slot field
[PATCH 15/44] nfsd41: replace ce_opcnt with nfsd4_slot field
[PATCH 16/44] nfsd41: nfsd41: replace ce_status with nfsd4_slot field
[PATCH 17/44] nfsd41: obliterate nfsd4_copy_pages
[PATCH 18/44] nfsd41: obliterate nfsd41_copy_replay_data
[PATCH 19/44] nfsd41: obliterate nfsd4_release_respages
[PATCH 20/44] nfsd41: remove iovlen field from nfsd4_compound_state
[PATCH 21/44] nfsd41: remove struct nfsd4_cache_entry
[PATCH 22/44] nfsd41: obliterate nfsd4_set_statp
[PATCH 23/44] nfsd41: rename nfsd4_enc_uncached_replay
[PATCH 24/44] nfsd41: encode replay sequence from the slot values
[PATCH 25/44] nfsd41: fix nfsd4_replay_cache_entry comments
[PATCH 26/44] nfsd41: fix nfsd4_store_cache_entry comments
[PATCH 27/44] nfsd41: support 16 slots per session
[PATCH 28/44] nfsd41: use the maximum operations per compound in nfsd4_compoundargs
[PATCH 29/44] nfsd41: fix nfsd4_store_cache_entry dprintk
[PATCH 30/44] nfsd41: add test for failed sequence operation
[PATCH 31/44] nfsd41: remove redundant failed sequence check
[PATCH 32/44] nfsd41: only reference the session on non-replay sequence
[PATCH 33/44] nfsd41: Remove ip address collision detection case per review comment
[PATCH 34/44] nfsd41: Backchannel: cleanup nfs4.0 callback encode routines
[PATCH 35/44] nfsd41: Backchannel: minorversion support for the back channel
[PATCH 36/44] nfsd41: sunrpc: svc_tcp_recv_record()
[PATCH 37/44] nfsd41: sunrpc: Added rpc server-side backchannel handling
[PATCH 38/44] nfsd41: Backchannel: callback infrastructure
[PATCH 39/44] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
[PATCH 40/44] nfsd41: Backchannel: Server backchannel RPC wait queue
[PATCH 41/44] nfsd41: Backchannel: Setup sequence information
[PATCH 42/44] nfsd41: Backchannel: cb_sequence callback
[PATCH 43/44] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
[PATCH 44/44] nfsd41: Refactor create_client()


