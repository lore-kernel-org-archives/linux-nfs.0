Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60909 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411Ab3LDVD6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 16:03:58 -0500
Date: Wed, 4 Dec 2013 16:03:56 -0500
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Antti =?utf-8?B?VMO2bmt5csOk?= <daedalus@pingtimeout.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
Message-ID: <20131204210356.GA19452@fieldses.org>
References: <529CEBC3.8060505@pingtimeout.net>
 <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com>
 <529CF322.4080701@pingtimeout.net>
 <20131203204806.GA2648@fieldses.org>
 <20131203212210.GC2648@fieldses.org>
 <529ED1C8.70208@pingtimeout.net>
 <20131204154104.GB14646@fieldses.org>
 <529F943D.30004@pingtimeout.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <529F943D.30004@pingtimeout.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 10:44:45PM +0200, Antti Tönkyrä wrote:
> Looks like I can strace it and I did an example strace, if you need
> something more specific please do tell. Command log has completion
> timestamps for associating what part of strace happened at what
> command.
> 
> http://daedalus.pingtimeout.net/dbg/strace-ioerr.txt
> http://daedalus.pingtimeout.net/dbg/strace-commandlog.txt

Eh, not much use without knowing fuse's protocol, but:

> And just in case you missed my other mail, the I/O error doesn't
> kill the share if using NFSv3 (mount -t nfs -o vers=3,intr,hard
> ...). The initial I/O error happens but the share doesn't die even
> when there are file handles open there.

Oh, I overlooked that.  So that merits another look at the network
trace:

> >>http://daedalus.pingtimeout.net/dbg/eilseq_ioerr.pcap

And I see something I'd overlooked before: the client is sending the
later opens with the same open owner and sequence id.  But NFS4ERR_IO is
a seqid-mutating error.  So now I think this probably *is* a client
bug....

What's the client kernel version?

--b.
