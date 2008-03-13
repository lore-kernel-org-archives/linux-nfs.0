From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/6] SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
Date: Thu, 13 Mar 2008 15:43:30 -0400
Message-ID: <20080313194330.GK29517@fieldses.org>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080313174807.13840.38440.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <47D97C5A.6020100@citi.umich.edu> <1205435968.13453.27.camel@heimdal.trondhjem.org> <1205436339.13453.35.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56417 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267AbYCMTnd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 15:43:33 -0400
In-Reply-To: <1205436339.13453.35.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 13, 2008 at 03:25:38PM -0400, Trond Myklebust wrote:
> 
> On Thu, 2008-03-13 at 15:19 -0400, Trond Myklebust wrote:
> > On Thu, 2008-03-13 at 15:11 -0400, Olga Kornievskaia wrote:
> > > Trond,
> > > 
> > >     We were thinking of using RPCAUTH_LOOKUP_ROOTCREDS flag to acquire 
> > > machine creds for authenticated callback.
> > 
> > I'd strongly suggest using a different flag for that purpose. The
> > function of RPCAUTH_LOOKUP_ROOTCREDS _today_ is to allow a future
> > swap-over-nfs to use root credentials when paging out memory.
> > 
> > That is not the same as machine creds...
> 
> 
> In fact, I'd strongly urge you to add the information for machine creds
> to the 'struct auth_cred' instead. The latter is the lookup key for
> 'rpc_authops->lookup_cred()'.

So something like 

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 7a69ca3..d624169 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -26,6 +26,7 @@ struct auth_cred {
 	uid_t	uid;
 	gid_t	gid;
 	struct group_info *group_info;
+	int	is_machine_cred;
 };
 
?  No objection, but it seems like mild overkill for a single bit when
the necessary functions already take a flag parameter.  Or do you want
this information in that structure for future uses of the auth_cred as a
key into a more general cred cache?

--b.
