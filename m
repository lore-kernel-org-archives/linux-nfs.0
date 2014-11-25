Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([149.20.54.216]:37081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbaKYTFr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 14:05:47 -0500
Date: Tue, 25 Nov 2014 14:05:40 -0500 (EST)
Message-Id: <20141125.140540.263011245662392838.davem@davemloft.net>
To: tytso@mit.edu
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
From: David Miller <davem@davemloft.net>
In-Reply-To: <20141125185806.GA28116@thunk.org>
References: <20141125181032.GJ5050@linux.vnet.ibm.com>
	<20141125.132445.152609149279137368.davem@davemloft.net>
	<20141125185806.GA28116@thunk.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Theodore Ts'o <tytso@mit.edu>
Date: Tue, 25 Nov 2014 13:58:06 -0500

> On Tue, Nov 25, 2014 at 01:24:45PM -0500, David Miller wrote:
>> 
>> And then if some fundamental part of userland (glibc, klibc, etc.) finds
>> a useful way to use splice for a fundamental operation, we're back to
>> square one.
> 
> I'll note that the applications for these super-tiny kernels are
> places where it's not likely they would be using glibc at all; think
> very tiny embedded systems.  The userspace tends to be highly
> restricted for the same space reasons why there is an effort to make
> the kernel as small as possible.

This is why I mentioned klibc, in order to avoid replies like your's,
it seems I have failed.
