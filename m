Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751915Ab2ARMOq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jan 2012 07:14:46 -0500
Subject: Re: svcgssd: Allow administrators to specify timeout for the cached
 context
From: Sachin Prabhu <sprabhu@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Date: Wed, 18 Jan 2012 12:14:38 +0000
In-Reply-To: <20120117184901.GC15460@fieldses.org>
References: <1326800668.2747.55.camel@sprabhu.fab.redhat.com>
	 <20120117134951.GA15479@umich.edu>
	 <1326814728.2747.59.camel@sprabhu.fab.redhat.com>
	 <20120117163133.GB3387@umich.edu> <20120117163426.GB13977@fieldses.org>
	 <20120117172444.GA3787@umich.edu> <20120117184901.GC15460@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1326888879.2747.66.camel@sprabhu.fab.redhat.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-01-17 at 13:49 -0500, J. Bruce Fields wrote:
> On Tue, Jan 17, 2012 at 12:24:44PM -0500, Jim Rees wrote:
> > J. Bruce Fields wrote:
> > 
> >   On Tue, Jan 17, 2012 at 11:31:33AM -0500, Jim Rees wrote:
> >   > Sachin Prabhu wrote:
> >   > 
> >   >   On Tue, 2012-01-17 at 08:49 -0500, Jim Rees wrote:
> >   >   > Sachin Prabhu wrote:
> >   >   > 
> >   >   >   We had a user report that for an export shared with sec=krb5*, any
> >   >   >   changes in user credentials(ex: add user to a secondary group) take some
> >   >   >   time before they take effect over the NFS share.
> >   >   > 
> >   >   > Re-authenticating, either by removing the service ticket or by re-running
> >   >   > kinit at the client, should also flush the old credentials.  Can you confirm
> >   >   > that works?
> >   >   
> >   >   We have tried it but it doesn't work unless you actually clean up the
> >   >   cache on the NFS server with the command 
> >   >   echo `date +'%s'` > /proc/net/rpc/auth.rpcsec.context/flush
> >   > 
> >   > Bruce, shouldn't this work?  Is this a bug or a feature?
> >   
> >   kdestroy, kinit, etc. on the client only affect userspace; the NFS
> >   client in the kernel continues to use the same gss context.
> > 
> > I would find it surprising if kdestroy didn't actually discard my
> > credentials.  In fact I might even view this as a security risk.
> 
> Volunteers to fix this are welcomed....  I think this might be part of
> the project Simo Sorce is working on, but I'm not sure.

I have tested by setting a timeout on the the client side rpc.gssd.
Using kdestroy-kinit, I was able to get a new kerberos ticket and
subsequently force the NFS server to obtain new credentials for the
user.

I do agree with Jim Rees that this is a security issue. The user can use
kdestroy to destroy credentials before logging out. However the
credentials cached in the kernel will allow the user to continue
accessing the NFS share for as long as the cache is valid.

Sachin Prabhu


