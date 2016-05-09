Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:64481 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbcEINJZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2016 09:09:25 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Steve French <smfrench@gmail.com>
Cc: David Howells <dhowells@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-afs@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        Deepa Dinamani <deepa.kernel@gmail.com>
Subject: Re: [RFC][PATCH 0/6] Enhanced file stat system call
Date: Mon, 09 May 2016 15:09:04 +0200
Message-ID: <4211584.odaTcq8sN6@wuerfel>
In-Reply-To: <CAH2r5muL336k178DJHxKByfbGMMc=_m5jsCctgRQCc1H+SRSQg@mail.gmail.com>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <CAH2r5mvWHwmqkzyfjHro__dWf-9ZAskPHgHDGS22jNzXZVQ4iA@mail.gmail.com> <CAH2r5muL336k178DJHxKByfbGMMc=_m5jsCctgRQCc1H+SRSQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday 05 May 2016 21:00:18 Steve French wrote:
> On Thu, May 5, 2016 at 5:54 PM, Steve French <smfrench@gmail.com> wrote:
> > On Wed, May 4, 2016 at 8:46 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> >> On Friday 29 April 2016 13:57:36 David Howells wrote:
> >>> struct statx *buffer);
> >>>
> >>> This is an enhanced file stat function that provides a number of useful
> >>> features, in summary:
> >>>
> >>> (1) More information: creation time, data version number, inode
> >>> generation
> >>> number and flags. A subset of these is available through a number of
> >>> filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).
> >>>
> >>
> >> I have a question about birthtime/creationtime: As we are gaining a way
> >> to read this, should we also provide a way to update it using a new
> >> variant
> >> of the utimensat syscall in order to have 'cp -a' create an identical
> >> copy,
> >> or is the idea that this is defined as the time that is particular copy
> >> of the inode was created?
> >>
> >> I've discussed this with Deepa in the past, as she is driving the
> >> convertion of the inode timestamps to timespec64 now, and we will
> >> need a new version of utimensat for her work as well. I can see good
> >> reasons either way (allowing updates of btime or disallowing them).
> >
> It would help interop with Windows (and presumably Mac) if birth time can be
> updated

Ok, thanks. That is certainly a good reason in favor.

If nothing else comes up, I guess we can prepare a patch for a new
utimensat variant to do this and wait for more comments on that.

	Arnd
