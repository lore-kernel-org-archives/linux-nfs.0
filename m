Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087Ab3HASq1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 14:46:27 -0400
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for
 persistent per-UID kerberos caches
From: Simo Sorce <simo@redhat.com>
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: David Howells <dhowells@redhat.com>, keyrings@linux-nfs.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, linux-nfs@vger.kernel.org,
        krbdev@mit.edu, linux-kernel@vger.kernel.org
In-Reply-To: <51FAA0CC.7010106@fifthhorseman.net>
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	 <20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
	 <51FAA0CC.7010106@fifthhorseman.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Aug 2013 14:29:58 -0400
Message-ID: <1375381798.15733.207.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-08-01 at 13:54 -0400, Daniel Kahn Gillmor wrote:
> On 08/01/2013 01:39 PM, David Howells wrote:
> > The uid is -1 or the user's own UID for the user's own cache or the uid of some
> > other user's cache (requires CAP_SETUID).  This permits rpc.gssd or whatever to
> > mess with the cache.
> 
> Is the goal here eventually to be able to avoid the upcall to rpc.gssd
> entirely?

No, the kernel does not have a GSSAPI implementation anyway, and you do
not want one in kernel.

>   It seems a little bit roundabout to have the kernel call up
> into userspace for the credentials, only to talk to a process which then
> calls back into the kernel for something that the kernel has already
> well-defined internally.

It's called 'abstraction' :-)
The fact that nfs client is in kernel and that the keys api is in kernel
is basically just a coincidence.

> It seems like a non-privileged user could use this to store arbitrary
> data in this keyring as a way of hiding what would otherwise be
> filesystem activity or using it for some sort of odd/sneaky IPC
> mechanism.  Is this an intentional side effect?

Just as a user can add data into a shm segment ?
Is there any difference ?

> Sorry if these are obvious questions.  feel free to point me to
> already-documented answers if they exist.

There isn't much documentation, but it is certainly good to sort out any
questions so we can add answer to any documentation we will come up
with.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

