Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shards.monkeyblade.net ([149.20.54.216]:37394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaKYT1v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 14:27:51 -0500
Date: Tue, 25 Nov 2014 14:27:41 -0500 (EST)
Message-Id: <20141125.142741.1620673255148724338.davem@davemloft.net>
To: ebiederm@xmission.com
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
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
From: David Miller <davem@davemloft.net>
In-Reply-To: <87egsr9jkz.fsf@x220.int.ebiederm.org>
References: <20141125185310.GA24891@cloud>
	<20141125.140441.401150380839514113.davem@davemloft.net>
	<87egsr9jkz.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 25 Nov 2014 13:16:44 -0600

> David Miller <davem@davemloft.net> writes:
> 
>> From: josh@joshtriplett.org
>> Date: Tue, 25 Nov 2014 10:53:10 -0800
>>
>>> It's not a "slippery slope"; it's been our standard practice for ages.
>>
>> We've never put an entire class of generic system calls behind
>> a config option.
> 
> CONFIG_SYSVIPC has been in the kernel as long as I can remember.
> 
> I seem to remember a plan to remove that code once userspace had
> finished migrating to more unixy interfaces to ipc.  But in 20 years
> that migration does does not seem to have finished, or even look
> like it ever will.
> 
> But if we started a slippery slope it was long long ago.

Fair enough.

Would be amusing if these tiny systems have it enabled.
