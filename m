Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f45.google.com ([74.125.82.45]:44511 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaKYULf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 15:11:35 -0500
Date: Tue, 25 Nov 2014 21:11:29 +0100
From: Pieter Smith <pieter@boesman.nl>
To: David Miller <davem@davemloft.net>
Cc: josh@joshtriplett.org, rdunlap@infradead.org, alexander.h.duyck@intel.com,
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
Message-ID: <20141125201129.GA27167@smipidev>
References: <5474ABB6.3030400@infradead.org>
 <20141125.121305.2094097848188324942.davem@davemloft.net>
 <20141125185310.GA24891@cloud>
 <20141125.140441.401150380839514113.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141125.140441.401150380839514113.davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 25, 2014 at 02:04:41PM -0500, David Miller wrote:
> From: josh@joshtriplett.org
> Date: Tue, 25 Nov 2014 10:53:10 -0800
> 
> > It's not a "slippery slope"; it's been our standard practice for ages.
> 
> We've never put an entire class of generic system calls behind
> a config option.

I would have loved to make them optional individually, but they all are
semantic variations of the same thing: Moving data between fd's without that
data passing through userspace. It therefore isn't surprising that these
syscalls share an underlying entanglement of code (which is where the bulk of
the space saving is to be had).

What a tiny product developer should be asking himself, is: "Do I really need
to efficiently move data between file descriptors?". If the answer no, he can
disable CONFIG_SYSCALL_SPLICE to squeeze an extra 8KB out of his kernel.
