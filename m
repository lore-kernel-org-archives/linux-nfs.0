Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752630Ab2HUNHQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 09:07:16 -0400
Date: Tue, 21 Aug 2012 09:07:06 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS4ERR_DELAY
Message-ID: <20120821090706.3833fdf6@corrin.poochiereds.net>
In-Reply-To: <k100a0$sm1$1@ultimate100.geggus.net>
References: <k0vgkt$mm0$1@ultimate100.geggus.net>
	<k0vjq7$o7l$1@ultimate100.geggus.net>
	<20120821064100.701ec6e9@corrin.poochiereds.net>
	<k100a0$sm1$1@ultimate100.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 21 Aug 2012 12:52:16 +0000 (UTC)
Sven Geggus <lists@fuchsschwanzdomain.de> wrote:

> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > It's often the case that this indicates a problem communicating over
> > the callback channel. For instance, the server is trying to recall a
> > delegation but the client isn't responding, so the server has to wait
> > until the recall attempt times out before proceeding.
> 
> Hm I'm not shure if I understand this correctly.
> 
> I am talking about exactly 3 machines (and one single user for now) here:
> clientA, clientB and the NFS-server.
> 
> "user" is logged in on clientA any now opens a shell to ssh to clientB.
> 

Right, so you probably opened ~/Xauthority on clientA and got a
delegation. Then you ssh'ed to clientB and opened the file there. At
that point, the server has to recall the delegation. Usually that's
pretty quick, but if the server can't talk to clientA on the callback
port then it has to wait and eventually time out before it can allow
the open on clientB to proceed.

> The NFS-server is providing the home for the user on both machines.
> 
> The ssh is now getting delayed for up to 1 minute because the NFS server
> does not allow for the .Xauthority file to be deleted immediately.
> 
> It is probably worth to mention, that I'm currently experimenting with
> btrfs on the server. Is there a chance that this bug will disapper when I
> change the underlaying filesystem of the server to ext4?
> 
> Sven
> 

You asked for hints on how to debug it, and I gave one. The server will
often return NFS4ERR_DELAY when it's waiting for a delegation recall to
complete. I'd make sure that that's all working as expected.

-- 
Jeff Layton <jlayton@redhat.com>
