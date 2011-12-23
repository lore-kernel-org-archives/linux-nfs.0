Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:46988 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757623Ab1LWS4q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2011 13:56:46 -0500
Received: by werm1 with SMTP id m1so4126132wer.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Dec 2011 10:56:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <7BA9681E-6562-467F-9EBE-45F768E057B2@oracle.com>
References: <CAOO4vO7nfROsXh6r6NTPF9MtXXNH0LawT=TfxXUea=wae3tYxw@mail.gmail.com>
	<67C3FBA0-8C89-46B4-80FF-1F043250DED4@oracle.com>
	<7BA9681E-6562-467F-9EBE-45F768E057B2@oracle.com>
Date: Fri, 23 Dec 2011 13:56:44 -0500
Message-ID: <CAHVgHyW6yccKzEJKQQwVpjNWB5CL0UAdsXKGf1E86ujv1FWUyw@mail.gmail.com>
Subject: Re: NFSv4 empty RPC thrashing?
From: Andy Adamson <androsadamson@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Paul Anderson <pha@umich.edu>, "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 0ced63d1 introduced in 3.0-rc1 fixes this condition.

NFSv4: Handle expired stateids when the lease is still valid

Currently, if the server returns NFS4ERR_EXPIRED in reply to a READ or
WRITE, but the RENEW test determines that the lease is still active, we
fail to recover and end up looping forever in a READ/WRITE + RENEW death
spiral.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org

-->Andy

On Thu, Dec 22, 2011 at 2:25 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Dec 22, 2011, at 1:36 PM, Chuck Lever wrote:
>
>> Hi Paul, long time!
>>
>> On Dec 22, 2011, at 1:31 PM, Paul Anderson wrote:
>>
>>> Issue: extremely high rate packets like so (tcpdump):
>>>
>>> 16:31:09.308678 IP (tos 0x0, ttl 64, id 41517, offset 0, flags [DF],
>>> proto TCP (6), length 144)
>>>   r20.xxx.edu.1362383749 > nfsb.xxx.edu.nfs: 88 null
>>> 16:31:09.308895 IP (tos 0x0, ttl 64, id 22578, offset 0, flags [DF],
>>> proto TCP (6), length 100)
>>>   nfsb.xxx.edu.nfs > r20.xxx.edu.1362383749: reply ok 44 null
>>> 16:31:09.308926 IP (tos 0x0, ttl 64, id 41518, offset 0, flags [DF],
>>> proto TCP (6), length 192)
>>>   r20.xxx.edu.1379160965 > nfsb.xxx.edu.nfs: 136 null
>>>
>>> All linux kernels are from kernel.org, version 2.6.38.5 with the
>>> addition of Mosix.  All userland is Ubuntu 10.04LTS.
>>>
>>> Scenario: the compute cluster is composed of 50-60 compute nodes, and
>>> 10 or so head nodes that act as compute/login and high rate NFS
>>> serving, for the purpose of largely sequential processing of high
>>> volume genetic sequencing data (one recent job was 50-70TiBytes in, 50
>>> TiBytes out).  We see this problem regularly (two servers are
>>> currently being hit this way right now), and is apparently cleared
>>> only on reboot of the server.
>>>
>>> Something in our use of the cluster appears to be triggering what
>>> looks like a race condition in the NFSv4 client/server communications.
>>> This issue prevents us from using NFS reliably in our cluster.
>>> Although we do very high I/O at times, this alone does not appear to
>>> be the trigger.  It is possibly a related to a problem of having SLURM
>>> starting 200-300 jobs at once, where each job hits a common NFS
>>> fileserver for the program binaries, for example.  In our cluster
>>> testing, this appears to reliably cause about half the jobs to fail
>>> while loading the program itself - they hang in D state indefinitely,
>>> but are killable.
>>>
>>> Looking at dozens of clients, we can do tcpdump, and see messages
>>> similar to the above being sent at a high rate from the gigabit
>>> connected compute nodes - the main indication being a context switch
>>> rate of 20-30K per second.  The 10 gigabit connected server is
>>> functioning, but seeing context switch rates of 200-300K per second -
>>> an exceptional rate that appears to slow down NFS services for all
>>> other users.  I have not done any extensive packet capture to
>>> determine actual traffic rates, but am pretty sure it is limited by
>>> wire speed and CPU.
>>>
>>> The client nodes in this scenario are not actively being used - some
>>> show zero processes in D state, others show dozens of jobs stuck in D
>>> state (these jobs are unkillable) - the NFSv4 server shows nfsd jobs
>>> running flat out.
>>>
>>> Mount commands look like this:
>>> for h in $servers do ;
>>>   mount -t nfs4 -o rw,soft,intr,nodev,nosuid,async ${h}:/ /net/$h
>>> done
>>>
>>> The NFSv4 servers all start using stock Ubuntu 10.04 setup - no tuning
>>> has been done.
>>>
>>> We can trivially get packet captures with more packets, but they are
>>> all similar - 15-20 client nodes all pounding one NFS server node.
>>
>> We'd need to see full-frame raw captures.  "tcpdump -s0 -w /tmp/raw"  Let's see a few megabytes.
>>
>> On the face of it, it looks like it could be a state reclaim loop, but I can't say until I see a full network capture.
>
> Paul sent me a pair of pcap traces off-list.
>
> This is yet another a state reclaim loop.  The server is returning NFS4ERR_EXPIRED to a READ request, but the client's subsequent RENEW gets NFS4_OK, so it doesn't do any state recovery.  It simply keeps retrying the READ.
>
> Paul, have you tried upgrading your clients to the latest kernel.org release?  Was there a recent network partition or server reboot that triggers these events?
>
> One reason this might happen is if the client is using an expired state ID for the READ, and then uses a valid client ID during the RENEW request.  This can happen if the client failed, some time earlier, to completely reclaim state after a server outage.
>
> Bruce, is there any way to look at the state ID and client ID tokens to verify they are for the same lease?
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
