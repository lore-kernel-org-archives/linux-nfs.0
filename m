Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:56974 "EHLO
        elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750779AbdLGUFP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Dec 2017 15:05:15 -0500
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Drew Leske'" <drew.leske@computecanada.ca>,
        <linux-nfs@vger.kernel.org>
References: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca>
In-Reply-To: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca>
Subject: RE: Non-root chown, NFSv4 ACLs
Date: Thu, 7 Dec 2017 12:05:12 -0800
Message-ID: <027101d36f96$b16f3830$144da890$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I have been unable to find clear information on this so apologies if this=
 is a
> poor question for this mailing list.
> 
> I have an NFS fileserver exporting to a client system where a web service=

> manages files on behalf of logged-in users.  In order to do this, the ser=
vice
> must be able to manipulate ownership of files and directories, but it is
> undesirable to run the web service as root.  The web service is given the=

> `CAP_CHOWN` capability through `setcap(8)`.  This works fine on a local
> filesystem but does not work under NFS.
> 
> I have replicated this on a test server mounting as either NFS v3 or v4. =
 To
> test, I make a copy of `/bin/chown` and give it the `CAP_CHOWN` capabilit=
y.
> On a local filesystem, I can then, as myself, change the ownership of a f=
ile to
> some other user.  On the NFS-mounted filesystem, I get `Operation not
> permitted`.  I have tried this on v3 and v4 to the same result.  (On v4.1=
 I
> receive =E2=80=9CInvalid argument=E2=80=9D whether as an unprivileged use=
r or as root=E2=80=94I
> have not looked further into this as I suspect it=E2=80=99s irrelevant to=
 my current
> problem.)
> 
> In looking into ACLs to see if they may provide the answer, I came across=
 the
> NFSv4 ACE permission of `o` for ownership.  This seemed to me to be exact=
ly
> what I needed.  Unfortunately, while this permission appears to be
> accepted, it is not applied and has no effect: subsequent calls to
> `nfs4_getfacl` show no change, and ownership changes are still disallowed=
=2E  I
> have tried enabling ACLs and user extended attributes on the exported
> filesystem, but they appear to have no effect.
> 
> I understand that NFSv4 ACLs are not fully supported in Linux due to the
> inoperability with POSIX ACLs, however, a Linux-NFS wiki page on ACLs
> (http://wiki.linux-nfs.org/wiki/index.php/ACLs) describing the existing
> mapping of NFSv4 ACLs to POSIX ACLs states that while the mapping is
> imperfect, =E2=80=9Cit accepts most NFSv4 ACLs=E2=80=9D and states the on=
ly exceptions have
> to do with explicit denies.
> 
> I have looked briefly at the `richacls` project, but that=E2=80=99s not p=
rovided by
> either of the OS distributions I may use (Ubuntu or CentOS), and I don=E2=
=80=99t
> know either of the following:
> 
> 1. Should it be possible for a user to be able to change the ownership of=
 a file
> or directory over NFS, using Linux `CAP_CHOWN`?
> 
> 2. Should the NFSv4 ACL =E2=80=9Cownership=E2=80=9D permission be settabl=
e in my
> environment?
> 
> There are two fileservers.  On one, the exported filesystem is ZFS; on th=
e
> other (where I am doing most of my testing), the exported filesystem is e=
xt4.
> 
> At this stage I am open to using either NFS v3 or v4, and have tried both=
=2E
> 
> A possible workaround is to have the software call an SUID copy of `chown=
`
> that is only available to the user ID of the web service, but this is les=
s
> desirable.

I think this may be your only solution. NFS/RPC has no way to communicate p=
ermission CAPs to the server.

If CAPs could be user based as well as process based, then you could grant =
the web service's user ID the appropriate CAPs on the server.

NFS v4 ACLs could help, however, they are imperfect since a file owner coul=
d remove the ACE that allows the web service's user ID to change ownership.=


Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

