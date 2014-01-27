Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:33832 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753781AbaA0Ttw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 14:49:52 -0500
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Pavel Shilovsky'" <piastry@etersoft.ru>
Cc: "'Kernel Mailing List'" <linux-kernel@vger.kernel.org>,
        "'linux-cifs'" <linux-cifs@vger.kernel.org>,
        "'linux-fsdevel'" <linux-fsdevel@vger.kernel.org>,
        "'Linux NFS Mailing list'" <linux-nfs@vger.kernel.org>,
        <wine-devel@winehq.org>, <nfs-ganesha-devel@lists.sourceforge.net>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>	<051001cf13b4$080833b0$18189b10$@mindspring.com> <CAKywueTOi-WPpgH7x3VK7EkGJXE8fHUqcLgSUm6o6UA+uaQtjA@mail.gmail.com>
In-Reply-To: <CAKywueTOi-WPpgH7x3VK7EkGJXE8fHUqcLgSUm6o6UA+uaQtjA@mail.gmail.com>
Subject: RE: [PATCH v7 0/7] Add O_DENY* support for VFS and CIFS/NFS
Date: Mon, 27 Jan 2014 11:49:49 -0800
Message-ID: <02de01cf1b98$f115f240$d341d6c0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 2014/1/17 Frank Filz <ffilzlnx@mindspring.com>:
> > This looks wonderful and will be useful to the Ganesha user space NFS
> > server also.
> >
> > I do have a couple questions.
> >
> > 1. How will this interact with the idea of private locks from the
> > patch set Jeff Layton has been pushing?
> 
> They don't touch each other.
> 
> >
> > 2. If a process opens multiple file descriptors with deny modes, will
> > they conflict with each other (which is the behavior we will want for
> Ganesha).
> 
> Yes, a deny mode is associated with file descriptor - so, it will conflict
with any
> other access/deny modes of file descriptors from any process.
> 
> >
> > 3. Is there any functionality to upgrade or downgrade the access and
> > deny modes (thinking in terms of NFS v4 support of OPEN upgrade and
> > OPEN_DOWNGRADE operations).
> 
> The proposed patchset doesn't allow to change deny modes after an open is
> done. But we can add a functionality to let flock syscall change deny
modes
> as on option.

Yes, that would be good. NFS v4 allows upgrade/downgrade of acces/deny modes
(hmm, changing access mode would be trickier, but we need to be able to
upgrade/downgrade those as well as deny modes...). It could still be done
with an fcntl.  I don't know if any NFS clients make use of
upgrade/downgrade (I do know there are pynfs tests for it).

Interestingly, upgrade/downgrade would be a solution to Ganesha's problems
with POSIX locks being dumped on any file descriptor close since we could
change the access mode as needed rather than needing to close and open the
file.

Frank


