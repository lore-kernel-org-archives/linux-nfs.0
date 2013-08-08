Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965524Ab3HHOq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Aug 2013 10:46:56 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAK3OfOj6E_thwgwdZUDXrr_7XW4xJkzwxdGU6gKcEJ3twOsm=A@mail.gmail.com>
References: <CAK3OfOj6E_thwgwdZUDXrr_7XW4xJkzwxdGU6gKcEJ3twOsm=A@mail.gmail.com> <20130801173846.28023.19009.stgit@warthog.procyon.org.uk> <20130801173854.28023.82045.stgit@warthog.procyon.org.uk>
To: Nico Williams <nico@cryptonector.com>
Cc: dhowells@redhat.com, keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        simo@redhat.com, linux-kernel@vger.kernel.org, krbdev@mit.edu
Subject: Re: [PATCH 1/2] KEYS: Implement a big key type that can save to tmpfs
Date: Thu, 08 Aug 2013 15:46:45 +0100
Message-ID: <16961.1375973205@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nico Williams <nico@cryptonector.com> wrote:

> b) how to create tmpfs locations in which to store credentials (which
> can be unbounded in size, so storing them in the kernel is silly;

Ummm...  tmpfs stores them in the kernel too - though it can page them out to
swap.

I have altered my big-key implementation to just store small items in an
internal buffer and big items in a tmpfs file.  This means that small items
will use up _less_ kernel memory if they're in a key because they won't require
the overhead of a dentry struct and an inode struct.

> (b) can be solved in many ways, and the simplest is to have a
> filesystem where top-level directories named after UIDs "exist" as
> soon as they are referenced and as long as they are non-empty.  You
> can use autofs + tmpfs, or a variant of tmpfs for this.

Don't forget to add user namespaces into the mix :-/

David
