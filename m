Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:43966 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964804AbaGPPpj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 11:45:39 -0400
Received: by mail-qg0-f42.google.com with SMTP id j5so935694qga.1
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 08:45:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtS_O3i6fBhW7vTurL=Y7cKmoeGjTXiEMU5mbb3tR3-LjA@mail.gmail.com>
References: <CALtMJECmW-yYgD3W5FUxQZJVZkb5NSJpQ5V9Q3ZE=1NKeCDtOA@mail.gmail.com>
	<20140710175136.GA26561@fieldses.org>
	<CALtMJECLdEOsmuW4AOnNsAyY+OMr3MtFN9W71DRw3tpidKrU8A@mail.gmail.com>
	<CAHQdGtQAgKyFgwp+6w64vXkcKkBQ=YVfiH0jgaonAMumHoTutg@mail.gmail.com>
	<CALtMJEDT=jCWMR0Akjo72fL3SW63dEmDTQbdg5Pv_DV5Oggz_g@mail.gmail.com>
	<CAHQdGtS_O3i6fBhW7vTurL=Y7cKmoeGjTXiEMU5mbb3tR3-LjA@mail.gmail.com>
Date: Wed, 16 Jul 2014 17:45:38 +0200
Message-ID: <CALtMJEALbP3DKpaL9Bz6tNjj3GHYUo7wb=VRbOcjB1+hOr6GCg@mail.gmail.com>
Subject: Re: `ls` shows no files in mounted nfs folder, but ls 'file' works
From: Andreas Fenkart <afenkart@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Daniel Mack <zonque@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014-07-16 16:47 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
> On Wed, Jul 16, 2014 at 1:21 AM, Andreas Fenkart <afenkart@gmail.com> wrote:

> That unfortunately only shows a few READ requests, probably because
> the readdirs etc are cached. Could you try again with a directory that
> is not in cache and/or try "echo 3 >/proc/sys/vm/drop_caches" before
> retrying the 'ls /'?

# tcpdump -s 0 -w /tmp/nfs-client_v4.dump
# echo 3 >/proc/sys/vm/drop_caches
# ls -l /

file is logged to tmpfs, then copied
http://www.pcapr.net/view/afenkart/2014/6/3/8/nfs-client_v4.dump.html

> Note: I am a little surprised that there are no GETATTRs in that dump.
> Even if the readdir is cached, the client is supposed to revalidate
> the directory.

should be there now

Andreas
