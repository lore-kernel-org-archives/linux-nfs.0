From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] 3-word attributes encoding
Date: Mon, 30 Mar 2009 21:44:39 -0400
Message-ID: <20090331014439.GA7273@fieldses.org>
References: <49D0D931.2060808@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:59775 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961AbZCaBou (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 21:44:50 -0400
In-Reply-To: <49D0D931.2060808@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2009 at 05:37:37PM +0300, Benny Halevy wrote:
> Bruce,
> 
> As I mentioned in a reply to Trond,
> "nfsd41: support for 3-word long attribute bitmask"
> changes the server fattr encoding logic so it may send
> back a bitmap of length 1, even if the client sent a
> bitmap of length 2, if the second word of the bitmap
> is zero.  Although I think this a valid implementation
> and other servers may do the same, it seems sub-optimal
> for the client's decoding of acl of fs_locations.

"suboptimal" means it does some extra memcpy'ing?

> It's pretty easy to revert to the old behavior on the server
> by always returning at least two bitmap words, or, if we
> keep the bitmap length, not just the val, in nfsd4_decode_bitmap
> we can return a bitmap of the same length in the reply.

Odd thing to have to do, but OK. --b.  

> 
> Let me know what you think...
> 
> Other than that,
> git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30
> holds version 3 of the nfsd41 patchset, rebased onto your
> update for-2.6.30 branch, and with these cleanup patches squashed-in:
> 
> [PATCH 1/3] SQUASHME: get callback minorversion from fore channel's
> [PATCH 2/3] SQUASHME: nfsd41: use nfsd4_cb_sequence for callback minorversion
> [PATCH 3/3] SQUASHME: Revert "sunrpc: add cl_private field to struct rpc_clnt"
> 
> Benny
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
