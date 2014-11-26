Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 251.110.2.81.in-addr.arpa ([81.2.110.251]:47165 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbaKZMYt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Nov 2014 07:24:49 -0500
Date: Wed, 26 Nov 2014 12:19:03 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
To: David Miller <davem@davemloft.net>
Cc: josh@joshtriplett.org, rdunlap@infradead.org, pieter@boesman.nl,
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
        Paul.Durrant@citrix.com, paulmck@linux.vnet.ibm.com,
        pefoley2@pefoley.com, tgraf@suug.ch, therbert@google.com,
        trond.myklebust@primarydata.com, willemb@google.com,
        xiaoguangrong@linux.vnet.ibm.com, zhenglong.cai@cs2c.com.cn
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Message-ID: <20141126121903.5231c854@lxorguk.ukuu.org.uk>
In-Reply-To: <20141125.140441.401150380839514113.davem@davemloft.net>
References: <5474ABB6.3030400@infradead.org>
	<20141125.121305.2094097848188324942.davem@davemloft.net>
	<20141125185310.GA24891@cloud>
	<20141125.140441.401150380839514113.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 25 Nov 2014 14:04:41 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: josh@joshtriplett.org
> Date: Tue, 25 Nov 2014 10:53:10 -0800
> 
> > It's not a "slippery slope"; it's been our standard practice for ages.
> 
> We've never put an entire class of generic system calls behind
> a config option.

Try running an original MCC Linux binary and C lib on a current kernel

We've put *entire binary formats* behind a config option. We've put older
syscalls behind it, we've put sysfs behind it, sysctl behind it, the
older microcode interfaces behind it, ISA bus as a concept behind
options. VDSO, IPC, even 32bit support ... the list goes on and on.

I'd say those were far more generic on the whole than splice/sendfile.

Alan
