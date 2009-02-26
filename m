From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/2] NFSD: fix handling of unsupported nfsv4 ops
Date: Thu, 26 Feb 2009 12:37:22 -0800
Message-ID: <49A6FD82.6080808@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs mailing list <pnfs@linux-nfs.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:9629 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755174AbZBZUh1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2009 15:37:27 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both patches fix issues I introduced in 2.6.27.
The first one is more crucial to get to the 2.6.2{7,8} stable streams
but while at it, I'd pull both.
This was triggered in connectathon with the Sun OpenSolaris
client trying to read extended attrs (when copying a file).
This translates to a NFS4 OP_OPENATTR which caused our server to barf.

[PATCH 1/2] NFSD: provide encode routine for OP_OPENATTR
[PATCH 2/2] NFSD: return nfsv4 error code nfserr_notsupp rather than nfsv[23]'s nfserr_opnotsupp

Benny
