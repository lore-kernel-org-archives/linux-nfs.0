Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr30130.outbound.protection.outlook.com ([40.107.3.130]:6883
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752200AbdJPPSm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Oct 2017 11:18:42 -0400
Reply-To: skinsbursky@virtuozzo.com
Subject: Re: [RFC} NFS client issue with exclusive creation when server died
 in the middle
To: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: "Sergey.Lysanov@acronis.com" <Sergey.Lysanov@acronis.com>
References: <31f5b837-3e74-753b-2ebd-135c8aaef96f@virtuozzo.com>
 <1508165865.3096.10.camel@primarydata.com>
From: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
Message-ID: <193aa760-eae0-94c2-f949-63be6a850b88@virtuozzo.com>
Date: Mon, 16 Oct 2017 17:18:36 +0200
MIME-Version: 1.0
In-Reply-To: <1508165865.3096.10.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



16.10.2017 16:57, Trond Myklebust пишет:
> On Mon, 2017-10-16 at 10:49 +0200, Stanislav Kinsburskiy wrote:
>> Hi,
>>
>> We discovered an issue with NFSv4.0 mount.
>> Server has crashed (or killed by OOM; it was Ganesha) on exclusive
>> open-create operation after file was actually created, but no
>> response was send to the client.
>> Server was restarted (with grace period), and next clients attempt to
>> create a file after server is ready fails with EEXIST.
>> This is, probably, because for each open request client creates
>> opendata and puts new jiffies value as the verifier (in
>> nfs4_opendata_alloc) in the request.
>> Does it sound like a client issue?
>>
> 
> Hi Stanislav,
> 
> If it didn't receive a reply, the client should be reusing the same
> opendata for the resend of the operation after state recover is
> complete. Doesn't it?
> 

Hi Trond,

Well, yes, it should. But looks like it doesn't, unfortunately. That's at least what we saw on the server side.
It was git clone operation and server crashed somewhere in the middle.
Then server was migrated (we have a shared storage), but migration uses grace logic, so it's equal to server restart.
That what we saw during clone:

nfs server 192.168.56.201:/0200000000000003: resource temporarily unavailable (jukebox)
nfs server 192.168.56.201:/0200000000000003: resource temporarily unavailable (jukebox)
nfs server 192.168.56.201:/0200000000000003: resource temporarily unavailable (jukebox)
nfs server 192.168.56.201:/0200000000000003: resource temporarily unavailable (jukebox)
nfs server 192.168.56.201:/0200000000000003: resource available again

then git failed with the following:

error: unable to create file src/test/cli/ceph-authtool/list-empty-bin.t (File exists) 

because ganesha received OPEN operation with createmode4 = exclusive4 and with the verifier that initialized by NFS client:

verf[0] = jiffies;
verf[1] = current->pid;
memcpy(p->o_arg.u.verifier.data, verf, sizeof(p->o_arg.u.verifier.data));

And this verifier didn't match the one, which created file had already.
So, our assumption, that verifier has changed, because otherwise Ganesha returns 0.

Below is my understanding (hopefully correct):
1) client started open/create request in nfs4_do_open (where there is a loop around _nfs4_do_open)
2) it received a non-fatal error from server (NFS4ERR_BAD_STATEID or other)
3) it repeats open/create operation, but with new verifier, which is allocated in:

_nfs4_do_open
  nfs4_opendata_alloc

while is such a case client has to use old verifier. But I was released already upon failed open/create request.

What do you think about it?

