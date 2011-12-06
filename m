Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:55144 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642Ab1LFRBY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Dec 2011 12:01:24 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RXyOR-000580-63
	for linux-nfs@vger.kernel.org; Tue, 06 Dec 2011 18:01:23 +0100
Received: from NORTHWEST-R.car1.Denver1.Level3.net ([4.28.99.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 18:01:23 +0100
Received: from orion by NORTHWEST-R.car1.Denver1.Level3.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 18:01:23 +0100
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: rpc.gssd locks up with -vv or higher
Date: Tue, 6 Dec 2011 17:01:13 +0000 (UTC)
Message-ID: <loom.20111206T175726-323@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See https://bugzilla.redhat.com/show_bug.cgi?id=667770

Running rpc.gssd with -vvv, it will eventually hang.  Back trace of hung process:

#0  0x00ae8416 in __kernel_vsyscall ()
#1  0x004be5d1 in __lll_lock_wait_private () from /lib/libc.so.6
#2  0x0044985c in _L_lock_12621 () from /lib/libc.so.6
#3  0x00447797 in malloc () from /lib/libc.so.6
#4  0x0043a398 in open_memstream () from /lib/libc.so.6
#5  0x004a9ae5 in __vsyslog_chk () from /lib/libc.so.6
#6  0x0017d15f in vsyslog (kind=512, 
    fmt=0x1806cc "dir_notify_handler: sig %d si %p data %p\n", args=0xbfc03938
"%")
    at /usr/include/bits/syslog.h:48
#7  xlog_backend (kind=512, fmt=0x1806cc "dir_notify_handler: sig %d si %p data
%p\n", 
    args=0xbfc03938 "%") at xlog.c:150
#8  0x001777d4 in printerr (priority=2, 
    format=0x1806cc "dir_notify_handler: sig %d si %p data %p\n") at
err_util.c:64
#9  0x00177c9e in dir_notify_handler (sig=37, si=0xbfc0396c, data=0xbfc039ec)
    at gssd_main_loop.c:66
#10 <signal handler called>
#11 0x00444984 in _int_malloc () from /lib/libc.so.6
#12 0x004477a0 in malloc () from /lib/libc.so.6
#13 0x0046db77 in __alloc_dir () from /lib/libc.so.6
#14 0x0046dc5a in opendir () from /lib/libc.so.6
#15 0x0046e7ef in scandir64@@GLIBC_2.2 () from /lib/libc.so.6
#16 0x00179285 in process_pipedir () at gssd_proc.c:565
#17 update_client_list () at gssd_proc.c:594
#18 0x00177f40 in gssd_run () at gssd_main_loop.c:216
#19 0x00177bf9 in main (argc=2, argv=0xbfc04134) at gssd.c:187

Looks like malloc is getting called from a signal handler called while in a
malloc call, which is verboten.  Not sure what the best way around this, but it
looks like dir_notify_handler cannot call printerr.  I suppose this only occurs
when -vv or greater is given.  Path looks a little different in 1.2.5, but looks
like xlog_backend still calls vsyslog which can do the same thing.



