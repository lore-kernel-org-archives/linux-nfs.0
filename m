From: Benny Halevy <bhalevy@panasas.com>
Subject: 3-word attributes encoding
Date: Mon, 30 Mar 2009 17:37:37 +0300
Message-ID: <49D0D931.2060808@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16892 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751500AbZC3Ohm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 10:37:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

As I mentioned in a reply to Trond,
"nfsd41: support for 3-word long attribute bitmask"
changes the server fattr encoding logic so it may send
back a bitmap of length 1, even if the client sent a
bitmap of length 2, if the second word of the bitmap
is zero.  Although I think this a valid implementation
and other servers may do the same, it seems sub-optimal
for the client's decoding of acl of fs_locations.

It's pretty easy to revert to the old behavior on the server
by always returning at least two bitmap words, or, if we
keep the bitmap length, not just the val, in nfsd4_decode_bitmap
we can return a bitmap of the same length in the reply.

Let me know what you think...

Other than that,
git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30
holds version 3 of the nfsd41 patchset, rebased onto your
update for-2.6.30 branch, and with these cleanup patches squashed-in:

[PATCH 1/3] SQUASHME: get callback minorversion from fore channel's
[PATCH 2/3] SQUASHME: nfsd41: use nfsd4_cb_sequence for callback minorversion
[PATCH 3/3] SQUASHME: Revert "sunrpc: add cl_private field to struct rpc_clnt"

Benny
