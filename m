From: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
Subject: Re: Fw: Deadlock regression in v2.6.31.6
Date: Wed, 25 Nov 2009 09:56:59 +0100
Message-ID: <64b4daae0911250056g3364d24l98850a272dcfe483@mail.gmail.com>
References: <20091124233555.da6439c4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:38593 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934379AbZKYI4y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2009 03:56:54 -0500
Received: by fxm5 with SMTP id 5so6705720fxm.28
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2009 00:56:59 -0800 (PST)
In-Reply-To: <20091124233555.da6439c4.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The problem vanishes as soon as I run v2.6.31.5 (neither kernel contains
> any significant modules).

I did a bisect, and it turns out that the problem is there in 2.6.31.5 as well.
The traces are still valid.  This is on an NFS mounted root partition
(NFSv3 over TCP), no other filesystems mounted (except a tmpfs here or
there).  I turned on some debugging in net/sunrpc/sched.c, and the
following happens when I execute "apt-get --reinstall install man-db"
(it happens everytime, so it is very reproducible):

RPC:  9697 setting alarm for 60000 ms
RPC:  9697 __rpc_wake_up_task (now 7827)
RPC:  9697 disabling timer
RPC:  9697 removed from queue cfa72d88 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:  9697 __rpc_execute flags=0x1 cf849c44
RPC:  9697 sleep_on(queue "xprt_pending" time 7828)
RPC:  9697 added to queue cfa72d88 "xprt_pending"
RPC:  9697 setting alarm for 60000 ms
RPC:  9697 __rpc_wake_up_task (now 7830)
RPC:  9697 disabling timer
RPC:  9697 removed from queue cfa72d88 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:  9697 __rpc_execute flags=0x1 cf849c44
RPC:  9697 sleep_on(queue "xprt_pending" time 7831)
RPC:  9697 added to queue cfa72d88 "xprt_pending"
RPC:  9697 setting alarm for 60000 ms
RPC:  9697 __rpc_wake_up_task (now 7833)
RPC:  9697 disabling timer
RPC:  9697 removed from queue cfa72d88 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:  9697 __rpc_execute flags=0x1 cf849c44
RPC:  9697 sleep_on(queue "xprt_pending" time 7835)
RPC:  9697 added to queue cfa72d88 "xprt_pending"
RPC:  9697 setting alarm for 60000 ms
RPC:  9697 __rpc_wake_up_task (now 7836)
RPC:  9697 disabling timer
RPC:  9697 removed from queue cfa72d88 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:  9697 __rpc_execute flags=0x1 cf849c44
RPC:  9697 sleep_on(queue "xprt_pending" time 7838)
RPC:  9697 added to queue cfa72d88 "xprt_pending"
RPC:  9697 setting alarm for 60000 ms
RPC:  9697 __rpc_wake_up_task (now 7839)
RPC:  9697 disabling timer
RPC:  9697 removed from queue cfa72d88 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:  9697 __rpc_execute flags=0x1 cf849c44
RPC:  9697 sleep_on(queue "xprt_pending" time 7841)
RPC:  9697 added to queue cfa72d88 "xprt_pending"
RPC:  9697 setting alarm for 60000 ms
RPC:  9697 __rpc_wake_up_task (now 7842)
RPC:  9697 disabling timer
RPC:  9697 removed from queue cfa72d88 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:  9697 __rpc_execute flags=0x1 cf849c44
RPC:  9697 sleep_on(queue "xprt_pending" time 7844)
RPC:  9697 added to queue cfa72d88 "xprt_pending"
RPC:  9697 setting alarm for 60000 ms
RPC:  9697 __rpc_wake_up_task (now 7845)
RPC:  9697 disabling timer
RPC:  9697 removed from queue cfa72d88 "xprt_pending"
RPC:       __rpc_wake_up_task done

Ad infinitum.
The cf849c44 is the task parameter which I printed as well.
It looks like an endless loop in the statemachine.
The kernel hangs at this point, the only way to get out of there is
using SysBreak.
I tried debugging it further, but I got lost in the statemachine (I think).
-- 
Sincerely,
                Stephen R. van den Berg.
