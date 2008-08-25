From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] mount problems with Acopia and OpenVZ
Date: Mon, 25 Aug 2008 18:44:46 -0400
Message-ID: <1219704286.7665.72.camel@localhost>
References: <57bc13580808251454l168e68f1g43f6ad137eb68b35@mail.gmail.com>
	 <1219703180.7665.67.camel@localhost>
	 <20080825182903.2d86036b@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Bradner <greg.bradner@gmail.com>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:46767 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757366AbYHYWov (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2008 18:44:51 -0400
In-Reply-To: <20080825182903.2d86036b-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-08-25 at 18:29 -0400, Jeff Layton wrote:

> RHEL5 is based on 2.6.18 actually, it may have been that this issue
> was pulled in before the 5.0 release though...

No. The NFS client code (more specifically the mount code) is based on
stuff which was merged into 2.6.19 as part of the initial support for
cachefs.

> > Basically the problem is that if you have the same NFS partition mounted
> > somewhere else, then the NFS client will reuse those mount options.
> > I can't remember for certain if the fix has been backported to
> > RHEL-5.2/CentOS-5.2, but it is worth trying.
> > 
> 
> To my knowledge, this is fixed in 5.2.

Thanks!
  Trond

