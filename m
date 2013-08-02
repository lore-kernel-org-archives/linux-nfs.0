Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdcaid.dreamhost.com ([208.97.132.83]:55275 "EHLO
	homiemail-a85.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751670Ab3HBUtJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Aug 2013 16:49:09 -0400
MIME-Version: 1.0
In-Reply-To: <20130801173854.28023.82045.stgit@warthog.procyon.org.uk>
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	<20130801173854.28023.82045.stgit@warthog.procyon.org.uk>
Date: Fri, 2 Aug 2013 15:49:06 -0500
Message-ID: <CAK3OfOj6E_thwgwdZUDXrr_7XW4xJkzwxdGU6gKcEJ3twOsm=A@mail.gmail.com>
Subject: Re: [PATCH 1/2] KEYS: Implement a big key type that can save to tmpfs
From: Nico Williams <nico@cryptonector.com>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org, simo@redhat.com,
        linux-kernel@vger.kernel.org, krbdev@mit.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think this is the wrong design.

There are two problems you're trying to solve:

a) how rpc.gssd finds credentials for processes on behalf of which it's acting

b) how to create tmpfs locations in which to store credentials (which
can be unbounded in size, so storing them in the kernel is silly; also
the apps that use them are all user-land apps, so that too means
there's no point in storing them in the kernel).

Keyrings for the forst problem (or PAGs, or anything similar) is fine:
on upcall to gssd the kernel tells it what it needs to know to find
those credentials.

(b) can be solved in many ways, and the simplest is to have a
filesystem where top-level directories named after UIDs "exist" as
soon as they are referenced and as long as they are non-empty.  You
can use autofs + tmpfs, or a variant of tmpfs for this.

Solving (b) in a way that does not add a new ccache type (though
having a KEYRING: ccache type that means "find the ccache URI in my
keyring" is fine) is important because many of us run multiple
implementations of Kerberos on any given host, and we do it because:

 - vendors are always behind the curve
 - legacy software linked with old versions of libkrb5 and friends
 - third party software

Please review the above.  Thanks,

Nico
--
