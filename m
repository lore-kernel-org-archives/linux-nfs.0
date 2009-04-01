From: Benny Halevy <bhalevy@panasas.com>
Subject: nfs41-for-next
Date: Wed, 01 Apr 2009 15:37:20 +0300
Message-ID: <49D36000.8030708@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27203 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757176AbZDAMh1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 08:37:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

git://linux-nfs.org/~bhalevy/linux-pnfs.git nfs41-for-next
holds the nfs41-for-2.6.30 patches rebased onto today's
linux-next.  Note that nfsd41-for-2.6.30 is already in
linux-next via Bruce's tree so nfs41-for-next provides
both the client and server code for nfsv4.1.

The only material change between nfs41-for-2.6.30 and
nfs41-for-next is that I dropped this patch:
"FIXME: nfs41: sunrpc: handle clnt==NULL in call_status"
from -for-next since it's not strictly needed there
as clnt is nor dereferenced anymore in the -ENOTCONN
case in call_status().

Benny
