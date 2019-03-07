Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD0FAC43381
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:53:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6F77520652
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:53:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726250AbfCGPxG convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 10:53:06 -0500
Received: from mail.lysator.liu.se ([130.236.254.3]:55369 "EHLO
        mail.lysator.liu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726579AbfCGPxG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 10:53:06 -0500
Received: from mail.lysator.liu.se (localhost [127.0.0.1])
        by mail.lysator.liu.se (Postfix) with ESMTP id 451AF4000D
        for <linux-nfs@vger.kernel.org>; Thu,  7 Mar 2019 16:53:01 +0100 (CET)
Received: by mail.lysator.liu.se (Postfix, from userid 1004)
        id 32DF040016; Thu,  7 Mar 2019 16:53:01 +0100 (CET)
Received: from [IPv6:2001:6b0:17:f002:8f4:6288:84ed:c77c] (unknown [IPv6:2001:6b0:17:f002:8f4:6288:84ed:c77c])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.lysator.liu.se (Postfix) with ESMTPSA id 0742A4000D
        for <linux-nfs@vger.kernel.org>; Thu,  7 Mar 2019 16:53:00 +0100 (CET)
From:   Peter Eriksson <pen@lysator.liu.se>
Content-Type: text/plain;
        charset=utf-8
Content-Transfer-Encoding: 8BIT
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: [Patch] NULL-pointer dereference in gssd (nfs-utils version 1.3.0,
 1.3.4 & 2.3.3)
Date:   Thu, 7 Mar 2019 16:52:58 +0100
References: <77C72E28-D137-408E-834B-623341F21BB3@lysator.liu.se>
To:     linux-nfs@vger.kernel.org
In-Reply-To: <77C72E28-D137-408E-834B-623341F21BB3@lysator.liu.se>
Message-Id: <0B89AD32-CDD9-4AD4-A059-DDB3580E172D@lysator.liu.se>
X-Mailer: Apple Mail (2.3445.102.3)
X-Virus-Scanned: ClamAV using ClamSMTP
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please find enclosed a couple of silly patches that fixes this core-dump in rpc.gssd in nfs-utils 2.3.3, 1.3.4 & 1.3.0


— NFS-UTILS 2.3.3 — 

diff -r -u nfs-utils-2.3.3/utils/gssd/gssd_proc.c nfs-utils-2.3.3-liu/utils/gssd/gssd_proc.c
--- nfs-utils-2.3.3/utils/gssd/gssd_proc.c	2018-09-06 20:09:08.000000000 +0200
+++ nfs-utils-2.3.3-liu/utils/gssd/gssd_proc.c	2019-03-01 21:07:42.580105572 +0100
@@ -345,11 +345,12 @@
 
 	/* create an rpc connection to the nfs server */
 
-	printerr(2, "creating %s client for server %s\n", clp->protocol,
-			clp->servername);
+	printerr(2, "creating %s client for server %s\n", 
+		 clp->protocol ? clp->protocol : "<null>",
+		 clp->servername ? clp->servername : "<null>");
 
 	protocol = IPPROTO_TCP;
-	if ((strcmp(clp->protocol, "udp")) == 0)
+	if (clp->protocol && strcmp(clp->protocol, "udp") == 0)
 		protocol = IPPROTO_UDP;
 
 	switch (addr->sa_family) {




— NFS-UTILS 1.3.4 —

diff -u -r nfs-utils-1.3.4/utils/gssd/gssd_proc.c nfs-utils-1.3.4-liu/utils/gssd/gssd_proc.c
--- nfs-utils-1.3.4/utils/gssd/gssd_proc.c	2016-08-03 20:25:15.000000000 +0200
+++ nfs-utils-1.3.4-liu/utils/gssd/gssd_proc.c	2019-03-07 16:47:31.388471317 +0100
@@ -345,11 +345,12 @@
 
 	/* create an rpc connection to the nfs server */
 
-	printerr(2, "creating %s client for server %s\n", clp->protocol,
-			clp->servername);
+	printerr(2, "creating %s client for server %s\n", 
+                 clp->protocol ? clp->protocol : "<null>",
+                 clp->servername ? clp->servername : "<null>");
 
 	protocol = IPPROTO_TCP;
-	if ((strcmp(clp->protocol, "udp")) == 0)
+	if (clp->protocol && (strcmp(clp->protocol, "udp")) == 0)
 		protocol = IPPROTO_UDP;
 
 	switch (addr->sa_family) {



— NFS-UTILS 1.3.0 —

diff -u -r nfs-utils-1.3.0/utils/gssd/gssd_proc.c nfs-utils-1.3.0-liu/utils/gssd/gssd_proc.c
--- nfs-utils-1.3.0/utils/gssd/gssd_proc.c	2014-03-25 16:12:07.000000000 +0100
+++ nfs-utils-1.3.0-liu/utils/gssd/gssd_proc.c	2019-03-07 16:45:17.776417634 +0100
@@ -878,12 +878,13 @@
 
 	/* create an rpc connection to the nfs server */
 
-	printerr(2, "creating %s client for server %s\n", clp->protocol,
-			clp->servername);
+	printerr(2, "creating %s client for server %s\n", 
+                 clp->protocol ? clp->protocol : "<null>",
+                 clp->servername ? clp->servername : "<null>");
 
-	if ((strcmp(clp->protocol, "tcp")) == 0) {
+	if (clp->protocol && (strcmp(clp->protocol, "tcp")) == 0) {
 		protocol = IPPROTO_TCP;
-	} else if ((strcmp(clp->protocol, "udp")) == 0) {
+	} else if (clp->protocol && (strcmp(clp->protocol, "udp")) == 0) {
 		protocol = IPPROTO_UDP;
 	} else {
 		printerr(0, "WARNING: unrecognized protocol, '%s', requested "


- Peter


> On 1 Mar 2019, at 13:25, Peter Eriksson <pen@lysator.liu.se> wrote:
> 
> I’m seeing Segmentation Faults in gssd from nfs-utils 1.3.4 and 2.3.3 when running it on a machine running CentOS 7.6.1810 / kernel 3.10.0-957.5.1.el7.x86_64 that uses GSSAPI quite a bit (a Linux machine doing validation checks of our fileserver - runs a list of SMB/NFS/LDAP/Kerberos check every minute 24/7). We compiled our own version since the version that CentOS delivers (1.3.0) also crashed (unsure if it is the same bug there though).
> 
> 
> # gdb ./gssd
> (gdb) run -f -v
> ...
> [New Thread 0x7fffef7fe700 (LWP 24902)]
> Error doing scandir on directory '/run/user/11189': No such file or directory
> [Thread 0x7fffef7fe700 (LWP 24902) exited]
> [New Thread 0x7fffeffff700 (LWP 24904)]
> Error doing scandir on directory '/run/user/11189': No such file or directory
> [Thread 0x7fffeffff700 (LWP 24904) exited]
> 
> Program received signal SIGSEGV, Segmentation fault.
> [Switching to Thread 0x7ffff4cec700 (LWP 24448)]
> create_auth_rpc_client (clp=clp@entry=0x621590, tgtname=tgtname@entry=0x0, 
>    clnt_return=clnt_return@entry=0x7ffff4cebd48, 
>    auth_return=auth_return@entry=0x7ffff4cebcd0, uid=uid@entry=0, 
>    authtype=authtype@entry=0, cred=cred@entry=0x0) at gssd_proc.c:352
> 352		if ((strcmp(clp->protocol, "udp")) == 0)
> Missing separate debuginfos, use: debuginfo-install glibc-2.17-260.el7_6.3.x86_64 gssproxy-0.7.0-21.el7.x86_64 keyutils-libs-1.5.8-3.el7.x86_64 krb5-libs-1.15.1-37.el7_6.x86_64 libcom_err-1.42.9-13.el7.x86_64 libevent-2.0.21-4.el7.x86_64 libselinux-2.5-14.1.el7.x86_64 libtirpc-0.2.4-0.15.el7.x86_64 pcre-8.32-17.el7.x86_64
> 
> (gdb) where
> #0  create_auth_rpc_client (clp=clp@entry=0x621590, tgtname=tgtname@entry=0x0, 
>    clnt_return=clnt_return@entry=0x7ffff4cebd48, 
>    auth_return=auth_return@entry=0x7ffff4cebcd0, uid=uid@entry=0, 
>    authtype=authtype@entry=0, cred=cred@entry=0x0) at gssd_proc.c:352
> #1  0x0000000000406d21 in krb5_use_machine_creds (rpc_clnt=0x7ffff4cebd48, 
>    service=0x6293c0 "*", tgtname=0x0, srchost=0x0, uid=0, clp=0x621590)
>    at gssd_proc.c:569
> #2  process_krb5_upcall (clp=clp@entry=0x621590, uid=uid@entry=0, fd=13, 
>    srchost=srchost@entry=0x0, tgtname=tgtname@entry=0x0, 
>    service=service@entry=0x6293c0 "*") at gssd_proc.c:657
> #3  0x000000000040759c in handle_gssd_upcall (info=0x6293a0) at gssd_proc.c:819
> #4  0x00007ffff6de6dd5 in start_thread () from /lib64/libpthread.so.0
> #5  0x00007ffff68f6ead in clone () from /lib64/libc.so.6
> 
> (gdb) frame 0
> #0  create_auth_rpc_client (clp=clp@entry=0x621590, tgtname=tgtname@entry=0x0, 
>    clnt_return=clnt_return@entry=0x7ffff4cebd48, 
>    auth_return=auth_return@entry=0x7ffff4cebcd0, uid=uid@entry=0, 
>    authtype=authtype@entry=0, cred=cred@entry=0x0) at gssd_proc.c:352
> 352		if ((strcmp(clp->protocol, "udp")) == 0)
> 
> (gdb) list
> 347	
> 348		printerr(2, "creating %s client for server %s\n", clp->protocol,
> 349				clp->servername);
> 350	
> 351		protocol = IPPROTO_TCP;
> 352		if ((strcmp(clp->protocol, "udp")) == 0)
> 353			protocol = IPPROTO_UDP;
> 354	
> 355		switch (addr->sa_family) {
> 356		case AF_INET:
> 
> (gdb) print clp
> $1 = (struct clnt_info *) 0x621590
> 
> (gdb) print clp->protocol
> $2 = 0x0
> 
> (gdb) print *clp
> $3 = {list = {tqe_next = 0x0, tqe_prev = 0xffffffff}, wd = 0, scanned = false, 
>  name = 0x0, relpath = 0x0, servicename = 0x0, servername = 0x0, prog = 0, 
>  vers = 0, protocol = 0x0, krb5_fd = 0, krb5_ev = {ev_active_next = {
>      tqe_next = 0x0, tqe_prev = 0x0}, ev_next = {tqe_next = 0x0, 
>      tqe_prev = 0x0}, ev_timeout_pos = {ev_next_with_common_timeout = {
>        tqe_next = 0x0, tqe_prev = 0x0}, min_heap_idx = 0}, ev_fd = 0, 
>    ev_base = 0x0, _ev = {ev_io = {ev_io_next = {tqe_next = 0x0, 
>          tqe_prev = 0x0}, ev_timeout = {tv_sec = 0, tv_usec = 0}}, 
>      ev_signal = {ev_signal_next = {tqe_next = 0x0, tqe_prev = 0x0}, 
>        ev_ncalls = 0, ev_pncalls = 0x0}}, ev_events = 0, ev_res = 0, 
>    ev_flags = 0, ev_pri = 0 '\000', ev_closure = 0 '\000', ev_timeout = {
>      tv_sec = 0, tv_usec = 0}, ev_callback = 0x0, ev_arg = 0x0}, gssd_fd = 0, 
>  gssd_ev = {ev_active_next = {tqe_next = 0x0, tqe_prev = 0x0}, ev_next = {
>      tqe_next = 0x0, tqe_prev = 0x0}, ev_timeout_pos = {
>      ev_next_with_common_timeout = {tqe_next = 0x0, tqe_prev = 0x0}, 
>      min_heap_idx = 0}, ev_fd = 496, ev_base = 0x70, _ev = {ev_io = {
>        ev_io_next = {tqe_next = 0x0, tqe_prev = 0x7f3865333232}, 
>        ev_timeout = {tv_sec = 0, tv_usec = 273}}, ev_signal = {
>        ev_signal_next = {tqe_next = 0x0, tqe_prev = 0x7f3865333232}, 
>        ev_ncalls = 0, ev_pncalls = 0x111}}, ev_events = -1864, 
>    ev_res = -2373, ev_flags = 32767, ev_pri = 0 '\000', 
>    ev_closure = 0 '\000', ev_timeout = {tv_sec = 140737332902072, 
>      tv_usec = 4294977170}, ev_callback = 0x6218c4, ev_arg = 0x240}, addr = {
> ---Type <return> to continue, or q <return> to quit---
>    ss_family = 32, 
>    __ss_padding = "\000\000\000\000\000\000\260\020b\000\000\000\000\000\270\367\273\366\377\177\000\000`\002\000\000\000\000\000\000\301\000\000\000\000\000\000\000\360\027b\000\000\000\000\000\000\214b", '\000' <repeats 13 times>, "\241\000\000\000\000\000\000\000\200\021b\000\000\000\000\000H\370\273\366\377\177", '\000' <repeats 26 times>, "q\000\000\000\000\000\000", __ss_align = 6427008}}
> 
> (gdb) frame 1
> #1  0x0000000000406d21 in krb5_use_machine_creds (rpc_clnt=0x7ffff4cebd48, 
>    service=0x6293c0 "*", tgtname=0x0, srchost=0x0, uid=0, clp=0x621590)
>    at gssd_proc.c:569
> 569				if ((create_auth_rpc_client(clp, tgtname, rpc_clnt,
> 
> (gdb) list
> 564					printerr(1, "WARNING: gss_krb5_ccache_name "
> 565						 "with name '%s' failed (%s)\n",
> 566						 *ccname, error_message(min_stat));
> 567					continue;
> 568				}
> 569				if ((create_auth_rpc_client(clp, tgtname, rpc_clnt,
> 570							&auth, uid,
> 571							AUTHTYPE_KRB5,
> 572							GSS_C_NO_CREDENTIAL)) == 0) {
> 573					/* Success! */
> 
> (gdb) print tgtname
> $6 = 0x0
> 
> (gdb) print rpc_clnt
> $7 = (CLIENT **) 0x7ffff4cebd48
> 
> (gdb) print *rpc_clnt
> $8 = (CLIENT *) 0x0
> 
> (gdb) frame 2
> #2  process_krb5_upcall (clp=clp@entry=0x621590, uid=uid@entry=0, fd=13, 
>    srchost=srchost@entry=0x0, tgtname=tgtname@entry=0x0, 
>    service=service@entry=0x6293c0 "*") at gssd_proc.c:657
> 657				auth =	krb5_use_machine_creds(clp, uid, srchost, tgtname,
> 
> (gdb) list
> 652				goto out_return_error;
> 653		}
> 654		if (auth == NULL) {
> 655			if (uid == 0 && (root_uses_machine_creds == 1 ||
> 656					service != NULL)) {
> 657				auth =	krb5_use_machine_creds(clp, uid, srchost, tgtname,
> 658								service, &rpc_clnt);
> 659				if (auth == NULL)
> 660					goto out_return_error;
> 661			} else {
> 
> (gdb) print uid
> $9 = 0
> 
> (gdb) print srchost
> $10 = 0x0
> 
> (gdb) print tgtname
> $11 = 0x0
> 
> 
> Exactly what is causing this event to happen is unclear (a lot of automated checks are running, but they run well for a couple of hours before this crash occur).
> 
> Please let me know if there is some other information someone might need to fix this bug… (I’m going to add sanity checks to the code in order to try to mitigate the crash and instead fail in a more “nice” way).
> 
> - Peter

