Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:37086 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751245AbdGQDFH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Jul 2017 23:05:07 -0400
Date: Sun, 16 Jul 2017 23:05:04 -0400
From: "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
Message-ID: <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
 <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
 <1500245845.13893.3.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1500245845.13893.3.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 16, 2017 at 10:57:27PM +0000, Trond Myklebust wrote:
 
 > > BUG: KASAN: global-out-of-bounds in call_start+0x93/0x100
 > > Read of size 8 at addr ffffffff8d582588 by task kworker/0:1/22
 > 
 > Does the following patch fix it?

Yep, seems to do the trick!

	Dave

