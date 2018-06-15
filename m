Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:50156 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755699AbeFOOXW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jun 2018 10:23:22 -0400
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [BUG BISECT] NFSv4 client fails on Flush Journal to Persistent
 Storage
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAJKOXPfX0CytKcYDaDAYYuCQjk-mcGjFRHfZco-wPQsc4G1agA@mail.gmail.com>
Date: Fri, 15 Jun 2018 10:23:04 -0400
Cc: Sudeep Holla <sudeep.holla@arm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        "linux-samsung-soc@vger.kernel.org"
        <linux-samsung-soc@vger.kernel.org>
Message-Id: <BCD39D7E-EEEC-4EB9-824E-63323C333C88@oracle.com>
References: <CAJKOXPd2rntNOpU1quR9Zm_J22+=pEaj4ZTC_tdZ0zcRYUciFg@mail.gmail.com>
 <CAPKp9uZ79ybkv7dMpcy2GQ9L+rWk+vdExQ48diWWQPOUdDQtSQ@mail.gmail.com>
 <CAJKOXPfX0CytKcYDaDAYYuCQjk-mcGjFRHfZco-wPQsc4G1agA@mail.gmail.com>
To: Krzysztof Kozlowski <krzk@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 15, 2018, at 10:07 AM, Krzysztof Kozlowski <krzk@kernel.org> =
wrote:
>=20
> On Fri, Jun 15, 2018 at 2:53 PM, Sudeep Holla <sudeep.holla@arm.com> =
wrote:
>> Hi,
>>=20
>> On Thu, Jun 7, 2018 at 12:19 PM, Krzysztof Kozlowski =
<krzk@kernel.org> wrote:
>>> Hi,
>>>=20
>>> When booting my boards under recent linux-next, I see failures of =
systemd:
>>>=20
>>> [FAILED] Failed to start Flush Journal to Persistent Storage.
>>> See 'systemctl status systemd-journal-flush.service' for details.
>>>         Starting Create Volatile Files and Directories...
>>> [**    ] A start job is running for Create V=E2=80=A6 [  223.209289] =
nfs:
>>> server 192.168.1.10 not responding, still trying
>>> [  223.209377] nfs: server 192.168.1.10 not responding, still trying
>>>=20
>>> Effectively the boards fails to boot. Example is here:
>>> https://krzk.eu/#/builders/1/builds/2157
>>>=20
>>=20
>> I too encountered the same issue.
>>=20
>>> This was bisected to:
>>> commit 37ac86c3a76c113619b7d9afe0251bbfc04cb80a
>>> Author: Chuck Lever <chuck.lever@oracle.com>
>>> Date:   Fri May 4 15:34:53 2018 -0400
>>>=20
>>>    SUNRPC: Initialize rpc_rqst outside of xprt->reserve_lock
>>>=20
>>>    alloc_slot is a transport-specific op, but initializing an =
rpc_rqst
>>>    is common to all transports. In addition, the only part of =
initial-
>>>    izing an rpc_rqst that needs serialization is getting a fresh =
XID.
>>>=20
>>>    Move rpc_rqst initialization to common code in preparation for
>>>    adding a transport-specific alloc_slot to xprtrdma.
>>>=20
>>>    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>    Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>>=20
>>=20
>> Unfortunately, spent time to bisect independently without seeing this
>> report and got the same culprit.
>>=20
>>>=20
>>> Bisect log attached. Full configuration:
>>> 1. exynos_defconfig
>>> 2. ARMv7, octa-core, Exynos5422 and Exynos4412 (Odroid XU3, U3 and =
others)
>>> 3. NFSv4 client (from Raspberry Pi)
>>>=20
>>=20
>> Yes the issue is seen only with NFSv4 client and with latest systemd =
I think.
>> My Ubuntu 16.04(32bit FS) is  boots fine while 18.04 has the above =
issue.
>> Passing nfsv3 in kernel command line makes it work again.
>=20
> Thanks for reply!
>=20
> I test it on systemd versions 236 and 238... and it fails on both.
> However one board passes always - it is Odroid HC1 with same core
> configuration as described before. Probably there is some different SW
> package on it.
>=20
>>> Let me know if you need any more information.
>>>=20
>>=20
>> Also I was observing this issue with Linus master branch from
>> the time the above patch was merged until today. The issue
>> is no longer seen since this morning however I just enabled lockdep
>> and got these messages.
>=20
> All recent linux-next fail. Today's Linus' tree (4c5e8fc62d6a ("Merge
> tag 'linux-kselftest-4.18-rc1-2' of
> git://git.kernel.org/pub/scm/linux/kernel/git/shuah/linux-kselftest"))
> managed to get up on one board but stuck on different board with the
> same issue.
>=20
> I am quite surprised that there is no response from the author of the
> commit and this was just moved from next (while failing) to Linus'
> tree... bringing the issue to mainline now.

Sorry. This morning is the first time I've seen this report, which was
not To: or Cc'd to me.

Since I don't have access to this kind of hardware, I will have to ask
for your help to perform basic troubleshooting.

Can we start by capturing the network traffic that occurs while you
reproduce the problem? Use tshark or tcpdump on your NFS server, filter
on the IP of the client, and send me (or the list) the raw pcap file.


--
Chuck Lever



