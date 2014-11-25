Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([149.20.54.216]:36522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbaKYSY4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 13:24:56 -0500
Date: Tue, 25 Nov 2014 13:24:45 -0500 (EST)
Message-Id: <20141125.132445.152609149279137368.davem@davemloft.net>
To: paulmck@linux.vnet.ibm.com
Cc: rdunlap@infradead.org, pieter@boesman.nl, josh@joshtriplett.org,
        alexander.h.duyck@intel.com, viro@zeniv.linux.org.uk, ast@plumgrid.com,
        akpm@linux-foundation.org, beber@meleeweb.net,
        catalina.mocanu@gmail.com, dborkman@redhat.com, edumazet@google.com,
        ebiederm@xmission.com, fabf@skynet.be,
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
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141125181032.GJ5050@linux.vnet.ibm.com>
References: <5474ABB6.3030400@infradead.org>
	<20141125.121305.2094097848188324942.davem@davemloft.net>
	<20141125181032.GJ5050@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Tue, 25 Nov 2014 10:10:32 -0800

> I certainly sympathize with this concern, given the importance of software
> portability.  However, the tiny-hardware alternative appears ot some sort
> of special-purpose embedded OS, which most definitely will suffer from
> software compatibility issues.  I guess that the good news is that much
> of the tiny hardware that used to be 8 or 16 bits is now 32 bits, which
> means that it has at least some chance of running some form of Linux.  ;-)

And then if some fundamental part of userland (glibc, klibc, etc.) finds
a useful way to use splice for a fundamental operation, we're back to
square one.

I simply do not agree with modifying the user facing interface, especially
one with decades of precedence.
