From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not
 specified by user
Date: Tue, 01 Sep 2009 15:31:19 -0400
Message-ID: <1251833479.18608.69.camel@heimdal.trondhjem.org>
References: <20090901143012.3978.11441.stgit@matisse.1015granger.net>
	 <20090901150545.GA22846@fieldses.org>
	 <7C5C14D9-F315-4DF8-A2F4-C7F0981AC968@oracle.com>
	 <20090901151830.GC22846@fieldses.org>
	 <18678BB3-52C6-4376-BBD1-50B8947BAAC7@oracle.com>
	 <20090901160914.GG22846@fieldses.org>
	 <73E8EAAF-9164-4F78-A9D4-1CC86A6A6255@oracle.com>
	 <20090901163846.GJ22846@fieldses.org>
	 <B9CADBA9-54B0-44AD-A8DC-FE3ED63341BC@oracle.com>
	 <1251829540.18608.31.camel@heimdal.trondhjem.org>
	 <D11105A9-4FAB-4F5C-BF02-BE489520C150@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44984 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752870AbZIATbX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 15:31:23 -0400
In-Reply-To: <D11105A9-4FAB-4F5C-BF02-BE489520C150@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-01 at 14:58 -0400, Chuck Lever wrote:
> On Sep 1, 2009, at 2:25 PM, Trond Myklebust wrote:
> > On Tue, 2009-09-01 at 14:07 -0400, Chuck Lever wrote:
> >> OK, one more corner case.
> >>
> >> What if the mount doesn't specify "sec=" and the only flavor in the
> >> server's auth list is AUTH_NULL?  Seems like we should allow that  
> >> one.
> >
> > Amend the above statement to "the only flavour in the server's auth  
> > list
> > that is supported by the client", and I'll agree.
> 
> > If a server advertises auth_dh, auth_krb4 and auth_null, then we  
> > should
> > definitely try auth_null rather than failing.
> 
> What if the list has AUTH_GSS_KRB5 and AUTH_NULL?  Should the kernel  
> try AUTH_GSS flavors if it can't tell whether gssd is running or there  
> is a valid local keytab?

Firstly, we can tell if gssd is running. There is a timeout period of 30
seconds, but after that timeout, if there are no listeners on the end of
the gssd pipe, the rpc_pipefs code will return ETIMEDOUT.

> How does the kernel construct a list of client-supported auth flavors?

Although we do have the auth_flavors[] list, we don't currently have a
list that enumerates all the supported pseudoflavours. Instead, we have
auth_flavors[], and then a separate list of all the rpcsec_gss auth
mechanisms that are currently loaded into kernel memory.
I suggest we need to unify the information in those two lists, perhaps
by having everyone register into a separate list of all pseudoflavours
that are acceptable as parameters for rpcauth_create().

> > We should also try it if the server is broken, and returns an empty
> > list, but only after first attempting to cycle through all the other
> > flavours that are supported by the client.
> 
> 
> If the server returns an empty list, we can't negotiate.  We are  
> fairly certain only old Linux servers return an empty list, in which  
> case the client can assume all we've got is AUTH_NULL and AUTH_UNIX.   

...or RPCSEC_GSS/krb5

> I think allowing the mount to proceed with AUTH_UNIX is the best  
> choice here.

As I said, this functionality is in also required in order to make NFSv4
security negotiation work.

Trond

