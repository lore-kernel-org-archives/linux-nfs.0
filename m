Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kalahimbra.net ([138.201.151.60]:42128 "EHLO
        mail.kalahimbra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755697AbeFYUvb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2018 16:51:31 -0400
Received: from [192.168.178.46] (p5DC4FA69.dip0.t-ipconnect.de [93.196.250.105])
        by mail.kalahimbra.net (Postfix) with ESMTPSA id 150A120223
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jun 2018 22:51:07 +0200 (CEST)
Subject: Re: Commit which exposes blocked tasks with NFSv4.0 and Kerberos
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <12dbf081-259b-edbc-bf4e-d9dc1b77fc9b@uni-passau.de>
 <7545bff284c4f03efed693faaa5fa6633c08d927.camel@hammerspace.com>
From: =?UTF-8?B?QXJtaW4gR3LDtsOfbGluZ2Vy?=
        <armin.groesslinger@uni-passau.de>
Message-ID: <2514f048-aae4-19a2-f142-acb6b8a3623b@uni-passau.de>
Date: Mon, 25 Jun 2018 22:51:29 +0200
MIME-Version: 1.0
In-Reply-To: <7545bff284c4f03efed693faaa5fa6633c08d927.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2018-06-24 at 22:56, Trond Myklebust wrote:
> On Sun, 2018-06-24 at 22:30 +0200, Armin Größlinger wrote:
>> Meanwhile, I have been able to do some bisecting of kernel sources to
>> find a commit which exposes the hangs. It seems that since commit
>>
>> 2aca5b869ace67a63aab895659e5dc14c33a4d6e
>> SUNRPC: Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT
>>
>> (introduced with v3.18-rc1) the uninterruptible hangs occur. When I
>> revert this commit, then I do not observe the uninterruptible hangs.
>> I've tested this on Ubuntu 16.04's 4.4 kernel and Debian 9's 4.9
>> kernel
>> and several stock kernels.
> 
> That's the patch that implements this part of the NFSv4 spec:
>  https://tools.ietf.org/html/rfc7530#section-3.1.1

I don't think the commit I referred to is the problem,
I think it exposes the underlying problem.

> So are you seeing the connection break when these hangs occur?

Sometimes the server (with Debian's 4.9.88 kernel) logs

[  194.473842] rpc-srv/tcp: nfsd: sent only 204 when sending 232 bytes -
shuttting down socket

but not always when the hang occurs. Is there another way to check if
the connection is "broken"?

> If the
> connection hasn't broken, then the problem is more likely to be the
> server silently dropping requests, and hence failing to meet the
> obligation to reply to the client's RPC call (as spelled out in the
> above section of the spec).

Initially (in our group at the university) we observed the problem with
a Nexenta NFS server. I could not reproduce the problem with a FreeBSD
server. In addition, the problem seems to be very timing sensitive: it
occurs less when our Nexenta server under a heavier load and I cannot
reproduce it with my test VMs when I disable KVM acceleration (so the
VMs run 2-5 times slower).

I now tried also with Linux 4.18-rc2 as NFS server (instead of 4.9.88
from Debian Stretch) and then I could not observe the hanging tasks on
the client but the test program seems to "pause" for 30-120 seconds
every few iterations (and continues after the pause). After 2.5 hours,
the 2 GB RAM of the client were almost completely consumed by the kernel
(i.e., commands on the shell failed with "cannot fork: Cannot allocate
memory"), so there seems to be a memory leak?

With 4.18-rc2 as NFS client, I still see the OOM killer killing all
processes a few seconds after starting my test program (as mentioned in
my previous email).

With 4.18-rc2 as NFS server, I see many messages like

[ 1098.832570] rpc-srv/tcp: nfsd: got error -104 when sending 232 bytes
- shutting down socket
[ 1137.164829] rpc-srv/tcp: nfsd: sent only 204 when sending 232 bytes -
shutting down socket
[ 1211.284693] rpc-srv/tcp: nfsd: got error -104 when sending 232 bytes
- shutting down socket
[ 1236.512956] rpc-srv/tcp: nfsd: got error -104 when sending 232 bytes
- shutting down socket
[ 1258.140792] rpc-srv/tcp: nfsd: sent only 204 when sending 232 bytes -
shutting down socket
[ 1299.744482] rpc-srv/tcp: nfsd: sent only 204 when sending 232 bytes -
shutting down socket
[ 1372.608731] rpc-srv/tcp: nfsd: sent only 204 when sending 232 bytes -
shutting down socket
[ 1376.272594] rpc-srv/tcp: nfsd: sent only 204 when sending 232 bytes -
shutting down socket
[ 1376.412361] rpc-srv/tcp: nfsd: sent only 204 when sending 232 bytes -
shutting down socket
[ 1386.340604] rpc-srv/tcp: nfsd: got error -104 when sending 232 bytes
- shutting down socket
[ 1406.828262] rpc-srv/tcp: nfsd: got error -32 when sending 232 bytes -
shutting down socket

on the server (but the client keeps running - with 30-120 second pauses
mentioned above) and the port of the NFS connection changes frequently
(every few seconds).

I'm not sure what to try next and whether to blame the server or the
client for the misbehavior.

Regards,
Armin


