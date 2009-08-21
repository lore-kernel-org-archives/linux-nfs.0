From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v3 cached directory content out of sync
Date: Fri, 21 Aug 2009 14:49:51 -0400
Message-ID: <1250880591.27154.18.camel@heimdal.trondhjem.org>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Stefan Egli <stefan.egli@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:42846 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755644AbZHUStx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 14:49:53 -0400
In-Reply-To: <d4098e2f0908211122y5d024dd1sd2f80356749315cc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 20:22 +0200, Stefan Egli wrote:
>  Question 1: Would you agree that this is a bug or is it 'NFS as designed' ?

It sounds like a bug. You don't mention which client you are using.

>  Question 2: Is such a file content delay in NFS 'as designed' - I'm
> assuming that fiddling with NFS mount parameters could put a 'defined
> maximum' to such a delay? Or is there no such maximum and under 'bad
> luck' situations it can go infinitely high (which would be Q1) ?

You can tune the amount of time the client caches information by using
the 'ac*' mount options. In this case, you will want to adjust the
values of 'acdirmin' and 'acdirmax', probably setting them to zero.

'man 5 nfs' should provide you with more information.

>  Question 3: What is a suggested best-practice NFS mount parameter set
> for complying with the following requirements:
>    * lots of reads - tons of files - reads often from different files
>    * few writes - but if written it should propagate to all NFS
> clients 'immediately'
>    * high load situations (as with the 400GB read/write stuff above) -
> and after or even during this doing a 'ls' in a directory should
> produce consistent results on different attached NFS clients

See above

>  Question 4: If we'd somehow manually detected such a directory
> content inconsistency - would there be something like a 'hey NFS
> client, flush all NFS caches NOW' thing?

No.

>  Question 5: any of this related to commit 37d9d76d8b3a2ac5817e1fa3263cfe
> 0fdb439e51: NFS: flush cached directory information slightly more readily. ?

You client should be seeing mtime changes when you are creating new
files, so it shouldn't need to look at the ctime.

The only time when ctime changes are relevant are if you use 'rsync' to
copy the files without specifying --omit-dir-times.
IOW: if something is explicitly setting the mtime on the directory.

Cheers
  Trond

