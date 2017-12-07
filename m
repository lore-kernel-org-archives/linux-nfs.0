Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:36010 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdLGTnb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Dec 2017 14:43:31 -0500
Received: by mail-pg0-f42.google.com with SMTP id k134so5184001pga.3
        for <linux-nfs@vger.kernel.org>; Thu, 07 Dec 2017 11:43:31 -0800 (PST)
Received: from node-1w7jr9sq93lx1vi9jricio5nu.ipv6.telus.net (node-1w7jr9sq93lx1vi9jricio5nu.ipv6.telus.net. [2001:569:bc00:8000:d18a:da81:2ff5:14aa])
        by smtp.gmail.com with ESMTPSA id a12sm9390006pgd.60.2017.12.07.11.43.29
        for <linux-nfs@vger.kernel.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 11:43:29 -0800 (PST)
From: Drew Leske <drew.leske@computecanada.ca>
Content-Type: text/plain; charset=utf-8
Subject: Non-root chown, NFSv4 ACLs
Message-Id: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca>
Date: Thu, 7 Dec 2017 11:43:28 -0800
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I have been unable to find clear information on this so apologies if =
this is a poor question for this mailing list.

I have an NFS fileserver exporting to a client system where a web =
service manages files on behalf of logged-in users.  In order to do =
this, the service must be able to manipulate ownership of files and =
directories, but it is undesirable to run the web service as root.  The =
web service is given the `CAP_CHOWN` capability through `setcap(8)`.  =
This works fine on a local filesystem but does not work under NFS.

I have replicated this on a test server mounting as either NFS v3 or v4. =
 To test, I make a copy of `/bin/chown` and give it the `CAP_CHOWN` =
capability.  On a local filesystem, I can then, as myself, change the =
ownership of a file to some other user.  On the NFS-mounted filesystem, =
I get `Operation not permitted`.  I have tried this on v3 and v4 to the =
same result.  (On v4.1 I receive =E2=80=9CInvalid argument=E2=80=9D =
whether as an unprivileged user or as root=E2=80=94I have not looked =
further into this as I suspect it=E2=80=99s irrelevant to my current =
problem.)

In looking into ACLs to see if they may provide the answer, I came =
across the NFSv4 ACE permission of `o` for ownership.  This seemed to me =
to be exactly what I needed.  Unfortunately, while this permission =
appears to be accepted, it is not applied and has no effect: subsequent =
calls to `nfs4_getfacl` show no change, and ownership changes are still =
disallowed.  I have tried enabling ACLs and user extended attributes on =
the exported filesystem, but they appear to have no effect.

I understand that NFSv4 ACLs are not fully supported in Linux due to the =
inoperability with POSIX ACLs, however, a Linux-NFS wiki page on ACLs =
(http://wiki.linux-nfs.org/wiki/index.php/ACLs) describing the existing =
mapping of NFSv4 ACLs to POSIX ACLs states that while the mapping is =
imperfect, =E2=80=9Cit accepts most NFSv4 ACLs=E2=80=9D and states the =
only exceptions have to do with explicit denies.

I have looked briefly at the `richacls` project, but that=E2=80=99s not =
provided by either of the OS distributions I may use (Ubuntu or CentOS), =
and I don=E2=80=99t know either of the following:

1. Should it be possible for a user to be able to change the ownership =
of a file or directory over NFS, using Linux `CAP_CHOWN`?

2. Should the NFSv4 ACL =E2=80=9Cownership=E2=80=9D permission be =
settable in my environment?

There are two fileservers.  On one, the exported filesystem is ZFS; on =
the other (where I am doing most of my testing), the exported filesystem =
is ext4.

At this stage I am open to using either NFS v3 or v4, and have tried =
both. =20

A possible workaround is to have the software call an SUID copy of =
`chown` that is only available to the user ID of the web service, but =
this is less desirable.

Any tips, information or guidance on this would be greatly appreciated.

Thanks,
Drew.

----
Drew Leske=20
Senior Software Developer
D=C3=A9veloppeur de logiciel principal
drew.leske@computecanada.ca=20




