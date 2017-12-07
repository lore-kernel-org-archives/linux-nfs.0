Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:40341 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdLGUVC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Dec 2017 15:21:02 -0500
Received: by mail-pg0-f50.google.com with SMTP id k15so5239762pgr.7
        for <linux-nfs@vger.kernel.org>; Thu, 07 Dec 2017 12:21:02 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Non-root chown, NFSv4 ACLs
From: Drew Leske <drew.leske@computecanada.ca>
In-Reply-To: <027101d36f96$b16f3830$144da890$@mindspring.com>
Date: Thu, 7 Dec 2017 12:21:00 -0800
Cc: linux-nfs@vger.kernel.org
Message-Id: <DF7ABD6D-2C40-4536-8CF6-67A3225E29BC@computecanada.ca>
References: <DEC3CF38-E451-4E22-B904-DCD35188F000@computecanada.ca> <027101d36f96$b16f3830$144da890$@mindspring.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> A possible workaround is to have the software call an SUID copy of =
`chown`
>> that is only available to the user ID of the web service, but this is =
less
>> desirable.
>=20
> I think this may be your only solution. NFS/RPC has no way to =
communicate permission CAPs to the server.
>=20
> If CAPs could be user based as well as process based, then you could =
grant the web service's user ID the appropriate CAPs on the server.
>=20
> NFS v4 ACLs could help, however, they are imperfect since a file owner =
could remove the ACE that allows the web service's user ID to change =
ownership.

Frank, thanks for your response.  On the CAPs, I figured as much, but =
wondered if there was a way to assign the capability on the server=E2=80=94=
but I believe it=E2=80=99s only process-based, so I=E2=80=99d have to =
assign it to nfsd.  However nfsd runs as root and so already has the =
capability.  So in essence it seems NFS is the gatekeeper here, a =
thought which appears to be borne out by the traffic I=E2=80=99m seeing =
via `nfstrace`=E2=80=94NFS server returns a permissions error to the =
client.  So I wonder how to make the NFS server be okay with that user =
changing the ownership of files?

You are right about the file owners being able to remove the ACE however =
in this particular context the users would not have this ability via the =
web service, and when mounting the filesystem themselves would probably =
not have access to the commands, or know how to use them, or want to; =
and in any case would be warned against doing so.

Drew.=
