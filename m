From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Thu, 23 Oct 2008 10:55:45 -0400
Message-ID: <1224773745.7625.4.camel@localhost>
References: <20081022091207.GA12996@squirrel.roonstrasse.net>
	 <20081023123628.GA18549@squirrel.roonstrasse.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	harry@atmos.washington.edu
To: Max Kellermann <max@duempel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754137AbYJWO4Q@vger.kernel.org>
In-Reply-To: <20081023123628.GA18549@squirrel.roonstrasse.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-10-23 at 14:36 +0200, Max Kellermann wrote:
> On 2008/10/22 11:12, Max Kellermann <max@duempel.org> wrote:
> > after I was able to fix http://lkml.org/lkml/2008/10/17/147, the
> > server which was already upgraded to 2.6.27.2 still gets very high
> > load.  It is a web server with NFS file storage (NetApp), and while
> > the others in the cluster (kernel 2.6.25) have a load of 1-3, 2.6.27.2
> > gets 30-50.
> > 
> > I did an oprofile, with the following results (server just started,
> > load "only" 5-10):
> > 
> > 87593    56.1116  (no location information)   vmlinux
> > vmlinux                  rpcauth_lookup_credcache
> > 16037    10.2732  auth_generic.c:0            vmlinux
> > vmlinux                  generic_match
> > 6460      4.1382  (no location information)   php4
> > php4                     (no symbols)
> > 2478      1.5874  (no location information)   libc-2.7.so
> > libc-2.7.so              (no symbols)
> > [...]
> > 
> > We havn't configured any special authentication method.  It is a NFSv3
> > over UDP mount, but the kernel has NFSv4 and therefore KRB5 enabled.
> > 
> > Any ideas why rpcauth_lookup_credcache() goes overboard with CPU
> > usage?
> 
> I have bisected the problem: 98a8e323 is the result ("SUNRPC: Add a
> helper rpcauth_lookup_generic_cred()").  5c691044 is ok.
> 
> See the attached oprofile annotation data for both commits.  I guess
> that the function rpcauth_lookup_credcache() is waiting for a spinlock
> too often and too long.  Trond, any idea?

Can you add a '-v' to the rpc.gssd daemon startup line? I'd like to see
how often you are creating new gss contexts.

> Harry: added you to Cc because your problem sounds similar.

Harry's problem is should be unrelated. afaik, he is seeing a problem
with userland RPC code, not kernel rpc code.

Trond
