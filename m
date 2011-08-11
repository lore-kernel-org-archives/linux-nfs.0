Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56830 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752633Ab1HKBKg convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Aug 2011 21:10:36 -0400
In-Reply-To: <20110810175829.a834d80f.rdunlap@xenotime.net>
References: <CA+55aFwkJdyEpyNY64aAQ5ChrPZ8Kvx9iRUwy1J6_SRaxoN=zA@mail.gmail.com>
 <20110810122304.96b8be67.rdunlap@xenotime.net> <CA+a=Yy5izxiyvW5eYiWuute9E1vXwNTj4frdzNeEwsLDrszesg@mail.gmail.com>
 <20110810175829.a834d80f.rdunlap@xenotime.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 10 Aug 2011 18:10:14 -0700
Message-ID: <CA+55aFzcSLrhkexEn=J7BN8F3P3Vy+EAjwgGwMQPdeoYoQG+Bw@mail.gmail.com>
Subject: Re: Linux 3.1-rc1 (nfs/pnfs and drivers/md)
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Peng Tao <bergwolf@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-raid@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 10, 2011 at 5:58 PM, Randy Dunlap <rdunlap@xenotime.net> wrote:
>
> The blocklayout parts of NVS_V4_1 could depend on BLOCK.  or all of NVS_V4_1
> can depend on BLOCK.

Absolutely. Replace "could" by "should".

There's no way I'll take a patch to make NFS "select BLOCK". If the
block layer isn't enabled, then NFS obviously shouldn't be doing any
pnfs stuff.

                        Linus
