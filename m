Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from thunk.org ([69.25.196.29]:55819 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757452Ab0GWBWM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 21:22:12 -0400
Date: Thu, 22 Jul 2010 21:21:30 -0400
From: "Ted Ts'o" <tytso@mit.edu>
To: tridge@samba.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Jeremy Allison <jra@samba.org>, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, Volker.Lendecke@sernet.de,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        Jan Engelhardt <jengelh@medozas.de>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
 extended file stats available [ver #6]
Message-ID: <20100723012130.GD16373@thunk.org>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
 <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
 <30448.1279800887@redhat.com>
 <E1Obuiy-00C9jr-Al@intern.SerNet.DE>
 <AANLkTikBCXK6uEwWq4f0LvpdoKCPs3jvyFa4Zw4e2J_7@mail.gmail.com>
 <E1Obxpd-00CRIo-SF@intern.SerNet.DE>
 <AANLkTimwIq0pBhCeOjOVjB0yeM3JHOvzVoj9M4ui6al9@mail.gmail.com>
 <20100722162712.GB10352@jeremy-laptop>
 <AANLkTimdFCGSKLn7aGMpBMIauHTsHY7hpAAmpo6uTcnD@mail.gmail.com>
 <19528.60019.28495.655512@samba.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <19528.60019.28495.655512@samba.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 23, 2010 at 11:03:47AM +1000, tridge@samba.org wrote:
> 
> The other big difference from POSIX timestamps is that the
> CreationTime is settable on Windows, and some of the windows UI
> behaviour relies on this.

Well, not POSIX, because POSIX doesn't have CreationTime at all.
BSD's birthtime doesn't allow it to be set, and the question here is
largely philosophical.  Does it literally mean "file creation time" in
terms of when the OS created the file, or does it mean "file" in the
sense of application contents.  For example, if an application edits
the file and saves it out using "write file to foo.new; sync; rename
foo to foo.bak; rename foo.new to foo", should the creation time for
the newly written file "foo" be the time when the editor saved out the
file (i.e., when "foo.new" was created), or copied from the original
file "foo"'s creation time.

This is something (whether or not the application is allowed to set
the creation time) that I think makes sense to be either a filesystem
level mount option, or superblock tunable, or even a per-process
personality flag.

However, I think Linus's idea of using a per-process flag to control
whether or not "ctime" has the original POSIX semantics or some new
"creation time" semantics would lead to a huge amount of confusion.
Given that a number of new filesystems, including both ext4 and btrfs,
have creation time, it makes sense for us to have a fourth timestamp.
Whether or not our creation time is settable or not is a separate
question, and I don't think we need to follow BSD's lead on this.  If
GNOME and/or KDE applications start using it, I could see this
becoming that gets wide adoption fairly quickly.

						- Ted

