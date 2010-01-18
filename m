Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3996 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660Ab0ARWdm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jan 2010 17:33:42 -0500
Date: Mon, 18 Jan 2010 17:33:36 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: enabling IPv6
Message-ID: <20100118173336.18a8323b@tlielax.poochiereds.net>
In-Reply-To: <0FE403CA-9487-485C-9949-FEC072EC2314@oracle.com>
References: <20100118144746.1e05865e@tlielax.poochiereds.net>
	<0FE403CA-9487-485C-9949-FEC072EC2314@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 18 Jan 2010 16:28:39 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jan 18, 2010, at 2:47 PM, Jeff Layton wrote:
> 
> > With the commit of the statd patches over the weekend, we're now
> > positioned to be able to ship IPv6-enabled nfs-utils in distros. There
> > is a potential snag though...
> >
> > Consider this situation:
> >
> > Admin has a Linux server set up. Server has both IPv4 and IPv6 addrs.
> > Both addresses are in DNS.
> >
> > Without an IPv6-enabled nfs-utils, he mounts via IPv4 and all works
> > fine. Now with an IPv6 enabled nfs-utils, mount.nfs prefers the IPv6
> > addr and the mount fails (or hangs for a long time and then fails, if
> > it's using NFSv4)...
> 
> Why should it fail?
> 

Because Linux NFS servers that work over IPv6 pretty much don't exist
yet.

> > While I don't really like it, I think we may need to consider making
> > mount.nfs prefer IPv4 addrs when it can resolve a hostname to both v4
> > and v6. Otherwise, we run the risk of breaking an awful lot of working
> > setups...
> 
> Isn't that what "proto=udp" vs. "proto=udp6" is for?
> 

Yes. But that assumes that the admin will know to use that. As it
stands now, they'll have to do a bit of investigation to figure out why
the mount failed and then figure out how to fix it.

Obviously, that's less ideal than a solution that leaves setups working
that are working today. I don't think we ought to put the onus on users
to add extra mount options to stay working.

-- 
Jeff Layton <jlayton@redhat.com>
