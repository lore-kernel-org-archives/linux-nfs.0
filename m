From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/2] nfsv4 compound status
Date: Mon, 31 Mar 2008 17:35:23 +0300
Message-ID: <47F0F6AB.3030302@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:16167 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750765AbYCaOfh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Mar 2008 10:35:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two patches in this patchset implement what we discussed last month:
http://linux-nfs.org/pipermail/nfsv4/2008-February/007945.html

[PATCH 1/2] nfs: return negative error value from nfs{,4}_stat_to_errno

    All use sites for nfs{,4}_stat_to_errno negate their return value.
    It's more efficient to return a negative error from the stat_to_errno convertors
    rather than negating its return value everywhere. This also produces slightly
    smaller code.

[PATCH 2/2] nfs: use compound hdr.status to override op status.

    The compound header status must be equivalent to the
    status of the last operation in the compound results.
    In certain cases like lack of resources or xdr decoding error,
    the nfs server may return a non-zero status in the compound header
    which is not returned by any operation.  In this case we would
    notice that today when looking for the respective operations
    code in the results and we return -EIO when we cannot find it.
    This patch fixes that by returning the status available in the
    comound header instead.

    This patch also fixes 3 call sites where we looked at the comound
    hdr.status in the success case which is useless (yet benign).
    These are nfs4_xdr_dec_{fsinfo,setclientid,setclientid_confirm}

Benny
