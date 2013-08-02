Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754681Ab3HBRMt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 13:12:49 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <51FAA0CC.7010106@fifthhorseman.net>
References: <51FAA0CC.7010106@fifthhorseman.net> <20130801173846.28023.19009.stgit@warthog.procyon.org.uk> <20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: dhowells@redhat.com, keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        krbdev@mit.edu, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
        linux-kernel@vger.kernel.org, simo@redhat.com,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for persistent per-UID kerberos caches
Date: Fri, 02 Aug 2013 18:12:40 +0100
Message-ID: <7370.1375463560@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Daniel Kahn Gillmor <dkg@fifthhorseman.net> wrote:

> > The uid is -1 or the user's own UID for the user's own cache or the uid of
> > some other user's cache (requires CAP_SETUID).  This permits rpc.gssd or
> > whatever to mess with the cache.
> 
> Is the goal here eventually to be able to avoid the upcall to rpc.gssd
> entirely?  It seems a little bit roundabout to have the kernel call up
> into userspace for the credentials, only to talk to a process which then
> calls back into the kernel for something that the kernel has already
> well-defined internally.

I would like to see use of request_key() eventually so that the kernel can
fish a key directly out of the keyring if it needs one.  My kAFS filesystem
could pretty much use that immediately.

However, I don't really want to put all the Kerberos communications into the
kernel.  The keys obtained by request_key() on behalf of a filesystem might be
kerberos tickets or they might be something else.

> It seems like a non-privileged user could use this to store arbitrary data
> in this keyring as a way of hiding what would otherwise be filesystem
> activity or using it for some sort of odd/sneaky IPC mechanism.  Is this an
> intentional side effect?

It is true that a non-privileged user can store arbitrary keys in their
keyring and they could use it as an IPC mechanism if they really wanted to -
but if they could do that, they could use socketpairs, pipes or shm instead so
I'm not sure they can do anything that they couldn't do by some other
mechanism anyway.

Note that key accesses are regulated by the active LSM and I think can appear
in the audit log.

David
