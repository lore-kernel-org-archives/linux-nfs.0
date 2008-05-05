From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Ensure that 'noac' and/or 'actimeo=0' turn off
	attribute caching
Date: Mon, 05 May 2008 11:59:43 -0400
Message-ID: <1210003183.7409.5.camel@localhost>
References: <20080502202502.29449.81285.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <6A5A94A9-6F7A-469C-926D-A39B18381FFE@oracle.com>
	 <1210001033.7409.1.camel@localhost>
	 <95989F05-2BCE-4923-94C6-46D46270D120@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53988 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754576AbYEEP7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 11:59:47 -0400
In-Reply-To: <95989F05-2BCE-4923-94C6-46D46270D120@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-05-05 at 11:55 -0400, Chuck Lever wrote:
> nfs_update_inode() is the only other place that actually uses the  
> value of nfsi->attrtimeo (and it uses it with time_in_range).  I'm  
> merely asking if we have verified that the behavior is correct if
> nfsi- 
>  >attrtimeo == 0.
> 
> The logic there is abstruse, so it's difficult to tell if the (nfsi- 
>  >attrtimeo == 0) case is behaving as expected.  I don't see any  
> obvious problem with it right now.

That part of the code is irrelevant as far as actimeo=0/noac is
concerned. It is the mechanism that decides whether or not to double the
existing value of nfsi->attrtimeo for the case where the file/directory
hasn't changed in a while.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
