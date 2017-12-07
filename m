Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56972 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750947AbdLGVeT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Dec 2017 16:34:19 -0500
Date: Thu, 7 Dec 2017 16:34:19 -0500
To: Drew Leske <drew.leske@computecanada.ca>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Non-root chown, NFSv4 ACLs
Message-ID: <20171207213419.GA6147@fieldses.org>
References: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 07, 2017 at 11:43:28AM -0800, Drew Leske wrote:
> I have replicated this on a test server mounting as either NFS v3 or
> v4.  To test, I make a copy of `/bin/chown` and give it the
> `CAP_CHOWN` capability.  On a local filesystem, I can then, as myself,
> change the ownership of a file to some other user.  On the NFS-mounted
> filesystem, I get `Operation not permitted`.

Yeah, as others have said, the protocol just gives the client no way to
say "this rpc call is being made by a process that has the CAP_CHOWN
capability".  All the server gets is a uid and some gids (or a krb5
principal).

The relevant code for knfsd is in fs/nfsd/auth.c:nfsd_setuser().  It
just temporarily changes the credentials that the current nfsd process
runs with to credentials taken from what the client provided in the rpc
call.

I guess in theory we could provide some way to tell the server that a
certain user to get CAP_CHOWN.  Doesn't that it mean it could
effectively access anything by chowning it to its own uid and the
chowning it back?  Maybe we'd want some more restrictive capability.  Or
maybe you'd be OK with just mapping the user to root.

In theory I wonder if the structured privileges in rfc 7861 could be
used to communicate capabilities?

> I have tried this on v3 and v4 to the same result.  (On v4.1 I receive
> “Invalid argument” whether as an unprivileged user or as root—I have
> not looked further into this as I suspect it’s irrelevant to my
> current problem.)

Huh.  Chown as root on 4.1 works for me on latest upstream.  Hard to
think why 4.1 would make a difference.

--b.

> In looking into ACLs to see if they may provide the answer, I came across the NFSv4 ACE permission of `o` for ownership.  This seemed to me to be exactly what I needed.  Unfortunately, while this permission appears to be accepted, it is not applied and has no effect: subsequent calls to `nfs4_getfacl` show no change, and ownership changes are still disallowed.  I have tried enabling ACLs and user extended attributes on the exported filesystem, but they appear to have no effect.
> 
> I understand that NFSv4 ACLs are not fully supported in Linux due to the inoperability with POSIX ACLs, however, a Linux-NFS wiki page on ACLs (http://wiki.linux-nfs.org/wiki/index.php/ACLs) describing the existing mapping of NFSv4 ACLs to POSIX ACLs states that while the mapping is imperfect, “it accepts most NFSv4 ACLs” and states the only exceptions have to do with explicit denies.
> 
> I have looked briefly at the `richacls` project, but that’s not provided by either of the OS distributions I may use (Ubuntu or CentOS), and I don’t know either of the following:
> 
> 1. Should it be possible for a user to be able to change the ownership of a file or directory over NFS, using Linux `CAP_CHOWN`?
> 
> 2. Should the NFSv4 ACL “ownership” permission be settable in my environment?
> 
> There are two fileservers.  On one, the exported filesystem is ZFS; on the other (where I am doing most of my testing), the exported filesystem is ext4.
> 
> At this stage I am open to using either NFS v3 or v4, and have tried both.  
> 
> A possible workaround is to have the software call an SUID copy of `chown` that is only available to the user ID of the web service, but this is less desirable.
> 
> Any tips, information or guidance on this would be greatly appreciated.
> 
> Thanks,
> Drew.
> 
> ----
> Drew Leske 
> Senior Software Developer
> Développeur de logiciel principal
> drew.leske@computecanada.ca 
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
