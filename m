Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:61749 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756060Ab2DQNMK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2012 09:12:10 -0400
Received: by wgbdr13 with SMTP id dr13so6380286wgb.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 06:12:08 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pstaubach\@exagrid.com" <pstaubach@exagrid.com>,
        "viro\@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch\@infradead.org" <hch@infradead.org>,
        "michael.brantley\@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner\@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
	<20120416154322.0d95e435@corrin.poochiereds.net>
	<1334607906.2879.36.camel@lade.trondhjem.org>
	<20120416190548.2463d1d0@corrin.poochiereds.net>
Date: Tue, 17 Apr 2012 15:12:20 +0200
In-Reply-To: <20120416190548.2463d1d0@corrin.poochiereds.net> (Jeff Layton's
	message of "Mon, 16 Apr 2012 19:05:48 -0400")
Message-ID: <87sjg2o62z.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

>> 
>> Won't something like fstatat(AT_FDCWD, "", &stat, AT_EMPTY_PATH) risk
>> looping forever there, or am I missing something?
>> 
>
> To make sure I understand, that should be "shortcut" for a lookup of the
> cwd?
>
> So I guess the concern is that you'd do the above and get a successful
> lookup since you're just going to get back the cwd. At that point,
> you'd attempt the getattr and get ESTALE back. Then, you'd redo the
> lookup with LOOKUP_REVAL set -- but since we're operating on the
> cwd, we don't have a way to redo the lookup since we don't have a
> pathname that we can look up again...
>
> So yeah, I guess if you're sitting in a stale directory, something like
> that could loop eternally.
>
> Do you think the proposed check for fatal_signal_pending is enough to
> mitigate such a problem? Or do we need to limit the number of retries
> to address those sorts of loops?

Lets step back a bit.

The retry is needed when when we discover during ->getattr() that the
cached lookup returned a stale file handle.

If the lookup wasn't cached or if there was no lookup at all
(stat(".") and friends) then retrying will not gain anything.

And that also means that retrying multiple times is pointless, since
after the first retry we are sure to have up-to-date attributes.

Unfortunately it's impossible for the filesystem to know whether a
->getattr (or other inode operation) was perfromed after a cached or a
non-cached lookup.

I'm not sure what the right interface for this would be.  One would be
to just pass the "cached-or-not" information as a flag.  That works for
getattr() but not for other operations.

Another is to introduce atomic lookup+foo variants of these operations
just like for open.  E.g. the lookup+getattr is called if the cached
lookup fails or if the cached lookup succeeds and the plain ->getattr
call returns ESTALE.

Thanks,
Miklos
