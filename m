From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/47] NFSv4.1 Sessions server code for 2.6.30
Date: Fri, 27 Mar 2009 05:58:45 +0300
Message-ID: <49CC40E5.2080506@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:12210 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753039AbZC0C71 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 22:59:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Here's the latest server patches implementing the NFSv4.1
Sessions features.

This patchset is based over your for-2.6.30 branch
and is also available from
git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30
(tagged as nfsd41-for-2.6.30-2009-03-27)

The implementation status highlights are captured in
Documentation/filesystems/nfs41-server.txt.
The gist of it is that the implementation is functional
to the level of passing Connectathon tests with v2,v3,v4,v4.1
(tested with CONFIG_NFS_V4_1 defined to 'y')

The patches are listed below.

Thanks for your review and help with this project so far.
Kudos to all the contributors (Authors/SOBs: Andy Adamson,
Dean Hildebrand, Marc Eshel, Mike Sager, Ricardo Labiaga, and
myself)  This is a pretty significant milestone for us
(well, the real one will be when all this ends up working
flawlessly in the kernel. :)

Benny

[PATCH 01/47] nfsd: don't use the deferral service, return NFS4ERR_DELAY
[PATCH 02/47] sunrpc: add cl_private field to struct rpc_clnt
[PATCH 03/47] nfsd: embed nfsd4_current_state in nfsd4_compoundres
[PATCH 04/47] nfsd: add a struct nfsd4_slot pointer to struct nfsd4_compound_state
[PATCH 05/47] nfs41: common protocol definitions
[PATCH 06/47] nfsd41: change NFSERR_REPLAY_ME
[PATCH 07/47] nfsd41: Add Kconfig symbols for NFSv4.1
[PATCH 08/47] nfsd41: define nfs41 error codes
[PATCH 09/47] nfsd41: sessions basic data types
[PATCH 10/47] nfsd41: introduce nfs4_client cl_sessions list
[PATCH 11/47] nfsd41: release_session when client is expired
[PATCH 12/47] nfsd41: sessionid hashing
[PATCH 13/47] nfsd41: xdr infrastructure
[PATCH 14/47] nfsd: remove nfsd4_ops array size
[PATCH 15/47] nfsd41: proc stubs
[PATCH 16/47] nfsd41: exchange_id operation
[PATCH 17/47] nfsd41: match clientid establishment method
[PATCH 18/47] nfsd41: sequence operation
[PATCH 19/47] nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules
[PATCH 20/47] nfsd41: DRC save, restore, and clear functions
[PATCH 21/47] nfsd41: hard page limit for DRC
[PATCH 22/47] nfsd41: nfsd DRC logic
[PATCH 23/47] nfsd41: clear DRC cache on free_session
[PATCH 24/47] nfsd41: create_session operation
[PATCH 25/47] nfsd41: Add a create session replay cache
[PATCH 26/47] nfsd41: non-page DRC for solo sequence responses
[PATCH 27/47] nfsd41: destroy_session operation
[PATCH 28/47] nfsd41: stateid handling
[PATCH 29/47] nfsd41: check encode size for sessions maxresponse cached
[PATCH 30/47] nfsd41: clientid handling
[PATCH 31/47] nfsd41: access_valid
[PATCH 32/47] nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid bmap
[PATCH 33/47] nfsd41: provide support for minor version 1 at rpc level
[PATCH 34/47] nfsd: cleanup nfs4.0 callback encode routines
[PATCH 35/47] nfsd: minorversion support for the back channel
[PATCH 36/47] nfsd41: sunrpc: Added rpc server-side backchannel handling
[PATCH 37/47] nfsd41: callback infrastructure
[PATCH 38/47] nfsd41: Remember the auth flavor to use for callbacks
[PATCH 39/47] nfsd41: introduce cl_cb_mutex
[PATCH 40/47] nfsd41: cb_sequence callback
[PATCH 41/47] nfsd41: introduce nfs4_cb_call_sync for nfs4 and nfs41
[PATCH 42/47] nfsd41: cb_recall callback
[PATCH 43/47] nfsd41: pass writable attrs mask to nfsd4_decode_fattr
[PATCH 44/47] nfsd41: support for 3-word long attribute bitmask
[PATCH 45/47] nfsd41: SUPPATTR_EXCLCREAT attribute
[PATCH 46/47] nfsd41: CREATE_EXCLUSIVE4_1
[PATCH 47/47] nfsd41: Documentation/filesystems/nfs41-server.txt

