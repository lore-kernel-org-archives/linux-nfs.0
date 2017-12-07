Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:46591 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdLGWy0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Dec 2017 17:54:26 -0500
Received: by mail-pf0-f181.google.com with SMTP id c204so5781464pfc.13
        for <linux-nfs@vger.kernel.org>; Thu, 07 Dec 2017 14:54:26 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Non-root chown, NFSv4 ACLs
From: Drew Leske <drew.leske@computecanada.ca>
In-Reply-To: <20171207213419.GA6147@fieldses.org>
Date: Thu, 7 Dec 2017 14:54:22 -0800
Cc: linux-nfs@vger.kernel.org
Message-Id: <F6FBCAE9-DB8D-4965-B761-58ACDF245BC3@computecanada.ca>
References: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca> <20171207213419.GA6147@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Yeah, as others have said, the protocol just gives the client no way =
to
> say "this rpc call is being made by a process that has the CAP_CHOWN
> capability".  All the server gets is a uid and some gids (or a krb5
> principal).

That answers that, then.  Thank you (and Frank earlier) for clarifying =
that for me.

> I guess in theory we could provide some way to tell the server that a
> certain user to get CAP_CHOWN.  Doesn't that it mean it could
> effectively access anything by chowning it to its own uid and the
> chowning it back?  Maybe we'd want some more restrictive capability.  =
Or
> maybe you'd be OK with just mapping the user to root.

In this context, and I don=E2=80=99t see a lot of use cases for this, =
the web service=E2=80=99s user can do whatever it wants, and basically =
acts like root.  On my list of things to try for this case is to map the =
user to root on the server, so that effectively that ID can do whatever =
it wants.  I don=E2=80=99t know if this will work and I don=E2=80=99t =
believe it=E2=80=99s a good solution for a couple of different reasons =
(for example, it would apply to other filesystems exported by the =
fileserver).

> Huh.  Chown as root on 4.1 works for me on latest upstream.  Hard to
> think why 4.1 would make a difference.

If I find anything interesting there I will let you know but I believe =
it to be a red herring.  Actually, I just rebuilt the exported =
filesystem and I=E2=80=99m now able to do this with 4.1, so perhaps it =
has to do with the stuff I was playing around with for ACLs.

>> In looking into ACLs to see if they may provide the answer, I came =
across the NFSv4 ACE permission of `o` for ownership.  This seemed to me =
to be exactly what I needed.  Unfortunately, while this permission =
appears to be accepted, it is not applied and has no effect: subsequent =
calls to `nfs4_getfacl` show no change, and ownership changes are still =
disallowed.  I have tried enabling ACLs and user extended attributes on =
the exported filesystem, but they appear to have no effect.
>>=20
>> I understand that NFSv4 ACLs are not fully supported in Linux due to =
the inoperability with POSIX ACLs, however, a Linux-NFS wiki page on =
ACLs (http://wiki.linux-nfs.org/wiki/index.php/ACLs) describing the =
existing mapping of NFSv4 ACLs to POSIX ACLs states that while the =
mapping is imperfect, =E2=80=9Cit accepts most NFSv4 ACLs=E2=80=9D and =
states the only exceptions have to do with explicit denies.

The remaining question for me then is around the NFSv4 ACL and the =
ownership change permission, and whether I should be able to get that to =
work, especially on a stock system.  I know there are some issues with =
mapping NFSv4 ACLs to so-called =E2=80=9CPOSIX=E2=80=9D ACLs, but I =
didn=E2=80=99t see anything in the documentation to suggest it isn=E2=80=99=
t implemented.  Should I expect this to work without installing the =
richacls software?

Here=E2=80=99s an example of me trying the NFSv4 ACLs for this:

[testdir1] nfs4_getfacl drewsfile
A::OWNER@:rwatTcCy
A::GROUP@:rwatcy
A::EVERYONE@:rtcy
[testdir1] nfs4_setfacl -a A::OWNER@:o drewsfile
[testdir1] nfs4_getfacl drewsfile
A::OWNER@:rwatTcCy
A::GROUP@:rwatcy
A::EVERYONE@:rtcy

So it is accepted, but fails to apply.  Here=E2=80=99s trying to assign =
a garbage permission:

[testdir1] nfs4_setfacl -a A::OWNER@:p drewsfile
Bad Ace Mask:p
Failed while inserting ACE(s) (at index 1).

Is this because of the mapping to POSIX ACLs, which has no provision for =
ownership management by non-root users?  Does this require the richacls =
software?

Thanks,
Drew.

