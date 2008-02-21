From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: compound header status
Date: Thu, 21 Feb 2008 00:18:36 -0500
Message-ID: <E472128B1EB43941B4E7FB268020C89B054968F1@riverside.int.panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <nfsv4@linux-nfs.org>, <pnfs@linux-nfs.org>,
	<linux-nfs@vger.kernel.org>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:11408 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751165AbYBUFTK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2008 00:19:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, we had a discussion today in Austin about the COMPOUND result header
status.  Looking at fs/nfs/nfs4xdr.c we saw that some decoding routines
return an error based on hdr.status after all the compound operations
decoding completed successfully.

For example:
static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, struct nfs_fsinfo *fsinfo)
{
	struct xdr_stream xdr;
	struct compound_hdr hdr;
	int status;

	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
	status = decode_compound_hdr(&xdr, &hdr);
	if (!status)
		status = decode_setclientid_confirm(&xdr);
	if (!status)
		status = decode_putrootfh(&xdr);
	if (!status)
		status = decode_fsinfo(&xdr, fsinfo);
	if (!status)
		status = -nfs4_stat_to_errno(hdr.status);
		                             ^^^^^^^^^^
	return status;
}

It seems like this is unneeded since hdr.status must be NFS_OK if all operations
in the compound succeeded (and assuming we decode the results from all ops we sent).
The first error will be found by decode_op_hdr called by any of the decoding
routines for the individual ops.
If hdr.status contains an error in this case, the server must be broken, isn't it?

Also, nfs4_stat_to_errno is not handling the success case very efficiently as
it looks for it in its mapping table like any other error code.

One more thing, all use sites for nfs4_stat_to_errno negate its return value
so it might make sense to return a negative error from nfs4_stat_to_errno rather
than negating its return value everywhere.

Benny

