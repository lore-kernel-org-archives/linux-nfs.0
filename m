Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35352 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751133AbdKIUsA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 15:48:00 -0500
Date: Thu, 9 Nov 2017 15:47:58 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
Message-ID: <20171109204757.GB11619@parsley.fieldses.org>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 08, 2017 at 06:40:22PM -0800, Linus Torvalds wrote:
> Anyway, that cmovne noise makes it a bit hard to see the actual part
> that matters (and that traps) but I'm almost certain that it's the
> "mnt->mnt_sb->s_flags" loading that is part of calculate_f_flags()
> when it then does
> 
>      flags_by_sb(mnt->mnt_sb->s_flags);
> 
> and I think mnt->mnt_sb is NULL. We know it's not 'mnt' itself that is
> NULL, because we wouldn't have gotten this far if it was.
> 
> Now, afaik, mnt->mnt_sb should never be NULL in the first place for a
> proper path. And the vfs_statfs() code itself hasn't changed in a
> while.
> 
> Which does seem to implicate nfsd as having passed in a bad path to
> vfs_statfs(). But I'm not seeing any changes in nfsd either.
> 
> In particular, there are *no* nfsd changes in that 4.13.8..4.13.11
> range. There is a bunch of xfs changes, though. What's the underlying
> filesystem that you are exporting?
> 
> But bringing in Al Viro and Bruce Fields explicitly in case they see
> something. And Darrick, just in case it might be xfs.

Looking at https://lkml.org/lkml/2017/11/8/1086 for the actual oops...

It doesn't remind me of any known issue.

And I don't see how we can call vfs_statfs() with a bad path:
nfsd4_encode_getattr would have to have been called with nfserr 0 and
ga_fhp->fh_export bad.

Looking at nfsd4_proc_compound, I can't see how we could get there in
the op->status == 0 case without the fh_verify() in nfsd4_getattr having
succeeded and assigned the result to ga_fhp.

So either I'm overlooking something or the bug's elsewhere.

It sounds like you're varying *only* the server version, so there's not
much chance that this could be triggered by changes in client behavior?

--b.
