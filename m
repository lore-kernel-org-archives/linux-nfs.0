From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/6] NFSD: minor cleanups for 2.6.29
Date: Mon, 15 Dec 2008 19:38:09 +0200
Message-ID: <49469601.7020101@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pnfs mailing list <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:3781 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755156AbYLORiP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2008 12:38:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,  following are half a dozen patches
from the nfs41/pnfs tree
git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd-for-2.6.29

[PATCH 1/6] nfsd: add etoosmall to nfserrno
[PATCH 2/6] nfsd: dprint each op status in nfsd4_proc_compound
[PATCH 3/6] nfsd: git rid of nfs4_cb_null_ops declaration
[PATCH 4/6] nfsd: delete wrong file comment from nfsd/nfs4xdr.c
[PATCH 5/6] nfsd: last_byte_offset
[PATCH 6/6] nfsd: get rid of NFSD_VERSION

Benny
