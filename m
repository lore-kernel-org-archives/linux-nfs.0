Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:54811 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130Ab2JVSDp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 14:03:45 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so3281640vbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 11:03:44 -0700 (PDT)
Date: Mon, 22 Oct 2012 14:03:39 -0400
From: Chris Perl <chris.perl@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: RPC Race Condition
Message-ID: <20121022180339.GC24763@nyc-qws-132.nyc.delacy.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="WIyZ46R2i8wDzkSu"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I believe I may have identified a race condition with the client side
RPC code that comes into play when handling a reconnect.

First, I'll detail how to reproduce it, then give some details on what I
think is going on.


TO REPRODUCE:

Client is 192.168.1.100
Server is 192.168.1.200

client# showmount -e server
Export list for server:
/export/test 192.168.1.100
client# mkdir -p /mnt/test
client# mount -t nfs -o \
	ro,relatime,vers=3,rsize=131072,wsize=524288,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,proto=tcp,timeo=600,retrans=2,sec=sys \
	192.168.1.200:/export/test /mnt/test

Note: I have set all the ac* variables to 0 to better be able to trace
the calls my user space program is making to things that go out over the
wire.  This is not crucial as the problem still exists with these set to
the default.

Now, on the client start the attached python program [1] with real time
priority (SCHED_RR), stat'ing a file on the NFS mount:

client# touch /mnt/test/file.txt
client# chrt 50 ./hang.py /mnt/test/file.txt 10

>From here, it is necessary to simulate a network event such that the
client is unable to talk to the server, but the server is still able to
talk to the client.

client# ip route add blackhole 192.168.1.200/32 && ip route flush cache

Now, we wait until the userspace program makes its next stat call.  Once
it does, restart the NFS server processes on the server:

server# /etc/init.d/nfs restart

The idea of restarting the nfs server processes is to ensure that FINs
and/or an RST come across from the server to the client, changing the
state of its socket while its waiting for the response to its call of
`call_transmit' from within `__rpc_execute'.

Finally back on the client, remove the blackhole route:

client# ip route del 192.168.1.200/32 && ip route flush cache

Once the route is removed, you should be able to do things like ping the
server again, run `rpcinfo -p' against it, etc.  However, any NFS
operations for this server will continue to hang.  The way to recover is
to kill the SCHED_RR process.  After that, things will recover.


NOTES:

This setup for reproducing the problem may seem a little silly, but we
had something very similiar happen in our production environment a
couple of weeks ago and it caused us to get into this situation.  Note
that it has nothing to do with the server side of things.  I've seen
this happen with a linux NFS server (as above) and with a NAS from a
large storage vendor.

If you run the stat'ing process as a normal process, i.e. SCHED_OTHER,
then everything recovers without intervention (i.e. it all works as it
should).  However, I believe the same race condition is still there, but
just doesn't manifest because in this case the stat'ing process does not
have the same scheduling advantage over rpciod.

We experienced this problem on the following CentOS kernel:
2.6.32-279.5.2.el6.centos.plus.x86_64, but I've verified that the same
behavior exists as late as 3.7rc2.

During the hanging, if you watch the network, you can see that the
client continually completes a TCP 3-way handhsake, but then immediately
tears the connection down.


MY ATTEMPTED ANALYSIS:

First, I am no expert and just starting looking at the rpc code in the
kernel about 2 weeks ago.  Therefore some or all of what I lay out here
may be wrong or misguided etc.  This is just what I've been able to
figure out by looking at the source code and writing a bunch of
SystemTap scripts.

I can get more detailed if necessary (including sharing the SystemTap
scripts I used to observe this behavior), but don't want to make this
email overly long, so will just touch on the high points:

  - The sleeping process is that is in the middle of waiting for a
    response to `call_transmit' is woken up via `xs_error_report' when
    the FINs and/or RST comes across the wire.

  - It finds the `tk_status' field of the task set to EAGAIN, and so
    retries `call_transmit'.

  - On the next attempt, `tcp_sendmsg' and its call of
    `sk_stream_wait_connect' see the socket has an error of ECONNRESET.
    Therefore, the next call to `call_status' sees this and sets the
    next `tk_action' to be `call_bind'. 

  - `call_bind' does its thing and then we come to `call_connect'

  - `call_connect' schedules the execution of `xs_tcp_setup_socket' with
    rpciod via rpciod's workqueue and then goes to sleep.

  - Here is where I believe the problem comes about.  Our sleeping
    thread waiting for the connect to finish is woken up by rpciod
    early via the following call stack:

      0xffffffffa042f840 : rpc_make_runnable+0x0/0x80 [sunrpc]
      0xffffffffa042fb5e : rpc_wake_up_task_queue_locked+0x18e/0x270 [sunrpc]
      0xffffffffa042fc8e : rpc_wake_up_status+0x4e/0x80 [sunrpc]
      0xffffffffa04288ec : xprt_wake_pending_tasks+0x2c/0x30 [sunrpc]
      0xffffffffa042b9fd : xs_error_report+0x4d/0x90 [sunrpc]
      0xffffffff81487436 : tcp_disconnect+0x356/0x410 [kernel]
      0xffffffff814a9c20 : inet_stream_connect+0x50/0x2c0 [kernel]
      0xffffffff8142bb20 : kernel_connect+0x10/0x20 [kernel]
      0xffffffffa042b368 : xs_tcp_setup_socket+0xe8/0x4c0 [sunrpc]
      0xffffffff8108c760 : worker_thread+0x170/0x2a0 [kernel]
      0xffffffff81091d66 : kthread+0x96/0xa0 [kernel]
      0xffffffff8100c14a : child_rip+0xa/0x20 [kernel]

    It appears that with rpciod trying to reconnect, it winds up
    indirectly invoking `xs_error_report' via a callback from the
    sock/tcp layer.

  - At this point the `tk_status' is set to EAGAIN, so if
    `call_connect_status' handled EGAIN by setting `tk_action' to
    `call_connect' again AND rpciod was finished trying to execute
    `xs_tcp_setup_socket' then we would be ok.

  - However, `call_connect_status' sets `tk_action' to `call_transmit'
    and goes on.

  - At this point rpciod is still executing trying to connect the
    socket, and eventually will succeed, but now our thread and rpciod
    are racing to see who can update/check the state of the socket
    first.

    Depending on who wins and what status is returned,
    `xs_tcp_send_request' will either tear the connection down and
    retry, or it will simply retry without the teardown.  We can wind up
    in a loop of setup/teardowns and are never able to actually return
    from `__rpc_execute.'

    Since we're stuck in `__rpc_execute' and the transport is locked, no
    other NFS operations can come in and they all hang.

Simply changing `call_connect_status' to handle EAGAIN as described
above did "fix" my problem and I could no longer reproduce the issue,
however I believe that could result in another race condition with
multiple rpciod's trying to execute `xs_tcp_setup_socket' at the same
time.

I think the "right" fix, at least as far as I can tell would be to
ensure that rpciod does not wake up the process sleeping on
`call_connect' until it is completely done with its work (whether that
is success or failure).  I believe this coupled with making
`call_connect_status' handle EAGAIN would work.

Unfortunately, I'm stretching my abilities here and do not really have a
good understanding of how the interactions come together to be able to
submit a patch to fix this.


WORKAROUND:

Based on what I found above I decided to try setting the real time
priority of all my rpciod threads to one higher than that of my real
time stat'ing process (i.e. 51).  When I did this, I could no longer
reproduce the problem.  Setting the rt priority to 49 however, did allow
it to still happen.  I believe this is essentially the same reason that
things seem to work normally for SCHED_OTHER processes.  Simply that
they do not have the same scheduling advantage over rpciod and therefore
its likely that rpciod wins and our thread finds the socket state as
either `TCP_SYN_SENT' or `TCP_ESTABLISHED' and everything recovers.

Chris

[1] hang.py

--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="hang.py"

#!/usr/bin/python

import os 
import sys
import time
import datetime

f=sys.argv[1]
s=float(sys.argv[2])

while True:
	r = os.stat(f)
	print "%s %r" % (datetime.datetime.now(), r)
	time.sleep(s)

--WIyZ46R2i8wDzkSu--
