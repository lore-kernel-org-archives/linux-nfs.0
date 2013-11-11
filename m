Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753499Ab3KKMTO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Nov 2013 07:19:14 -0500
Date: Mon, 11 Nov 2013 07:18:25 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: devel@openvz.org, ebiederm@xmission.com, oleg@redhat.com,
        bfields@fieldses.org, bharrosh@panasas.com
Subject: call_usermodehelper in containers
Message-ID: <20131111071825.62da01d1@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have a bit of a problem wrt to upcalls that use call_usermodehelper
with containers and I'd like to bring this to some sort of resolution...

A particularly problematic case (though there are others) is the
nfsdcltrack upcall. It basically uses call_usermodehelper to run a
program in userland to track some information on stable storage for
nfsd.

One could envision nfsd running on a machine with several containers,
and each would need to track its own database of info on stable
storage. When processing RPCs that come into the network address within
a certain container, we want to ensure that it tracks this info inside
the mount namespace within that container as well.

So, we ideally need to ensure that when this upcall is run, that we run
the correct binary in the container *and* that it does all of its file
I/O within the correct mount namespace. We might also need other
namespace swapping as well.

Stanislav posted a patch a few months ago that tried to address this:

    https://lkml.org/lkml/2013/5/22/80

However, it failed to address some problems -- namely that we have to
consider the case where a container may be running with reduced
capabilities. We want to ensure that the UMH upcall inherits the
correct capability set for its container as well.

What's the correct approach to fix this? One possibility would be to
keep a kernel thread around that sits in the correct namespace(s) and
has the right privileges, and then use that to launch UMH programs.
That thread could be spawned whenever someone runs rpc.nfsd inside a
container.

Not very elegant, but it seems like something that would work.

Are there better approaches?

-- 
Jeff Layton <jlayton@redhat.com>
