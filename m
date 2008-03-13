From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/6] SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
Date: Thu, 13 Mar 2008 15:25:38 -0400
Message-ID: <1205436339.13453.35.camel@heimdal.trondhjem.org>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080313174807.13840.38440.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <47D97C5A.6020100@citi.umich.edu>
	 <1205435968.13453.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13053 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbYCMTZp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 15:25:45 -0400
In-Reply-To: <1205435968.13453.27.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-03-13 at 15:19 -0400, Trond Myklebust wrote:
> On Thu, 2008-03-13 at 15:11 -0400, Olga Kornievskaia wrote:
> > Trond,
> > 
> >     We were thinking of using RPCAUTH_LOOKUP_ROOTCREDS flag to acquire 
> > machine creds for authenticated callback.
> 
> I'd strongly suggest using a different flag for that purpose. The
> function of RPCAUTH_LOOKUP_ROOTCREDS _today_ is to allow a future
> swap-over-nfs to use root credentials when paging out memory.
> 
> That is not the same as machine creds...


In fact, I'd strongly urge you to add the information for machine creds
to the 'struct auth_cred' instead. The latter is the lookup key for
'rpc_authops->lookup_cred()'.

Cheers
  Trond

-- 
Trond Myklebust
NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
