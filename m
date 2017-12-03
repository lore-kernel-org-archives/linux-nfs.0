Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0070.hostedemail.com ([216.40.44.70]:50964 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751380AbdLCV2l (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Dec 2017 16:28:41 -0500
Date: Sun, 3 Dec 2017 16:22:56 -0500
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>,
        "elfring@users.sourceforge.net" <elfring@users.sourceforge.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "peterz@infradead.org" <peterz@infradead.org>
Subject: Re: Difficulties for compilation without extra optimisation
Message-ID: <20171203162256.4ea0750d@vmware.local.home>
In-Reply-To: <1512314250.3673.6.camel@primarydata.com>
References: <7f072f78-eef4-6d87-d233-cee71dac5a32@users.sourceforge.net>
        <a2ac6d05-fdd6-82bb-075e-b7eb81b516fe@users.sourceforge.net>
        <1512314250.3673.6.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 3 Dec 2017 15:17:32 +0000
Trond Myklebust <trondmy@primarydata.com> wrote:

> > I would like to check corresponding build results then without extra
> > optimisation applied by the compiler.
> > But I got surprised by error messages for a command like the
> > following.
> > 
> > elfring@Sonne:~/Projekte/Linux/next-patched> my_cc=/usr/bin/gcc-7 &&
> > LANG=C make -j4 CC="${my_cc}" HOSTCC="${my_cc}" EXTRA_CFLAGS='-O0'
> > allmodconfig fs/nfs/write.o

Why would you compile the kernel without optimization? There's many
places in the kernel that WILL NOT BUILD without optimization. In fact,
we do a lot of tricks to make sure that things work the way we expect
it to, because we add broken code that only gets compiled out when gcc
optimizes the code the way we expect it to be, and the kernel build
will break otherwise.

-- Steve
