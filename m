From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/47] NFSv4.1 Sessions server code for 2.6.30
Date: Sat, 28 Mar 2009 11:28:50 +0300
Message-ID: <49CDDFC2.4070402@panasas.com>
References: <49CC40E5.2080506@panasas.com> <20090328000134.GH18222@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:12086 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751332AbZC1I2z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:28:55 -0400
In-Reply-To: <20090328000134.GH18222@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 28, 2009, 3:01 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Fri, Mar 27, 2009 at 05:58:45AM +0300, Benny Halevy wrote:
>> Hi Bruce,
>>
>> Here's the latest server patches implementing the NFSv4.1
>> Sessions features.
>>
>> This patchset is based over your for-2.6.30 branch
>> and is also available from
>> git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30
> 
> There's a few merge conflicts with my current for-2.6.30--probably my
> fault for not pushing that out recently enough, apologies.  Would you
> mind updating?
> 
> --b.
> 

Sure. Here's a rebased version with two minor changes (see below)

Benny

[PATCH v2 01/47] nfsd: don't use the deferral service, return NFS4ERR_DELAY
commit message edited.

[PATCH v2 02/47] nfsd: embed nfsd4_current_state in nfsd4_compoundres
[PATCH v2 03/47] nfsd: add a struct nfsd4_slot pointer to struct nfsd4_compound_state
[PATCH v2 04/47] nfs41: common protocol definitions
[PATCH v2 05/47] nfsd41: change NFSERR_REPLAY_ME
[PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
[PATCH v2 07/47] nfsd41: define nfs41 error codes
[PATCH v2 08/47] nfsd41: sessions basic data types
[PATCH v2 09/47] nfsd41: introduce nfs4_client cl_sessions list
[PATCH v2 10/47] nfsd41: release_session when client is expired
[PATCH v2 11/47] nfsd41: sessionid hashing
[PATCH v2 12/47] nfsd41: xdr infrastructure
[PATCH v2 13/47] nfsd: remove nfsd4_ops array size
[PATCH v2 14/47] nfsd41: proc stubs
[PATCH v2 15/47] nfsd41: exchange_id operation
[PATCH v2 16/47] nfsd41: match clientid establishment method
[PATCH v2 17/47] nfsd41: sequence operation
[PATCH v2 18/47] nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules
[PATCH v2 19/47] nfsd41: DRC save, restore, and clear functions
[PATCH v2 20/47] nfsd41: hard page limit for DRC
[PATCH v2 21/47] nfsd41: nfsd DRC logic
[PATCH v2 22/47] nfsd41: clear DRC cache on free_session
[PATCH v2 23/47] nfsd41: create_session operation
[PATCH v2 24/47] nfsd41: Add a create session replay cache
[PATCH v2 25/47] nfsd41: non-page DRC for solo sequence responses
[PATCH v2 26/47] nfsd41: destroy_session operation
[PATCH v2 27/47] nfsd41: stateid handling
[PATCH v2 28/47] nfsd41: check encode size for sessions maxresponse cached
[PATCH v2 29/47] nfsd41: clientid handling
[PATCH v2 30/47] nfsd41: access_valid
[PATCH v2 31/47] nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid bmap
[PATCH v2 32/47] nfsd41: provide support for minor version 1 at rpc level
[PATCH v2 33/47] nfsd: cleanup nfs4.0 callback encode routines
[PATCH v2 34/47] sunrpc: add cl_private field to struct rpc_clnt
patch moved forward, right before first use.

[PATCH v2 35/47] nfsd: minorversion support for the back channel
[PATCH v2 36/47] nfsd41: sunrpc: Added rpc server-side backchannel handling
[PATCH v2 37/47] nfsd41: callback infrastructure
[PATCH v2 38/47] nfsd41: Remember the auth flavor to use for callbacks
[PATCH v2 39/47] nfsd41: introduce cl_cb_mutex
[PATCH v2 40/47] nfsd41: cb_sequence callback
[PATCH v2 41/47] nfsd41: introduce nfs4_cb_call_sync for nfs4 and nfs41
[PATCH v2 42/47] nfsd41: cb_recall callback
[PATCH v2 43/47] nfsd41: pass writable attrs mask to nfsd4_decode_fattr
[PATCH v2 44/47] nfsd41: support for 3-word long attribute bitmask
[PATCH v2 45/47] nfsd41: SUPPATTR_EXCLCREAT attribute
[PATCH v2 46/47] nfsd41: CREATE_EXCLUSIVE4_1
[PATCH v2 47/47] nfsd41: Documentation/filesystems/nfs41-server.txt
