Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33124 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbdIVTVQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Sep 2017 15:21:16 -0400
Received: by mail-qt0-f196.google.com with SMTP id b1so1299051qtc.0
        for <linux-nfs@vger.kernel.org>; Fri, 22 Sep 2017 12:21:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1506013553.7873.13.camel@redhat.com>
References: <CANnNPBYoZFcXZJopjcPWZ5jdRQoQV16VVHM+=A=Pm2=_GZ=Msw@mail.gmail.com>
 <1506013553.7873.13.camel@redhat.com>
From: Manjunath Patil <mbpatil.linux@gmail.com>
Date: Fri, 22 Sep 2017 12:21:13 -0700
Message-ID: <CANnNPBZr-RDFoLrogkt7yMHR-+t1bvxj5WOu2OS4K3Dmp5MHCQ@mail.gmail.com>
Subject: Re: [Bug ?] Permanent FIN_WAIT_2 state on NFS client with bad NFS server
To: David Wysochanski <dwysocha@redhat.com>
Cc: linux-nfs@vger.kernel.org, manjunath.b.patil@oracle.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David,

On Thu, Sep 21, 2017 at 10:05 AM, David Wysochanski <dwysocha@redhat.com> wrote:
> On Wed, 2017-09-20 at 15:17 -0700, Manjunath Patil wrote:
>> Hi,
>>
>> With autoclose trying to close the connection, after the idle timeout
>> in NFSv3 mounts,
>> a bad NFS server may not send the final FIN, leading the client stay
>> in FIN_WAIT_2 state forever.
>> This is easily reproducible by simulating the bad server behavior. I
>> used 'netstat -an | grep 2049' to observer socket state.
>>
> How long did you wait and how did you simulate the failure?  I am very
> interested in your test case.
I observer this in ct environment. In this case the fin_wait_2 stayed forever.
ct had to restart the node to get out.

We tried to simulate this behavior in Linux nfs server by stopping the
incoming FIN
for 2049 port inside kernel. This prevented the server from sending
the final FIN for some time.

The linux server eventually sent a FIN after some delay. Though I am
not sure, I think this is due to

/* apparently the "standard" is that clients close
 * idle connections after 5 minutes, servers after
 * 6 minutes
 *   http://www.connectathon.org/talks96/nfstcp.pdf
 */
static int svc_conn_age_period = 6*60;

>
> I am not sure which kernels you are testing but in my tests (simulating
> a dropped FIN from the NFS server but not blocking the ACK or further
> packets) I've seen that the sunrpc TCP keepalive commit
> 7f260e8575bf53b93b77978c1e39f8e67612759c caused a RST to happen after
> around 4 minutes so it won't get stuck forever.  The only way I could
> get a FIN_WAIT_2 indefinite hang was to block all traffic from the
> server port which arguably, if that happens you'll get a hang but only a
> bit later so I concluded such a test seems invalid.
I have observed this behavior with OL6 and upsteam 4.14-rc1 kernel.
I do not see tcp-keepalive causing a RST, rather the FIN_WAIT_2 state
stays till it gets
the final FIN from server.
>
>
>> This is will also stall the other RPC requests from connecting and
>> proceeding as XPRT_CLOSING flag is already set.
>>
>> This can be observed in the 4.14-rc1 as well.
>> This behavior is introduced with the following commit -
>> caf4ccd SUNRPC: Make xs_tcp_close() do a socket shutdown rather than a
>> sock_release
>>
>> Once we reverse this commit, the FIN_WAIT_2 state lasts only for 60 seconds.
>>
>
> Interesting maybe the problem is back on some upstream kernels (I mostly
> test RHEL6, RHEL7, and some fedora).  Do you know what is actually
> firing to get the TCP connection out of FIN_WAIT_2?  Have you tried to
> trace this?
I think this is because, caf4ccd introduces the half close behavior to
xprt_autoclose()
In this case, its expected to wait for final FIN from server. However
if a bad server
chose to not send the final FIN, I think we do not have a  backup plan
on client side.

In the earlier behavior of full close, the tcp clears the FIN_WAIT_2
state after /proc/sys/net/ipv4/tcp_fin_timeout
which is 60 seconds.

>
> I first saw FIN_WAIT_2 hangs after commit
> 9cbc94fb06f98de0e8d393eaff09c790f4c3ba46 which removed
> xs_tcp_scheduler_linger_timeout was backported to RHEL6.  Later we added
> the TCP keepalive commit which seems to have resolved these hangs as far
> as I know.
>
>
>> Any thoughts correcting this behavior?
>> or is this behavior expected?
>>
> Depending on your test, it may be expected behavior but it sounds like
> not if truly you are stuck in FIN_WAIT_2 indefinitely and you've not got
> some permanent firewall rule blocking traffic, etc.
>
>
>
>> -Thanks,
>> Manjunath
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
-Thanks,
Manjunath
