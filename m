Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f173.google.com ([209.85.128.173]:62673 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758239AbaGAOVl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 10:21:41 -0400
Received: by mail-ve0-f173.google.com with SMTP id db11so9795002veb.32
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 07:21:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140701101034.520b04bb@tlielax.poochiereds.net>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<20140630125142.GA32089@infradead.org>
	<20140630085934.2bf86ba0@tlielax.poochiereds.net>
	<20140630193237.GA11935@fieldses.org>
	<20140630162014.20e63e1a@tlielax.poochiereds.net>
	<CAHQdGtQtHaKx6mEXzO7XndZPo19joccuPa0_z0T_79TiG1434w@mail.gmail.com>
	<20140630163647.5227ac55@tlielax.poochiereds.net>
	<20140701101034.520b04bb@tlielax.poochiereds.net>
Date: Tue, 1 Jul 2014 10:21:40 -0400
Message-ID: <CAHQdGtQZP8RGqWS0pw-X97D_3GE1tqxaeVMSXgLa+VtaSLae2w@mail.gmail.com>
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 1, 2014 at 10:10 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
>
> Quite right. I changed the program to be run as root and had each child
> process do an setfsuid/setfsgid to a different UID/GID combo:
>
> [jlayton@tlielax lockperf]$ time sudo  ./opentest -n 128 -l 100 /mnt/rawhide/opentest
>
> real    0m3.448s
> user    0m0.078s
> sys     0m0.377s
> [jlayton@tlielax lockperf]$ time sudo  ./opentest -n 128 -l 100 /mnt/rawhide/opentest
>
> real    0m3.344s
> user    0m0.053s
> sys     0m0.374s
> [jlayton@tlielax lockperf]$ time sudo  ./opentest -n 128 -l 100 /mnt/rawhide/opentest
>
> real    0m3.550s
> user    0m0.049s
> sys     0m0.394s
>
>
> ...so the speedup seems to be quite dramatic, actually -- 3x faster or
> so with the patched kernel.
>
> The underlying filesystem is ext4 here, and the config is a rawhide
> debug kernel config. For my next trick, I'll build some non-debug
> kernels and replicate the test with them. Stay tuned...

Just for grins, we should probably also try with the 3 client side
OPEN parallelisation patches in my 'devel' branch. I'd expect them to
give a slight performance improvement with your original test (i.e.
the one that doesn't play the UID/GID games)

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
