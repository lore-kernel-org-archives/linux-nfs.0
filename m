From: Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Sun, 27 Jan 2008 13:08:42 +0100
Message-ID: <479C744A.6020207@abinetworks.biz>
References: <476CEC5E.9070002@abinetworks.biz> <838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc> <476E47F5.4090807@abinetworks.biz> <20071225140431.9264970a.akpm@linux-foundation.org> <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com> <4791EE99.3030802@abinetworks.biz> <5FD6714F-EF9A-4F07-B2B6-D6F6CC911936@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns4.abinetworks.biz ([216.218.212.66]:35476 "EHLO
	ns4.abinetworks.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbYA0MLj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jan 2008 07:11:39 -0500
In-Reply-To: <5FD6714F-EF9A-4F07-B2B6-D6F6CC911936@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Chuck,

i have produced the output you requested using the code i used to show 
you last time (which simply tries to open(... | O_TRUNC) a file onto the 
nfs mount and writes "Hello" into it. I simply iterate execution 2 
times. The mount is a loop mount on 127.0.0.1
Since the second execution (the first time it creates the file) you get 
EINVAL:

FILE CREATION:

hydra:~# tcpdump -s0 -i lo port 2049
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 65535 bytes
12:15:06.306619 IP localhost.251828621 > localhost.nfs: 120 getattr fh Unknown/47521E2B0223C100000000000000000000000000000000000000000000000000
12:15:06.306666 IP localhost.nfs > localhost.251828621: reply ok 96 getattr DIR 40777 ids 0/0 sz 4096
12:15:06.306705 IP localhost.268605837 > localhost.nfs: 128 lookup fh Unknown/47521E2B0223C100000000000000000000000000000000000000000000000000 "test"
12:15:06.306752 IP localhost.nfs > localhost.268605837: reply ok 28 lookup ERROR: No such file or directory
12:15:06.306786 IP localhost.285383053 > localhost.nfs: 160 create fh Unknown/47521E2B0223C100000000000000000000000000000000000000000000000000 "test"
12:15:06.306917 IP localhost.nfs > localhost.285383053: reply ok 128 create fh Unknown/48521E2B0323C120000000000000000000000000000000000000000000000000
12:15:06.307179 IP localhost.302160269 > localhost.nfs: 144 write fh Unknown/48521E2B0323C120000000000000000000000000000000000000000000000000 5 (5) bytes @ 0 (0)
12:15:06.307283 IP localhost.nfs > localhost.302160269: reply ok 96 write


...EINVAL ON OPEN

12:15:14.825249 IP localhost.318937485 > localhost.nfs: 120 getattr fh Unknown/48521E2B0323C120000000000000000000000000000000000000000000000000
12:15:14.825337 IP localhost.nfs > localhost.318937485: reply ok 96 getattr REG 100700 ids 99/99 sz 5
12:15:14.825403 IP localhost.335714701 > localhost.nfs: 152 setattr fh Unknown/48521E2B0323C120000000000000000000000000000000000000000000000000
12:15:14.825496 IP localhost.nfs > localhost.335714701: reply ok 28 setattr ERROR: Invalid argument

This is a 2.6.23.9 (which shouldnt be different from 2.6.22 at least 
under nfs client POV)

Now for a working 2.6.21.7 kernel (FILE CREATION):

ios:~# tcpdump -s0 -i lo port 2049
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 65535 bytes
12:37:09.463537 IP debian.1135581207 > debian.nfs: 116 getattr fh Unknown/0100182B0223D900000000000000000000000000000000000000000000000000
12:37:09.463845 IP debian.nfs > debian.1135581207: reply ok 96 getattr DIR 40777 ids 0/0 sz 4096
12:37:09.463939 IP debian.1152358423 > debian.nfs: 124 lookup fh Unknown/0100182B0223D900000000000000000000000000000000000000000000000000 "test"
12:37:09.464012 IP debian.nfs > debian.1152358423: reply ok 28 lookup ERROR: No such file or directory
12:37:09.464083 IP debian.1169135639 > debian.nfs: 156 create fh Unknown/0100182B0223D900000000000000000000000000000000000000000000000000 "test"
12:37:09.464293 IP debian.nfs > debian.1169135639: reply ok 128 create fh Unknown/0200182B0323D932000000000000000000000000000000000000000000000000
12:37:09.464488 IP debian.1185912855 > debian.nfs: 140 write fh Unknown/0200182B0323D932000000000000000000000000000000000000000000000000 5 (5) bytes @ 0 (0)
12:37:09.464674 IP debian.nfs > debian.1185912855: reply ok 96 write

and open O | TRUNC going perfect

12:37:14.442789 IP debian.1202690071 > debian.nfs: 116 getattr fh Unknown/0200182B0323D932000000000000000000000000000000000000000000000000
12:37:14.442868 IP debian.nfs > debian.1202690071: reply ok 96 getattr REG 100700 ids 99/99 sz 5
12:37:14.442998 IP debian.1219467287 > debian.nfs: 148 setattr fh Unknown/0200182B0323D932000000000000000000000000000000000000000000000000
12:37:14.443165 IP debian.nfs > debian.1219467287: reply ok 96 setattr REG 100700 ids 99/99 sz 0
12:37:14.443394 IP debian.1236244503 > debian.nfs: 140 write fh Unknown/0200182B0323D932000000000000000000000000000000000000000000000000 5 (5) bytes @ 0 (0)
12:37:14.443480 IP debian.nfs > debian.1236244503: reply ok 96 write
12:37:14.443511 IP debian.1253021719 > debian.nfs: 116 getattr fh Unknown/0200182B0323D932000000000000000000000000000000000000000000000000
12:37:14.443551 IP debian.nfs > debian.1253021719: reply ok 96 getattr REG 100700 ids 99/99 sz 5


Here follows the kernel debug info @ setattr for the 'broken' 
kernel/uspace-server:

>>> <8>NFS call setattr
>>> <8>RPC: new task initialized, procpid 18656
>>> <8>RPC: allocated task f7bec500
>>> <8>RPC: 0 looking up UNIX cred
>>> <8>RPC: 740 __rpc_execute flags=0x480
>>> <8>RPC: 740 call_start nfs2 proc 2 (sync)
>>> <8>RPC: 740 call_reserve (status 0)
>>> <8>RPC: 740 reserved req f1416000 xid 643f3c42
>>> <8>RPC: 740 call_reserveresult (status 0)
>>> <8>RPC: 740 call_allocate (status 0)
>>> <8>RPC: 740 allocated buffer of size 528 at e627b800
>>> <8>RPC: 740 call_bind (status 0)
>>> <8>RPC: 740 call_connect xprt f70d4000 is connected
>>> <8>RPC: 740 call_transmit (status 0)
>>> <8>RPC: 740 xprt_prepare_transmit
>>> <8>RPC: 740 xprt_cwnd_limited cong = 0 cwnd = 512
>>> <8>RPC: 740 call_encode (status 0)
>>> <8>RPC: 740 marshaling UNIX cred f4efcb40
>>> <8>RPC: 740 using AUTH_UNIX cred f4efcb40 to wrap rpc data
>>> <8>RPC: 740 xprt_transmit(148)
>>> <8>RPC: xs_udp_data_ready...
>>> <8>RPC: cong 256, cwnd was 512, now 512
>>> <8>RPC: 740 xid 643f3c42 complete (28 bytes received)
>>> <8>RPC: xs_udp_send_request(148) = 148
>>> <8>RPC: 740 xmit complete
>>> <8>RPC: wake_up_next(f70d4114 "xprt_resend")
>>> <8>RPC: wake_up_next(f70d40e4 "xprt_sending")
>>> <8>RPC: 740 call_status (status 28)
>>> <8>RPC: 740 call_decode (status 28)
>>> <8>RPC: 740 validating UNIX cred f4efcb40
>>> <8>RPC: 740 using AUTH_UNIX cred f4efcb40 to unwrap rpc data
>>> <8>RPC: 740 call_decode result -22
>>> <8>RPC: 740 return 0, status -22
>>> <8>RPC: 740 release task
>>> <8>RPC: freeing buffer of size 528 at e627b800
>>> <8>RPC: 740 release request f1416000
>>> <8>RPC: wake_up_next(f70d4174 "xprt_backlog")
>>> <8>RPC: 740 releasing UNIX cred f4efcb40
>>> <8>RPC: rpc_release_client(f6f1f880)
>>> <8>NFS reply setattr: -22

...and for the working one:

<4>NFS call  setattr
<4>RPC:       new task initialized, procpid 12112
<4>RPC:       allocated task f3ae2140
<4>RPC:     0 looking up UNIX cred
<4>RPC:   171 __rpc_execute flags=0x480
<4>RPC:   171 call_start nfs2 proc 2 (sync)
<4>RPC:   171 call_reserve (status 0)
<4>RPC:   171 reserved req f3cb4000 xid 4daf9817
<4>RPC:   171 call_reserveresult (status 0)
<4>RPC:   171 call_allocate (status 0)
<4>RPC:   171 call_bind (status 0)
<4>RPC:   171 call_connect xprt f6b83400 is connected
<4>RPC:   171 call_transmit (status 0)
<4>RPC:   171 xprt_prepare_transmit
<4>RPC:   171 xprt_cwnd_limited cong = 0 cwnd = 512
<4>RPC:   171 call_encode (status 0)
<4>RPC:   171 marshaling UNIX cred e984f1c0
<4>RPC:   171 using AUTH_UNIX cred e984f1c0 to wrap rpc data
<4>RPC:   171 xprt_transmit(148)
<4>RPC:       xs_udp_send_request(148) = 148
<4>RPC:   171 xmit complete
<4>RPC:   171 sleep_on(queue "xprt_pending" time 81013324)
<4>RPC:   171 added to queue f6b83544 "xprt_pending"
<4>RPC:   171 setting alarm for 700 ms
<4>RPC:       wake_up_next(f6b83514 "xprt_resend")
<4>RPC:       wake_up_next(f6b834e4 "xprt_sending")
<4>RPC:   171 sync task going to sleep
<4>RPC:       xs_udp_data_ready...
<4>RPC:       cong 256, cwnd was 512, now 512
<4>RPC:       wake_up_next(f6b83514 "xprt_resend")
<4>RPC:       wake_up_next(f6b834e4 "xprt_sending")
<4>RPC:   171 xid 4daf9817 complete (96 bytes received)
<4>RPC:   171 __rpc_wake_up_task (now 81013324)
<4>RPC:   171 disabling timer
<4>RPC:   171 removed from queue f6b83544 "xprt_pending"
<4>RPC:       __rpc_wake_up_task done
<4>RPC:   171 sync task resuming
<4>RPC:   171 deleting timer
<4>RPC:   171 call_status (status 96)
<4>RPC:   171 call_decode (status 96)
<4>RPC:   171 validating UNIX cred e984f1c0
<4>RPC:   171 using AUTH_UNIX cred e984f1c0 to unwrap rpc data
<4>RPC:   171 call_decode result 0
<4>RPC:   171 return 0, status 0
<4>RPC:   171 release task
<4>RPC:   171 release request f3cb4000
<4>RPC:       wake_up_next(f6b83574 "xprt_backlog")
<4>RPC:   171 releasing UNIX cred e984f1c0
<4>RPC:       rpc_release_client(cab12680, 1)
<4>NFS reply setattr: 0

I can notice the error returned by call_decode and the different size of 
reply (which is an error reply sized 28).
Might this be bound to the different packet lengths ? In the working 
solution packets are always 4 bytes shorter than in the broken one.

thanks for any help,

Gianluca

Chuck Lever wrote:

> Hi Gianluca-
>
> On Jan 19, 2008, at 7:35 AM, Gianluca Alberici wrote:
>
>> Hello Chuck,
>>
>> As you requested i have finally found out that the problem was 
>> introduced in 2.6.22 (2.6.21.7 works, after 2.6.21.7 theres 2.6.22)
>>
>> I have also examined the changeslogs: 2.6.22 introduce a certain 
>> number of patches into NFS client. Many of them are yours and Trond's.
>>
>> Pls can you help with this ?
>
>
>
> [ I trimmed the Linux kernel mailing list because this is an NFS 
> specific problem. No need to add more noise on lkml. ]
>
> The first thing to do is to capture a network trace during the failing 
> operation. Capturing a trace with a working kernel, and one with a 
> failing kernel, would let us see how the behavior changes between the 
> two.
>
> To capture a network trace, you can use "tcpdump" on your client:
>
> sudo tcpdump -s0 -w /tmp/dumpfile hostname-of-server
>
> Substitute the fully-qualified domain name of your server for 
> "hostname-of-server".
>
> Try this with a working client and a broken client. The /tmp/ dumpfile 
> will be a binary file. You can post it on a convenient web site, or 
> attach it to e-mail.
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>

