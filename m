From: mike <mike503@gmail.com>
Subject: Re: Trying to determine why my NFS connection goes away
Date: Thu, 14 Jun 2007 23:33:17 -0700
Message-ID: <bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
References: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
	<1181874951.15174.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hz5Mx-0004Xf-S5
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 23:33:15 -0700
Received: from an-out-0708.google.com ([209.85.132.247])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hz5N0-0006eI-RU
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 23:33:19 -0700
Received: by an-out-0708.google.com with SMTP id b38so184639ana
	for <nfs@lists.sourceforge.net>; Thu, 14 Jun 2007 23:33:17 -0700 (PDT)
In-Reply-To: <1181874951.15174.15.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

no - if you look at the mount parameters i am explicitly stating TCP.
i have compiled kernels with TCP as well. i haven't used UDP in
forever. also i do have NFSv4 available but have had odd issues in the
past, i don't know how stable it is for simple mounts now (i don't
need anything crazy, or thousands of client machines, etc)

i should also mention that i applied these to try to ensure i don't
have any leftover sockets, trying to cut down on the amount of TCP
overhead, etc. i've been having the same NFS issues before this too
(at least the same messages) so it's not due to that (at least,
there's no reason to consider that the culprit)

this is the same sysctl config on both the client and the server.

[root@web03 ~]# cat /etc/sysctl.conf
# Uncomment the next line to enable TCP/IP SYN cookies
net.ipv4.tcp_syncookies=1

# others
vm.swappiness=10
net.ipv4.ip_local_port_range = 1024 65000

# Controls IP packet forwarding
net.ipv4.ip_forward = 1
net.ipv4.conf.default.forwarding=1

# Controls whether core dumps will append the PID to the core filename.
# Useful for debugging multi-threaded applications.
kernel.core_uses_pid = 1

# suggested
net.ipv4.icmp_echo_ignore_broadcasts = 1
# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_source_route = 0
# Uncomment the next line to enable Spoof protection (reverse-path filter)
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.accept_redirects = 0

# my guess
net.ipv4.tcp_max_orphans = 1024
# Decrease the time default value for tcp_keepalive_time connection
net.ipv4.tcp_keepalive_time = 300
# Turn off the tcp_window_scaling
net.ipv4.tcp_window_scaling = 0
# Turn off the tcp_sack
net.ipv4.tcp_sack = 0
# Turn off the tcp_timestamps
net.ipv4.tcp_timestamps = 0

net.ipv4.tcp_rfc1337 = 1
net.core.rmem_default = 262144
net.core.rmem_max = 262144

# These ensure that TIME_WAIT ports either get reused or closed fast.
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_tw_recycle = 1

# TCP memory
net.core.rmem_max = 16777216
net.core.rmem_default = 16777216
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 262144

net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2

# If you have a lot of large file uploads, increasing the receive
buffers will help.
net.ipv4.tcp_rmem = 4096 87380 524288
net.core.rmem_max = 1048576

# Increasing the TCP send and receive buffers will increase the
performance a lot if (and only if) you have a lot of large files to
send.
net.ipv4.tcp_wmem = 4096 65536 524288
net.core.wmem_max = 1048576

# you shouldn't be using conntrack on a heavily loaded server anyway,
but these are
# suitably high for our uses, insuring that if conntrack gets turned
on, the box doesn't die
net.ipv4.ip_conntrack_max = 1048576
net.nf_conntrack_max = 1048576


On 6/14/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2007-06-14 at 16:25 -0700, mike wrote:
> > THE ISSUE (easily repeatable by doing a bunch of file I/O on the client - using
> > nhfsstone, eventually my "normal" web load hits it too)
> >
> > I will dump as much information as possible... I really want to make
> > sure that I have the most optimal setup.
> >
> > This is the output from dmesg that concerns me:
> >
> >  nfs: server raid01 not responding, still trying
> >  nfs: server raid01 not responding, still trying
> >  nfs: server raid01 not responding, still trying
> >  nfs: server raid01 OK
> >  nfs: server raid01 OK
> >  nfs: server raid01 OK
> >  nfs: server raid01 not responding, still trying
> >  nfs: server raid01 not responding, still trying
> >  nfs: server raid01 not responding, still trying
> >  nfs: server raid01 OK
> >  nfs: server raid01 OK
>
> It sounds as if you are using UDP mounts in a situation where you
> probably should be using TCP mounts.
>
> Cheers
>  Trond
>
>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
