Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cliff.cs.toronto.edu ([128.100.3.120]:54101 "EHLO
	cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbaKEQp4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 11:45:56 -0500
From: Chris Siebenmann <cks@cs.toronto.edu>
To: Steve Dickson <SteveD@redhat.com>
cc: Chris Siebenmann <cks@cs.toronto.edu>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Best approach for authenticating hosts for NFS (v3)?
In-reply-to: Your message of Wed, 05 Nov 2014 11:32:12 -0500.
             <545A510C.4000208@RedHat.com>
Date: Wed, 05 Nov 2014 11:45:55 -0500
Message-Id: <20141105164555.3958A400746@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On 11/04/2014 11:53 AM, Chris Siebenmann wrote:
> > PS: 'switch to NFS v4 to strongly authenticate user requests' is not an
> >     option for us. We specifically value things that cannot be done
> >     with true verification of user identification, like cron, and we
> >     don't have and don't want to build the infrastructure that would
> >     be required for strongly authenticated NFS v4.
> The exact same "strongly authenticate" that in v4 is available
> with v3. NFS secure mounts (-o krb5) are available 
> with all NFS protocol versions.
> 
> Tying NFS secure mounts with an FreeIPA environment should work
> out well..    

 NFS v4 isn't the problem; strong authentication of user identities (and
Kerberos) is the problem. Our environment and our users rely on the many
forms that setuid takes[*] and as far as I know those are impossible with
strong identification (in any NFS or remote filesystem protocol) because
the point of strong authentication is that the server no longer trusts
clients when they say 'honest, I'm working on behalf of uid <X>'.

(Instead the client must prove it by presenting a secret only the user
is supposed to have access to, which the user must have somehow loaded
on the client.)

	- cks
[*: including but not limited to crontabs, .forward files, user run web
    apps and CGI-BINs, and detached processes left running for weeks.
]
