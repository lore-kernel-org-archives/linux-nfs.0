Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34346 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754434Ab2AQStC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 13:49:02 -0500
Date: Tue, 17 Jan 2012 13:49:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jim Rees <rees@umich.edu>
Cc: Sachin Prabhu <sprabhu@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: svcgssd: Allow administrators to specify timeout for the
 cached context
Message-ID: <20120117184901.GC15460@fieldses.org>
References: <1326800668.2747.55.camel@sprabhu.fab.redhat.com>
 <20120117134951.GA15479@umich.edu>
 <1326814728.2747.59.camel@sprabhu.fab.redhat.com>
 <20120117163133.GB3387@umich.edu>
 <20120117163426.GB13977@fieldses.org>
 <20120117172444.GA3787@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120117172444.GA3787@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 17, 2012 at 12:24:44PM -0500, Jim Rees wrote:
> J. Bruce Fields wrote:
> 
>   On Tue, Jan 17, 2012 at 11:31:33AM -0500, Jim Rees wrote:
>   > Sachin Prabhu wrote:
>   > 
>   >   On Tue, 2012-01-17 at 08:49 -0500, Jim Rees wrote:
>   >   > Sachin Prabhu wrote:
>   >   > 
>   >   >   We had a user report that for an export shared with sec=krb5*, any
>   >   >   changes in user credentials(ex: add user to a secondary group) take some
>   >   >   time before they take effect over the NFS share.
>   >   > 
>   >   > Re-authenticating, either by removing the service ticket or by re-running
>   >   > kinit at the client, should also flush the old credentials.  Can you confirm
>   >   > that works?
>   >   
>   >   We have tried it but it doesn't work unless you actually clean up the
>   >   cache on the NFS server with the command 
>   >   echo `date +'%s'` > /proc/net/rpc/auth.rpcsec.context/flush
>   > 
>   > Bruce, shouldn't this work?  Is this a bug or a feature?
>   
>   kdestroy, kinit, etc. on the client only affect userspace; the NFS
>   client in the kernel continues to use the same gss context.
> 
> I would find it surprising if kdestroy didn't actually discard my
> credentials.  In fact I might even view this as a security risk.

Volunteers to fix this are welcomed....  I think this might be part of
the project Simo Sorce is working on, but I'm not sure.

--b.
