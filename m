From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 0/51] nfs41 server patches for review
Date: Mon, 10 Nov 2008 22:39:16 +0200
Message-ID: <49189BF4.50404@panasas.com>
References: <491895A0.3040809@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:49190 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456AbYKJUjV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:39:21 -0500
Received: by ey-out-2122.google.com with SMTP id 6so1026153eyi.37
        for <linux-nfs@vger.kernel.org>; Mon, 10 Nov 2008 12:39:19 -0800 (PST)
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The patchset is also available on
git://linux-nfs.org/~bhalevy/linux-pnfs.git nfs41-2.6.28-review

Cumulated diff for the server side changes:

http://git.linux-nfs.org/?p=bhalevy/linux-pnfs.git;a=commitdiff_plain;h=nfs41-2.6.28-rc4-server-review-2008-11-10;hp=nfs41-2.6.28-rc4-client-review-2008-11-10

Benny

On Nov. 10, 2008, 22:12 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Bruce,
> 
> Here's the patch series for nfs41 server side, rebased
> over 2.6.28 for review.
> 
> I've cleaned up the patch as much as I could in the given
> time frame but surely there's more work to be done.
> 
> I encourage others to comment on the patches as well.
> 
> Note that the following patch in the client sie patchset:
> 	[RFC 06/85] nfs41: common protocol definitions
> contains common code and is needed for the server side
> to compile and run.
> 
> Thanks,
> 
> Benny
> 
> pre-nfs41 misc. patches:
> [RFC 01/51] nfsd: add etoosmall to nfserrno
> [RFC 02/51] nfsd: dprint each op status in nfsd4_proc_compound
> [RFC 03/51] nfsd: git rid of nfs4_cb_null_ops declaration
> [RFC 04/51] nfsd: fix file comment in fs/nfsd/nfs4xdr.c
> 
> basic sessions support:
> [RFC 05/51] nfsd41: Add Kconfig symbols for NFSv4.1
> [RFC 06/51] nfsd41: define nfs41 error codes
> [RFC 07/51] nfsd41: sessions basic data types
> [RFC 08/51] nfsd41: introduce nfs4_client cl_sessions list
> [RFC 09/51] nfsd41: destroy_session when client is expired
> [RFC 10/51] nfsd41: sessionid hashing
> [RFC 11/51] FIXME: nfsd41: reduce server lease time for nfs41
> 
> minorversion 1 support:
> [RFC 12/51] nfsd41: provide support for minor version 1 at rpc level
> [RFC 13/51] FIXME: nfsd41: introduce current_session
> [RFC 14/51] nfsd41: introduce nfs41_{get,set}_slot_state
> [RFC 15/51] FIXME: nfsd41: free up slot unless operation is dropped
> [RFC 16/51] nfsd41: stateid handling
> [RFC 17/51] nfsd41: clientid handling
> [RFC 18/51] nfsd41: access_valid
> [RFC 19/51] nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid bmap
> [RFC 20/51] nfsd: last_byte_offset
> [Hmm, this one actually belongs in the pre-nfs41 section]
> 
> nfs41 ops:
> [RFC 21/51] nfsd41: xdr stubs
> [RFC 22/51] nfsd41: proc stubs
> [RFC 23/51] nfsd41: exchange_id operation
> [RFC 24/51] nfsd41: print exchange flags when purging client
> [RFC 25/51] nfsd41: create_session operation
> [RFC 26/51] nfsd41: destroy_session operation
> [RFC 27/51] nfsd41: sequence operation
> 
> backchannel support:
> [RFC 28/51] FIXME: nfsd41: sunrpc: Added rpc server-side backchannel handling
> [RFC 29/51] nfsd: BUG_ON_UNLOCKED_STATE
> [RFC 30/51] nfsd: lock state around nfs4_put_delegation in nfsd_break_deleg_cb err path
> [RFC 31/51] FIXME: nfsd: kref_get cb_client while doing the callback
> 
> callback support:
> [RFC 32/51] nfsd41: callback infrastructure
> [RFC 33/51] nfsd41: introduce cl_cb_mutex
> [RFC 34/51] nfsd41: cb_sequence callback
> [RFC 35/51] nfsd41: introduce nfs4_cb_call_sync for nfs4 and nfs41
> [RFC 36/51] nfsd41: cb_recall callback
> 
> CREATE_EXCLUSIVE4_1:
> [RFC 37/51] nfsd41: pass writable attrs mask to nfsd4_decode_fattr
> [RFC 38/51] nfsd41: support for 3-word long attribute bitmask
> [RFC 39/51] nfsd41: SUPPATTR_EXCLCREAT attribute
> [RFC 40/51] nfsd41: CREATE_EXCLUSIVE4_1
> 
> replay cache:
> [RFC 41/51] sunrpc: Add deferral save and restore state callback
> [RFC 42/51] nfsd: save and restore defer result pages
> [RFC 43/51] nfsd: deferral processing
> [RFC 44/51] nfsd41: slab cache for current session
> [RFC 45/51] nfsd41: DRC save, restore, and clear functions
> [RFC 46/51] nfsd41: nfsd nfsd4_sequence DRC logic
> [RFC 47/51] nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules
> [RFC 48/51] nfsd41: nfsd DRC logic
> [RFC 49/51] nfsd41: clear DRC cache on free_session
> [RFC 50/51] nfsd41: Add a create session replay cache
> [RFC 51/51] nfsd41: print DRC statistics
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs

