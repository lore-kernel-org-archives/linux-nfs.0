Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54012 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667AbZETCNb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2009 22:13:31 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: [RFC 0/10] nfsd41 server backchannel for 2.6.31
Date: Tue, 19 May 2009 19:07:57 -0700
Message-ID: <273FE88A07F5D445824060902F70034405CEB64D@SACMVEXC1-PRD.hq.netapp.com>
From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
To: <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>, <andros@netapp.com>,
        <batsakis@netapp.com>, <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

[resend with extended cc list]

Bruce,

We've reworked the v4.1 backchannel patches to use asynchronous RPCs.
We've also addressed the comments you made on the previous series (RFC
03, RFC 04, and RFC 05).  We are still working to address Trond's
comments for RFC 03, but do not want to hold off the review of the rest
of the patches.  Can you please consider the set for inclusion in
2.6.31, with the note that an update to RFC 03 will be coming soon.

[RFC 01/11] nfsd: cleanup nfs4.0 callback encode routines
[RFC 02/11] nfsd: minorversion support for the back channel
[RFC 03/11] nfsd41: sunrpc: svc_tcp_recv_record()
[RFC 04/11] nfsd41: sunrpc: Added rpc server-side backchannel handling
[RFC 05/11] nfsd41: callback infrastructure
[RFC 06/11] nfsd41: Backchannel: Add sequence arguments to callback RPC
arguments
[RFC 07/11] nfsd41: Backchannel: Server backchannel RPC wait queue
[RFC 08/11] nfsd41: Backchannel: Setup sequence information
[RFC 09/11] nfsd41: cb_sequence callback
[RFC 10/11] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
[RFC 11/11] nfsd41: Refactor create_client()

Thanks,

- ricardo
