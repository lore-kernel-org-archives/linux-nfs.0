Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33894 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdLUFkK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Dec 2017 00:40:10 -0500
Date: Thu, 21 Dec 2017 05:40:00 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: NeilBrown <neilb@suse.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] VFS: don't keep disconnected dentries on d_anon
Message-ID: <20171221054000.GX21978@ZenIV.linux.org.uk>
References: <87y3lxj9wr.fsf@notabene.neil.brown.name>
 <CA+55aFw98_-SRszjy4dh97VhnZeOMpcVVzS8Mvew2b9juYDTmg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFw98_-SRszjy4dh97VhnZeOMpcVVzS8Mvew2b9juYDTmg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 20, 2017 at 04:57:28PM -0800, Linus Torvalds wrote:
> On Wed, Dec 20, 2017 at 2:45 PM, NeilBrown <neilb@suse.com> wrote:
> >
> > We could just leave the code unchanged, but apart from that being
> > potentially confusing, the (unfair) bit-spin-lock which protects
> > s_anon can become a bottle neck when lots of disconnected dentries are
> > being created.
> >
> > So this patch renames s_anon to s_roots, and stops storing
> > disconnected dentries on the list.  Only dentries obtained with
> > d_obtain_root() are now stored on this list.  There are many fewer of
> > these (only NFS and NILFS2 use the call, and only during filesystem
> > mount) so contention on the bit-lock will not be a problem.
> 
> Thanks, Neil. This is much nicer than the magical special case patch
> for s_anon bitlock.
> 
> Al, I'm going to assume I'll get this through your vfs tree (with
> whatever edits from the comments people made).

*nod*

I've got sidetracked digging through the Lustre mess with dcache (revalidation
stuff, again), will finish once I get some sleep.  In any case, I like that
variant; it's definitely going to be applied.
