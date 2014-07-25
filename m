Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:49612 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbaGYWMl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 18:12:41 -0400
Received: by mail-vc0-f176.google.com with SMTP id id10so8186798vcb.21
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 15:12:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALtMJEALbP3DKpaL9Bz6tNjj3GHYUo7wb=VRbOcjB1+hOr6GCg@mail.gmail.com>
References: <CALtMJECmW-yYgD3W5FUxQZJVZkb5NSJpQ5V9Q3ZE=1NKeCDtOA@mail.gmail.com>
	<20140710175136.GA26561@fieldses.org>
	<CALtMJECLdEOsmuW4AOnNsAyY+OMr3MtFN9W71DRw3tpidKrU8A@mail.gmail.com>
	<CAHQdGtQAgKyFgwp+6w64vXkcKkBQ=YVfiH0jgaonAMumHoTutg@mail.gmail.com>
	<CALtMJEDT=jCWMR0Akjo72fL3SW63dEmDTQbdg5Pv_DV5Oggz_g@mail.gmail.com>
	<CAHQdGtS_O3i6fBhW7vTurL=Y7cKmoeGjTXiEMU5mbb3tR3-LjA@mail.gmail.com>
	<CALtMJEALbP3DKpaL9Bz6tNjj3GHYUo7wb=VRbOcjB1+hOr6GCg@mail.gmail.com>
Date: Fri, 25 Jul 2014 18:12:40 -0400
Message-ID: <CAHQdGtS34K6S_59Huvx8EK+mh1QwSrjtUXaNogGYSm5aQZCA=w@mail.gmail.com>
Subject: Re: `ls` shows no files in mounted nfs folder, but ls 'file' works
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andreas Fenkart <afenkart@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Daniel Mack <zonque@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 11:45 AM, Andreas Fenkart <afenkart@gmail.com> wrote:
> 2014-07-16 16:47 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
>> On Wed, Jul 16, 2014 at 1:21 AM, Andreas Fenkart <afenkart@gmail.com> wrote:
>
>> That unfortunately only shows a few READ requests, probably because
>> the readdirs etc are cached. Could you try again with a directory that
>> is not in cache and/or try "echo 3 >/proc/sys/vm/drop_caches" before
>> retrying the 'ls /'?
>
> # tcpdump -s 0 -w /tmp/nfs-client_v4.dump
> # echo 3 >/proc/sys/vm/drop_caches
> # ls -l /
>
> file is logged to tmpfs, then copied
> http://www.pcapr.net/view/afenkart/2014/6/3/8/nfs-client_v4.dump.html
>
>> Note: I am a little surprised that there are no GETATTRs in that dump.
>> Even if the readdir is cached, the client is supposed to revalidate
>> the directory.
>
> should be there now

Still not seeing the readdir, but the getattrs are there and all looks OK.
Question: the server is knfsd from a Linux 3.14.4 kernel, is that
correct? So it does have commit 83b19121522 (nfsd: revert v2 half of
"nfsd: don't return high mode bits")?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
