From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 0/10] nfsd41 server backchannel for 2.6.31
Date: Fri, 01 May 2009 02:00:22 +0300
Message-ID: <49FA2D86.8060402@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32443 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752703AbZD3XB2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:01:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

After squashing and merging Ricardo's latest patchset
please review the following patchset and consider for 2.6.31.

Thanks,

Benny

[RFC 01/10] nfsd: cleanup nfs4.0 callback encode routines
[RFC 02/10] nfsd: minorversion support for the back channel
[RFC 03/10] nfsd41: sunrpc: Added rpc server-side backchannel handling
[RFC 04/10] nfsd41: Remember the auth flavor to use for callbacks
[RFC 05/10] nfsd41: callback infrastructure
[RFC 06/10] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
[RFC 07/10] nfsd41: Backchannel: Server backchannel RPC wait queue
[RFC 08/10] nfsd41: Backchannel: Setup sequence information
[RFC 09/10] nfsd41: cb_sequence callback
[RFC 10/10] nfsd41: cb_recall callback
