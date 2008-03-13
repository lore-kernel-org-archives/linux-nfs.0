From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/6] SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
Date: Thu, 13 Mar 2008 16:45:28 -0400
Message-ID: <20080313204528.GB9283@fieldses.org>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080313174807.13840.38440.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <47D97C5A.6020100@citi.umich.edu> <1205435968.13453.27.camel@heimdal.trondhjem.org> <1205436339.13453.35.camel@heimdal.trondhjem.org> <20080313194330.GK29517@fieldses.org> <1205440566.15354.21.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44094 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477AbYCMUpb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 16:45:31 -0400
In-Reply-To: <1205440566.15354.21.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 13, 2008 at 04:36:06PM -0400, Trond Myklebust wrote:
> 
> On Thu, 2008-03-13 at 15:43 -0400, J. Bruce Fields wrote:
> > On Thu, Mar 13, 2008 at 03:25:38PM -0400, Trond Myklebust wrote:
> > > 
> > > On Thu, 2008-03-13 at 15:19 -0400, Trond Myklebust wrote:
> > > > On Thu, 2008-03-13 at 15:11 -0400, Olga Kornievskaia wrote:
> > > > > Trond,
> > > > > 
> > > > >     We were thinking of using RPCAUTH_LOOKUP_ROOTCREDS flag to acquire 
> > > > > machine creds for authenticated callback.
> > > > 
> > > > I'd strongly suggest using a different flag for that purpose. The
> > > > function of RPCAUTH_LOOKUP_ROOTCREDS _today_ is to allow a future
> > > > swap-over-nfs to use root credentials when paging out memory.
> > > > 
> > > > That is not the same as machine creds...
> > > 
> > > 
> > > In fact, I'd strongly urge you to add the information for machine creds
> > > to the 'struct auth_cred' instead. The latter is the lookup key for
> > > 'rpc_authops->lookup_cred()'.
> > 
> > So something like 
> > 
> > diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
> > index 7a69ca3..d624169 100644
> > --- a/include/linux/sunrpc/auth.h
> > +++ b/include/linux/sunrpc/auth.h
> > @@ -26,6 +26,7 @@ struct auth_cred {
> >  	uid_t	uid;
> >  	gid_t	gid;
> >  	struct group_info *group_info;
> > +	int	is_machine_cred;
> >  };
> 
> Yes. Unless we need more information. Will we ever be in a situation
> where we want to specify a full 

A full principal name, or something?  No, I can't think of a reason for
now.

> > ?  No objection, but it seems like mild overkill for a single bit when
> > the necessary functions already take a flag parameter.
> 
> The flag parameter should be for internal use by the RPC auth code to
> pass around lookup intent information (see gss_match(), which is the
> only remaining callback that actually uses that parameter).
> 
> The lookup key, OTOH, should be a single structure.
> 
> >   Or do you want
> > this information in that structure for future uses of the auth_cred as a
> > key into a more general cred cache?
> 
> See the rest of the patch series...

Whoops, OK, will do.

> Basically, if the administrator changes our security landscape on the
> fly, either by migrating our filesystem, or by changing the supported
> security flavours, then we're going to have to renegotiate security on
> the fly. We really do _not_ want the NFS structures to cache RPC
> credentials which are tied to a particular auth mechanism or rpcsec_gss
> session.
> The "generic" credential I'm proposing is the tool for carrying all the
> information that is needed in order to lookup/create an on-the-wire
> credential at the instant when we issue the RPC call.

Got it; putting the information that we want a host credential into the
auth_cred sounds right. Thanks!

--b.
