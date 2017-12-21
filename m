Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:37004 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755824AbdLUA5a (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 19:57:30 -0500
MIME-Version: 1.0
In-Reply-To: <87y3lxj9wr.fsf@notabene.neil.brown.name>
References: <87y3lxj9wr.fsf@notabene.neil.brown.name>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 20 Dec 2017 16:57:28 -0800
Message-ID: <CA+55aFw98_-SRszjy4dh97VhnZeOMpcVVzS8Mvew2b9juYDTmg@mail.gmail.com>
Subject: Re: [PATCH/RFC] VFS: don't keep disconnected dentries on d_anon
To: NeilBrown <neilb@suse.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 20, 2017 at 2:45 PM, NeilBrown <neilb@suse.com> wrote:
>
> We could just leave the code unchanged, but apart from that being
> potentially confusing, the (unfair) bit-spin-lock which protects
> s_anon can become a bottle neck when lots of disconnected dentries are
> being created.
>
> So this patch renames s_anon to s_roots, and stops storing
> disconnected dentries on the list.  Only dentries obtained with
> d_obtain_root() are now stored on this list.  There are many fewer of
> these (only NFS and NILFS2 use the call, and only during filesystem
> mount) so contention on the bit-lock will not be a problem.

Thanks, Neil. This is much nicer than the magical special case patch
for s_anon bitlock.

Al, I'm going to assume I'll get this through your vfs tree (with
whatever edits from the comments people made).

                Linus
