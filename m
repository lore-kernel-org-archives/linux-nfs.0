Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([149.20.54.216]:35581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaKYRNO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 12:13:14 -0500
Date: Tue, 25 Nov 2014 12:13:05 -0500 (EST)
Message-Id: <20141125.121305.2094097848188324942.davem@davemloft.net>
To: rdunlap@infradead.org
Cc: pieter@boesman.nl, josh@joshtriplett.org, alexander.h.duyck@intel.com,
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
        Paul.Durrant@citrix.com, paulmck@linux.vnet.ibm.com,
        pefoley2@pefoley.com, tgraf@suug.ch, therbert@google.com,
        trond.myklebust@primarydata.com, willemb@google.com,
        xiaoguangrong@linux.vnet.ibm.com, zhenglong.cai@cs2c.com.cn
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
From: David Miller <davem@davemloft.net>
In-Reply-To: <5474ABB6.3030400@infradead.org>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
	<5474ABB6.3030400@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 25 Nov 2014 08:17:58 -0800

> Is the splice family of syscalls the only one that tiny has identified
> for optional building or can we expect similar treatment for other
> syscalls?
> 
> Why will many embedded systems not need these syscalls?  You know
> exactly what apps they run and you are positive that those apps do
> not use splice?

I think starting to compile out system calls is a very slippery
slope we should not begin the journey down.

This changes the forward facing interface to userspace.
