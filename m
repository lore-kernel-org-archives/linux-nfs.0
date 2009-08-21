From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4
 referrals and migration
Date: Fri, 21 Aug 2009 10:21:33 -0400
Message-ID: <1250864493.6514.71.camel@heimdal.trondhjem.org>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com>
	 <20090821094248.23bc54f1@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45169 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755540AbZHUOVd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 10:21:33 -0400
In-Reply-To: <20090821094248.23bc54f1-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 09:42 -0400, Jeff Layton wrote:
> On Wed, 19 Aug 2009 19:38:53 -0400
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > The NFSv4 and NFSv4.1 protocols both allow for the redirection of a client
> > from one server to another in order to support filesystem migration and
> > replication. For full protocol support, we need to add the ability to
> > convert a DNS host name into an IP address that we can feed to the RPC
> > client.
> > 
> > We'll reuse the sunrpc cache, now that it has been converted to work with
> > rpc_pipefs.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> 
> I'm happy to see this problem get resolved. Much of this functionality
> however is already provided by the keys API. While it's more geared
> toward dealing with auth tokens, it's still a fairly decent generic upcall
> implementation and could easily have been used here with a lot less new
> code added. Why did you decide to roll your own implementation instead?

As I told you at Connectathon, I don't trust the keyring mechanism at
all for this.
The user is free to inject anything they want into their keyring caches.
Trusting that information when doing a mount onto a shared namespace is
inappropriate.

The point then is that if you can't trust the caching mechanism, then
you have to build a new cache. I chose to reuse Neil's rpc-cache stuff,
because it has some nice properties:

      * Write access is restricted to privileged processes using
        standard filesystem techniques.
      * The cache contents can be easily verified using the 'contents'
        pseudofile.
      * The contents can be easily cleared using the 'flush' pseudofile.

The only property I really didn't like about his cache mechanism (that
it uses procfs), I easily worked around.

As I said to Chuck, the plan is to also rewrite the idmapper to use a
similar mechanism. The current idmapper has scalability problems that we
need to address in order to make NFSv4 perform in environments with lots
of users.

Cheers
   Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
