From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/6] SUNRPC: Fix RPCAUTH_LOOKUP_ROOTCREDS
Date: Thu, 13 Mar 2008 16:42:36 -0400
Message-ID: <1205440956.15354.27.camel@heimdal.trondhjem.org>
References: <20080313174806.13840.90325.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <20080313174807.13840.38440.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <47D97C5A.6020100@citi.umich.edu>
	 <1205435968.13453.27.camel@heimdal.trondhjem.org>
	 <1205436339.13453.35.camel@heimdal.trondhjem.org>
	 <20080313194330.GK29517@fieldses.org>
	 <1205440566.15354.21.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39414 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752847AbYCMUnU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 16:43:20 -0400
In-Reply-To: <1205440566.15354.21.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-03-13 at 16:36 -0400, Trond Myklebust wrote:
> On Thu, 2008-03-13 at 15:43 -0400, J. Bruce Fields wrote:

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

Sorry, I meant to say 'a full principal'. IOW: will we ever need to
specify principals beyond the simple 'uid/keyring' and 'machine cred'
distinction.

-- 
Trond Myklebust
NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
