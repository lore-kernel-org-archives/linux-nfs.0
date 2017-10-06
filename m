Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:57328 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751474AbdJFWM5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Oct 2017 18:12:57 -0400
Received: by mail-qt0-f195.google.com with SMTP id 34so16966305qtb.13
        for <linux-nfs@vger.kernel.org>; Fri, 06 Oct 2017 15:12:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1507323087.10354.11.camel@primarydata.com>
References: <CANnNPBYoZFcXZJopjcPWZ5jdRQoQV16VVHM+=A=Pm2=_GZ=Msw@mail.gmail.com>
 <1506013553.7873.13.camel@redhat.com> <CANnNPBZr-RDFoLrogkt7yMHR-+t1bvxj5WOu2OS4K3Dmp5MHCQ@mail.gmail.com>
 <CANnNPBaSbrsggKA07T7TX8Lznj=NG_33P9XjxETh4FEVYO2q2Q@mail.gmail.com> <1507323087.10354.11.camel@primarydata.com>
From: Manjunath Patil <mbpatil.linux@gmail.com>
Date: Fri, 6 Oct 2017 15:12:56 -0700
Message-ID: <CANnNPBb--DVL1263G=BQSW-kK7QacWEE8sL+KNrtdYpCwq6HJA@mail.gmail.com>
Subject: Re: [Bug ?] Permanent FIN_WAIT_2 state on NFS client with bad NFS server
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "dwysocha@redhat.com" <dwysocha@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "manjunath.b.patil@oracle.com" <manjunath.b.patil@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 6, 2017 at 1:51 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> On Fri, 2017-10-06 at 12:13 -0700, Manjunath Patil wrote:
>> Hi David,
>>
>> On Fri, Sep 22, 2017 at 12:21 PM, Manjunath Patil
>> <mbpatil.linux@gmail.com> wrote:
>> > Hi David,
>> >
>> > On Thu, Sep 21, 2017 at 10:05 AM, David Wysochanski <dwysocha@redha
>> > t.com> wrote:
>> > > On Wed, 2017-09-20 at 15:17 -0700, Manjunath Patil wrote:
>> > > > Hi,
>> > > >
>> > > > With autoclose trying to close the connection, after the idle
>> > > > timeout
>> > > > in NFSv3 mounts,
>> > > > a bad NFS server may not send the final FIN, leading the client
>> > > > stay
>> > > > in FIN_WAIT_2 state forever.
>> > > > This is easily reproducible by simulating the bad server
>> > > > behavior. I
>> > > > used 'netstat -an | grep 2049' to observer socket state.
>> > > >
>> > >
>> > > How long did you wait and how did you simulate the failure?  I am
>> > > very
>> > > interested in your test case.
>> >
>> > I observer this in ct environment. In this case the fin_wait_2
>> > stayed forever.
>> > ct had to restart the node to get out.
>> >
>> > We tried to simulate this behavior in Linux nfs server by stopping
>> > the
>> > incoming FIN
>> > for 2049 port inside kernel. This prevented the server from sending
>> > the final FIN for some time.
>> >
>> > The linux server eventually sent a FIN after some delay. Though I
>> > am
>> > not sure, I think this is due to
>> >
>> > /* apparently the "standard" is that clients close
>> >  * idle connections after 5 minutes, servers after
>> >  * 6 minutes
>> >  *   http://www.connectathon.org/talks96/nfstcp.pdf
>> >  */
>> > static int svc_conn_age_period = 6*60;
>>
>> I tried to increase this value.
>> After setting this value to a high value [60*60], I could see the
>> client staying in FIN_WAIT_2 state forever.
>>
>> To repeat, my test case is,
>> 1. Take a nfs server and make it not send the FIN on 2049 port
>> 2. Use any upstream kernel [I used 4.14-rc1] as nfs client
>> 3. Let the mount be idle for 5 mins so that autoclose gets triggered.
>> 4. after this, client stays in FIN_WAIT_2 state[we can observer it
>> with netstat -an | grep 2049].
>> 5. At this point no new NFS connection is allowed on this port. So
>> mount is hung for application.
>
> What do you mean when you say "make it not send FIN"? Are you just
> filtering all packets with a FIN flag set? Normally, a FIN is expected
> to be ACKed by the recipient so that it can be retransmitted if lost.
In my test-case I prevented TCP layer itself[by code change] from
sending FIN packet on port 2049.

The client sends FIN, gets a ACK
then
Client expects final FIN, server never sends it.
>
>
> However, even if it does not receive the FIN from the server, then the
> FIN_WAIT2 state should automatically time out after
> /proc/sys/net/ipv4/tcp_fin_timeout seconds (see the description in the
> SO_LINGER2 socket option). Isn't this working?
>
I think this behavior is true only for full close of socket. The
present issue is happening only with autoclose()
The autoclose behavior is changed from full close to half close with
the following commit -
caf4ccd SUNRPC: Make xs_tcp_close() do a socket shutdown rather than a
sock_release

The following commit might be related too -
9cbc94f SUNRPC: Remove TCP socket linger code

-Thanks,
manjunath
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
