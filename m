From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [pnfs] nfs41: sunrpc: handle clnt==NULL in call_status
Date: Wed, 05 Nov 2008 13:52:42 -0500
Message-ID: <RTPCLUEXC2-PRDEAOeI00000065@RTPMVEXC1-PRD.hq.netapp.com>
References: <273FE88A07F5D445824060902F700344029749C8@SACMVEXC1-PRD.hq.netapp.com>
 <ABA3FEB2-D34F-4F09-A315-C08C39FD5964@oracle.com>
 <4911E076.2030605@opengridcomputing.com>
 <3682CC68-8C61-472B-8D75-B19F31576428@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Tucker <tom@opengridcomputing.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	"Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41857 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828AbYKESyB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 13:54:01 -0500
In-Reply-To: <3682CC68-8C61-472B-8D75-B19F31576428@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 01:41 PM 11/5/2008, Chuck Lever wrote:
>On Nov 5, 2008, at 1:05 PM, Tom Tucker wrote:
>> FWIW, We already require IPoIB because the NFSRDMA implementation  
>> uses the RDMA CM which is IP address based.
>
>Oh, that's too bad.  I thought the IP sideband requirement would go  
>away with NFSv4 over RDMA because NLM/NSM would be retired.

Just think of it like ARP. The RDMA CM is a low-level discovery and
connection protocol, which isn't actually used by RPC or NFS at all.
It just magically comes into play when the RPC client calls into the
rdma_connect() subsystem. RDMA uses IP addresses, btw.

Tom.

