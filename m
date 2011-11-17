Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:44326 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756189Ab1KQLGd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2011 06:06:33 -0500
Message-ID: <4EC4EA91.5070607@Calva.COM>
Date: Thu, 17 Nov 2011 12:05:53 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Jim Rees <rees@umich.edu>, Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
References: <4EC3FD8B.6000705@calvaedi.com>	<20111116144718.78b2e288@corrin.poochiereds.net>	<20111116234434.GA12882@umich.edu>	<20111116203119.1d9c0dd6@corrin.poochiereds.net> <20111116203810.4e1b9d28@corrin.poochiereds.net>
In-Reply-To: <20111116203810.4e1b9d28@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17/11/11 02:38, Jeff Layton wrote:
> Note too that the gssd code distinguishes between an expired TGT and a
> non-existent credcache. The latter will give you the error you desire
> here. So one possibility is just to remove the credcache from /tmp in
> this situation.

Something to scan /tmp for expired credentials and zap em?  rpc.gssd 
would communicate that to the kernel?

Whadaya know, that works.

With the 3.1-rc10 kernel I let my ticket expire, did a ls - it hangs.

Now, from another terminal I do a kdestroy on my ticket cache, and (a 
second or so later) the ls gets an EPERM.

So this behaviour can be changed from userland with no changes to the 
kernel, rpc.gssd or anything else.

Some fun racing possibilities.
