Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13033 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751610Ab0I3R5i convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 13:57:38 -0400
Subject: Re: [PATCH] nfs-utils: Add nfs.upcall for idmapper
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        SteveD@redhat.com
In-Reply-To: <05795369-58D0-414E-80C1-D7212DA7CFE8@oracle.com>
References: <4CA39681.3000104@netapp.com>
	 <1285798396.3557.18.camel@heimdal.trondhjem.org>
	 <4CA48CEF.9060600@netapp.com>
	 <59CA8CDE-0A68-4F99-BB09-804D24452148@oracle.com>
	 <1285866437.14635.27.camel@heimdal.trondhjem.org>
	 <05795369-58D0-414E-80C1-D7212DA7CFE8@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 30 Sep 2010 13:57:36 -0400
Message-ID: <1285869456.14635.59.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-09-30 at 13:30 -0400, Chuck Lever wrote:

> My only concern here is that the new design does not preclude the easy ability to get the TXT record and cache its value locally for a reasonable period of time.  Replacing a long-running daemon with a multiple invocation program may change the picture a little, if I understand the new design correctly.

I don't think that is true. Look at the ease with which David adapted
the cifs dns resolver to get the AFSDB resource record.

In fact, if we wanted to get a specific TXT record for the kernel, we
can do that today using the existing dns_query() mechanism, and then
writing a userspace handler. I therefore don't see the need to add that
functionality to the idmapper.

> In the end, we could rely on local caching of DNS results (by, say, nscd) and let libnfsidmap do the DNS search whenever it wants.
> 
> >> Finally, if at all possible, it would be better if the kernel could automatically recognize and use nfs.upcall rather than the legacy idmapping mechanism.  My experience with CONFIG options is that people will almost always choose the wrong setting no matter how many large neon arrows you add.  I know there are likely some technical challenges here.
> > 
> > I don't think that is easy to do. The keyring upcall mechanism will
> > almost always succeed, no matter whether or not there is a handler for
> > the type of key requested. Instead, it will result in a negative lookup.
> > Unfortunately, seeing a negative key isn't sufficient to determine that
> > no handler exists.
> 
> Yes, I acknowledge it may be difficult.  And perhaps using the keyring mechanism as it stands today to detect which mechanism to use might not be trivial.  Maybe the keyring mechanism is deficient in this regard and could be fixed?
> 
> However, the general principal still holds (based on experience we both have! :-) that having an automated mechanism is better than a build-time CONFIG option.  If we consider this for a bit and decide it's too hard, then so be it.

It is hard, because there is more than 1 question that needs to be
answered:

  - Does the user have a recent copy of the key-utils package installed?
  - Does the user have the latest nfs-utils package installed?
  - Does the user have /etc/request-key.conf configured correctly?

The keyring upcall mechanism only really answers the first question.

IOW: This is hard to do in the kernel. OTOH, it is really trivial to do
in the kernel package and nfs-utils package dependency lists...

Cheers
  Trond
