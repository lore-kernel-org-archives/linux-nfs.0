Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932797AbcBAO4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2016 09:56:09 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <476553248.3261178.1454301625977.JavaMail.yahoo@mail.yahoo.com>
References: <476553248.3261178.1454301625977.JavaMail.yahoo@mail.yahoo.com> <476553248.3261178.1454301625977.JavaMail.yahoo.ref@mail.yahoo.com>
To: a a <x5q9b8n384@yahoo.com>
Cc: dhowells@redhat.com, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [Linux-cachefs] Actually persistent? How?
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 01 Feb 2016 14:56:07 +0000
Message-ID: <5998.1454338567@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

a a <x5q9b8n384@yahoo.com> wrote:

> I am trying to use the user space daemon cachefilesd with NFS/FS-Cache. I
> have read in many places that this cache uses local disk space so as to be
> persistent across reboots of the client. I am using it as both read and
> write as a primary means of guaranteeing that files written to the server
> will not be corrupted due to network glitches. What I cannot find out
> anywhere that I have looked is the way to actually use this persistence.
>
> I have 2 use cases. In both, I am running the latest Ubuntu Linux on both
> client and server. I am writing a very large file to the NFS server through
> the mount point. This works just fine.
>
> 1. In the middle of writing, I disable the network interface for the
> server. What seems to happen is that the writing continues from the client
> into the local cache and the application (in this case the "cp" command)
> received an "all ok", meaning that the file has been written
> successfully. When I restore the NFS server network interface, the caching
> and NFS client seem to recover and when I check next on the server after a
> small bit of time, the file exists remotely and is complete and
> uncorrupted. This seems to work fine and I have no further issues with this
> use case (assuming that this is actually what happens; I need to perhaps run
> more tests and verify that NFS actually resumes data writing to the server
> when the connection is restored.)
> 
> 2. In the second use case, I run the same operation (writing a large file,
> cutting off the server network connection) and I get back an "all ok" as
> before. This time, I shutdown the client, restore network capability to the
> server and then re-start the client. At this time, I do not get any further
> automatic synchronization and the file I was trying to write out is
> corrupted on the server. It seems that starting cachesfilesd kills the cache
> including dirty blocks.

At present, the cache does not, in and of itself, provide any synchronisation
with the server - that's entirely a function of the network filesystem.

Currently, when you interrupt the connection, the NFS client retains the
writeback state and resumes writing back *from RAM*.  If you reboot the client
whilst connection is interrupted, all that state is lost and the writeback is
not completed.

The reason that the cache object is then deleted, I suspect, is that the
coherency information on the cache object doesn't match that retrieved over
the network.

> Is there any way to have this second use case work by coming up when the
> client is restarted, recognize that there are still dirty cache elements and
> sync them up to the server automatically?

This will require the NFS client to not only save the dirty data to the cache,
but also save the fact that it is dirty - and how far the writeback has got.

One problem that you have with NFS is that the change attribute is not
guaranteed to be incremented monotonically with each data modification on the
server as far as I can tell (and doesn't even necessarily exist).  So you
cannot tell if another write jumped in whilst you were writing back unless you
have leases that are persistent over a client reboot.

> Is this even possible? Is this supposed to work? Have I missed something or
> need to run some sort of different test?

This needs work on the NFS client and possibly fscache to make it work.

This goes hand-in-hand with disconnected client operation.

> If not, my question then is, why bother having a persistent cache that is
> supposedly coherent over reboots of the client if executing cachefilesd
> simply zaps the cache as its first operation?

It doesn't - or it shouldn't.  If the cache object is coherent with respect to
the server object, it won't[*].  So for large *read only* sets it may make a
difference.

[*] Unless it needs to cull the cache to make space.

David
