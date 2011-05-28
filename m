Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17310 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087Ab1E1QBY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 May 2011 12:01:24 -0400
Subject: Re: [PATCH v2] rpc.mountd: let mountd consult /etc/services for port
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110528132953.GA8525@merit.edu>
Date: Sat, 28 May 2011 12:01:06 -0400
Cc: Mi Jinlong <mijinlong@cn.fujitsu.com>, Steve Dickson <SteveD@redhat.com>,
        NFS <linux-nfs@vger.kernel.org>
Message-Id: <D3F4AA10-8A35-4600-815B-D63CB7EF7315@oracle.com>
References: <4DAD48C7.9090808@cn.fujitsu.com> <4DE0C380.7040608@cn.fujitsu.com> <20110528132953.GA8525@merit.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Jim-

On May 28, 2011, at 9:29 AM, Jim Rees wrote:

> Mi Jinlong wrote:
> 
>  At RHEL, if user set port for mountd at /etc/services as 
>  "mount   12345/tcp", mountd should be bind to 12345, but the 
>  latest nfs-utils, mountd get a rand port, not 12345.
> 
>  This patch make sure mountd be bind to the port which was set
>  at /etc/service.
> 
> Is this really such a good idea?  I would find this behavior surprising.

I also find this behavior surprising.  However, this patch fixes a regression.  If you build mountd today with the legacy RPC library, it already consults /etc/services, and has done for a long while.  Mi is simply restoring this traditional behavior for newer TI-RPC builds.

> I expect listeners to either use a well-known port, in which case they look in
> /etc/services and fall back to a compiled-in constant (like telnet or ftp),
> or use an ephemeral port, in which case they don't even look at
> /etc/services.  This patch would change mountd so that its behavior
> (well-known versus ephemeral) depends on /etc/services rather than a
> run-time option.

As I read it: If -p is specified, mountd uses that value for the listener port.  Otherwise, if -p is not specified, mountd looks in /etc/services, and uses the port listed there.  If there is no "mountd" service listed in /etc/services, it uses an ephemeral port.

For any ONCRPC service other than NFS and rpcbind, there is typically no built-in fixed port.  In that sense, the rpc. daemons are not like telnet or ftp.  Ephemeral ports are used and registered with rpcbind, so well-known ports are not needed.

> The change in behavior would not be immediately obvious, either, because who
> is going to notice that mountd is now on a well-known port?

A problem certainly arises going the other way: if the port value was fixed in order to transit a firewall, and the port becomes ephemeral, then the problem becomes obvious.  This is exactly how mountd is broken today since, when built with TI-RPC, it no longer consults /etc/services and instead it uses an ephemeral port.  Admittedly, this is rare.

> You could argue that the admin would have to add a line to /etc/services for
> anything to change, and I guess I could be convinced.  But are you sure some
> distro packaging person isn't going to put that line in without
> understanding the implications?

/etc/services does not by default contain an entry for mountd (or statd, which is also affected by this change).  Without those entries, the daemons behave exactly as you expect.  This is probably why we never noticed mountd looked in /etc/services.  That, and this behavior isn't documented anywhere.

Since there is no IANA-listed port number assignment for the legacy mountd or statd services, I doubt /etc/services will be changed by a distro as you suggest.  However, distros will change the file to add new well-known ports for other services.  Installing a new copy will erase any local changes.  This is a good reason to prefer -p instead.

> Yes, I know putting mountd on a random port isn't going to thwart a
> determined hacker.  I'm thinking of the nuisance factor.  Consider ssh.
> It's a secure protocol, so there isn't really a security risk with leaving
> it on port 22, but sometimes you have to move it off to keep the log files
> from filling up with crap.
> 
> Here's an alternate proposal.  Have the "-p" option take either a number or
> a name.  If it's a name, look it up in /etc/services.

-p should be able to take a name anyway.  It would be a simple change.

I personally think -p is sufficient for setting the listener port as needed, and no-one has identified any hard requirement (like ancient HA clustering scripts that everyone uses and no-one wants to change) for having mountd read /etc/services.

I believe /etc/services is a well-known port registry, a local copy of IANA's registry.  Because mountd is an RPC service, fixing mountd's port is a local setting, and is not based on any standard.  Thus /etc/services is not an appropriate mechanism for setting mountd's listener port value.

So, we could also address this by getting rid of the legacy RPC behavior instead.  However, in cases like this, I typically choose to stick with legacy behavior, since that improves backwards compatibility.  It already works like this for legacy RPC builds, so in some sense we are stuck with it.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



