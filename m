From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH][nfs-utils] configuration: Fix a typo in configure.ac
Date: Mon, 1 Mar 2010 09:22:07 -0500
Message-ID: <20100301142207.GC17660@fieldses.org>
References: <1266709510.3507.1.camel@localhost.localdomain> <20100222182202.GB11356@fieldses.org> <4B8BB9B8.8040703@RedHat.com> <20100301132554.GA17054@fieldses.org> <4B8BC5B9.1020304@RedHat.com> <20100301135534.GA17660@fieldses.org> <4B8BCB7D.1030202@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58774 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748Ab0CAOVC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 09:21:02 -0500
In-Reply-To: <4B8BCB7D.1030202-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 01, 2010 at 09:13:17AM -0500, Steve Dickson wrote:
> 
> 
> On 03/01/2010 08:55 AM, J. Bruce Fields wrote:
> > No, that's not enough.  They may be accessing the server through other
> > clients.
> Understood... just curious, would you happen to know of any clients
> that use 4.1 as the default? Was there any at this year's Connectathon?

I don't know what their policies are.

Someone will turn it on by default at some point, and we've no way to
ensure they'll do that at the same point that the linux 4.1 server is
up to spec.

> > We need users to make a conscious decision to turn on the server-side.
> > It's not enough to do it only on the client side.
> Right. At this point people will either have to recompile nfs-utils using
> the --enable-nfsv41 flag or edit their initscript and do the echo trick... 
> So isn't having to do one of the above be construed as conscious decision?

Recompiling with the --enable-nfsv41 flag isn't a good way for a *user*
to request 4.1 support.  It really only makes sense for *distributors*.

--b.
