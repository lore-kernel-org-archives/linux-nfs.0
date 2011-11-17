Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:43519 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755461Ab1KQJhN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2011 04:37:13 -0500
Message-ID: <4EC4D5BE.2030906@Calva.COM>
Date: Thu, 17 Nov 2011 10:37:02 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Trond Myklebust <trond.myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
References: <4EC3FD8B.6000705@calvaedi.com> <20111116144718.78b2e288@corrin.poochiereds.net>
In-Reply-To: <20111116144718.78b2e288@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16/11/11 20:47, Jeff Layton wrote:
> On Wed, 16 Nov 2011 19:14:35 +0100
> John Hughes<john@calvaedi.com>  wrote:
>
>> With recent kernels if the Kerberos ticket for a nfs4 mount expires any
>> user process trying to access the mount hangs until a new ticket is
>> obtained.  Simultaneously a (luckily rate-limited, but still seemingly
>> endless) stream of "Error: state manager encountered RPCSEC_GSS session
>> expired against NFSv4 server" messages is written to the kernel log.
[...]
>> This patch restores the old behavior, which makes nfs4 mounted home
>> directories usable for me.
>>
> Uhhh, no...EKEYEXPIRED was never passed to userland. The patchset that
> added EKEYEXPIRED returns in this codepath also added the code to make
> it hang.

You are, of course, right.  userland used to get EPERM.

> This not a bug, or at least it's intentional behavior. When a krb5
> ticket expires, we *want* the process to hang. Otherwise, people with
> long running jobs will often find that their jobs error out
> inexplicably when their ticket expires.
I thought that was what kstart/krenew were for.
> The patches that introduced this behavior went into 2.6.34. See the
> commits around 2c64348 (and some preceding ones in the rpc layer).

Ah, I'm a Debian user - 2.6.32 for the moment, soon to be 3.?

> If you want to fix this use case, you'll need to come up with a scheme
> that doesn't regress this behavior. I think that you'll really need to
> ensure that whatever process you expect to re-fetch your TGT is not
> dependent on accessing kerberized nfs mounts. That really seems like an
> untenable chicken and egg situation.

Ow.  "Fixing" (at least) Gnome-3 and Gnome-2 screen-lock/screensavers.

How about a mount option to chose between the two behaviours?

