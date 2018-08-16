Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg1-f196.google.com ([209.85.215.196]:47000 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725971AbeHPVga (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2018 17:36:30 -0400
MIME-Version: 1.0
References: <153313703562.13253.5766498657900728120.stgit@warthog.procyon.org.uk>
 <17763.1534350685@warthog.procyon.org.uk> <87pnyiew8x.fsf@xmission.com>
 <CAH2r5muKOWBe9zMM8duNJ3rp1bzQh-mUj5zYoARO5pmc4de_+A@mail.gmail.com> <87tvnuz0ms.fsf@suse.com>
In-Reply-To: <87tvnuz0ms.fsf@suse.com>
From: Steve French <smfrench@gmail.com>
Date: Thu, 16 Aug 2018 13:36:13 -0500
Message-ID: <CAH2r5mvLSf2Cqdi9LwVre2MyiSh+7ZxGgRp_Am3D_090oFDCzw@mail.gmail.com>
Subject: Re: Should we split the network filesystem setup into two phases?
To: =?UTF-8?Q?Aur=C3=A9lien_Aptel?= <aaptel@suse.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Howells <dhowells@redhat.com>,
        trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>,
        Steve Dickson <steved@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        ebiederm@redhat.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
        CIFS <linux-cifs@vger.kernel.org>, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, v9fs-developer@lists.sourceforge.net
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 16, 2018 at 12:23 PM Aur=C3=A9lien Aptel <aaptel@suse.com> wrot=
e:
>
> Steve French <smfrench@gmail.com> writes:
> > In cifs we attempt to match new mounts to existing tree connections
> > (instances of connections to a \\server\share) from other mount(s)
> > based first on whether security settings match (e.g. are both
> > Kerberos) and then on whether encryption is on/off and whether this is
> > a snapshot mount (smb3 previous versions feature).  If neither is
> > mounted with a snaphsot and the encryption settings match then
> > we will use the same tree id to talk with the server as the other
> > mounts use.  Interesting idea to allow mount to force a new
> > tree id.
>
> We actually already have this mount option in cifs.ko, it's "nosharesock"=
.

Yes - good point.  It is very easy to do on cifs.  I mainly use that to sim=
ulate
multiple clients for testing servers (so each mount to the same server
whether or not the share matched, looks like a different client, coming
from a different socket and thus with different session ids and tree
ids as well).

It is very useful when trying to simulate multiple clients running to the s=
ame
server while using only one client machine (or VM).

> > What was the NFS mount option you were talking about?
> > Looking at the nfs man page the only one that looked similar
> > was "nosharecache"

The nfs man page apparently discourages its use:

"As of kernel 2.6.18, the behavior specified by nosharecache is legacy
caching behavior. This is  considered  a  data risk"


--=20
Thanks,

Steve
