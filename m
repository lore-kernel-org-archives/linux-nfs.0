Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51611 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755058Ab3LCVWM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Dec 2013 16:22:12 -0500
Date: Tue, 3 Dec 2013 16:22:11 -0500
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Antti =?utf-8?B?VMO2bmt5csOk?= <daedalus@pingtimeout.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
Message-ID: <20131203212210.GC2648@fieldses.org>
References: <529CEBC3.8060505@pingtimeout.net>
 <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com>
 <529CF322.4080701@pingtimeout.net>
 <20131203204806.GA2648@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131203204806.GA2648@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 03, 2013 at 03:48:06PM -0500, Dr Fields James Bruce wrote:
> OK, it makes sense that touching a file with a bad name would get an
> error, but you're seeing that cause later creates of files on the same
> filesystem fail.  I can't figure out why that would happen.
...

So maybe there's some other problem here, but...

> > >>Given that widely used ntfs-3g FUSE module also returns EILSEQ on the same case (I tested this) I would argue that a fix should be done for upstream especially since RFC5661 clearly defines that invalid UTF-8 sequence should map into NFSERR_INVAL, exact quote: "Where the client sends an invalid UTF-8 string, the server should return NFS4ERR_INVAL (see Table 5)".
> > >The NFS client will then happily map that straight into EINVAL for you...

This seems like a spec bug?

NFS4ERR_INVAL only makes sense if you could really mandate UTF-8 on the
wire all the time.  But I don't know what other error would work.

I guess a client could map INVAL to EILSEQ on open or lookup (is there
any other reason a correct client should ever see INVAL on those ops?).
Or do that only if fs_charset is supported and has
FSCHARSET_CAP4_ALLOWS_ONLY_UTF8 set.  Yuch.

--b.
