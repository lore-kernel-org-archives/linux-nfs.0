Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbaKIUuZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2014 15:50:25 -0500
Date: Sun, 9 Nov 2014 15:50:06 -0500
From: Simo Sorce <simo@redhat.com>
To: Chris Siebenmann <cks@cs.toronto.edu>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Best approach for authenticating hosts for NFS (v3)?
Message-ID: <20141109155006.5f00da7e@willson.usersys.redhat.com>
In-Reply-To: <20141105164555.3958A400746@apps1.cs.toronto.edu>
References: <545A510C.4000208@RedHat.com>
	<20141105164555.3958A400746@apps1.cs.toronto.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 05 Nov 2014 11:45:55 -0500
Chris Siebenmann <cks@cs.toronto.edu> wrote:

> > On 11/04/2014 11:53 AM, Chris Siebenmann wrote:
> > > PS: 'switch to NFS v4 to strongly authenticate user requests' is
> > > not an option for us. We specifically value things that cannot be
> > > done with true verification of user identification, like cron,
> > > and we don't have and don't want to build the infrastructure that
> > > would be required for strongly authenticated NFS v4.
> > The exact same "strongly authenticate" that in v4 is available
> > with v3. NFS secure mounts (-o krb5) are available 
> > with all NFS protocol versions.
> > 
> > Tying NFS secure mounts with an FreeIPA environment should work
> > out well..    
> 
>  NFS v4 isn't the problem; strong authentication of user identities
> (and Kerberos) is the problem. Our environment and our users rely on
> the many forms that setuid takes[*] and as far as I know those are
> impossible with strong identification (in any NFS or remote
> filesystem protocol) because the point of strong authentication is
> that the server no longer trusts clients when they say 'honest, I'm
> working on behalf of uid <X>'.

On a Linux server you can use gss-proxy and give it authority to
impersonate any user through the s4u2proxy protocol.
It will require a KDC that can manage s4u2proxy (AD or FreeIPA).

> (Instead the client must prove it by presenting a secret only the user
> is supposed to have access to, which the user must have somehow loaded
> on the client.)
> 
> 	- cks
> [*: including but not limited to crontabs, .forward files, user run
> web apps and CGI-BINs, and detached processes left running for weeks.
> ]
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Simo Sorce * Red Hat, Inc * New York
