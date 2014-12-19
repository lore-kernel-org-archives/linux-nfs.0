Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:33798 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbaLSPhK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 10:37:10 -0500
Received: by mail-vc0-f170.google.com with SMTP id hy4so401392vcb.29
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 07:37:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyErUrXJ+XA6tcGMAtVX7CJaahV6TzzGR1a=E_sXzp9i3g@mail.gmail.com>
References: <CAN-5tyErUrXJ+XA6tcGMAtVX7CJaahV6TzzGR1a=E_sXzp9i3g@mail.gmail.com>
Date: Fri, 19 Dec 2014 10:37:09 -0500
Message-ID: <CAHQdGtRtEY0myfQdfEtTS9njP7zWREUZ9GbYG01M2Ap4WUy-7w@mail.gmail.com>
Subject: Re: question about code in delegation.c
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga

On Fri, Dec 19, 2014 at 10:11 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Hi Trond,
>
> I have a question about a patch you committed 57bfa891 and
> specifically about the comment that's in the code saying "deal with
> the broken servers that hand out two delegations for the same file".
> Why is this considered to be broken?
>
> The situation I'm experiencing has the following flow:
> 1. client opens a file and gets a write delegation.
> 2. this file is then closed, it's subsequently locally opened for
> write (no open on the wire). delegation stateid is also used for write
> operations seen on the wire. all is good.
> 3. then client (on the wire) sends an open for read. first i'm not
> sure why this is not local. but let's say the client is allowed to do
> so.

Does the client know that this is the same file? i.e. is this a
situation where it is using the same directory filehandle + filename
in the open?

> 4. the server knows this client has a write delegation for this file
> so it replies to the open with the write delegation.
> 5. then code in "nfs_node_set_delegation" sees that it's the same
> delegation and ends up returning "it". however from the server's point
> of you, it considers the client returning the one delegation it gave
> out.

It won't return a delegation with a matching stateid and _type_ to the
one it already holds.

That said, the code should probably make a distinction here:

1) If the delegation stateid matches, we shouldn't delegreturn.
Instead, just check the delegation type and try to figure out if this
is an upgrade from a read delegation to a write delegation.
or
2) If the delegation stateid doesn't match, figure out whether or not
this is a delegation upgrade, and either discard the old stateid if it
is (good server) or discard the new stateid if it isn't (broken
server). Issue delegreturn for the stateid we're discarding.

> 6. the client proceeds to use the delegation stateid which causes the
> server to send BAD_SESSIONID which leads the client to initiate state
> recovery and mark it's locks lost and return EIO.

BAD_SESSIONID? That's just wrong...

> (a) it seems like the open for read shouldn't have gone on the wire to
> begin with, but
> (b) if there are cases when we do want to send an open even if we hold
> a delegation, then shouldn't we just ignore if we receive the same
> delegation that already hold?
>
> Thank you.



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
