Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:62907 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbaAOSZO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jan 2014 13:25:14 -0500
Received: by mail-qa0-f44.google.com with SMTP id w5so1219892qac.3
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jan 2014 10:25:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140115175723.GA4596@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
	<1389807296.16290.32.camel@tucsk.piliscsaba.szeredi.hu>
	<20140115175723.GA4596@fieldses.org>
Date: Wed, 15 Jan 2014 19:25:11 +0100
Message-ID: <CAJfpegs0+t4S1y9mhRMJMAERh-a95KjK_JQ7F5SRrfsNZOdoMA@mail.gmail.com>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
From: Miklos Szeredi <miklos@szeredi.hu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Miklos Szeredi <mszeredi@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 15, 2014 at 6:57 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Jan 15, 2014 at 06:34:56PM +0100, Miklos Szeredi wrote:
>> On Wed, 2014-01-15 at 10:17 -0500, J. Bruce Fields wrote:
>> > From: "J. Bruce Fields" <bfields@redhat.com>
>> >
>> > d_splice_alias can create duplicate directory aliases (in the !new
>> > case), or (in the new case) d_move without holding appropriate locks.
>>
>> It can d_move, because the dentry is known to be disconnected, i.e. it
>> doesn't have a parent for which we could obtain the lock.
>
> DCACHE_DISCONNECTED doesn't mean that.

You're right, but I'm also right, because __d_find_alias() will check
IS_ROOT() too.  So only "root" disconnected dentries will be moved.

>
> When you lookup a dentry by filehandle that dentry is initially marked
> DCACHE_DISCONNECTED.  It is cleared only after reconnect_path() has
> verified that the dentry is reachable all the way from the root.
>
> So !DCACHE_DISCONNECTED implies that the dentry is connected all the way
> up to the root, but the converse is not true.
>
> This has been a source of confusion, but it is explained in
> Documentation/filesystems/nfs/Exporting.  Recently I've cleaned up a few
> odd uses of DCACHE_DISCONNECTED and rewritten reconnect_path(), partly
> as an attempt to clarify the situation.
>
> Let me know if any of that doesn't look right to you....
>
>> > d_materialise_unique deals with both of these problems.  (The latter
>> > seems to be dealt by trylocks (see __d_unalias), which look like they
>> > could cause spurious lookup failures--but that's at least better tha
>> > corrupting the dcache.)
>> >
>> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>> > ---
>> >  fs/dcache.c |   25 +------------------------
>> >  1 file changed, 1 insertion(+), 24 deletions(-)
>> >
>> > Only lightly tested....  If this is right, then we can also just ditch
>> > d_splice_alias completely, and clean up the various d_find_alias's.
>> >
>> > I think the only reason we have both d_splice_alias and
>> > d_materialise_unique is that the former was written for exportable
>> > filesystems and the latter for distributed filesystems.
>> >
>> > But we have at least one exportable filesystem (fuse) using
>> > d_materialise_unique.  And I doubt d_splice_alias was ever completely
>> > correct even for on-disk filesystems.
>> >
>> > Am I missing some subtlety?
>>
>> One subtle difference is that for a non-directory d_splice_alias() will
>> reconnect a DCACHE_DISCONNECTED dentry if one exists, while
>> d_materialise_unique() will not.
>
> Actually until f80de2cde10350b8d146e375ff8b634e72e6a827 "dcache: don't
> clear DCACHE_DISCONNECTED too early", it was the reverse:
> d_materialise_unique cleared DISCONNECTED and d_splice_alias (correctly)
> did not.
>
> The only place where it should be cleared is reconnect_path().
>
>> Does this matter in practice?   The small number of extra dentries
>> probably does not matter.
>
> Directories are assumed to have unique aliases.  When they don't, the
> kernel can deadlock or crash.

What I meant is that d_materialise_unique() will currently not reuse
disconnected *nondirectory* dentries, hence there may be more aliases
than necessary.  This could easily be fixed, though.

Thanks,
Miklos


>
> --b.
