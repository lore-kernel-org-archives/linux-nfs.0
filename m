From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/6] SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
Date: Thu, 13 Mar 2008 15:39:54 -0400
Message-ID: <1205437195.13453.37.camel@heimdal.trondhjem.org>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080313174807.13840.38440.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <47D97C5A.6020100@citi.umich.edu>
	 <1205435968.13453.27.camel@heimdal.trondhjem.org>
	 <47D980CC.3020909@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48431 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754138AbYCMTky (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 15:40:54 -0400
In-Reply-To: <47D980CC.3020909@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-03-13 at 15:30 -0400, Olga Kornievskaia wrote:
> 
> Trond Myklebust wrote:
> > On Thu, 2008-03-13 at 15:11 -0400, Olga Kornievskaia wrote:
> >   
> >> Trond,
> >>
> >>     We were thinking of using RPCAUTH_LOOKUP_ROOTCREDS flag to acquire 
> >> machine creds for authenticated callback..
> >>     
> >
> > I'd strongly suggest using a different flag for that purpose. The
> > function of RPCAUTH_LOOKUP_ROOTCREDS _today_ is to allow a future
> > swap-over-nfs to use root credentials when paging out memory.
> >
> > That is not the same as machine creds...
> >   
> I apologize I forgot that I introduced a new flag instead, 
> RPCAUTH_USE_MACH_CRED. It should fit with the other flags such as 
> RPCAUTH_CRED_NEW in auth.h.

As I said, I'd rather have that flag in 'struct auth_cred' so that it
works with the "generic" cred mechanism.

Cheers
  Trond

-- 
Trond Myklebust
NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
