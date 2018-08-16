Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:47274 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725969AbeHPUVW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2018 16:21:22 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Steve French <smfrench@gmail.com>
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
References: <153313703562.13253.5766498657900728120.stgit@warthog.procyon.org.uk>
        <17763.1534350685@warthog.procyon.org.uk>
        <87pnyiew8x.fsf@xmission.com>
        <CAH2r5muKOWBe9zMM8duNJ3rp1bzQh-mUj5zYoARO5pmc4de_+A@mail.gmail.com>
Date: Thu, 16 Aug 2018 12:21:23 -0500
In-Reply-To: <CAH2r5muKOWBe9zMM8duNJ3rp1bzQh-mUj5zYoARO5pmc4de_+A@mail.gmail.com>
        (Steve French's message of "Thu, 16 Aug 2018 11:24:56 -0500")
Message-ID: <87in4acjn0.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: Should we split the network filesystem setup into two phases?
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve French <smfrench@gmail.com> writes:

> On Thu, Aug 16, 2018 at 2:56 AM Eric W. Biederman <ebiederm@xmission.com> wrote:
>>
>> David Howells <dhowells@redhat.com> writes:
>>
>> > Having just re-ported NFS on top of the new mount API stuff, I find that I
>> > don't really like the idea of superblocks being separated by communication
>> > parameters - especially when it might seem reasonable to be able to adjust
>> > those parameters.
>> >
>> > Does it make sense to abstract out the remote peer and allow (a) that to be
>> > configured separately from any superblocks using it and (b) that to be used to
>> > create superblocks?
> <snip>
>> At least for devpts we always create a new filesystem instance every
>> time mount(2) is called.  NFS seems to have the option to create a new
>> filesystem instance every time mount(2) is called as well, (even if the
>> filesystem parameters are the same).  And depending on the case I can
>> see the attraction for other filesystems as well.
>>
>> So I don't think we can completely abandon the option for filesystems
>> to always create a new filesystem instance when mount(8) is called.
>
> In cifs we attempt to match new mounts to existing tree connections
> (instances of connections to a \\server\share) from other mount(s)
> based first on whether security settings match (e.g. are both
> Kerberos) and then on whether encryption is on/off and whether this is
> a snapshot mount (smb3 previous versions feature).  If neither is
> mounted with a snaphsot and the encryption settings match then
> we will use the same tree id to talk with the server as the other
> mounts use.  Interesting idea to allow mount to force a new
> tree id.
>
> What was the NFS mount option you were talking about?
> Looking at the nfs man page the only one that looked similar
> was "nosharecache"

I was remembering this from reading the nfs mount code:

static int nfs_compare_super(struct super_block *sb, void *data)
{
...
	if (!nfs_compare_super_address(old, server))
		return 0;
	/* Note: NFS_MOUNT_UNSHARED == NFS4_MOUNT_UNSHARED */
	if (old->flags & NFS_MOUNT_UNSHARED)
		return 0;
...
}

If a filesystem has NFS_MOUNT_UNSHARED set it does not serve as a
candidate for new mount requests.  Skimming the code it looks like
nosharecache is what sets NFS_MOUNT_UNSHARED.


Another interesting and common case is tmpfs which always creates a new
filesystem instance whenever it is mounted.

Eric
