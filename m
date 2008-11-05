From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [pnfs] nfs41: sunrpc: handle clnt==NULL in call_status
Date: Wed, 05 Nov 2008 13:08:04 -0500
Message-ID: <1225908484.16857.20.camel@heimdal.trondhjem.org>
References: <273FE88A07F5D445824060902F700344029749C8@SACMVEXC1-PRD.hq.netapp.com>
	 <ABA3FEB2-D34F-4F09-A315-C08C39FD5964@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38308 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752793AbYKESIO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 13:08:14 -0500
In-Reply-To: <ABA3FEB2-D34F-4F09-A315-C08C39FD5964@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-11-05 at 11:53 -0500, Chuck Lever wrote:
> Now we have to have this conversation again when adding any new  
> transport capability, such as SCTP.

> Plus, to support NFSv4.1 over RDMA, you now _require_ the existence of  
> an IP network between client and server.  This may be as minor as  
> ensuring IPoIB is configured on both ends, but it's still a  
> significant extra step for a pure SAN over RDMA environment.  This  
> obviates the whole point of combining the forward and back channels  
> onto one transport.
> 
> In my opinion you are making the developer's life simpler now and  
> complicating the lives of current users and admins, and future  
> developers.

Please read what Ricardo said: this is a _first_ approximation, not a
final solution. Given what they're hoping to achieve, I'm fine with
doing a simple implementation of sessions first, then progressively
refining it.

Furthermore, there should be nothing conceptually  in his design that
prevents you from adapting it to other transports: it is basically just
preallocating a buffer, then using that as a receive buffer when you
find that you have a callback request.


Trond

