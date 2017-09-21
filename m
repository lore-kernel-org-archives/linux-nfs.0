Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:44725 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751788AbdIURFz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Sep 2017 13:05:55 -0400
Received: by mail-qk0-f170.google.com with SMTP id b23so6424089qkg.1
        for <linux-nfs@vger.kernel.org>; Thu, 21 Sep 2017 10:05:55 -0700 (PDT)
Message-ID: <1506013553.7873.13.camel@redhat.com>
Subject: Re: [Bug ?] Permanent FIN_WAIT_2 state on NFS client with bad NFS
 server
From: David Wysochanski <dwysocha@redhat.com>
To: Manjunath Patil <mbpatil.linux@gmail.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 21 Sep 2017 13:05:53 -0400
In-Reply-To: <CANnNPBYoZFcXZJopjcPWZ5jdRQoQV16VVHM+=A=Pm2=_GZ=Msw@mail.gmail.com>
References: <CANnNPBYoZFcXZJopjcPWZ5jdRQoQV16VVHM+=A=Pm2=_GZ=Msw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-09-20 at 15:17 -0700, Manjunath Patil wrote:
> Hi,
> 
> With autoclose trying to close the connection, after the idle timeout
> in NFSv3 mounts,
> a bad NFS server may not send the final FIN, leading the client stay
> in FIN_WAIT_2 state forever.
> This is easily reproducible by simulating the bad server behavior. I
> used 'netstat -an | grep 2049' to observer socket state.
> 
How long did you wait and how did you simulate the failure?  I am very
interested in your test case.

I am not sure which kernels you are testing but in my tests (simulating
a dropped FIN from the NFS server but not blocking the ACK or further
packets) I've seen that the sunrpc TCP keepalive commit
7f260e8575bf53b93b77978c1e39f8e67612759c caused a RST to happen after
around 4 minutes so it won't get stuck forever.  The only way I could
get a FIN_WAIT_2 indefinite hang was to block all traffic from the
server port which arguably, if that happens you'll get a hang but only a
bit later so I concluded such a test seems invalid.


> This is will also stall the other RPC requests from connecting and
> proceeding as XPRT_CLOSING flag is already set.
> 
> This can be observed in the 4.14-rc1 as well.
> This behavior is introduced with the following commit -
> caf4ccd SUNRPC: Make xs_tcp_close() do a socket shutdown rather than a
> sock_release
> 
> Once we reverse this commit, the FIN_WAIT_2 state lasts only for 60 seconds.
> 

Interesting maybe the problem is back on some upstream kernels (I mostly
test RHEL6, RHEL7, and some fedora).  Do you know what is actually
firing to get the TCP connection out of FIN_WAIT_2?  Have you tried to
trace this?

I first saw FIN_WAIT_2 hangs after commit
9cbc94fb06f98de0e8d393eaff09c790f4c3ba46 which removed
xs_tcp_scheduler_linger_timeout was backported to RHEL6.  Later we added
the TCP keepalive commit which seems to have resolved these hangs as far
as I know.


> Any thoughts correcting this behavior?
> or is this behavior expected?
> 
Depending on your test, it may be expected behavior but it sounds like
not if truly you are stuck in FIN_WAIT_2 indefinitely and you've not got
some permanent firewall rule blocking traffic, etc.



> -Thanks,
> Manjunath
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


