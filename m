Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36904 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbcCWPQL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2016 11:16:11 -0400
Date: Wed, 23 Mar 2016 11:16:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve French <smfrench@gmail.com>
Cc: Jeremy Allison <jra@samba.org>,
        Richard Sharpe <realrichardsharpe@gmail.com>,
        Richard Yao <ryao@gentoo.org>,
        Cedric Blancher <cedric.blancher@gmail.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160323151608.GA13177@fieldses.org>
References: <20160321223627.GA12999@thunk.org>
 <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com>
 <20160322001255.GA2353@fieldses.org>
 <009F3E87-7919-4774-9129-72DB08F76553@gentoo.org>
 <56F0AC2A.30300@gentoo.org>
 <CACyXjPyYK0CggZNGfQQj6BBAfahU7PmVzwpzfeUqBannUTdhqA@mail.gmail.com>
 <20160322200801.GF4083@fieldses.org>
 <20160322214255.GA10921@jra3>
 <CAH2r5mtoYNrjkJ+zCbx7Mif9d-+-P_uBmdQNDwLA57wW6t7L6Q@mail.gmail.com>
 <CAH2r5murJ73bfoHWGTDPOBxud3E+rdzW00Snn-TZuc-iEtWgrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAH2r5murJ73bfoHWGTDPOBxud3E+rdzW00Snn-TZuc-iEtWgrw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 22, 2016 at 11:19:51PM -0500, Steve French wrote:
> On Tue, Mar 22, 2016 at 11:13 PM, Steve French <smfrench@gmail.com> wrote:
> > Yes, the browser still uses it (at least on the system I tried
> > yesterday), and so do a few important subsystems (the file resource
> > manager for example).  Presumably streams are used even more on Mac.
> >
> > I was experimenting with some patches in the last few weeks to list
> > streams (either via an xattr as ntfs-3g does, but I am leaning toward
> > an ioctl for cifs.ko).  They are needed for backup (at least), and not
> > just for accessing Macs (which use resource forks extensively), but
> > since Windows stores the zone identifier (where a file came from is
> > stored when internet explorer downloads anything) in an alternate data
> > stream, and also "FCI" (file classification information) is stored
> > there.

Sounds like there are important user, then.

> I should also note that since SMB3 operations are handle based
> (except open/create itself), I prefer using an ioctl rather than xattr
> query to list streams.

So on Linux you'd want that ioctl to return a file descriptor for a
given stream?

> In addition, by overlapping the alternate
> data stream name space, with the EAs name space they are
> harder to tell apart (xattrs are used less frequently on Windows
> than in the past but they do show up from time to time,
> e.g. in their Services for Unix).  Seems wrong to make it easy
> to confuse streams and EAs (extended attributes).

Sounds like everyone's agreed that the two should be kept distinct.

--b.
