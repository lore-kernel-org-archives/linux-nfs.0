Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hr2.samba.org ([144.76.82.148]:43844 "EHLO hr2.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045AbcCWRCJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2016 13:02:09 -0400
Date: Wed, 23 Mar 2016 10:01:45 -0700
From: Jeremy Allison <jra@samba.org>
To: Steve French <smfrench@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Richard Sharpe <realrichardsharpe@gmail.com>,
        Richard Yao <ryao@gentoo.org>,
        Cedric Blancher <cedric.blancher@gmail.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: Making an interface for alternative data streams
Message-ID: <20160323170145.GB4807@jra3>
Reply-To: Jeremy Allison <jra@samba.org>
References: <CALXu0UdPyhBpOb-q-jpVN55d5unAQYXQFSm7HgNKWBH0Q_-gmg@mail.gmail.com>
 <20160322001255.GA2353@fieldses.org>
 <009F3E87-7919-4774-9129-72DB08F76553@gentoo.org>
 <56F0AC2A.30300@gentoo.org>
 <CACyXjPyYK0CggZNGfQQj6BBAfahU7PmVzwpzfeUqBannUTdhqA@mail.gmail.com>
 <20160322200801.GF4083@fieldses.org>
 <20160322214255.GA10921@jra3>
 <CAH2r5mtoYNrjkJ+zCbx7Mif9d-+-P_uBmdQNDwLA57wW6t7L6Q@mail.gmail.com>
 <CAH2r5murJ73bfoHWGTDPOBxud3E+rdzW00Snn-TZuc-iEtWgrw@mail.gmail.com>
 <CAH2r5muya2+hWQup99QcxKV9XE4T_pWW565+fqWeu1tAnXSxoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAH2r5muya2+hWQup99QcxKV9XE4T_pWW565+fqWeu1tAnXSxoQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 23, 2016 at 09:45:07AM -0500, Steve French wrote:
> One of the arguments in favor of additional interfaces (ioctl or
> openat) for accessing alternate data streams which may not be obvious
> to Windows users is that while alternate data streams can be opened
> just like regular files in Windows (and thus over SMB3 mounts), in
> Linux it is hard to allow opening a stream and still support files
> with the ':' (colon) character in their file name since colon is used
> a separator for the stream name in Windows (and is a reserved
> character), but is a valid character in POSIX.    When we use a cifs
> or smb3 mount to Windows or Mac we typically map characters (into the
> Unicode remap range just above 0xF000) like ':' the same way the Mac
> does (and Windows services for Mac does as well).  This is enabled
> with mount option "mapposix"
> 
> So without an ioctl to query the stream contents (or a new syscall),
> you have to choose whether to either allow : in a filename or allow
> opening streams.
> 
> There is some additional information on some of the more important
> uses in Windows for alternate data streams at the end of the article
> in this link: https://blogs.technet.microsoft.com/askcore/2013/03/24/alternate-data-streams-in-ntfs/

Sorry Steve, but none of the uses in there can be called "important".

I personally have an intense dislike for streams in a filesystem,
and was very disappointed when Microsoft re-added them to the
previously streamless ReFS (probably for backwards compatibility
stuff like this).

There's no way to transfer stream-riddled files over the Internet,
and the amount of code complexity we have in Samba having to deal
with them is nasty and has lead to more than one security hole in
the past.

Please don't add this to Linux.
