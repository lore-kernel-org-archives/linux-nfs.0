From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [pnfs] [RFC 0/10] nfsd41 server backchannel for 2.6.31
Date: Tue, 19 May 2009 20:04:51 -0700
Message-ID: <273FE88A07F5D445824060902F70034405CEB672@SACMVEXC1-PRD.hq.netapp.com>
References: <273FE88A07F5D445824060902F70034405CEB64D@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
	<linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
	<bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25460 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751822AbZETDEz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2009 23:04:55 -0400
In-Reply-To: <273FE88A07F5D445824060902F70034405CEB64D-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Labiaga, Ricardo
> Sent: Tuesday, May 19, 2009 7:08 PM
> To: bfields@fieldses.org
> Cc: Adamson, Andy; linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
> Subject: [pnfs] [RFC 0/10] nfsd41 server backchannel for 2.6.31
> 
> [resend with extended cc list]
> 
> Bruce,
> 
> We've reworked the v4.1 backchannel patches to use asynchronous RPCs.
> We've also addressed the comments you made on the previous series (RFC
> 03, RFC 04, and RFC 05).  We are still working to address Trond's
> comments for RFC 03, but do not want to hold off the review of the
rest
> of the patches.  Can you please consider the set for inclusion in
> 2.6.31, with the note that an update to RFC 03 will be coming soon.

Correction, an update to RFC 04 will be coming soon.  Sorry for the
noise.

- ricardo

> 
> [RFC 01/11] nfsd: cleanup nfs4.0 callback encode routines
> [RFC 02/11] nfsd: minorversion support for the back channel
> [RFC 03/11] nfsd41: sunrpc: svc_tcp_recv_record()
> [RFC 04/11] nfsd41: sunrpc: Added rpc server-side backchannel handling
> [RFC 05/11] nfsd41: callback infrastructure
> [RFC 06/11] nfsd41: Backchannel: Add sequence arguments to callback
RPC
> arguments
> [RFC 07/11] nfsd41: Backchannel: Server backchannel RPC wait queue
> [RFC 08/11] nfsd41: Backchannel: Setup sequence information
> [RFC 09/11] nfsd41: cb_sequence callback
> [RFC 10/11] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
> [RFC 11/11] nfsd41: Refactor create_client()
> 
> Thanks,
> 
> - ricardo
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
