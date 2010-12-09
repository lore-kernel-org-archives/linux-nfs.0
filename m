Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout0.mh.bbc.co.uk ([132.185.144.151]:33349 "EHLO
	mailout0.mh.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162Ab0LINLg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 08:11:36 -0500
Date: Thu, 9 Dec 2010 13:11:31 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4: "Viminfo file is not writable" -- stat(2) uid/gid
	incorrect
Message-ID: <20101209131131.GB11772@rd.bbc.co.uk>
References: <20101208153340.GD20844@rd.bbc.co.uk> <1291835999.3067.13.camel@heimdal.trondhjem.org> <20101208202009.GH20844@rd.bbc.co.uk> <1291841129.3067.22.camel@heimdal.trondhjem.org> <20101208211930.GI20844@rd.bbc.co.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101208211930.GI20844@rd.bbc.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

* David Flynn (davidf@rd.bbc.co.uk) wrote:
> * Trond Myklebust (Trond.Myklebust@netapp.com) wrote:
> > While the open() call may indeed fail to set the uid/gid (because to do
> > so would require an upcall right in the middle of an asynchronous RPC
> > call), it should normally mark the inode as requiring revalidation if
> > this is the case.
> 
> Where ought this occur (so we can validate that it is indeed the case)?
> 
> > The ensuing stat() should then trigger a GETATTR call on the wire, which
> > will correct the uid/gid.

I've re-run the test with nfs client debugging turned on.  I've also
modified the test case to write output to /dev/kmsg to allow easier
identification of what is going on.  An annotated log is available
at:

ftp://ftp.kw.bbc.co.uk/davidf/priv/nfs-20101209/bad

NB, the system i've run this on has an nfsroot[1], and 1MiB kernel log
ring buffer.  with nfs debugging, the test case would occasionally
do as expected, the transcript of this is available as:

ftp://ftp.kw.bbc.co.uk/davidf/priv/nfs-20101209/good

I've tried to keep the formatting similar, so that you can do:
$ diff -u <(sed -e 's/^\[.\+\]//' bad) <(sed -e 's/^\[.\+\]//' good)

This is available as:
 ftp://ftp.kw.bbc.co.uk/davidf/priv/nfs-20101209/bad-to-good.diff

[1] although i can reproduce on systems without nfsroot, i don't have
root access to them.

..david
