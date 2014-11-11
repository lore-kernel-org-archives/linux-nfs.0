Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35373 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307AbaKKSYn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2014 13:24:43 -0500
Message-ID: <5462545F.4010706@RedHat.com>
Date: Tue, 11 Nov 2014 13:24:31 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: bstroesser@ts.fujitsu.com, neilb@suse.de, linux-nfs@vger.kernel.org
CC: bfields@fieldses.org
Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
References: <d6437a$6ag11f@dgate10u.abg.fsc.net>
In-Reply-To: <d6437a$6ag11f@dgate10u.abg.fsc.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 11/05/2014 03:21 PM, bstroesser@ts.fujitsu.com wrote:
> Hello,
> 
> I'm sending a small set of 3 patches for a problem, that I have
> reported a few weeks ago.
> rpc.mountd can be blocked by a bad client, that sends lots of
> RPC requests, but never reads the replies from the socket either
> intentionally or e.g. caused by a wrong configured MTU.
> 
> While looking for a possible solution, I found another weakness
> in rpc.mountd if it is used "multithreaded" (-t nn).
> 
> The first two patches fix that weakness in the case of !HAVE_LIBTIRPC
> and HAVE_LIBTIRPC.
> The third patch more a kind of suggestion how the main problem could
> be fixed. I don't know whether we can set MAXREC without causing
> new troubles. When this patch is used, a  further patch for libtirpc
> also should be used. You can find it here:
>     http://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=201409

Over the weekend I took a good hard look at these 3 patches and
the one for libtirpc with the reproducer Bodo supplied me.
(Bodo, thanks all the help getting things set up!).

I agree with the libtirpc patch so its been committed,
but other three made me nervous so I wanted to take a 
good hard look at them. (Neil's question, "do we really
what to make these non-block" haunted me ;-) ).

It turns out, at least in my setup, these patches do not
and can not stop the mountd DOS that Bodo's reproducer
creates. 

Here is why they do not work: 

The fd that the write() is getting hung on, is not be created 
by the 3 nfs_svc_create() calls in mountd:main(). Its
being created by the accept() when the tcp connection
is created (via SVC_RECV()), so making those fds coming 
out of the nfs_svc_create() non-blocking does nothing. 

Here is the hang can't be stop (for now):

Here is the stack:
Stack trace of thread 4150:
#0  0x00000036816f0e90 write (libc.so.6)
#1  0x00007fd53837da6d write_vc (libtirpc.so.1)
#2  0x00007fd53838103f flush_out (libtirpc.so.1)
#3  0x00007fd53837dd81 svc_vc_reply (libtirpc.so.1)
#4  0x00007fd53837b096 svcerr_noprog (libtirpc.so.1)
#5  0x00007fd53837b360 svc_getreq_common (libtirpc.so.1)
#6  0x00000000004086d9 my_svc_getreqset (mountd)
#7  0x0000000000403d80 main (mountd)
#8  0x000000368161ffe0 __libc_start_main (libc.so.6)
#9  0x00000000004040f5 _start (mountd)

The fd that created by the SVC_RECV() is never 
given back to the app (in case mountd) to make
it non-blocking. Its used in the error path
where it get hung up in the write(). The
app has no control over that. 

Now I definitely see a problem, but these
patches (with the exception of the libtirpc
patch) don't address the problem I am seeing.

So unless I'm not seeing something, I'm not in
favor of taking these 3 patches.

thoughts?

steved.
