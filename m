Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55971 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700Ab2AQQe0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 11:34:26 -0500
Date: Tue, 17 Jan 2012 11:34:26 -0500
To: Jim Rees <rees@umich.edu>
Cc: Sachin Prabhu <sprabhu@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: svcgssd: Allow administrators to specify timeout for the
 cached context
Message-ID: <20120117163426.GB13977@fieldses.org>
References: <1326800668.2747.55.camel@sprabhu.fab.redhat.com>
 <20120117134951.GA15479@umich.edu>
 <1326814728.2747.59.camel@sprabhu.fab.redhat.com>
 <20120117163133.GB3387@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120117163133.GB3387@umich.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 17, 2012 at 11:31:33AM -0500, Jim Rees wrote:
> Sachin Prabhu wrote:
> 
>   On Tue, 2012-01-17 at 08:49 -0500, Jim Rees wrote:
>   > Sachin Prabhu wrote:
>   > 
>   >   We had a user report that for an export shared with sec=krb5*, any
>   >   changes in user credentials(ex: add user to a secondary group) take some
>   >   time before they take effect over the NFS share.
>   > 
>   > Re-authenticating, either by removing the service ticket or by re-running
>   > kinit at the client, should also flush the old credentials.  Can you confirm
>   > that works?
>   
>   We have tried it but it doesn't work unless you actually clean up the
>   cache on the NFS server with the command 
>   echo `date +'%s'` > /proc/net/rpc/auth.rpcsec.context/flush
> 
> Bruce, shouldn't this work?  Is this a bug or a feature?

kdestroy, kinit, etc. on the client only affect userspace; the NFS
client in the kernel continues to use the same gss context.

You're right, if those commands did remove the gss context, then the
client would have to go get a new one, and that would trigger an svcgssd
on the server side that should get the up-to-date information.

--b.
