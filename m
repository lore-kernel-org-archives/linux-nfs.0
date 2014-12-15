Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58835 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbaLOMwX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2014 07:52:23 -0500
Date: Mon, 15 Dec 2014 07:52:19 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Pablo Silva <psilvao@gmail.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: Fwd: NFS and Memory Buffers
In-Reply-To: <CAF1in6RCyK4VMM3j1ZD=1D25+cFU9YGg-UhR-kuYcNWNk+Stzg@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1412150749290.1119@planck.local>
References: <CAF1in6QVkgyuC7VQ5QdYnYtPRJgArDwg5sXtKiAvyszCcQoZ-g@mail.gmail.com> <CAF1in6RCyK4VMM3j1ZD=1D25+cFU9YGg-UhR-kuYcNWNk+Stzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Pablo,

	Why are you restarting snmpd between flushing cache and reading
memory values?  On a running system you can probably expect the
cache to immediately start to fill after a flush anyway.
y
Ben

On Mon, 15 Dec 2014, Pablo Silva wrote:

> Dear Readers:
>
>      My boss has entrusted me to analyze why the memory buffers are
> not released a Linux server with Centos 6.4.?
>
>     As informs me, the current reading is:
>
>
> [root@bck ~]# free -m
>              total       used       free     shared    buffers     cached
> Mem:         15936      15788        147          0       6746        438
> -/+ buffers/cache:       8604       7332
> Swap:         2047          0       2047
> [root@bck ~]#
> [root@bck ~]#
> [root@bck ~]# echo 3 > /proc/sys/vm/drop_caches && service snmpd
> restart && free -m
> Stopping snmpd:                                            [  OK  ]
> Starting snmpd:                                            [  OK  ]
>              total       used       free     shared    buffers     cached
> Mem:         15936        509      15426          0         93         16
> -/+ buffers/cache:        400      15536
> Swap:         2047          0       2047
> [root@bck ~]#
>
>    I can not find the solution to release the memory buffer and cache
> memory so grateful for any hint for finding the solution to this
> "problem".
>
> -Paul
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
