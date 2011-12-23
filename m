Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:43261 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480Ab1LWRPX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2011 12:15:23 -0500
Received: by vcbfk14 with SMTP id fk14so7437197vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Dec 2011 09:15:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <70A6F4A9-5285-4BC4-889B-6DCD65D40146@oracle.com>
References: <CAOO4vO7nfROsXh6r6NTPF9MtXXNH0LawT=TfxXUea=wae3tYxw@mail.gmail.com>
	<67C3FBA0-8C89-46B4-80FF-1F043250DED4@oracle.com>
	<7BA9681E-6562-467F-9EBE-45F768E057B2@oracle.com>
	<CAOO4vO6KnNxEbs96OPi2oCYsy9PxUU=pnFuE3T2BhOwvcC-SRA@mail.gmail.com>
	<70A6F4A9-5285-4BC4-889B-6DCD65D40146@oracle.com>
Date: Fri, 23 Dec 2011 12:15:22 -0500
Message-ID: <CAOO4vO5mxtOEcXugJUQLofJhCxcsDb282+_efskETOiEnPGNxw@mail.gmail.com>
Subject: Re: NFSv4 empty RPC thrashing?
From: Paul Anderson <pha@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Our new plan is to upgrade all client/server kernels to 3.0.12 and
retry in mid-January time frame.  We should be able to reproduce this
and one other possible problem quickly then.

Thanks, all!

Paul

On Thu, Dec 22, 2011 at 2:48 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Dec 22, 2011, at 2:37 PM, Paul Anderson wrote:
>
>> See way below for inline comments...
>>
>> On Thu, Dec 22, 2011 at 2:25 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>> On Dec 22, 2011, at 1:36 PM, Chuck Lever wrote:
>>>
>>>> Hi Paul, long time!
>>>>
>>>> On Dec 22, 2011, at 1:31 PM, Paul Anderson wrote:
>>>>
>>>>> Issue: extremely high rate packets like so (tcpdump):
>>>>>
>>>>> 16:31:09.308678 IP (tos 0x0, ttl 64, id 41517, offset 0, flags [DF],
>>>>> proto TCP (6), length 144)
>>>>>   r20.xxx.edu.1362383749 > nfsb.xxx.edu.nfs: 88 null
>>>>> 16:31:09.308895 IP (tos 0x0, ttl 64, id 22578, offset 0, flags [DF],
>>>>> proto TCP (6), length 100)
>>>>>   nfsb.xxx.edu.nfs > r20.xxx.edu.1362383749: reply ok 44 null
>>>>> 16:31:09.308926 IP (tos 0x0, ttl 64, id 41518, offset 0, flags [DF],
>>>>> proto TCP (6), length 192)
>>>>>   r20.xxx.edu.1379160965 > nfsb.xxx.edu.nfs: 136 null
>>>>>
>>>>> All linux kernels are from kernel.org, version 2.6.38.5 with the
>>>>> addition of Mosix.  All userland is Ubuntu 10.04LTS.
>>>>>
>>>>> Scenario: the compute cluster is composed of 50-60 compute nodes, and
>>>>> 10 or so head nodes that act as compute/login and high rate NFS
>>>>> serving, for the purpose of largely sequential processing of high
>>>>> volume genetic sequencing data (one recent job was 50-70TiBytes in, 50
>>>>> TiBytes out).  We see this problem regularly (two servers are
>>>>> currently being hit this way right now), and is apparently cleared
>>>>> only on reboot of the server.
>>>>>
>>>>> Something in our use of the cluster appears to be triggering what
>>>>> looks like a race condition in the NFSv4 client/server communications.
>>>>> This issue prevents us from using NFS reliably in our cluster.
>>>>> Although we do very high I/O at times, this alone does not appear to
>>>>> be the trigger.  It is possibly a related to a problem of having SLURM
>>>>> starting 200-300 jobs at once, where each job hits a common NFS
>>>>> fileserver for the program binaries, for example.  In our cluster
>>>>> testing, this appears to reliably cause about half the jobs to fail
>>>>> while loading the program itself - they hang in D state indefinitely,
>>>>> but are killable.
>>>>>
>>>>> Looking at dozens of clients, we can do tcpdump, and see messages
>>>>> similar to the above being sent at a high rate from the gigabit
>>>>> connected compute nodes - the main indication being a context switch
>>>>> rate of 20-30K per second.  The 10 gigabit connected server is
>>>>> functioning, but seeing context switch rates of 200-300K per second -
>>>>> an exceptional rate that appears to slow down NFS services for all
>>>>> other users.  I have not done any extensive packet capture to
>>>>> determine actual traffic rates, but am pretty sure it is limited by
>>>>> wire speed and CPU.
>>>>>
>>>>> The client nodes in this scenario are not actively being used - some
>>>>> show zero processes in D state, others show dozens of jobs stuck in D
>>>>> state (these jobs are unkillable) - the NFSv4 server shows nfsd jobs
>>>>> running flat out.
>>>>>
>>>>> Mount commands look like this:
>>>>> for h in $servers do ;
>>>>>   mount -t nfs4 -o rw,soft,intr,nodev,nosuid,async ${h}:/ /net/$h
>>>>> done
>>>>>
>>>>> The NFSv4 servers all start using stock Ubuntu 10.04 setup - no tuning
>>>>> has been done.
>>>>>
>>>>> We can trivially get packet captures with more packets, but they are
>>>>> all similar - 15-20 client nodes all pounding one NFS server node.
>>>>
>>>> We'd need to see full-frame raw captures.  "tcpdump -s0 -w /tmp/raw"  Let's see a few megabytes.
>>>>
>>>> On the face of it, it looks like it could be a state reclaim loop, but I can't say until I see a full network capture.
>>>
>>> Paul sent me a pair of pcap traces off-list.
>>>
>>> This is yet another a state reclaim loop.  The server is returning NFS4ERR_EXPIRED to a READ request, but the client's subsequent RENEW gets NFS4_OK, so it doesn't do any state recovery.  It simply keeps retrying the READ.
>>>
>>> Paul, have you tried upgrading your clients to the latest kernel.org release?  Was there a recent network partition or server reboot that triggers these events?
>>
>> We are evaluating a move to 3.0.x, and hope to be able to do that
>> sooner rather than later.  The impetus there is a set of improvements
>> in XFS dirty page flushing that we hope will reduce filesystem
>> corruption on normal reboots.
>
> I thought all those issues were cleared up by 2.6.38.  Good luck...
>
>> The two NFS servers in question were recently rebooted (one yesterday
>> shows this problem, the one I gave Chuck pcaps from was 8 days ago).
>> It would typically be the case on reboot that numerous processes in
>> the compute cluster would be attempting to access files, mostly
>> reading, but some writing.  I have not noticed if the thrashing
>> problem appears immediately on reboot - I thought it was not
>> instantaneous, but I could be wrong.
>
> For extra credit, you could try to capture network traffic on the clients while the server is rebooting to see if we can watch the putative state reclaim failure as it happens.  I'm guessing you'd have to wait until just after the server's grace period expires (90 seconds?) before things start going ka-fluey.
>
> Unless this is unbearable, I'd wait though until you have 3.0 deployed on your clients.  Either that will fix your problem, or it will be easier for us to patch if it doesn't.
>
>>> One reason this might happen is if the client is using an expired state ID for the READ, and then uses a valid client ID during the RENEW request.  This can happen if the client failed, some time earlier, to completely reclaim state after a server outage.
>>>
>> Since we rarely, if ever reboot the entire cluster at once, this is plausible.
>>
>>
>> Paul
>>
>>
>>>
>>> Bruce, is there any way to look at the state ID and client ID tokens to verify they are for the same lease?
>>>
>>> --
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>>
>>>
>>>
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
