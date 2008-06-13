From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 08/37] SUNRPC: Use GFP_NOFS when allocating credentials
Date: Fri, 13 Jun 2008 18:07:48 -0400
Message-ID: <1213394868.19011.93.camel@localhost>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
	 <20080612192200.24528.65570.stgit@localhost.localdomain>
	 <20080613211743.GP8501@fieldses.org> <1213392377.19011.80.camel@localhost>
	 <20080613213147.GQ8501@fieldses.org> <1213392894.19011.82.camel@localhost>
	 <20080613215803.GB14338@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64902 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192AbYFMWHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 18:07:52 -0400
In-Reply-To: <20080613215803.GB14338@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-06-13 at 17:58 -0400, J. Bruce Fields wrote:
> On Fri, Jun 13, 2008 at 05:34:54PM -0400, Trond Myklebust wrote:
> > On Fri, 2008-06-13 at 17:31 -0400, J. Bruce Fields wrote:
> > > No, that may be a problem too, but I mean: if we're worried about a
> > > deadlock due to some allocations that gssd performs on the downcall at
> > > the end of the context initiation, then shouldn't we also be worried
> > > about all the other allocations that gssd performs itself?
> > 
> > Definitely.
> 
> Do you have any ideas (however speculative) about how we'll deal with
> that?

Not really: AFAIK there are no mechanisms for fully pre-provisioning the
necessary resources that a userland app may need to ensure it can
function. mlock() won't, for instance, allow you to pre-provision the
socket buffer space that the kerberos stuff needs to communicate...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
