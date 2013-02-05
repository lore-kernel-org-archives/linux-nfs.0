Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43645 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754354Ab3BEOiT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2013 09:38:19 -0500
Date: Tue, 5 Feb 2013 09:38:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v2 0/8] Add O_DENY* support for VFS and CIFS/NFS
Message-ID: <20130205143813.GB9886@fieldses.org>
References: <1358441537-8672-1-git-send-email-piastry@etersoft.ru>
 <20130130221118.GB15584@fieldses.org>
 <CAKywueQcia1jJfdVJFzfHdc5zQ_86r3T4bmee9cpP18qqbcLFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKywueQcia1jJfdVJFzfHdc5zQ_86r3T4bmee9cpP18qqbcLFA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 05, 2013 at 03:33:21PM +0400, Pavel Shilovsky wrote:
> 2013/1/31 J. Bruce Fields <bfields@fieldses.org>:
> > On Thu, Jan 17, 2013 at 08:52:09PM +0400, Pavel Shilovsky wrote:
> >> This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanis, but that approach is non-atomic. This patchset build new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.
> >>
> >> These flags can be used by NFS (built-in-kernel) and CIFS (Samba) servers and Wine applications through VFS (for local filesystems) or CIFS/NFS modules. This will help when e.g. Samba and NFS server share the same directory for Windows and Linux users or Wine applications use Samba/NFS share to access the same data from different clients.
> >>
> >> According to the previous discussions the most problematic question is how to prevent situations like DoS attacks where e.g /lib/liba.so file can be open with DENYREAD, or smth like this. That's why one extra flag O_DENYMAND is added. It indicates to underlying layer that an application want to use O_DENY* flags semantic. It allows us not affect native Linux applications (that don't use O_DENYMAND flag) - so, these flags (and the semantic of open syscall that they bring) are used only for those applications that really want it proccessed that way.
> >
> > Maybe that's good enough.  A mount flag might be simpler and give
> > consistent enforcement for all users.
> >
> >>
> >> So, we have four new flags:
> >> O_DENYREAD - to prevent other opens with read access,
> >> O_DENYWRITE - to prevent other opens with write access,
> >> O_DENYDELETE - to prevent delete operations (this flag is not implemented in VFS and NFS part and only suitable for CIFS module),
> >> O_DENYMAND - to switch on/off three flags above.
> >
> > It would be useful to have some really careful documentation of how
> > these are meant to work.  Maybe try updating the open man page?
> 
> Yes, that's a good idea. Do you mean smth like this?
> 
> O_DENYMAND - used to inforce a mandatory share reservation scheme of
> the file access. If this flag is passed,
> the open fails with -ETXTBSY in following cases:
> 
> 1) if O_DENYREAD flag is specified and there is another open with
> O_DENYMAND flag and READ access to the file;
> 2) if O_DENYWRITE flag is specified and there is another open with
> O_DENYMAND flag and WRITE access to the file;
> 3) if READ access is requested and there is another open with
> O_DENYMAND and O_DENYREAD flags;
> 4) if WRITE access is requested and there is another open with
> O_DENYMAND and O_DENYWRITE flags;
> 
> Also, if O_DENYDELETE flag is specified and the open succeded, any
> further unlink operation will fail with -ETXTBSY untill this open is
> closed. Now this flag is processed by CIFS filesystems only.

Do you need to document interactions with flock() as well?

--b.
