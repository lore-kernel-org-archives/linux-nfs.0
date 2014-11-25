Return-Path: linux-nfs-owner@vger.kernel.org
Received: from imap.thunk.org ([74.207.234.97]:51252 "EHLO imap.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbaKYS7B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 13:59:01 -0500
Date: Tue, 25 Nov 2014 13:58:06 -0500
From: "Theodore Ts'o" <tytso@mit.edu>
To: David Miller <davem@davemloft.net>
Cc: paulmck@linux.vnet.ibm.com, rdunlap@infradead.org, pieter@boesman.nl,
        josh@joshtriplett.org, alexander.h.duyck@intel.com,
        viro@zeniv.linux.org.uk, ast@plumgrid.com, akpm@linux-foundation.org,
        beber@meleeweb.net, catalina.mocanu@gmail.com, dborkman@redhat.com,
        edumazet@google.com, ebiederm@xmission.com, fabf@skynet.be,
        fuse-devel@lists.sourceforge.net, geert@linux-m68k.org,
        hughd@google.com, iulia.manda21@gmail.com, JBeulich@suse.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        mcgrof@suse.com, mattst88@gmail.com, mgorman@suse.de, mst@redhat.com,
        miklos@szeredi.hu, netdev@vger.kernel.org, oleg@redhat.com,
        Paul.Durrant@citrix.com, pefoley2@pefoley.com, tgraf@suug.ch,
        therbert@google.com, trond.myklebust@primarydata.com,
        willemb@google.com, xiaoguangrong@linux.vnet.ibm.com,
        zhenglong.cai@cs2c.com.cn
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Message-ID: <20141125185806.GA28116@thunk.org>
References: <5474ABB6.3030400@infradead.org>
 <20141125.121305.2094097848188324942.davem@davemloft.net>
 <20141125181032.GJ5050@linux.vnet.ibm.com>
 <20141125.132445.152609149279137368.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141125.132445.152609149279137368.davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 25, 2014 at 01:24:45PM -0500, David Miller wrote:
> 
> And then if some fundamental part of userland (glibc, klibc, etc.) finds
> a useful way to use splice for a fundamental operation, we're back to
> square one.

I'll note that the applications for these super-tiny kernels are
places where it's not likely they would be using glibc at all; think
very tiny embedded systems.  The userspace tends to be highly
restricted for the same space reasons why there is an effort to make
the kernel as small as possible.

In these places, they are using Linux already, but they're using a 2.2
or 2.4 kernel because 3.0 is just too damned big.  So the goal is to
try to provide them an alternative which allows them to use a modern,
but stripped down kernel.  If glibc or klibc isn't going to work
without splice, then it's not going to work on a pre 2.6 kernel
anyway, so things are no worse with these systems anyway.

After all, if we can get these systems to using a 3.x kernel w/o
splice, that's surely better than their using a 2.2 or 2.4 kernel w/o
the splice system, isn't it?

Cheers,

					- Ted
