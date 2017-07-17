Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35467 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbdGQTCW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jul 2017 15:02:22 -0400
MIME-Version: 1.0
In-Reply-To: <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk> <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
 <1500245845.13893.3.camel@primarydata.com> <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 17 Jul 2017 12:02:20 -0700
Message-ID: <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
To: "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>,
        Trond Myklebust <trondmy@primarydata.com>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 16, 2017 at 8:05 PM, davej@codemonkey.org.uk
<davej@codemonkey.org.uk> wrote:
> On Sun, Jul 16, 2017 at 10:57:27PM +0000, Trond Myklebust wrote:
>
>  > > BUG: KASAN: global-out-of-bounds in call_start+0x93/0x100
>  > > Read of size 8 at addr ffffffff8d582588 by task kworker/0:1/22
>  >
>  > Does the following patch fix it?
>
> Yep, seems to do the trick!

I'm assuming I'll get this fix through a future pull request, and am
not applying the patch as-is. Just FYI.

                     Linus
