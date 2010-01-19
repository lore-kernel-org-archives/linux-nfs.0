From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] mount.nfs: prefer IPv4 addresses over IPv6 (try #2)
Date: Tue, 19 Jan 2010 15:51:44 -0500
Message-ID: <1263934304.4920.4.camel@localhost>
References: <1263907662-19107-1-git-send-email-jlayton@redhat.com>
	 <1667647A-2BB1-478D-8881-CE8EA2191F97@oracle.com>
	 <20100119153826.67dd97a5@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	steved@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:42316 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497Ab0ASUvx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jan 2010 15:51:53 -0500
In-Reply-To: <20100119153826.67dd97a5-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-01-19 at 15:38 -0500, Jeff Layton wrote: 
> On Tue, 19 Jan 2010 10:43:34 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
> > I think that doesn't describe this workaround adequately.  This is a  
> > temporary crutch that prevents us from using IPv6 if "proto=" isn't  
> > specified.  The underlying problem here is that nfs_lookup() returns  
> > just one address.
> > 
> 
> Yes. The best solution would be to somehow try all addresses in the
> list until one works. That's a larger project however and we'll
> probably need some significant kernel changes to handle that anyway.

Why would that involve kernel changes? I'm assuming that we can just
retry the mount call if we see that the server isn't listening on a
particular ip address+port combination.

Cheers
  Trond

