Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk1-f196.google.com ([209.85.222.196]:33314 "EHLO
        mail-qk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727994AbeIOVjj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Sep 2018 17:39:39 -0400
Received: by mail-qk1-f196.google.com with SMTP id z78-v6so6888067qka.0
        for <linux-nfs@vger.kernel.org>; Sat, 15 Sep 2018 09:20:09 -0700 (PDT)
Message-ID: <19e995d2233282dcfd636a62d16ebe9f3b8d6166.camel@redhat.com>
Subject: Re: Correctly understanding Linux's close-to-open consistency
From: Jeff Layton <jlayton@redhat.com>
To: Chris Siebenmann <cks@cs.toronto.edu>, linux-nfs@vger.kernel.org
Date: Sat, 15 Sep 2018 12:20:06 -0400
In-Reply-To: <20180913012458.A6651322562@apps1.cs.toronto.edu>
References: <20180913012458.A6651322562@apps1.cs.toronto.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-09-12 at 21:24 -0400, Chris Siebenmann wrote:
>  I'm trying to get my head around the officially proper way of
> writing to NFS files (not just what works today, and what I think
> is supposed to work, since I was misunderstanding things about that
> recently).
> 
>  Is it correct to say that when writing data to NFS files, the only
> sequence of operations that Linux NFS clients officially support is
> the following:
> 
> - all processes on all client machines close() the file
> - one machine (a client or the fileserver) opens() the file, writes
>   to it, and close()s again
> - processes on client machines can now open() the file again for
>   reading

No.

One can always call fsync() to force data to be flushed to avoid the
close of the write fd in this situation. That's really a more portable
solution anyway. A local filesystem may not flush data to disk, on close
(for instance) so calling fsync will ensure you rely less on filesystem
implementation details.

The separate open by the reader just helps ensure that the file's
attributes are revalidated (so you can tell whether cached data you hold
is still valid).

> Other sequences of operations may work in some particular kernel version
> or under some circumstances, but are not guaranteed to work over kernel
> version changes or in general.
> 

The NFS client (and the Linux kernel in general) will try to preserve as
much cached data as it can, but eventually it will end up being freed,
depending on the kernel's memory requirements. This is not behavior you
want to depend on, as an application developer.

> In an official 'we guarantee that if you do this, things will work' sense,
> how does taking NFS locks interact with this required sequence? Do NFS
> locks make some part of it unnecessary, or does it remain necessary and
> NFS locks are just there to let you coordinate who has a magic 'you can
> write' token and you still officially need to close and open and so on?
> 

If you use file locking (flock() or POSIX locks), then we treat those as
cache coherency points as well. The client will write back cached data
to the server prior to releasing a lock, and revalidate attributes (and
thus the local cache) after acquiring one.

If you have an application that does concurrent access via NFS over
multiple machines, then you probably want to be using file locking to
serialize things across machines.
-- 
Jeff Layton <jlayton@redhat.com>
