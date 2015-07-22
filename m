Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34361 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964876AbbGVMXq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 08:23:46 -0400
Received: by oigd21 with SMTP id d21so100033361oig.1
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2015 05:23:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1437552643-18774-1-git-send-email-jmarchan@redhat.com>
References: <1437552643-18774-1-git-send-email-jmarchan@redhat.com>
Date: Wed, 22 Jul 2015 08:23:45 -0400
Message-ID: <CAHQdGtRXhUi+=akuASUWo-tYy0YCWJtUts6fqGnA62fo1Jf5tA@mail.gmail.com>
Subject: Re: [RFC PATCH] nfs: avoid swap-over-NFS deadlock
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 22, 2015 at 4:10 AM, Jerome Marchand <jmarchan@redhat.com> wrote:
>
> Lockdep warns about a inconsistent {RECLAIM_FS-ON-W} ->
> {IN-RECLAIM_FS-W} usage. The culpritt is the inode->i_mutex taken in
> nfs_file_direct_write(). This code was introduced by commit a9ab5e840669
> ("nfs: page cache invalidation for dio").
> This naive test patch avoid to take the mutex on a swapfile and makes
> lockdep happy again. However I don't know much about NFS code and I
> assume it's probably not the proper solution. Any thought?
>
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

NFS is not the only O_DIRECT implementation to set the inode->i_mutex.
Why can't this be fixed in the generic swap code instead of adding
yet-another-exception-for-IS_SWAPFILE?

Cheers
  Trond
