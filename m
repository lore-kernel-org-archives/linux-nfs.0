Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52196 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728378AbeHPUXO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Aug 2018 16:23:14 -0400
From: =?utf-8?Q?Aur=C3=A9lien?= Aptel <aaptel@suse.com>
To: Steve French <smfrench@gmail.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Howells <dhowells@redhat.com>,
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
Subject: Re: Should we split the network filesystem setup into two phases?
In-Reply-To: <CAH2r5muKOWBe9zMM8duNJ3rp1bzQh-mUj5zYoARO5pmc4de_+A@mail.gmail.com>
References: <153313703562.13253.5766498657900728120.stgit@warthog.procyon.org.uk> <17763.1534350685@warthog.procyon.org.uk> <87pnyiew8x.fsf@xmission.com> <CAH2r5muKOWBe9zMM8duNJ3rp1bzQh-mUj5zYoARO5pmc4de_+A@mail.gmail.com>
Date: Thu, 16 Aug 2018 19:23:23 +0200
Message-ID: <87tvnuz0ms.fsf@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve French <smfrench@gmail.com> writes:
> In cifs we attempt to match new mounts to existing tree connections
> (instances of connections to a \\server\share) from other mount(s)
> based first on whether security settings match (e.g. are both
> Kerberos) and then on whether encryption is on/off and whether this is
> a snapshot mount (smb3 previous versions feature).  If neither is
> mounted with a snaphsot and the encryption settings match then
> we will use the same tree id to talk with the server as the other
> mounts use.  Interesting idea to allow mount to force a new
> tree id.

We actually already have this mount option in cifs.ko, it's "nosharesock".

> What was the NFS mount option you were talking about?
> Looking at the nfs man page the only one that looked similar
> was "nosharecache"

Cheers,
-- 
Aurélien Aptel / SUSE Labs Samba Team
GPG: 1839 CB5F 9F5B FB9B AA97  8C99 03C8 A49B 521B D5D3
SUSE Linux GmbH, Maxfeldstraße 5, 90409 Nürnberg, Germany
GF: Felix Imendörffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nürnberg)
