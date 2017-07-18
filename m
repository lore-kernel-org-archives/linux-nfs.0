Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44368 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752336AbdGROU6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Jul 2017 10:20:58 -0400
Date: Tue, 18 Jul 2017 10:20:58 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: [GIT PULL] Please pull an nfsd bugfix for 4.13
Message-ID: <20170718142058.GB19030@fieldses.org>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
 <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
 <1500245845.13893.3.camel@primarydata.com>
 <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
 <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.13-1

One fix for a problem introduced in the most recent merge window and
found by Dave Jones and KASAN.

--b.

Trond Myklebust (1):
      nfsd: Fix a memory scribble in the callback channel

 fs/nfsd/nfs4callback.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)
