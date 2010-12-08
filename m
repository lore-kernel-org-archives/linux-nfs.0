Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18704 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896Ab0LHS3u convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Dec 2010 13:29:50 -0500
Subject: Re: mount.nfs timeout of 9999ms (was Re: Listen backlog set to 64)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <alpine.NEB.2.01.1012081701170.11201@jrf.vwaro.pbz>
Date: Wed, 8 Dec 2010 13:28:06 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Message-Id: <45243C0D-2158-47DD-91AF-C91AB960F6B4@oracle.com>
References: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz> <20101116182026.GA3971@fieldses.org> <20101117090826.4b2724da@notabene.brown> <20101129205935.GD9897@fieldses.org> <alpine.NEB.2.01.1011301705220.26378@jrf.vwaro.pbz> <20101130200013.GA2108@fieldses.org> <alpine.NEB.2.01.1012011754120.12506@jrf.vwaro.pbz> <F5FCB254-E6CE-4B71-ABD9-33F098F9E0BA@oracle.com> <alpine.NEB.2.01.1012071143080.28772@jrf.vwaro.pbz> <C751B327-E608-4659-A96C-0B99C2C168E1@oracle.com> <alpine.NEB.2.01.1012081701170.11201@jrf.vwaro.pbz>
To: Mark Hills <mark@pogo.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 8, 2010, at 12:31 PM, Mark Hills wrote:

> On Wed, 8 Dec 2010, Chuck Lever wrote:
> 
>> On Dec 8, 2010, at 9:45 AM, Mark Hills wrote:
>> 
>>> On Wed, 1 Dec 2010, Chuck Lever wrote:
>>> 
>>>> On Dec 1, 2010, at 1:18 PM, Mark Hills wrote:
>>>> 
>>>>> On Tue, 30 Nov 2010, J. Bruce Fields wrote:
>>>>> 
>>>>>> On Tue, Nov 30, 2010 at 05:50:52PM +0000, Mark Hills wrote:
>>>>> [...]
>>>>>>> Our investigation brings us to rpc.mountd and mount.nfs communicating. In 
>>>>>>> the client log we see messages like:
>>>>>>> 
>>>>>>> Nov 24 12:09:43 nyrd001 automount[3782]: >> mount.nfs: mount to NFS server 'ss1a:/mnt/raid1/banana' failed: timed out, giving up
>>>>>>> 
>>>>>>> Using strace and isolating one of these, I can see a non-blocking connect 
>>>>>>> has already managed to make a connection and even send/receive some data. 
>>>>>>> 
>>>>>>> But soon a timeout of 9999 milliseconds in poll() causes a problem in 
>>>>>>> mount.nfs when waiting for a response of some sort. The socket in question 
>>>>>>> is a connection to mountd:
>>>>>>> 
>>>>>>> 26512 futex(0x7ff76affa540, FUTEX_WAKE_PRIVATE, 1) = 0
>>>>>>> 26512 write(3, "\200\0\0(j\212\254\365\0\0\0\0\0\0\0\2\0\1\206\245\0\0\0\3\0\0\0\0\0\0\0\0"..., 44) = 44
>>>>>>> 26512 poll([{fd=3, events=POLLIN}], 1, 9999 <unfinished ...>
>>>>>>> 
>>>>>>> When it returns:
>>>>>>> 
>>>>>>> 26512 <... poll resumed> )              = 0 (Timeout)
>>>>>>> 26512 rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
>>>>>>> 26512 rt_sigprocmask(SIG_SETMASK, ~[RTMIN RT_1], [], 8) = 0
>>>>>>> 26512 close(3)                          = 0
>>>>>>> 26512 rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
>>>>>>> 26512 write(2, "mount.nfs: mount to NFS server '"..., 100) = 100
>>>>>>> 
>>>>>>> There's no re-try from here, just a failed mount.
>>> [...]
>>>>>> Can you tell where the mountd threads are typically waiting?
>>>>> 
>>>>> Here's a trace from mountd. Note the long pause after fdatasync():
>>>>> 
>>>>> 31156 12:09:40 open("/var/lib/nfs/rmtab", O_WRONLY|O_CREAT|O_APPEND, 0666) = 14 <0.000010>
>>>>> 31156 12:09:40 fstat(14, {st_mode=S_IFREG|0644, st_size=62642, ...}) = 0 <0.000005>
>>>>> 31156 12:09:40 mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2af00c929000 <0.000007>
>>>>> 31156 12:09:40 fstat(14, {st_mode=S_IFREG|0644, st_size=62642, ...}) = 0 <0.000005>
>>>>> 31156 12:09:40 lseek(14, 62642, SEEK_SET) = 62642 <0.000006>
>>>>> 31156 12:09:40 write(14, "192.168.14.165:/mnt/raid1/abcde_"..., 57) = 57 <0.000013>
>>>>> 31156 12:09:40 fdatasync(14)            = 0 <15.413401>
>>> [...]
>>>> fdatasync() will write all outstanding dirty data on that partition to 
>>>> persistent storage, not just the dirty data for that file.  If /var is 
>>>> on a partition that has a lot of other activity, then this is the 
>>>> expected outcome, unfortunately.  I would expect such delays to be due 
>>>> to a large amount of outstanding writes, not to periodic synchronous 
>>>> writes.
>>> 
>>> Moving rmtab to a tmpfs, this moved the problem to another bottleneck 
>>> writing to /var, this time via syslog.
>>> 
>>> We identified a crontab entry which uses RPM to apply updates to the 
>>> server OS at randomised times which was blocking /var for 10 seconds or 
>>> so.
>> 
>> I think this is closer to the root cause than the mount.nfs connect 
>> timeout.  I might consider RPM or syslog to be the final culprit, but I 
>> wonder why a multi-threaded mountd would stop servicing TCP connects 
>> because it couldn't write to /var or to syslog?
> 
> Of course this is the root cause, but a mementary bottleneck at the server 
> isn't such a rare occurance, particularly when servicing bursts on a large 
> HPC cluster.

Fwiw, the solution on enterprise storage servers (often typically used in HPC cluster environments) has been to improve mountd so that momentary server system bottlenecks do not cause sporadic mountd service.  That seems like the larger part of an appropriate response to this problem on Linux.

>>> This returns the issue to giving up after the 9999 millisecond timeout 
>>> above, which I think is making the client overly sensitive.
>>> 
>>> The affected clients are Fedora 12 distribution: nfs-utils-1.2.1-4.fc12. 
>>> We are using mount.nfs for a v3 mount over TCP.
>>> 
>>> Locating this timeout wasn't easy. There's no '9999' in any of the 
>>> nfs-utils or glibc's rpc code.
>>> 
>>> It turns out that the timeout originates in 
>>> nfs-utils/support/nfs/rpc_socket.c as
>>> 
>>> #define NFSRPC_TIMEOUT_TCP	(10)
>>> 
>>> This is used to populate a struct timeval *timeout which is used and 
>>> updated by nfs_connect_nb(). Then the remaining timeout of 9999 
>>> milliseconds is used in an RPC clnt_call operation.
>>> 
>>> 10 seconds over TCP is simply too short to be reliable here; it's not a 
>>> long period of time for a fatal timeout. I will attempt to test on our 
>>> cluster with an extended timeout.
>> 
>> This is a TCP connect timeout, not a RPC retransmit timeout.  Waiting 10 
>> seconds for a TCP connect is really not that obnoxious.  The reason this 
>> is short is because we want mount.nfs to realize quickly that it's 
>> making no progress on stuck servers.
> 
> If my understanding of the code is correct, the 10 second timeout is not 
> just for the connect, but also for making an RPC call and receiving the 
> response (the struct timeval is carried through). Hence the diagnosis in 
> the previous mail.
> 
>>> I presume that the bug is that the timeout is too short, and not that 
>>> the timeout should cause a retry in a layer above -- because 
>>> re-sending the request over reliable TCP would not make sense.
>> 
>> The upper layer wouldn't resend the request, since the underlying 
>> transport never connected.
>> 
>>> For UDP the retries are handled inside the RPC call, clntudp_call(). 
>>> In which case, what is the reason the UDP timeout differs from TCP? 
>>> And is it also too small?
>> 
>> RPC over UDP doesn't have to connect to the server.  I wonder what would 
>> happen if you specified "mountproto=udp" when mounting exports on this 
>> overloaded server.
> 
> I think we'd still see the same issue over UDP, perhaps even more brutally 
> because of the shorter 3 second UDP timeout.
> 
> To clarify, we've deviated from the problem described in the original 
> email; opening a TCP connection to the mountd which is the problem, but 
> mountd's ability to send a message in response.

So, you've verified (with, say, a network trace) that the clients are connecting successfully, but mountd is not sending a reply to the MNT request with ten seconds?

>> We could consider making the TCP connect timeout value larger, but the 
>> price would be a mount.nfs command that is less responsive to hung 
>> servers.  For example, the legacy get_socket() code uses a 20 second TCP 
>> connect timeout for the pmap query, and a 30 second TCP connect timeout 
>> for the mount request.
>> 
>> But how large would be large enough?  If we chose a TCP connect timeout 
>> of 25 seconds, what would happen if your server required, say, 30 
>> seconds to accept a new TCP connection?  I think we would agree that the 
>> server side should be fixed in that case.
> 
> Whilst these timeouts could have resolved our problem, they are perhaps 
> too short to consider that a server is fatally down. Particularly if we 
> have already managed to open a TCP connection.

Perhaps.  If mountd is hung or otherwise unresponsive, a TCP connection could be open but the service may still be unresponsive for some reason.  But that's a nit.

> We've certainly managed to see the problem in the wild on a fairly 
> 'standard' RHEL 5.4 Linux server. In this case it was rpm, so what if the 
> sysadmin requires to run 'rpm' to perform some administration? They can't 
> do this without high risk to the clients.

>From what I have read, the server's configuration is the immediate problem here: namely that the disk that /var is on is slow, or there are bugs (or not-very-useful behavior) in the file system implementation used on /var, or that rpm should not cause such latency for other applications, or that the multi-threading architecture of mountd is incorrect.  Or some combination of these.

A ten second latency for file system operations is the real issue.

>> IMO adding another mount option would be mistaken.  It adds clutter to 
>> the mount user interface to work around what is clearly a problem on the 
>> server.
> 
> I agree that new options can be cluttered.
> 
> But I think the problem needs attention at both the client and sever side.

It seems reasonable to relax mount.nfs's timeout settings used when performing mount and rpcbind requests.  The question I have is what would be reasonable values to use instead of what we have?  (That question is directed to everyone who is still reading).

> In this case the cause of our load spike was something that we hope can be 
> avoided, but I can't eliminate the risk. When serving many hundreds of 
> clients we expect hot-spots of load, especially when a single user has 
> control over large groups of client hosts.

Yes, that's a typical problem in compute clusters that use NFS.

> Furthermore the chain of events of a mount failure is so severe, because 
> autofs caches the failed mount and present an empty directory for some 
> time after.

That's a good argument to get mountd changed so that it can better handle such mount bursts.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



