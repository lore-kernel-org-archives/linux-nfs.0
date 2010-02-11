From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/2] NFS: Don't generate a GETATTR when opening an
 O_DIRECT file
Date: Thu, 11 Feb 2010 14:14:12 -0500
Message-ID: <1265915652.478.22.camel@localhost>
References: <20100211185757.2666.90001.stgit@localhost.localdomain>
	 <20100211190918.2666.82008.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60051 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756795Ab0BKTOO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Feb 2010 14:14:14 -0500
In-Reply-To: <20100211190918.2666.82008.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-02-11 at 14:09 -0500, Chuck Lever wrote: 
> Close-to-open isn't needed for O_DIRECT files, since their data is
> never cached.  So if their attribute cache hasn't expired, skip the
> GETATTR.

Don't we still want to ensure that the access cache is still valid?

Cheers
  Trond
