From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not
 specified by user
Date: Tue, 01 Sep 2009 14:28:57 -0400
Message-ID: <1251829737.18608.34.camel@heimdal.trondhjem.org>
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
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:35489 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbZIAS3A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 14:29:00 -0400
In-Reply-To: <1251829540.18608.31.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-01 at 14:25 -0400, Trond Myklebust wrote:
> On Tue, 2009-09-01 at 14:07 -0400, Chuck Lever wrote:
> > On Sep 1, 2009, at 12:38 PM, J. Bruce Fields wrote:
> > 
> > > On Tue, Sep 01, 2009 at 12:29:30PM -0400, Chuck Lever wrote:
> > >> On Sep 1, 2009, at 12:09 PM, J. Bruce Fields wrote:
> > >>> And, sure, that'd be OK with me, and would probably be better than
> > >>> adding another exception, so I'm OK with skipping #3.  (We  
> > >>> definitely
> > >>> shouldn't omit #2, though.)
> > >>
> > >> Seems straightforward enough, but...  Why are we doing this again?   
> > >> It
> > >> still seems like non-standard behavior.  Are we simply attempting to
> > >> avoid the case where folks would get the "nobody" behavior  
> > >> unexpectedly
> > >> because of a mountd bug, or is there more to it?
> > >
> > > That's all there is to it.  As I said:
> > >
> > >>>>>>> 	2. In the absence of sec=, we should probably *not* choose
> > >>>>>>> 	AUTH_NULL.  (All mountd's before 1.1.3 list AUTH_NULL first on
> > >>>>>>> 	the returned list, so users with older servers may wonder why a
> > >>>>>>> 	client upgrade is making files they create suddenly be owned by
> > >>>>>>> 	nobody.) http://marc.info/?l=linux-nfs&m=125089022306281&w=2
> > >
> > >> I'm just thinking of what the documenting comment might say, and  
> > >> perhaps
> > >> some explanation added to nfs(5).
> > >
> > > "As a special case, to work around bugs in some older servers, the
> > > client will never automatically negotiate auth_null; if auth_null is
> > > desired, an explicit "sec=null" on the commandline is required."
> > >
> > > Or something like that.
> > 
> > OK, one more corner case.
> > 
> > What if the mount doesn't specify "sec=" and the only flavor in the  
> > server's auth list is AUTH_NULL?  Seems like we should allow that one.
> 
> Amend the above statement to "the only flavour in the server's auth list
> that is supported by the client", and I'll agree.
> 
> If a server advertises auth_dh, auth_krb4 and auth_null, then we should
> definitely try auth_null rather than failing.

We should also try it if the server is broken, and returns an empty
list, but only after first attempting to cycle through all the other
flavours that are supported by the client.

Trond

