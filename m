Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:35808 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751610AbdGaUuG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jul 2017 16:50:06 -0400
Received: by mail-qt0-f171.google.com with SMTP id p3so113312278qtg.2
        for <linux-nfs@vger.kernel.org>; Mon, 31 Jul 2017 13:50:06 -0700 (PDT)
Message-ID: <1501534204.4663.18.camel@redhat.com>
Subject: Re: lockd: server not responding
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 31 Jul 2017 16:50:04 -0400
In-Reply-To: <7B576AFA-7EF1-459E-827E-8793F50DB50C@oracle.com>
References: <7B576AFA-7EF1-459E-827E-8793F50DB50C@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-07-31 at 16:28 -0400, Chuck Lever wrote:
> Hi Jeff-
> 
> Observed with v4.13-rc[23] during NFSv3 connectation testing.
> The lock test stalls for a minute or two during test #7.
> 
> If you haven't already seen this, I can dig deeper.
> 
> Jul 31 16:11:08 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:864 for /export/tmp (/export/tmp)
> Jul 31 16:11:28 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:740 for /export/tmp (/export/tmp)
> Jul 31 16:11:28 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:844 for /export/tmp (/export/tmp)
> Jul 31 16:12:35 klimt kernel: lockd: server manet.1015granger.net not responding, timed out
> Jul 31 16:12:49 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:989 for /export/tmp (/export/tmp)
> Jul 31 16:12:49 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:844 for /export/tmp (/export/tmp)
> Jul 31 16:13:10 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:813 for /export/tmp (/export/tmp)
> Jul 31 16:13:10 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:860 for /export/tmp (/export/tmp)
> Jul 31 16:14:25 klimt kernel: lockd: server manet.1015granger.net not responding, timed out
> Jul 31 16:14:30 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:636 for /export/tmp (/export/tmp)
> Jul 31 16:14:30 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:960 for /export/tmp (/export/tmp)
> Jul 31 16:14:51 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:884 for /export/tmp (/export/tmp)
> Jul 31 16:14:51 klimt rpc.mountd[1640]: authenticated mount request from 192.168.2.2:822 for /export/tmp (/export/tmp)
> Jul 31 16:17:02 klimt rpc.mountd[1640]: authenticated unmount request from 192.168.2.2:778 for /export/tmp (/export/tmp)
> 
> 

That's not anything that I've seen, but I haven't been doing any v3
testing. Let me know what you find.

FWIW, the only real file locking change this cycle was a patch from
Christoph to clean up the fcntl getlk/setlk syscalls. lockd hooks in a
bit below that layer so I'd be surprised if that would affect it.

-- 
Jeff Layton <jlayton@redhat.com>
