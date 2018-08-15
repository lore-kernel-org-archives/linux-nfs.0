Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf1-f175.google.com ([209.85.210.175]:45326 "EHLO
        mail-pf1-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729562AbeHOToe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Aug 2018 15:44:34 -0400
Received: by mail-pf1-f175.google.com with SMTP id i26-v6so727387pfo.12
        for <linux-nfs@vger.kernel.org>; Wed, 15 Aug 2018 09:51:39 -0700 (PDT)
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: Should we split the network filesystem setup into two phases?
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <17763.1534350685@warthog.procyon.org.uk>
Date: Wed, 15 Aug 2018 09:51:36 -0700
Cc: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        sfrench@samba.org, steved@redhat.com, viro@zeniv.linux.org.uk,
        torvalds@linux-foundation.org,
        "Eric W. Biederman" <ebiederm@redhat.com>,
        linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net
Message-Id: <DCE0E619-68F8-4906-8062-68D63DDED665@amacapital.net>
References: <153313703562.13253.5766498657900728120.stgit@warthog.procyon.org.uk> <17763.1534350685@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 15, 2018, at 9:31 AM, David Howells <dhowells@redhat.com> wrote:
>=20
> Having just re-ported NFS on top of the new mount API stuff, I find that I=

> don't really like the idea of superblocks being separated by communication=

> parameters - especially when it might seem reasonable to be able to adjust=

> those parameters.
>=20
> Does it make sense to abstract out the remote peer and allow (a) that to b=
e
> configured separately from any superblocks using it and (b) that to be use=
d to
> create superblocks?
>=20
> Note that what a 'remote peer' is would be different for different
> filesystems:

...

I think this looks rather nice.  But maybe you should generalize the concept=
 of =E2=80=9Cpeer=E2=80=9D so that it works for btrfs too. In the case where=
 you mount two different subvolumes, you=E2=80=99re creating a *something*, a=
nd you=E2=80=99re then creating a filesystem that references it. It=E2=80=99=
s almost the same thing.

>=20
>=20


>=20
>    fs =3D fsopen("nfs", 0);
>    fsconfig(fs, FSCONFIG_SET_PEER, "peer.1", NULL, peer1);

As you mention below, this seems like it might have namespacing issues.

>    =20

> In terms of alternative interfaces, I'm not sure how easy it would be to m=
ake
> it like cgroups where you go and create a dir in a special filesystem, say=
,
> "/sys/peers/nfs", because the peers records and names would have to be net=
work
> namespaced.  Also, it might make it more difficult to use to create a root=
 fs.
>=20
> On the other hand, being able to adjust the peer configuration by:
>=20
>    echo 71 >/sys/peers/nfs/server.home/timeo
>=20
> does have a certain appeal.
>=20
> Also, netlink might be the right option, but I'm not sure how you'd pin th=
e
> resultant object whilst you make use of it.
>=20

My suggestion would be to avoid giving these things names at all. I think th=
at referring to them by fd should be sufficient, especially if you allow the=
m to be reopened based on a mount that uses them and allow them to get bind-=
mounted somewhere a la namespaces to make them permanent if needed.

> A further thought is that is it worth making this idea more general and
> encompassing non-network devices also?  This would run into issues of some=

> logical sources being visible across namespaces and but not others.

Indeed :)

It probably pays to rope a btrfs person into this discussion.
