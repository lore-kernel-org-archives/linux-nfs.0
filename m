Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48547 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850Ab3HBRuz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 13:50:55 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <51FAAF3D.3010806@fifthhorseman.net>
References: <51FAAF3D.3010806@fifthhorseman.net> <20130801173846.28023.19009.stgit@warthog.procyon.org.uk> <20130801173902.28023.68819.stgit@warthog.procyon.org.uk> <51FAA0CC.7010106@fifthhorseman.net> <1375381798.15733.207.camel@willson.li.ssimo.org>
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: dhowells@redhat.com, Simo Sorce <simo@redhat.com>, keyrings@linux-nfs.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, linux-nfs@vger.kernel.org,
        krbdev@mit.edu, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for persistent per-UID kerberos caches
Date: Fri, 02 Aug 2013 18:50:44 +0100
Message-ID: <7664.1375465844@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Daniel Kahn Gillmor <dkg@fifthhorseman.net> wrote:

> I guess this raises the question from a different perspective: if the
> kernel already supports arbitrary shm segments, filesystem locations,
> etc, which can be used for storing/passing opaque bytestrings between
> different parts of userspace, what advantages do we gain from having
> this new specific mechanism in the kernel?  Why couldn't those parts of
> userspace just rely on already-existing mechanisms instead of
> introducing this new interface?

Kernel services can use keys directly by calling request_key() without
necessarily having to upcall.


The keys service in the kernel was created initially for use by the kAFS
filesystem in the kernel which uses it for passing authentication tokens
around.  Let me describe how I originally envisioned this working as it may
help the discussion.


Every time a non-fd-based operation[*] is called, kAFS calls request_key() to
get a key containing an authentication token for the cell.

 [*] That is things like lookup, open(), rmdir() and stat() but not read() and
     write() which use a key cached in the file struct.

Keys can be preemptively added for kAFS by calling a klog or an aklog program
talk to the authentication server and then use add_key() to add a key into the
kernel.  The filesystem subsequently finds this and uses it without the need to
upcall.

Currently, that's all you can do with kAFS.

However, on my todo list is to make it able to upcall when it doesn't have a
key available.  This is provided for by the request_key() mechanism.
request_key() searches for the key and if one if is available, it returns it
otherwise it can[*] partially construct a key and then upcall to ask userspace
to instantiate it.

 [*] If the caller permits it to.

request_key() can upcall to a program it execs itself or it can upcall to a
running program (though the exact mechanism of the latter is to be worked out).

Say userspace then decides to do a Kerberos ticket request.  It could call
request_key() itself to search the original process's keyrings for a TGT which
it can then use to request a ticket.

Once it has the ticket, it can place the ticket data into the partially
constructed key and link the key into the kerberos ccache keyring to retain it.


Now, one of the problems I've got is that the name in the partially constructed
key is from the filesystem's view of the world - and this doesn't necessarily
coincide with that of the authentication server.  For example, the kAFS
filesystem wants a key named for the cell, eg.:

	afs.redhat.com

but the Kerberos ticket might look like:

	AFS/afs.redhat.com@REDHAT.COM

Now, I do permit partial matching, so I could ignore the "@REDHAT.COM" and just
slap "AFS/" on the front of what I'm looking for.

A further problem is the fact that keys have types and search only finds the
type asked for - though that can be dealt with in the keyring search algorithm.

David
