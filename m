Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out02.mta.xmission.com ([166.70.13.232]:48451 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaKYTSL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 14:18:11 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: David Miller <davem@davemloft.net>
Cc: josh@joshtriplett.org, rdunlap@infradead.org, pieter@boesman.nl,
        alexander.h.duyck@intel.com, viro@zeniv.linux.org.uk, ast@plumgrid.com,
        akpm@linux-foundation.org, beber@meleeweb.net,
        catalina.mocanu@gmail.com, dborkman@redhat.com, edumazet@google.com,
        fabf@skynet.be, fuse-devel@lists.sourceforge.net, geert@linux-m68k.org,
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
References: <5474ABB6.3030400@infradead.org>
	<20141125.121305.2094097848188324942.davem@davemloft.net>
	<20141125185310.GA24891@cloud>
	<20141125.140441.401150380839514113.davem@davemloft.net>
Date: Tue, 25 Nov 2014 13:16:44 -0600
In-Reply-To: <20141125.140441.401150380839514113.davem@davemloft.net> (David
	Miller's message of "Tue, 25 Nov 2014 14:04:41 -0500 (EST)")
Message-ID: <87egsr9jkz.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out splice family of syscalls (splice, vmsplice, tee and sendfile)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: josh@joshtriplett.org
> Date: Tue, 25 Nov 2014 10:53:10 -0800
>
>> It's not a "slippery slope"; it's been our standard practice for ages.
>
> We've never put an entire class of generic system calls behind
> a config option.

CONFIG_SYSVIPC has been in the kernel as long as I can remember.

I seem to remember a plan to remove that code once userspace had
finished migrating to more unixy interfaces to ipc.  But in 20 years
that migration does does not seem to have finished, or even look
like it ever will.

But if we started a slippery slope it was long long ago.

Eric
