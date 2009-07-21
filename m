From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 13:12:19 -0400
Message-ID: <1248196339.21343.8.camel@heimdal.trondhjem.org>
References: <4A64EB1F.4000602@candelatech.com>
	 <1248178527.5222.0.camel@heimdal.trondhjem.org>
	 <4A65F184.5060802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:41660 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755448AbZGURMW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 13:12:22 -0400
In-Reply-To: <4A65F184.5060802@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-07-21 at 09:49 -0700, Ben Greear wrote:
> On 07/21/2009 05:15 AM, Trond Myklebust wrote:
> 
> >
> > What does /var/lib/nfs/v4recovery look like on the server?
> 
> The server was misconfigured, but I still think the client should
> behave better in this case.  If you cannot reproduce it, let me know
> and I can try to be more specific.  If you still want the v4recovery
> information, let me know and I'll send it.

So how should the client behave, when a screwed up server allows it to
mount but starts returning illegal values for setclientid? The only
thing I can see we could do is to tell the user EINSANESERVER...

Now, we _should_ fix the wretched NFS server so that it doesn't do NFSv4
mounts when there is no configured root partition. We _should_ also fix
the damned thing so that it doesn't return illegal values.

Trond

