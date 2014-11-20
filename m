Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f181.google.com ([209.85.212.181]:43021 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756291AbaKTVOp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Nov 2014 16:14:45 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so6799473wiv.14
        for <linux-nfs@vger.kernel.org>; Thu, 20 Nov 2014 13:14:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyE60A+2h6My0Ebb=5j4DbVifDBuG6CjymCRsRefNTMd=w@mail.gmail.com>
References: <CAN-5tyE60A+2h6My0Ebb=5j4DbVifDBuG6CjymCRsRefNTMd=w@mail.gmail.com>
Date: Thu, 20 Nov 2014 13:14:44 -0800
Message-ID: <CAHQdGtSTc-34R_C0TwYmwk8KdQFadxQbhgmoTxzhWKhsYjiFww@mail.gmail.com>
Subject: Re: is receiving BAD_STATEID during IO on delegated stateid unrecoverable?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 20, 2014 at 12:57 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Hi folks,
>
> As far as I can tell, receiving a BAD_STATEID on an IO operation on a
> delegated stateid when there was a local lock acquired for this IO is
> unrecoverable — leads to EIO. Codewise, stateid recovery sees that it
> has a local lock and marks it lost and retry of the IO operation
> returns the EIO.
>
> Is the reason for seizing the IO is that if the server for some reason
> revoked this stateid then there is no guarantee about the locks and
> thus doing any IO.
>
> This also applies to both 4.0 and 4.1 code as far as I can tell.
>
> Can somebody confirm or tell me if this is wrong?
>

Yes. If the server has lost the lock, then the application has lost
atomicity for the set of operations that were supposed to be protected
by that lock, and this is why we return the EIO. In older kernels we
did try to recover the lock, but that can lead to application-visible
corruption of data, and so we no longer do that unless you explicitly
set the nfs 'recover_lost_locks' module parameter - see
Documentation/kernel-parameters.txt.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
