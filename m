Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:32903 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754675Ab2DQQCG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2012 12:02:06 -0400
Received: by wejx9 with SMTP id x9so4134039wej.19
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 09:02:05 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>,
        "Myklebust\, Trond" <Trond.Myklebust@netapp.com>,
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
References: <4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
	<20120416154322.0d95e435@corrin.poochiereds.net>
	<1334607906.2879.36.camel@lade.trondhjem.org>
	<20120416190548.2463d1d0@corrin.poochiereds.net>
	<87sjg2o62z.fsf@tucsk.pomaz.szeredi.hu>
	<20120417093222.2ff5e1bd@corrin.poochiereds.net>
	<1334671473.2963.27.camel@lade.trondhjem.org.localdomain>
	<20120417102035.2236e553@corrin.poochiereds.net>
	<20120417154549.GA27426@fieldses.org>
Date: Tue, 17 Apr 2012 18:02:13 +0200
In-Reply-To: <20120417154549.GA27426@fieldses.org> (J. Bruce Fields's message
	of "Tue, 17 Apr 2012 11:45:49 -0400")
Message-ID: <8762cyny7u.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Tue, Apr 17, 2012 at 10:20:35AM -0400, Jeff Layton wrote:
>> Well, it's possible, but it seems pathological to me for a server to do
>> that...
>> 
>> Bruce and I were discussing this the other day. It would be good to add
>> something like this to the RFCs:
>> 
>> "On a PUTFH, a server SHOULD hold a reference to the filehandle such
>
> For "filehandle" I'd specify "current and saved filehandle".
>
>> that it does not go stale over the life of the compound."
>
> And that's *much* less of a burden on the server than requiring that the
> compound execute atomically.
>
>> ...or something along those lines. That's a different matter though and
>> not directly related to this. :)
>
> Yes.

It's only related, because it proves that it's theoretically possible to
deal with this problem without introducing infinite retries.  And that
applies to all operations, not just getattr.

As for atomicity, the VFS doesn't have any atomicity guarantees here
either.  So for example getattr("foo") may end up with st_nlink == 0
with a concurrent rename("bar", "foo").  Whether this is permitted by
the standards is another matter, but it's not something that appears to
bother anybody.

Thanks,
Miklos
