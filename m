From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Tue, 29 Jan 2008 15:31:01 -0500
Message-ID: <1201638661.7969.7.camel@heimdal.trondhjem.org>
References: <476CEC5E.9070002@abinetworks.biz>
	 <838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc>
	 <476E47F5.4090807@abinetworks.biz>
	 <20071225140431.9264970a.akpm@linux-foundation.org>
	 <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com>
	 <4791EE99.3030802@abinetworks.biz>
	 <5FD6714F-EF9A-4F07-B2B6-D6F6CC911936@oracle.com>
	 <479C744A.6020207@abinetworks.biz>
	 <12964A18-350B-443F-B15A-D78B3723C89A@oracle.com>
	 <479F2463.2040704@abinetworks.biz>
	 <4AAA3DAF-898C-4ED5-BD07-4FD2B5CEEF16@oracle.com>
	 <Pine.LNX.4.64.0801291851110.4820@maggie.lkpg.cendio.se>
	 <7EE4B02B-3359-41C0-BFED-0947DF9F5F5A@oracle.com>
	 <479F8377.6090704@abinetworks.biz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Peter =?ISO-8859-1?Q?=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46112 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752154AbYA2UbX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 15:31:23 -0500
In-Reply-To: <479F8377.6090704-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-29 at 20:50 +0100, Gianluca Alberici wrote:
> Hello,
> 
> I confirm that i have encountered this same problem (EINVAL on open 
> (...O | TRUNC) with the following userspace servers:
> 
> - nfs-user-server shipped with debian sarge/etch etc...
> - cfsd (crypto file system which is an nfs server)
> 
> I want to underline again that these userspace servers have been woking 
> perfectly until 2.6.21.7 (which is the last 2.6.21)
> Since 2.6.22 the problem came out and it is still present into 2.6.24 
> rc7 (last i tested). Conclusion: there must have been something that is
> changed in 2.6.22 that caused the problem.

The only difference between these two dumps are the fact that the first
one isn't using the Sun convention for telling NFSv2 servers to set to
the current time (see the code in xdr_encode_current_server_time).

I don't see why this would be new behaviour after 2.6.21. The code for
this has been in the NFS client since 2.6.15 at least...

Trond

