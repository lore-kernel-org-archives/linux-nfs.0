Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34928 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751639AbcLFFC5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2016 00:02:57 -0500
Date: Tue, 6 Dec 2016 05:02:54 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: Revalidate failure leads to unmount
Message-ID: <20161206050254.GM1555@ZenIV.linux.org.uk>
References: <37A073FB-726E-4AF8-BC61-0DFBA6C51BD7@linuxhacker.ru>
 <CA893F6B-6EC3-477C-B20B-0E74CAFEA53C@linuxhacker.ru>
 <5B453EA9-676D-4240-BF2F-4827188962E4@linuxhacker.ru>
 <20161206020059.GL1555@ZenIV.linux.org.uk>
 <02B48074-7E2E-4DB5-9A88-4FD4E37088FA@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <02B48074-7E2E-4DB5-9A88-4FD4E37088FA@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 05, 2016 at 09:22:47PM -0500, Oleg Drokin wrote:

> Retry? Not always, of course, but if it was EINTR, why not?
> Sure, it needs some more logic to actually propagate those codes, or perhaps
> revalidate itself needs to be smarter not to fail for such cases?
> Or is this something that you think should be wholly within filesystem
> and as such in this case it's just an nfs bug?

Umm...  Might be doable, but then there's a nasty question - what if that
happens from umount(2) itself?
 
> > Like what?  Seriously, what would you do in such situation?  Leave the
> > damn thing unreachable (and thus impossible to unmount)?  Suppose the
> > /mnt/foo really had been removed (along with everything under it) on
> > the server.  You had something mounted on /mnt/foo/bar/baz; what should
> > the kernel do?
> 
> Well, if *I* ended up in this situation, I'd probably just recreate the missing
> path and then then did umount (ESTALE galore?) ;)
> (or course there are other less sane approaches like pinning the whole path until
> unmount happens, but that's likely rife with a lot of other gotchas, but
> there's a limited version of this already - if I have /mnt/foo mountpoint
> and I delete /mnt/foo on the server, nobody would notice because we pin
> the foo part already and all accesses go to the filesystem mounted on top).

Try it...

> But sure, when stuff is really missing, unmounting the subtrees looks like a very
> sensible thing to do.
> It's just I suspect revalidate for a network filesystem is more than just
> "valid" and "invalid", there's a third option of "I don't know, ask me later"
> (because the server is busy, down for a moment or whatever) and there's
> at least some value in being able to interrupt a process that's stuck on a network
> mountpoint without killing the whole thing under it, no?

It's actually even more interesting - some form of delaying invalidation
might very well be a good thing, *if* we had a way to unhash the sucker
and have it fall through into lookup.  With invalidation happening only
if lookup has returned something other than the object we'd just unhashed.
Then e.g. NFS could bail out in all cases when it would have to talk to
server and let the regular lookups do the work.  However, right now that
only works for directories - for regular files we just get a new alias and
that's it.  If something had been bound on top of the old one, we would lose
it.  And turning that check into "new dentry is an alias of what we'd
unhashed" is a bad idea - it's already been hashed by us, so we'd have
a window when dcache lookup would've picked that new alias.

In that respect irregularities in Lustre become very interesting.  What if
we taught d_splice_alias() to look for _exact_ unhashed alias (same parent,
same name) in case of non-directories and did "rehash and return that
alias, dropping inode reference" if one has been found?  Could we get rid
of the weird dcache games in Lustre that way?
