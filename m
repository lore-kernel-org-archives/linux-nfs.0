From: Roger Leigh <roger.leigh@epictechnology.co.uk>
Subject: rpc.statd: Received erroneous SM_UNMON request
Date: Thu, 28 Oct 2004 15:03:02 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041028140302.GA7584@epictechnology.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CNAs0-0007sv-57
	for nfs@lists.sourceforge.net; Thu, 28 Oct 2004 07:03:16 -0700
Received: from mail.metronet.co.uk ([213.162.97.75])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CNArz-0005mx-1N
	for nfs@lists.sourceforge.net; Thu, 28 Oct 2004 07:03:16 -0700
Received: from till2.lan (unknown [213.162.108.80])
	by smtp.metronet.co.uk (MetroNet Mail) with ESMTP id 16158419046
	for <nfs@lists.sourceforge.net>; Thu, 28 Oct 2004 15:02:23 +0100 (BST)
Received: from roger by till2.lan with local (Exim 4.34)
	id 1CNArm-0001zV-3g
	for nfs@lists.sourceforge.net; Thu, 28 Oct 2004 15:03:02 +0100
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi folks,

I'm getting a lot of these messages in my logs, and also hangs of up to
a minute on client machines during which a couple of these messages are
logged in the server (the client starts responding immediately after the
second message).  I've checked past posts with this problem, which
seemed to suggest
 - rpc.statd couldn't write /var/lib/nfs[/sm[.bak]]
   (this is not a problem)
 - the FQDN ("hostname -f") didn't match "uname -n"
   (they are identical on the server and client after I put the FQDN in
   /etc/hostname to correct uname -n)


The server has this export:
/srv/epic *(rw,sync,secure_locks,no_root_squash)

and the client has these mounts:
automount(pid2036) on /var/autofs/net type autofs
(rw,fd=5,pgrp=2036,minproto=2,maxproto=4)
till2:/home/epic on /var/autofs/net/till2/home/epic type nfs
(rw,nosuid,nodev,hard,intr,nfsvers=3,udp,rsize=8192,wsize=8192,addr=10.0.0.156)

This is using autofs4 with Linux 2.6.8.1 on both machines.


I've tried a number of NFS options, including tcp/udp, rsize/wsize,
checked tcp wrappers are permissive enough, but I've not been able to
identify the cause of the problem.  The hanging /may/ have been due
to too restrictive tcp wrappers (hosts.allow) on one of the machines,
but after relaxing the restrictions the SM_UNMON errors are still
being logged.


The application running on the client is a DOS database application
(Clipper-like) using database files on the server running under DOSEMU.
It uses record locking to lock regions of the file.  This part appears
to work well (it cooperates with locks taken by Samba from Windows
clients running the same program),but the hangs are not so good.


Are there any other known causes of this problem?
Is there anything else I can check?

This is what gets logged on the server:
Oct 27 11:35:25 till2 kernel: lockd: request from 0a00009d
Oct 27 11:35:25 till2 kernel: lockd: nlm_lookup_host(0a00009d, p=17,
v=4)
Oct 27 11:35:25 till2 kernel: lockd: host garbage collection
Oct 27 11:35:25 till2 kernel: lockd: nlmsvc_mark_resources
Oct 27 11:35:25 till2 kernel: lockd: delete host 10.0.0.157
Oct 27 11:35:25 till2 kernel: lockd: nsm_unmonitor(10.0.0.157)
Oct 27 11:35:25 till2 rpc.statd[2757]: Received erroneous SM_UNMON
request from till2.lan for 10.0.0.157
Oct 27 11:35:25 till2 kernel: lockd: creating host entry
Oct 27 11:35:25 till2 kernel: lockd: nsm_monitor(10.0.0.157)
Oct 27 11:35:25 till2 kernel: nsm: xdr_decode_stat_res status 0 state 83
Oct 27 11:35:25 till2 kernel: lockd: nlm_file_lookup(02000001 0400fe00
00010001 00010804 13bb0bdb 00010796)
Oct 27 11:35:25 till2 kernel: lockd: creating file for (02000001
0400fe00 00010001 00010804
13bb0bdb 00010796)
Oct 27 11:35:25 till2 kernel: lockd: found file dde34800 (count 0)
Oct 27 11:35:25 till2 kernel: lockd: nlmsvc_lock(dm-4/67588, ty=1,
pi=2229, 805306370-805306371, bl=0)

and this is the client log:
Oct 27 11:29:25 till1 kernel: lockd: release host 10.0.0.156
Oct 27 11:34:15 till1 kernel: lockd: nlm_lookup_host(0a00009c, p=17,
v=4)
Oct 27 11:34:15 till1 kernel: lockd: host garbage collection
Oct 27 11:34:15 till1 kernel: lockd: nlmsvc_mark_resources
Oct 27 11:34:15 till1 kernel: lockd: delete host 10.0.0.156
Oct 27 11:34:15 till1 kernel: lockd: nsm_unmonitor(10.0.0.156)
Oct 27 11:34:15 till1 rpc.statd[2099]: Received erroneous SM_UNMON
request from till1.lan for 10.0.0.156
Oct 27 11:34:15 till1 kernel: lockd: creating host entry
Oct 27 11:34:15 till1 kernel: lockd: nlm_bind_host(0a00009c)
Oct 27 11:34:15 till1 kernel: lockd: nsm_monitor(10.0.0.156)
Oct 27 11:34:15 till1 kernel: nsm: xdr_decode_stat_res status 0 state 79
Oct 27 11:34:15 till1 kernel: lockd: nlm_bind_host(0a00009c)
Oct 27 11:34:15 till1 kernel: lockd: release host 10.0.0.156
Oct 27 11:34:15 till1 kernel: lockd: get host 10.0.0.156
Oct 27 11:34:15 till1 kernel: lockd: nlm_lookup_host(0a00009c, p=17,
v=4)
Oct 27 11:34:15 till1 kernel: lockd: get host 10.0.0.156
Oct 27 11:34:15 till1 kernel: lockd: nlm_bind_host(0a00009c)


Many thanks,
Roger

-- 
Roger Leigh

                Printing on GNU/Linux?  http://gimp-print.sourceforge.net/
                GPG Public Key: 0x25BFB848.  Please sign and encrypt your mail.


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
