Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34118 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605Ab1AJU40 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 15:56:26 -0500
Subject: Re: question about nfs4 with krb5 behavior
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Roman Shtylman <shtylman@athenacr.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <201101101545.21890.shtylman@athenacr.com>
References: <201101101455.30608.shtylman@athenacr.com>
	 <20110110153504.0379874a@tlielax.poochiereds.net>
	 <201101101545.21890.shtylman@athenacr.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 Jan 2011 15:56:24 -0500
Message-ID: <1294692984.13131.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-01-10 at 15:45 -0500, Roman Shtylman wrote: 
> On Monday, January 10, 2011 03:35:04 pm Jeff Layton wrote:
> > On Mon, 10 Jan 2011 14:55:30 -0500
> > 
> > Roman Shtylman <shtylman@athenacr.com> wrote:
> > > I have setup nfs4 with krb5 server and successfully mounted a client. Two
> > > people can log into the client box and both access their respective
> > > shares and not each other's. However, when one user (who lets say has
> > > root privs) uses root to become the second user (using su) then that
> > > user can now access the info of the user he became.
> > > 
> > > I was under the impression that this should not be possible as the
> > > tickets for access should still be tied to the first user they logged in
> > > as. Is this true? Or do I have an error in my setup?
> > > 
> > > Process:
> > > Login as user A
> > > (User B logs into the machine from another terminal)
> > > sudo su B (to become user B on the machine)
> > > <can now edit files which belong to B>
> > 
> > That's correct, or is at least in accordance with the design. The
> > credcache is (usually) a file in /tmp. The kernel has to upcall to
> > userspace for that information. To do that, it passes along the uid of
> > the owner of the credcache. I think this is governed by the fsuid.
> > 
> > When you "su" to another user, all of the uid's associated with the
> > process are changed (real, effective, fs and saved). So, the uid passed to
> > the upcall in this case is B's and not A's.
> > 
> > This could potentially be "fixable" by moving the krb5 credcache into
> > the per-session keyring and then teach nfs to do keys API upcalls to get
> > the right blob. Not a trivial project, but it's doable. This is
> > something that would be nice for CIFS and maybe AFS too.
> 
> AFS does not have this behavior. 
> 
> What is a best practice for handling this situation? Prevent "untrusted" 
> machines from connecting to the nfs server? Basically any machine where a 
> normal user can become root would be a potential problem?

We really should add this question to the NFS FAQ (if it isn't already
there).

Just do not trust _any_ machine where you can't trust the root account.

It really doesn't matter what you do in the matter of fancy solutions;
if the root account is untrusted, it is game over as far as security is
concerned. The root user can read /dev/mem, can load untrusted modules,
can reboot into an untrusted kernel, replace the kerberos libraries with
trojans, hijack ttys, ...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

