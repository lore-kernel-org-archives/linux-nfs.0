From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/3] nfs-utils: add IPv6 support to nfsd
Date: Mon, 18 May 2009 11:48:47 -0400
Message-ID: <20090518114847.55dedb53@tlielax.poochiereds.net>
References: <1242064697-32520-1-git-send-email-jlayton@redhat.com>
	<1242064697-32520-4-git-send-email-jlayton@redhat.com>
	<00A26259-D5D8-4E1C-91F4-6AB5CE194870@oracle.com>
	<4A1181EE.7080401@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50100 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270AbZERPs4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 11:48:56 -0400
In-Reply-To: <4A1181EE.7080401-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 18 May 2009 11:42:38 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> Chuck Lever wrote:
> > On May 11, 2009, at 1:58 PM, Jeff Layton wrote:
> >> Add 2 new options to rpc.nfsd -- -4 and -6. -4 makes it an IPv4-only
> >> server, and -6 makes it IPv6-only. Restructure the -H option so that
> >> if the address appears to be or resolves to an IPv4 address, that
> >> IPv6 is disabled. Ditto if it resolves to an IPv6 address.
> > 
> > For rpc.statd, I'm following Olaf's suggestion to use /etc/netconfig to
> > decide what transports to use for listeners.  Basically, rpc.statd
> > attempts to start listeners for all visible netids (marked with 'v') in
> > /etc/netconfig.  This is how Solaris works, as I understand it.  I'm
> > planning to take this course for rpc.mountd as well.
> > 
> > Maybe rpc.nfsd should follow suit?
> I would have to agree... Jeff, what do you think?

Definitely agree. Once I'm through playing whack-a-mole on some CIFS
issues, I plan to sit down and look at incorporating that. Thanks for
having a look.

-- 
Jeff Layton <jlayton@redhat.com>
