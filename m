From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 000/112] What's in the NFS queue for linux-2.6.25
Date: Fri, 25 Jan 2008 13:26:01 -0500
Message-ID: <1201285561.24283.109.camel@heimdal.trondhjem.org>
References: <1201280354.24283.70.camel@heimdal.trondhjem.org>
	 <20080125173537.GA22782@uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17837 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753700AbYAYS0Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 13:26:16 -0500
In-Reply-To: <20080125173537.GA22782-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-01-25 at 18:35 +0100, Steinar H. Gunderson wrote:
> On Fri, Jan 25, 2008 at 11:59:13AM -0500, Trond Myklebust wrote:
> >       * More IPv6 cleanups from Chuck. NFSv4 support for IPv6 should now
> >         almost be complete (IPv6 callback support is still not ready).
> 
> Does this mean we can start beta testing these features out in the
> distributions now? Is nfs-utils (in particular nfsd/mountd) ready?

No. I'm talking about the kernel client support only. Server support is
a different matter...

I believe Chuck still has to make a change to the nfs-utils 'mount' in
order to make it capable of resolving IPv6 DNS lookups.

Trond
