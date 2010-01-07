Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839Ab0AGXc5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 18:32:57 -0500
Message-ID: <4B466F20.1090907@RedHat.com>
Date: Thu, 07 Jan 2010 18:32:48 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] showmount bug fixes
References: <20100107162421.27102.21422.stgit@localhost.localdomain> <4B461F48.4070906@RedHat.com> <7FEF347F-051D-4B08-A647-27506CFEC12A@oracle.com> <4B464355.1000405@RedHat.com> <3C1CD7DD-E915-4FDB-815A-6D9B78A68AE5@oracle.com>
In-Reply-To: <3C1CD7DD-E915-4FDB-815A-6D9B78A68AE5@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/07/2010 05:43 PM, Chuck Lever wrote:
> On Jan 7, 2010, at 3:25 PM, Steve Dickson wrote:
> If you think v2-only servers are so rare, why even bother downshifting
> the protocol version at all?  
I did think of this... since a point of this exercise is to begin
the end of v2 support... but since we have a habit of being backwards 
compatible (as well as being portable), I figure downshifting was the 
right thing to do...  

 
> The original showmount command does not
> have any problem connecting to a v2-only server, since it used only
> MNTv1 to do the EXPORT request.
True... The problem is showmount does not handle v3 only servers
which is another point of this discussion... 

> 
> Most legacy servers are NFSv2 only.  I bought a new-in-box ReadyNAS a
> year or so ago that ran Linux 2.4, and it's NFS server was, in fact,
> v2-only.
Really.. that is surprising... how well did it perform and could it 
negotiate up to v3?? 

steved.
