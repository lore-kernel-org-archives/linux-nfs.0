Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43657 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754866Ab3LCUsJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Dec 2013 15:48:09 -0500
Date: Tue, 3 Dec 2013 15:48:06 -0500
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Antti =?utf-8?B?VMO2bmt5csOk?= <daedalus@pingtimeout.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
Message-ID: <20131203204806.GA2648@fieldses.org>
References: <529CEBC3.8060505@pingtimeout.net>
 <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com>
 <529CF322.4080701@pingtimeout.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <529CF322.4080701@pingtimeout.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 02, 2013 at 10:52:50PM +0200, Antti Tönkyrä wrote:
> On 2013-12-02 22:45, Trond Myklebust wrote:
> >On Dec 2, 2013, at 15:21, Antti Tönkyrä <daedalus@pingtimeout.net> wrote:
> >
> >>Hello,
> >>
> >>NTFS file system and some other filesystems seem to return EILSEQ when user passes badly formatted data. Current NFSv4 implementation does not map EILSEQ into any known NFSv4 error code which causes problems in some use cases. In my case I observed that if filesystem returns EILSEQ, the NFS share will begin I/O erroring until it's able to recover (If there are handles open to the files in the share, I/O errors will continue until they are closed after which the share recovers after small period of time).

So how exactly does that happen?  I'd expect an error on open or lookup
to prevent the client from ever getting a filehandle in the first place.

Looking back at https://bugzilla.kernel.org/attachment.cgi?id=116211 ...

OK, it makes sense that touching a file with a bad name would get an
error, but you're seeing that cause later creates of files on the same
filesystem fail.  I can't figure out why that would happen.

Could we see a network trace showing that happen?

Would also be nice to confirm whether this is reproduceable with
something other than ZFS.

--b.

> >>
> >>Given that widely used ntfs-3g FUSE module also returns EILSEQ on the same case (I tested this) I would argue that a fix should be done for upstream especially since RFC5661 clearly defines that invalid UTF-8 sequence should map into NFSERR_INVAL, exact quote: "Where the client sends an invalid UTF-8 string, the server should return NFS4ERR_INVAL (see Table 5)".
> >The NFS client will then happily map that straight into EINVAL for you...
> >
> >Cheers,
> >   Trond
> Hello,
> 
> But if we get a (somewhat) sane error back, we'd avoid the whole NFS
> share dying in I/O errors because someone decided to touch a file
> with his terminal having wrong charset (if I understood this
> correctly). The problem here is that we don't simply get one I/O
> error from the offending file, but rather that the whole share dies
> after EILSEQ is returned from the backing filesystem.
