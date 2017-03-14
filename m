Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35478 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750932AbdCNWxI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Mar 2017 18:53:08 -0400
Received: by mail-qt0-f194.google.com with SMTP id r5so69076qtb.2
        for <linux-nfs@vger.kernel.org>; Tue, 14 Mar 2017 15:53:07 -0700 (PDT)
Message-ID: <1489531983.2682.19.camel@poochiereds.net>
Subject: Re: Infinite loop when connecting to unreachable NFS servers
From: Jeff Layton <jlayton@poochiereds.net>
To: Sebastian Schmidt <yath@yath.de>, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
Date: Tue, 14 Mar 2017 18:53:03 -0400
In-Reply-To: <20170314221525.u7e6fjfmh2qurhtx@marax.lan.yath.de>
References: <20170314221525.u7e6fjfmh2qurhtx@marax.lan.yath.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-03-14 at 23:15 +0100, Sebastian Schmidt wrote:
> Hi,
> 
> I was debugging some mysterious high CPU usage and tracked it down to
> monitoring daemon regularly calling stat*() on an NFS automount
> directory. The problem is triggered when mount.nfs passes mount() an
> addr= that points to an unreachable address (i.e. connecting fails
> immediately).
> 
> One way to reproduce is by trying to mount Google's DNS server, whose
> IPv6 address isn't properly parsed or rejected by nfs-utils, causing an
> invalid addr= to be passed to mount():
> 
> # strace -vf mount.nfs -v 2001:4860:4860:0:0:0:0:8888:/ /mnt
> write(1, "mount.nfs: timeout set for Tue Mar 14 22:57:49 2017", ...
> [...]
> socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
> bind(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
> connect(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("0.0.7.209")}, 16) = -1 EINVAL (Invalid argument)
> close(3)                                = 0
> write(1, "mount.nfs: trying text-based options 'vers=4.2,addr=0.0.7.209,clientaddr=0.0.0.0'", ...
> mount("2001:4860:4860:0:0:0:0:8888:/", "/mnt", "nfs", 0, "vers=4.2,addr=0.0.7.209,clientad"...) = ?
> +++ killed by SIGKILL +++
> 

That mount syntax is invalid. From nfs(5):

       The server's hostname can be an unqualified hostname, a fully qualified
       domain name, a dotted quad IPv4 address, or an IPv6 address enclosed in
       square brackets.  Link-local and  site-local  IPv6  addresses  must  be
       accompanied  by  an  interface  identifier.  See ipv6(7) for details on
       specifying raw IPv6 addresses.

So, something like this may work better:

    mount -t nfs '[2001:4860:4860:0:0:0:0:8888]:/' /mnt


> While this is certainly a bug in mount.nfs, too, the bug can also be
> triggered with net.conf.ipv6.all.disable_ipv6=1 and using a hostname that
> resolves to an IPv6 address only (/etc/hosts works) with mount.nfs.
> 
> <4>[ 6564.082853] RPC:     8 sleep_on(queue "xprt_pending" time 4296533344)
> <4>[ 6564.082855] RPC:     8 added to queue ffff8a673b146a18 "xprt_pending"
> <4>[ 6564.082858] RPC:     8 setting alarm for 180000 ms
> <4>[ 6564.082860] RPC:       xs_connect scheduled xprt ffff8a673b146800
> <4>[ 6564.082863] RPC:     8 sync task going to sleep
> <4>[ 6564.082868] RPC:       xs_bind 0000:0000:0000:0000:0000:0000:0000:0000:784: ok (0)
> <4>[ 6564.082870] RPC:       worker connecting xprt ffff8a673b146800 via tcp to 2001:4860:4860::8888 (port 2049)
> <4>[ 6564.082874] RPC:       ffff8a673b146800 connect status 99 connected 0 sock state 7
> <4>[ 6564.082876] RPC:     8 __rpc_wake_up_task (now 4296533344)
> <4>[ 6564.082878] RPC:     8 disabling timer
> <4>[ 6564.082880] RPC:     8 removed from queue ffff8a673b146a18 "xprt_pending"
> <4>[ 6564.082883] RPC:       __rpc_wake_up_task done
> <4>[ 6564.082885] RPC:       xs_tcp_state_change client ffff8a673b146800...
> <4>[ 6564.082887] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
> <4>[ 6564.082889] RPC:       disconnected transport ffff8a673b146800
> <4>[ 6564.082893] RPC:       wake_up_first(ffff8a673b146970 "xprt_sending")
> <4>[ 6564.082897] RPC:     8 sync task resuming
> <4>[ 6564.082899] RPC:     8 xprt_connect_status: retrying
> <4>[ 6564.082901] RPC:     8 call_connect_status (status -11)
> <4>[ 6564.082903] RPC:     8 call_timeout (minor)
> <4>[ 6564.082905] RPC:     8 call_bind (status 0)
> <4>[ 6564.082907] RPC:     8 call_connect xprt ffff8a673b146800 is not connected
> <4>[ 6564.082909] RPC:     8 xprt_connect xprt ffff8a673b146800 is not connected
> <4>[ 6564.082912] RPC:     8 sleep_on(queue "xprt_pending" time 4296533344)
> <4>[ 6564.082913] RPC:     8 added to queue ffff8a673b146a18 "xprt_pending"
> <4>[ 6564.082914] RPC:     8 setting alarm for 180000 ms
> <4>[ 6564.082914] RPC:       xs_connect scheduled xprt ffff8a673b146800
> <4>[ 6564.082916] RPC:     8 sync task going to sleep
> <4>[ 6564.082919] RPC:       xs_bind 0000:0000:0000:0000:0000:0000:0000:0000:938: ok (0)
> <4>[ 6564.082920] RPC:       worker connecting xprt ffff8a673b146800 via tcp to 2001:4860:4860::8888 (port 2049)
> <4>[ 6564.082923] RPC:       ffff8a673b146800 connect status 99 connected 0 sock state 7
> <4>[ 6564.082924] RPC:     8 __rpc_wake_up_task (now 4296533344)
> <4>[ 6564.082924] RPC:     8 disabling timer
> (and so on, until mount() times out)
> 
> Similar for the IPv6-literal test case, where it's failing to connect to
> 0.0.7.209, so it's affecting IPv4, too. While grepping around I found a
> comment saying "If a UDP socket connect fails, the delay behavior here
> prevents retry floods (hard mounts)." for xs_connect(), but I haven't
> figured out how to trigger the UDP connection code.
> 



-- 
Jeff Layton <jlayton@poochiereds.net>
