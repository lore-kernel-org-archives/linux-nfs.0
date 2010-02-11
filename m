From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/2] NFS: Don't generate a GETATTR when opening an
 O_DIRECT file
Date: Thu, 11 Feb 2010 14:34:01 -0500
Message-ID: <1265916841.478.31.camel@localhost>
References: <20100211185757.2666.90001.stgit@localhost.localdomain>
	 <20100211190918.2666.82008.stgit@localhost.localdomain>
	 <1265915652.478.22.camel@localhost>  <4B745872.7020807@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48022 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756735Ab0BKTeC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Feb 2010 14:34:02 -0500
In-Reply-To: <4B745872.7020807@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-02-11 at 14:20 -0500, Chuck Lever wrote: 
> On 02/11/2010 02:14 PM, Trond Myklebust wrote:
> > On Thu, 2010-02-11 at 14:09 -0500, Chuck Lever wrote:
> >> Close-to-open isn't needed for O_DIRECT files, since their data is
> >> never cached.  So if their attribute cache hasn't expired, skip the
> >> GETATTR.
> >
> > Don't we still want to ensure that the access cache is still valid?
> 
> Would it be reasonable/feasible to squelch the GETATTR but force an 
> ACCESS call from nfs_permission?

As long as the ACCESS call returns post-op attributes, then it is
reasonable to do this for NFSv3 (or for NFSv4 opendir()) in all cases.

I used to have patches for this, but was never able to show that the
resulting total number of GETATTR+ACCESS calls was much affected.

Cheers
   Trond
