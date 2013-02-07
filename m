Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40482 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758124Ab3BGOSf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 09:18:35 -0500
Date: Thu, 7 Feb 2013 09:18:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v2 3/8] vfs: Add O_DENYREAD/WRITE flags support for open
 syscall
Message-ID: <20130207141832.GA3222@fieldses.org>
References: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
 <1358441584-8783-3-git-send-email-piastry@etersoft.ru>
 <20130130221602.GC15584@fieldses.org>
 <CAKywueRh++TBazK8_kRN7AUb=EFhGv=Sv2CV0BESkfLFy+g5wA@mail.gmail.com>
 <20130205143514.GA9886@fieldses.org>
 <CAKywueS6oGNu9r_bypu32A89pOoiGb47kjXqw2ZcZQhZK+JV3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKywueS6oGNu9r_bypu32A89pOoiGb47kjXqw2ZcZQhZK+JV3g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 07, 2013 at 01:53:46PM +0400, Pavel Shilovsky wrote:
> 2013/2/5 J. Bruce Fields <bfields@fieldses.org>:
> > On Tue, Feb 05, 2013 at 03:45:31PM +0400, Pavel Shilovsky wrote:
> >> 2013/1/31 J. Bruce Fields <bfields@fieldses.org>:
> >> > On Thu, Jan 17, 2013 at 08:52:59PM +0400, Pavel Shilovsky wrote:
> >> >> If O_DENYMAND flag is specified, O_DENYREAD/WRITE/MAND flags are
> >> >> translated to flock's flags:
> >> >>
> >> >> !O_DENYREAD  -> LOCK_READ
> >> >> !O_DENYWRITE -> LOCK_WRITE
> >> >> O_DENYMAND   -> LOCK_MAND
> >> >>
> >> >> and set through flock_lock_file on a file.
> >> >>
> >> >> This change only affects opens that use O_DENYMAND flag - all other
> >> >> native Linux opens don't care about these flags. It allow us to
> >> >> enable this feature for applications that need it (e.g. NFS and
> >> >> Samba servers that export the same directory for Windows clients,
> >> >> or Wine applications that access the same files simultaneously).
> >> >
> >> > The use of an is_conflict callback seems unnecessarily convoluted.
> >> >
> >> > If we need two different behaviors, let's just use another flag (or an
> >> > extra boolean argument if we need to, or something).
> >>
> >> Ok, we can pass "bool is_mand" to flock_lock_file that will pass it
> >> further to flock_locks_conflict.
> >>
> >> >
> >> > The only caller for this new deny_lock_file is in the nfs code--I'm a
> >> > little unclear why that is.
> >>
> >> deny_lock_file is called not only in the nfs code but also in 2 places
> >> of fs/namei.c -- that enable this logic for VFS.
> >
> > Oops, apologies, I overlooked those somehow.
> >
> > What prevents somebody else from grabbing a lock on a newly-created file
> > before we grab our own lock?
> >
> > I couldn't tell on a quick look whether we hold some lock that prevents
> > that.
> 
> Nothing prevents it. If somebody grabbed a share mode lock on a file
> before we call deny_lock_file, we simply close this file and return
> -ETXTBSY.

But leave the newly-created file there--ugh.

> We can't grab it before atomic_open because we don't have an
> inode there.

If you can get the lock while still holding the directory i_mutex can't
you prevent anyone else from looking up the new file until you've gotten
the lock?

--b.

> Anyway, we can't make it atomic for VFS without big code
> changes, but for CIFS and NFS it is already atomic with the discussed
> patch.
