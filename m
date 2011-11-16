Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45678 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab1KPTq3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Nov 2011 14:46:29 -0500
Date: Wed, 16 Nov 2011 14:47:18 -0500
From: Jeff Layton <jlayton@redhat.com>
To: John Hughes <john@calvaedi.com>
Cc: Trond Myklebust <trond.myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
Message-ID: <20111116144718.78b2e288@corrin.poochiereds.net>
In-Reply-To: <4EC3FD8B.6000705@calvaedi.com>
References: <4EC3FD8B.6000705@calvaedi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Nov 2011 19:14:35 +0100
John Hughes <john@calvaedi.com> wrote:

> With recent kernels if the Kerberos ticket for a nfs4 mount expires any 
> user process trying to access the mount hangs until a new ticket is 
> obtained.  Simultaneously a (luckily rate-limited, but still seemingly 
> endless) stream of "Error: state manager encountered RPCSEC_GSS session 
> expired against NFSv4 server" messages is written to the kernel log.
> 
> In a common setup with user home directories nfs4 mounted on 
> workstations one of the processes that is likely to hang is the 
> screen-unlock function which would normally (via pam_krb5 or similar) 
> get the new ticket.
> 
> In older kernels the EKEYEXPIRED error would be passed to userland, 
> which would usualy just give up.
> 
> This patch restores the old behavior, which makes nfs4 mounted home 
> directories usable for me.
> 

Uhhh, no...EKEYEXPIRED was never passed to userland. The patchset that
added EKEYEXPIRED returns in this codepath also added the code to make
it hang. 

This not a bug, or at least it's intentional behavior. When a krb5
ticket expires, we *want* the process to hang. Otherwise, people with
long running jobs will often find that their jobs error out
inexplicably when their ticket expires.

The patches that introduced this behavior went into 2.6.34. See the
commits around 2c64348 (and some preceding ones in the rpc layer).

If you want to fix this use case, you'll need to come up with a scheme
that doesn't regress this behavior. I think that you'll really need to
ensure that whatever process you expect to re-fetch your TGT is not
dependent on accessing kerberized nfs mounts. That really seems like an
untenable chicken and egg situation.

-- 
Jeff Layton <jlayton@redhat.com>
