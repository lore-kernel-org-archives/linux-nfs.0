Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:35227 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932346Ab0IGR4M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 13:56:12 -0400
Subject: Re: RFC:  support srcaddr= option to bind to local IPs.
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Ben Greear <greearb@candelatech.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4C81449B.4010900@candelatech.com>
References: <4C81449B.4010900@candelatech.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Sep 2010 13:56:06 -0400
Message-ID: <1283882166.2788.48.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-09-03 at 11:55 -0700, Ben Greear wrote:
> This patch lets one bind the local side of NFS sockets to a particular
> IP address.  This can be useful for users on multi-homed systems.
> 
> This patch must be on top of the previous patch to fix the IPv6 address
> comparison or it will not work.
> 
> Comments and suggestions welcome...I'll incorporate those and post an
> official signed-off patch after that.
> 
> Thanks,
> Ben
> 

The code in nfs_callback_authenticate is going to break NFSv4 callbacks.
Callbacks are sent to the -oclientaddr address, not srcaddr (btw, I
really dislike that new boolean argument to nfs_find_client(). If you
don't want to compare the source address, then have the caller pass a
NULL pointer).

As has been pointed out to you before, all this is very intrusive, and
you have yet to give a description of why it is useful, and better than
using private socket namespaces (which is what container virtualised
systems will be wanting). The latter can even ensure that it all works
for userspace applications (such as rpc.statd) too.

IOW: I'd be quite happy to take patches to support private namespaces
properly: afaics, we do need to make nfs_find_client aware of them, and
ditto for lockd and the NFSv4 callback channel.
I remain less than convinced that we need to be able to specify
per-mountpoint source addresses...

Trond

