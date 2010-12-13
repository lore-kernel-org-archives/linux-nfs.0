Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42783 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757713Ab0LMQTs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Dec 2010 11:19:48 -0500
Subject: Re: mount.nfs timeout of 9999ms (was Re: Listen backlog set to 64)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <45243C0D-2158-47DD-91AF-C91AB960F6B4@oracle.com>
Date: Mon, 13 Dec 2010 11:19:10 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BCAE23E8-D105-4800-9D09-2926EDB5C9BA@oracle.com>
References: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz> <20101116182026.GA3971@fieldses.org> <20101117090826.4b2724da@notabene.brown> <20101129205935.GD9897@fieldses.org> <alpine.NEB.2.01.1011301705220.26378@jrf.vwaro.pbz> <20101130200013.GA2108@fieldses.org> <alpine.NEB.2.01.1012011754120.12506@jrf.vwaro.pbz> <F5FCB254-E6CE-4B71-ABD9-33F098F9E0BA@oracle.com> <alpine.NEB.2.01.1012071143080.28772@jrf.vwaro.pbz> <C751B327-E608-4659-A96C-0B99C2C168E1@oracle.com> <alpine.NEB.2.01.1012081701170.11201@jrf.vwaro.pbz> <45243C0D-2158-47DD-91AF-C91AB960F6B4@oracle.com>
To: Mark Hills <mark@pogo.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 8, 2010, at 1:28 PM, Chuck Lever wrote:

> 
> On Dec 8, 2010, at 12:31 PM, Mark Hills wrote:
> 
>> On Wed, 8 Dec 2010, Chuck Lever wrote:
>> 
>>> On Dec 8, 2010, at 9:45 AM, Mark Hills wrote:
>>> 
>>>> On Wed, 1 Dec 2010, Chuck Lever wrote:
>>>> 
>>>>> On Dec 1, 2010, at 1:18 PM, Mark Hills wrote:
>>>>> 
>>>> This returns the issue to giving up after the 9999 millisecond timeout 
>>>> above, which I think is making the client overly sensitive.
>>>> 
>>>> The affected clients are Fedora 12 distribution: nfs-utils-1.2.1-4.fc12. 
>>>> We are using mount.nfs for a v3 mount over TCP.
>>>> 
>>>> Locating this timeout wasn't easy. There's no '9999' in any of the 
>>>> nfs-utils or glibc's rpc code.
>>>> 
>>>> It turns out that the timeout originates in 
>>>> nfs-utils/support/nfs/rpc_socket.c as
>>>> 
>>>> #define NFSRPC_TIMEOUT_TCP	(10)
>>>> 
>>>> This is used to populate a struct timeval *timeout which is used and 
>>>> updated by nfs_connect_nb(). Then the remaining timeout of 9999 
>>>> milliseconds is used in an RPC clnt_call operation.
>>>> 
>>>> 10 seconds over TCP is simply too short to be reliable here; it's not a 
>>>> long period of time for a fatal timeout. I will attempt to test on our 
>>>> cluster with an extended timeout.
>>> 
>>> This is a TCP connect timeout, not a RPC retransmit timeout.  Waiting 10 
>>> seconds for a TCP connect is really not that obnoxious.  The reason this 
>>> is short is because we want mount.nfs to realize quickly that it's 
>>> making no progress on stuck servers.
>> 
>> If my understanding of the code is correct, the 10 second timeout is not 
>> just for the connect, but also for making an RPC call and receiving the 
>> response (the struct timeval is carried through). Hence the diagnosis in 
>> the previous mail.
>> 
>>>> I presume that the bug is that the timeout is too short, and not that 
>>>> the timeout should cause a retry in a layer above -- because 
>>>> re-sending the request over reliable TCP would not make sense.
>>> 
>>> The upper layer wouldn't resend the request, since the underlying 
>>> transport never connected.
>>> 
>>>> For UDP the retries are handled inside the RPC call, clntudp_call(). 
>>>> In which case, what is the reason the UDP timeout differs from TCP? 
>>>> And is it also too small?
>>> 
>>> RPC over UDP doesn't have to connect to the server.  I wonder what would 
>>> happen if you specified "mountproto=udp" when mounting exports on this 
>>> overloaded server.
>> 
>> I think we'd still see the same issue over UDP, perhaps even more brutally 
>> because of the shorter 3 second UDP timeout.
>> 
>> To clarify, we've deviated from the problem described in the original 
>> email; opening a TCP connection to the mountd which is the problem, but 
>> mountd's ability to send a message in response.
> 
> So, you've verified (with, say, a network trace) that the clients are connecting successfully, but mountd is not sending a reply to the MNT request with ten seconds?

I've opened https://bugzilla.linux-nfs.org/show_bug.cgi?id=196 to track the mount.nfs part of this issue.

It seems to me, however, that under normal circumstances nfs-utils 1.2.1 on Fedora 12 should be doing a kernel mount, and mount.nfs should not be attempting to send a MNT request.  Would it be possible to enable some trace debugging to capture the sequence of kernel events during a failed mount?

On the clients:

  # rpcdebug -m nfs -s mount

To disable:

  # rpcdebug -m nfs -c

Debugging messages will appear in /var/log/messages.

A full network trace could also be useful.  Just needed while your jobs are starting so we can capture the network traffic at mount time.

  # tcpdump -s 1600 -w /tmp/raw

Doing this on your clients would likely be more reliable than on the server.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




