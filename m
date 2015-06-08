Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34094 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753458AbbFHUtD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 16:49:03 -0400
Received: by oigz2 with SMTP id z2so38441213oig.1
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jun 2015 13:49:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150608151704.GF24159@fieldses.org>
References: <20150604195725.GC5209@fieldses.org>
	<1445478.RRUV9J93hm@sifl>
	<20150608151704.GF24159@fieldses.org>
Date: Mon, 8 Jun 2015 16:49:02 -0400
Message-ID: <CAHC9VhR2D6Gy31L0N8oPTwyz1+s-ACEr6MNiDZ=j6aMBXo_u+w@mail.gmail.com>
Subject: Re: [PATCH] selinux: fix setting of security labels on NFS
From: Paul Moore <paul@paul-moore.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>,
        selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org,
        Richard Chan <rc556677@outlook.com>,
        David Quigley <dpquigl@davequigley.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 8, 2015 at 11:17 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Jun 05, 2015 at 02:28:51PM -0400, Paul Moore wrote:
>> On Thursday, June 04, 2015 03:57:25 PM J. Bruce Fields wrote:
>> > From: "J. Bruce Fields" <bfields@redhat.com>
>> >
>> > Before calling into the filesystem, vfs_setxattr calls
>> > security_inode_setxattr, which ends up calling selinux_inode_setxattr in
>> > our case.  That returns -EOPNOTSUPP whenever SBLABEL_MNT is not set.
>> > SBLABEL_MNT was supposed to be set by sb_finish_set_opts, which sets it
>> > only if selinux_is_sblabel_mnt returns true.
>> >
>> > The selinux_is_sblabel_mnt logic was broken by eadcabc697e9 "SELinux: do
>> > all flags twiddling in one place", which didn't take into the account
>> > the SECURITY_FS_USE_NATIVE behavior that had been introduced for nfs
>> > with eb9ae686507b "SELinux: Add new labeling type native labels".
>> >
>> > This caused setxattr's of security labels over NFSv4.2 to fail.
>> >
>> > Cc: stable@kernel.org
>> > Cc: Eric Paris <eparis@redhat.com>
>> > Cc: David Quigley <dpquigl@davequigley.com>
>> > Reported-by: Richard Chan <rc556677@outlook.com>
>> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>> > ---
>> >  security/selinux/hooks.c | 1 +
>> >  1 file changed, 1 insertion(+)
>>
>> Applied, thanks.
>
> Thanks!
>
>> In the future, you don't have to worry about marking it for
>> stable, I'll take care of that when I merge it into the tree.
>
> OK.  With roles reversed, I usually appreciate the stable tag from
> submitters, just as a statement of their opinion as to whether it's
> stable-worthy, which can always be overridden.

Every subsystem is different, but in general I haven't found it too
difficult to determine if a given patch is stable worthy; on the rare
occasion that I'm uncertain I'll ask the submitter for their opinion.
I wouldn't say I discourage people from adding a stable tag, it is
just that I don't require people to add one to make it into my stable
queue, and I don't automatically add it to the queue if the poster
does tag it so (although that said, I don't recall ever removing a
stable CC).

> (I mean, this one seems obvious enough--one-liner, fixes a user-visible
> regression--but in more complicated cases their opinion might be
> useful.)

This patch is definitely a stable no-brainer.

> By the way, I suspect this requires (obvious) fixups to apply to some
> older kernels, let me know if help's needed there.

It may, I generally wait until the stable devs pick it up and if they
hit a merge conflict I fix it up, however, since you offered I may
kick it your way ;)

-- 
paul moore
www.paul-moore.com
