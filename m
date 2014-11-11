Return-Path: linux-nfs-owner@vger.kernel.org
Received: from dgate20.ts.fujitsu.com ([80.70.172.51]:58744 "EHLO
	dgate20.ts.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaKKTBr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2014 14:01:47 -0500
From: =?Windows-1252?Q?Str=F6sser=2C_Bodo?=
	<bodo.stroesser@ts.fujitsu.com>
To: Steve Dickson <SteveD@redhat.com>, "neilb@suse.de" <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "bfields@fieldses.org" <bfields@fieldses.org>
Date: Tue, 11 Nov 2014 20:01:39 +0100
Subject: RE: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
Message-ID: <8B06D1E6480A6747B23FEC34909D2B5EA81BA2988F@ABGEX70E.FSC.NET>
References: <d6437a$6ag11f@dgate10u.abg.fsc.net>
 <5462545F.4010706@RedHat.com>
In-Reply-To: <5462545F.4010706@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Steve Dickson [mailto:SteveD@redhat.com]
> Sent: Tuesday, November 11, 2014 7:25 PM
> To: Strösser, Bodo; neilb@suse.de; linux-nfs@vger.kernel.org
> Cc: bfields@fieldses.org
> Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
> 
> Hello,
> 
> On 11/05/2014 03:21 PM, bstroesser@ts.fujitsu.com wrote:
> > Hello,
> >
> > I'm sending a small set of 3 patches for a problem, that I have
> > reported a few weeks ago.
> > rpc.mountd can be blocked by a bad client, that sends lots of
> > RPC requests, but never reads the replies from the socket either
> > intentionally or e.g. caused by a wrong configured MTU.
> >
> > While looking for a possible solution, I found another weakness
> > in rpc.mountd if it is used "multithreaded" (-t nn).
> >
> > The first two patches fix that weakness in the case of !HAVE_LIBTIRPC
> > and HAVE_LIBTIRPC.
> > The third patch more a kind of suggestion how the main problem could
> > be fixed. I don't know whether we can set MAXREC without causing
> > new troubles. When this patch is used, a  further patch for libtirpc
> > also should be used. You can find it here:
> >     http://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=201409
> 
> Over the weekend I took a good hard look at these 3 patches and
> the one for libtirpc with the reproducer Bodo supplied me.
> (Bodo, thanks all the help getting things set up!).
> 
> I agree with the libtirpc patch so its been committed,
> but other three made me nervous so I wanted to take a
> good hard look at them. (Neil's question, "do we really
> what to make these non-block" haunted me ;-) ).
> 
> It turns out, at least in my setup, these patches do not
> and can not stop the mountd DOS that Bodo's reproducer
> creates.
> 
> Here is why they do not work:
> 
> The fd that the write() is getting hung on, is not be created
> by the 3 nfs_svc_create() calls in mountd:main(). Its
> being created by the accept() when the tcp connection
> is created (via SVC_RECV()), so making those fds coming
> out of the nfs_svc_create() non-blocking does nothing.

Sorry, Steve, unfortunately I have to disagree.

The hung we tried to reproduce on your config yesterday is fixed by
patch 3/3 only. It simply uses

            rpc_control(RPC_SVC_CONNMAXREC_SET, &maxrec);

to make libtirpc set O_NONBLOCK on the tcp connections for us. That
_definitely_ works well to avoid the hung, but maybe triggers the problem
in libtirpc which is fixed by the patch you committed.
I for myself was uncertain regarding this patch, but meanwhile Neil
pointed out, that setting MAXREC only affects the receive buffer size.
For receive the used RPC_MAXDATASIZE (= 9000) always will be enough.

The two other patches (1/3 and 2/3) are related to the use of "-t nn"
with rpc.mountd. They change the listening socket (TCP) and the reading
socket (UDP) to nonblocking mode. See the following comment from
source support/nfs/svc_socket.c, which is an old comment that doesn't
come from me:

       /* This socket might be shared among multiple processes
        * if mountd is run multi-threaded.  So it is safest to
        * make it non-blocking, else all threads might wake
        * one will get the data, and the others will block
        * indefinitely.
        * In all cases, transaction on this socket are atomic
        * (accept for TCP, packet-read and packet-write for UDP)
        * so O_NONBLOCK will not confuse unprepared code causing
        * it to corrupt messages.
        * It generally safest to have O_NONBLOCK when doing an accept
        * as if we get a RST after the SYN and before accept runs,
        * we can block despite being told there was an acceptable
        * connection.
        */

This comment describs precisely, why

	"We really do want non-blocking sockets here!"

as NeilBrown said. I don't think, that this was a question (Neil,
please correct me if I'm wrong).

The problem is, that the code switches to nonblocking mode only
if rpc.mountd was built without libtirpc and the "-p <portno>"
option is not used.

If you use the option or rpc.mountd is built with libtirpc, the
listening sockets are blocking. I have tested it simply by using
the socket features of bash and strace'ing rpc.mountd.

When connecting to a multithreaded rpc.mountd, all threads wake up
and call accept(), but of course only one thread gets the connection,
all others sleep on the accept().


So, we talk about switching to nonblocking mode for the listeners
(Patch 1/3 and 2/3) and the TCP connections (Patch 3/3).


Bodo 

> 
> Here is the hang can't be stop (for now):
> 
> Here is the stack:
> Stack trace of thread 4150:
> #0  0x00000036816f0e90 write (libc.so.6)
> #1  0x00007fd53837da6d write_vc (libtirpc.so.1)
> #2  0x00007fd53838103f flush_out (libtirpc.so.1)
> #3  0x00007fd53837dd81 svc_vc_reply (libtirpc.so.1)
> #4  0x00007fd53837b096 svcerr_noprog (libtirpc.so.1)
> #5  0x00007fd53837b360 svc_getreq_common (libtirpc.so.1)
> #6  0x00000000004086d9 my_svc_getreqset (mountd)
> #7  0x0000000000403d80 main (mountd)
> #8  0x000000368161ffe0 __libc_start_main (libc.so.6)
> #9  0x00000000004040f5 _start (mountd)
> 
> The fd that created by the SVC_RECV() is never
> given back to the app (in case mountd) to make
> it non-blocking. Its used in the error path
> where it get hung up in the write(). The
> app has no control over that.
> 
> Now I definitely see a problem, but these
> patches (with the exception of the libtirpc
> patch) don't address the problem I am seeing.
> 
> So unless I'm not seeing something, I'm not in
> favor of taking these 3 patches.
> 
> thoughts?
> 
> steved.
