Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62437 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753128Ab2CaVVd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Mar 2012 17:21:33 -0400
MIME-Version: 1.0
In-Reply-To: <1333228179.2719.14.camel@lade.trondhjem.org>
References: <1325927523-30103-1-git-send-email-levinsasha928@gmail.com>
 <5FF522E0-132E-4A6A-A40F-5CCD08AF800A@oracle.com> <20120107181221.GA3777@umich.edu>
 <1326111265.30169.5.camel@lappy> <CA+1xoqdQPi53GYr_Q6RtECJJcrz0TVVp4uNQX6jkfbQWQSNF7g@mail.gmail.com>
 <D3642511-B29B-4CA7-A133-C99B711954C1@oracle.com> <1333228179.2719.14.camel@lade.trondhjem.org>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sat, 31 Mar 2012 23:21:12 +0200
Message-ID: <CA+1xoqfv82ngQ4oc5uozZQjN7PipWVjVu670-uUGC5o_3Nec9A@mail.gmail.com>
Subject: Re: [PATCH] nfs: Don't try mounting device as nfs root unless type
 fully matches
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        Lukas Razik <linux@razik.name>, Pekka Enberg <penberg@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML Kernel <linux-kernel@vger.kernel.org>,
        Ingo Molnar <mingo@elte.hu>,
        Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 31, 2012 at 11:09 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Sat, 2012-03-31 at 11:27 -0400, Chuck Lever wrote:
>> Oops.  Trond?  This got dropped somewhere.
>
> I don't own the 'init' directory, and since quite frankly this isn't
> related to NFS at all, it should be sent to Linus directly.
>
> I'm quite happy to ack the patch if that would help.

The patch which has triggered this whole story (6829a048 ("NFS: Retry
mounting NFSROOT")) modified init/ as well, and went in through the
NFS tree. Can't this patch follow the same path?

Anyhow, I've Cc'ed Linus in hopes that this patch can somehow find
it's way into 3.4.
