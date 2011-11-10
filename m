Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.citrix.com ([66.165.176.89]:48553 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935349Ab1KJPxP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Nov 2011 10:53:15 -0500
Message-ID: <4EBBF35B.5000606@citrix.com>
Date: Thu, 10 Nov 2011 15:52:59 +0000
From: Andrew Cooper <andrew.cooper3@citrix.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: unexpected NFS timeouts, related to sync/async soft mounts over
 TCP
References: <4EBAC88D.40902@citrix.com> <BEF32B02-0D19-4D97-8E93-C1797DF02CFE@oracle.com> <4EBBB247.40805@citrix.com> <2E3D3F87-479E-4096-B086-C8F83A0147B5@oracle.com>
In-Reply-To: <2E3D3F87-479E-4096-B086-C8F83A0147B5@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/11/11 15:29, Chuck Lever wrote:
> On Nov 10, 2011, at 6:15 AM, Andrew Cooper wrote:
>
>> On 09/11/11 22:36, Chuck Lever wrote:
>>> On Nov 9, 2011, at 1:38 PM, Andrew Cooper wrote:
>>>
>>>> Hello,
>>>>
>>>> I am debugging an issue for a customer whereby an NFS mount undergoes an
>>>> unexpected timeout and throws an EIO.
>>>>
>>>> Using synchronous mounts results in no problems whatsoever, whereas
>>>> using asynchronous mounts causes the problem to occur.
>>>>
>>>> The problem exists only on 10GiB networks: I can't repro on slower
>>>> networks at all, even if it is the same 10GiB network link limited to
>>>> 1GiB.  It reproduces on multiple versions of XenServer (both Xen 3 and
>>>> Xen 4) with a 2.6.32 based dom0 kernel multiple different 10GiB network
>>>> cards (be2net and bnx2x specifically tested).  It also reproduces
>>>> against multiple different netapp servers running different firmware
>>>> versions.  It also appears to reproduces with NFSv3 and NFSv4, although
>>>> the customer setup uses NFSv3
>>>>
>>>> The difference between mount commands are "noac" for the synchronous
>>>> case as opposed to "actimeo=0" for the asynchronous case.
>>>>
>>>> The /proc/mounts entry for async is:
>>>> 10.70.148.3:/vol/camb5e3b16tmp/82ab4a02-c10f-144a-e8c2-2ae04f213b2a
>>>> /var/run/sr-mount/82ab4a02-c10f-144a-e8c2-2ae04f213b2a nfs
>>>> rw,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,soft,proto=tcp,port=65535,timeo=133,retrans=0,sec=sys,mountport=65535,addr=10.70.148.3
>>>> 0 0
>>>>
>>>> while the entry for sync is:
>>>> 10.70.148.3:/vol/camb5e3b15tmp/bc11aad3-b345-519f-1661-50e16bed6cdb
>>>> /var/run/sr-mount/bc11aad3-b345-519f-1661-50e16bed6cdb nfs
>>>> rw,sync,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,soft,proto=tcp,port=65535,timeo=133,retrans=0,sec=sys,mountport=65535,addr=10.70.148.3
>>>> 0 0
>>> Using the "soft" mount option means that any NFS level timeout is communicated to applications as EIO.  The client appears to be working as expected.  Do you see this problem if you replace the "soft" mount option with the "hard" mount option?
>> I am aware of soft mounts and EIOs.  I forgot to say that it also
>> appears with hard mounts, with the difference that the client eventually
>> retries and continues.
> Yeah, that's a pretty important omission!  :-)  A transport timeout should not cause an EIO on a hard mount.  More below.
>

Sorry.  I am not sure I was clear.  An EIO does not present itself with
a hard mount, but a TCP FIN is still injected into the stream by the
client, causing 15 seconds of deadlock, eventually fixed by sending a
RST and restarting with a new TCP stream.  At this point, softmounts
throw an EIO while hardmounts restart and continue successfully.

My problem is not the EIO on softmount or lack of EIO for hardmout, but
the fact that the client sees fit to try and close the TCP stream while
an apparently otherwise healthy NFS session is ongoing.

>>> Also, timeo=133 is actually a 13.3 second timeout setting.  The value of the timeo= mount option is in deciseconds.  This is unreasonably short for RPC over TCP, especially if the server becomes loaded.  A more reasonable timeout setting for RPC over TCP is 600.
>> I am aware of this as well.  The decisions about NFS options are done by
>> a separate team who have justified their decision to use softmounts with
>> a short timeo.  In our use case, the userland process needs to be
>> informed very quickly if the server goes down so it can fail over to the
>> backup.  13 seconds was considered the longest acceptable time for
>> virtual machines to be without their disks.
>>
>> The problem here is that some bug in the kernel is causing userland to
>> think the server has gone down while it is perfectly healthy and running
>> normally.
>>
>>> The difference between what you describe as a "synchronous" mount and an "asynchronous" mount is that the asynchronous mount can send multiple NFS WRITE operations for one file on the wire to the server concurrently.  The "synchronous" mount throttles write traffic, and requires each WRITE to complete at the server before the client sends the next WRITE.  You can see that the "asynchronous" mount can send a lot more traffic per unit time, and thus may result in the client waiting longer for WRITEs to complete.
>> I did an analysis of the latency between write requests and replies.  At
>> any one time in the stream, there are no more than 4 oustanding
>> requests, and the maximum latency between request and reply (as seen by
>> the client) is 50ms
>>
>>>> The bug itself feels very like a timing issue to me.  It becomes
>>>> substantially easier to reproduce if the kernel has a high workload:
>>>> Different options involve disabling things like TSO offload on the
>>>> network card or dd'ing from /dev/urandom to /tmp, but the problem cant
>>>> be reproduced occasionally without any artificial extra workload.  The
>>>> problem itself can be reprodued with a simple dd from /dev/zero onto the
>>>> nfs mount, which proceeds to transfer at ~220MBps until the EIO is hit.
>>>>
>>>> I have analyzed the TCP stream using TCPdump and Wireshark.  Everything
>>>> appears fine, with no NFS errors at all.  However, the client sticks a
>>>> TCP FIN in the final continuation of one of its 64k block writes, in the
>>>> middle of writing the file.
>>>>
>>>> The server ACKs the outstanding packets, and sends a Write Reply
>>>> (without error), but does not send its own FIN.  Then, 15 seconds later,
>>>> the client sends a TCP RST, and throws an EIO back to userspace.
>>>>
>>>> I am aware that sending a RST after 15 seconds is expected behavior
>>>> following changeset 7d1e8255cf959fba7ee2317550dfde39f0b936ae, in an
>>>> attempt to prevent deadlocks for a half closed TCP connection.  I have
>>>> searched through the commit log all the way to tip, but can not find a
>>>> commit making any reference to problems similar to this.
>>>>
>>>> What I am struggling to work out is why the client is sending a FIN in
>>>> the middle of an otherwise fine and error-free NFS stream.  using
>>>> "rpcdebug -m rpc -s trans" only says "disconnected" without giving a
>>>> reason for disconnecting.
>>>>
>>>> Is there a different debug flag I can use to find out why NFS thinks it
>>>> needs to disconnect, or does anyone have any suggestions as to where I
>>>> should start debugging the code?  I suspect the problem is in the sunrpc
>>>> subsystem but I am not very familiar with code this high level in the
>>>> kernel.
> "trans" is the obvious place to start, but you have done that already, and the instrumentation was inadequate.  You could enable all the RPC client-side debugging flags.  The usual problem with debugging messages is that they can mask timing problems.

It sadly does change the behavior.  I enabled all debugging by accident
to start with and the problem failed to occur, but throughput was an
order of magnitude slower.

> I don't think it's even possible for the NFS client (above the RPC client) to cause a transport connection close in the middle of an RPC.  So I doubt there would be much use in enabling NFS debugging flags.  More RPC debugging might tell us if indeed a retransmit timeout is occurring, or if it's some other problem (which seems to me increasingly likely).

Thats useful to know.

> If you think the bug was introduced by a recent commit, you could try a "git bisect" to pin down which one.  Or try later kernels (2.6.39 is the usual candidate) to see if the problem is addressed.
>

I am not aware of a changeset introducing this behavior.  It has
appeared as a result of switching from synchronous mounts to
asynchronous mounts in an attempt to increase aggregate throughput. 
(There are suitable precautions in place to mitigate potential data
loss/corruption with async mounts and a genuinely fallen-over server).

Unfortunately, I only have ssh access to the servers in question so dont
have a huge scope for installing different setups.  I am trying to get a
3.x kernel up and running to attempt to reproduce the problem.

> Otherwise, I think someone is going to have to sprinkle xprtsock.c with dprintks and try to narrow down the misbehavior.

I think this is probably what I am going to have to do;  Its nice to
have a suggested starting point.

I will report back as and when I get the 3.x kernel running and tested.

Thanks,

-- 
Andrew Cooper - Dom0 Kernel Engineer, Citrix XenServer
T: +44 (0)1223 225 900, http://www.citrix.com

