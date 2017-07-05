Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:35325 "EHLO
        mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752057AbdGEU3Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jul 2017 16:29:24 -0400
Received: by mail-vk0-f44.google.com with SMTP id 191so82540vko.2
        for <linux-nfs@vger.kernel.org>; Wed, 05 Jul 2017 13:29:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170702085354.GA20685@kroah.com>
References: <20170628144758.12225-1-trond.myklebust@primarydata.com> <20170702085354.GA20685@kroah.com>
From: Robert Kudyba <rkudyba@fordham.edu>
Date: Wed, 5 Jul 2017 16:29:22 -0400
Message-ID: <CAFHi+KQShB-m6GT87uKO=KN0AF-1t0+uXbW7UE2NFyi_wOSLDg@mail.gmail.com>
Subject: Re: [PATCH] Stable request to fix a reference leak and list corruption
To: Greg KH <greg@kroah.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        stable@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> Could we please queue up the following patch as a stable fix for
>> commit a974deee47? It needs to be applied to v4.10 and older.
>
> Now applied, thanks.

Until kernel 4.11.9 is into Fedora's updates, I downgraded our server
acting as the NIS master to 4.10.16-200. But all NIS users time out
with "ypserv: #011-> Error #-3. Could this be a different issue with
rpcbind or nfs-utils? Here are some debug enabled logs for RPC with a
different error "xs_error_report client ffff8d8223caa000, error=113"

Jul  5 16:13:05 dsm kernel: RPC:       looking up machine cred for service *
Jul  5 16:13:05 dsm kernel: RPC:       set up xprt to 150.108.64.64
(port 2049) via tcp
Jul  5 16:13:05 dsm kernel: RPC:       created transport
ffff8d8223cab800 with 65536 slots
Jul  5 16:13:05 dsm kernel: RPC:       creating nfs client for erdos
(xprt ffff8d8223cab800)
Jul  5 16:13:05 dsm kernel: RPC:       creating GSS authenticator for
client ffff8d8102d37c00
Jul  5 16:13:05 dsm kernel: RPC:       Couldn't create auth handle
(flavor 390004)
Jul  5 16:13:05 dsm kernel: RPC:       destroying transport ffff8d8223cab800
Jul  5 16:13:05 dsm kernel: RPC:       xs_destroy xprt ffff8d8223cab800
Jul  5 16:13:05 dsm kernel: RPC:       xs_close xprt ffff8d8223cab800
Jul  5 16:13:05 dsm kernel: RPC:       disconnected transport ffff8d8223cab800
Jul  5 16:13:05 dsm kernel: RPC:       set up xprt to ourip (port 2049) via tcp
Jul  5 16:13:05 dsm kernel: RPC:       created transport
ffff8d8223caa000 with 65536 slots
Jul  5 16:13:05 dsm kernel: RPC:       creating nfs client for erdos
(xprt ffff8d8223caa000)
Jul  5 16:13:05 dsm kernel: RPC:       creating UNIX authenticator for
client ffff8d8102d37c00
Jul  5 16:13:05 dsm kernel: RPC:       new task initialized, procpid 5281
Jul  5 16:13:05 dsm kernel: RPC:       allocated task ffff8d822385a900
Jul  5 16:13:05 dsm kernel: RPC: 65012 __rpc_execute flags=0x680
Jul  5 16:13:05 dsm kernel: RPC: 65012 call_start nfs4 proc NULL (sync)
Jul  5 16:13:05 dsm kernel: RPC: 65012 call_reserve (status 0)
Jul  5 16:13:05 dsm kernel: RPC: 65012 reserved req ffff8d8102d36000
xid fea54e04
Jul  5 16:13:05 dsm kernel: RPC:       wake_up_first(ffff8d8223caa170
"xprt_sending")
Jul  5 16:13:05 dsm kernel: RPC: 65012 call_reserveresult (status 0)
Jul  5 16:13:05 dsm kernel: RPC: 65012 call_refresh (status 0)
Jul  5 16:13:05 dsm kernel: RPC: 65012 holding NULL cred ffffffffc036e440
Jul  5 16:13:05 dsm kernel: RPC: 65012 refreshing NULL cred ffffffffc036e440
Jul  5 16:13:05 dsm kernel: RPC: 65012 call_refreshresult (status 0)
Jul  5 16:13:05 dsm kernel: RPC: 65012 call_allocate (status 0)
Jul  5 16:13:05 dsm kernel: RPC: 65012 allocated buffer of size 96 at
ffff8d8223caa800
Jul  5 16:13:05 dsm kernel: RPC: 65012 call_bind (status 0)
Jul  5 16:13:05 dsm kernel: RPC: 65012 call_connect xprt
ffff8d8223caa000 is not connected
Jul  5 16:13:05 dsm kernel: RPC: 65012 xprt_connect xprt
ffff8d8223caa000 is not connected
Jul  5 16:13:05 dsm kernel: RPC: 65012 sleep_on(queue "xprt_pending"
time 4557317640)
Jul  5 16:13:05 dsm kernel: RPC: 65012 added to queue ffff8d8223caa218
"xprt_pending"
Jul  5 16:13:05 dsm kernel: RPC: 65012 setting alarm for 60000 ms
Jul  5 16:13:05 dsm kernel: RPC:       xs_connect scheduled xprt
ffff8d8223caa000
Jul  5 16:13:05 dsm kernel: RPC: 65012 sync task going to sleep
Jul  5 16:13:05 dsm kernel: RPC:       xs_bind 0.0.0.0:699: ok (0)
Jul  5 16:13:05 dsm kernel: RPC:       worker connecting xprt
ffff8d8223caa000 via tcp to our ip (port 2049)
Jul  5 16:13:05 dsm kernel: RPC:       ffff8d8223caa000 connect status
115 connected 0 sock state 2
Jul  5 16:13:05 dsm kernel: RPC:       wake_up_first(ffff8d8223caa170
"xprt_sending")
Jul  5 16:13:05 dsm kernel: RPC:       xs_error_report client
ffff8d8223caa000, error=113...
Jul  5 16:13:05 dsm kernel: RPC: 65012 __rpc_wake_up_task (now 4557317640)
Jul  5 16:13:05 dsm kernel: RPC: 65012 disabling timer
Jul  5 16:13:05 dsm kernel: RPC: 65012 removed from queue
ffff8d8223caa218 "xprt_pending"
Jul  5 16:13:05 dsm kernel: RPC:       __rpc_wake_up_task done
Jul  5 16:13:05 dsm kernel: RPC: 65012 sync task resuming
Jul  5 16:13:05 dsm kernel: RPC:       xs_tcp_state_change client
ffff8d8223caa000...
Jul  5 16:13:05 dsm kernel: RPC:       state 7 conn 0 dead 0 zapped 1
sk_shutdown 3
Jul  5 16:13:05 dsm kernel: RPC: 65012 xprt_connect_status: retrying
Jul  5 16:13:05 dsm kernel: RPC: 65012 call_connect_status (status -113)
Jul  5 16:13:05 dsm kernel: RPC:       disconnected transport ffff8d8223caa000
Jul  5 16:13:05 dsm kernel: RPC: 65012 return 0, status -113
