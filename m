Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754202Ab1AJUfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Jan 2011 15:35:08 -0500
Date: Mon, 10 Jan 2011 15:35:04 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Roman Shtylman <shtylman@athenacr.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: question about nfs4 with krb5 behavior
Message-ID: <20110110153504.0379874a@tlielax.poochiereds.net>
In-Reply-To: <201101101455.30608.shtylman@athenacr.com>
References: <201101101455.30608.shtylman@athenacr.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 10 Jan 2011 14:55:30 -0500
Roman Shtylman <shtylman@athenacr.com> wrote:

> I have setup nfs4 with krb5 server and successfully mounted a client. Two 
> people can log into the client box and both access their respective shares and 
> not each other's. However, when one user (who lets say has root privs) uses 
> root to become the second user (using su) then that user can now access the 
> info of the user he became.
> 
> I was under the impression that this should not be possible as the tickets for 
> access should still be tied to the first user they logged in as. Is this true? 
> Or do I have an error in my setup?
> 
> Process:
> Login as user A
> (User B logs into the machine from another terminal)
> sudo su B (to become user B on the machine)
> <can now edit files which belong to B>
> 

That's correct, or is at least in accordance with the design. The
credcache is (usually) a file in /tmp. The kernel has to upcall to
userspace for that information. To do that, it passes along the uid of
the owner of the credcache. I think this is governed by the fsuid.

When you "su" to another user, all of the uid's associated with the
process are changed (real, effective, fs and saved). So, the uid passed to
the upcall in this case is B's and not A's.

This could potentially be "fixable" by moving the krb5 credcache into
the per-session keyring and then teach nfs to do keys API upcalls to get
the right blob. Not a trivial project, but it's doable. This is
something that would be nice for CIFS and maybe AFS too.

> If User B does not login before user A becomes user B, user A is not able to 
> edit user B's files even after he becomes user B.
> 

I suspect that that's just a negative cache entry that will eventually
time out.

-- 
Jeff Layton <jlayton@redhat.com>
