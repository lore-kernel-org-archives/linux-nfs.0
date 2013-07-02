Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:58830 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932139Ab3GBINE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jul 2013 04:13:04 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<sven@gegg.us>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1Utvht-0003IA-FM
	for linux-nfs@vger.kernel.org; Tue, 02 Jul 2013 10:13:02 +0200
Received: from sven  by ultimate100.geggus.net (envelope-from
	<sven@gegg.us>)
	with local (Exim 4.72)
	id 1Utvhp-0004nY-6k
	for linux-nfs@vger.kernel.org; Tue, 02 Jul 2013 10:12:57 +0200
Date: Tue, 2 Jul 2013 10:05:30 +0200
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net
Subject: Re: Kerberized NFS-Server Problem still present in 3.10.0-rc2
Message-ID: <20130702080530.GA17953@geggus.net>
References: <kpscp8$fo3$1@ultimate100.geggus.net>
 <20130619213412.GA2547@fieldses.org>
 <20130620080354.GA5591@geggus.net>
 <20130620144955.GB11728@fieldses.org>
 <20130620145209.GC11728@fieldses.org>
 <20130621083221.GA4103@geggus.net>
 <20130624215408.GD23596@fieldses.org>
 <20130625094612.GA2186@geggus.net>
 <20130701205234.GF19945@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130701205234.GF19945@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields schrieb am Montag, den 01. Juli um 22:52 Uhr:

> It includes the contents of /etc/krb5.keytab, so I'm guessing so.

The server is a test-vm anyway.

> It'd be interesting to know exactly where nfsd decides to drop the
> rpc that uses this new context....  Turning on all the nfsd and rpc
> debugging *might* help there.  (rpcdebug -m rpc -s all; rpcdebug -m nfsd
> -s all).

 ~/ # rpcdebug -m rpc -s all
rpc        xprt call debug nfs auth bind sched trans svcsock svcdsp misc cache
 ~/ # rpcdebug -m nfsd -s all
nfsd       sock fh export svc proc fileop auth repcache xdr lockd

Here is what I get (Kernel is vanilla 3.10.0):

Jul  2 09:52:41 vnfsrv kernel: Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
Jul  2 09:52:41 vnfsrv kernel: NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Jul  2 09:52:41 vnfsrv kernel: NFSD: starting 90-second grace period (net ffffffff81556500)
Jul  2 09:54:11 vnfsrv kernel: NFSD: laundromat service - starting
Jul  2 09:54:11 vnfsrv kernel: NFSD: end of grace period
Jul  2 09:54:11 vnfsrv kernel: NFSD: laundromat_main - sleeping for 90 seconds
Jul  2 09:55:42 vnfsrv kernel: NFSD: laundromat service - starting
Jul  2 09:55:42 vnfsrv kernel: NFSD: laundromat_main - sleeping for 90 seconds
Jul  2 09:56:42 vnfsrv kernel: svc: socket ffff8800167aad40 TCP (listen) state change 10
Jul  2 09:56:42 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff88001657a000
Jul  2 09:56:42 vnfsrv kernel: svc: socket ffff8800162147c0 TCP (listen) state change 1
Jul  2 09:56:42 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 09:56:42 vnfsrv kernel: nfsd: connect from 10.1.7.30, port=740
Jul  2 09:56:42 vnfsrv kernel: svc: svc_setup_socket ffff880016a2ed40
Jul  2 09:56:42 vnfsrv kernel: setting up TCP socket for reading
Jul  2 09:56:42 vnfsrv kernel: svc: svc_setup_socket created ffff880015259000 (inet ffff8800162147c0)
Jul  2 09:56:42 vnfsrv kernel: svc: transport ffff880015259000 served by daemon ffff8800167cc000
Jul  2 09:56:42 vnfsrv kernel: svc: server ffff8800167cc000, pool 0, transport ffff880015259000, inuse=3
Jul  2 09:56:42 vnfsrv kernel: svc: tcp_recv ffff880015259000 data 1 conn 0 close 0
Jul  2 09:56:42 vnfsrv kernel: svc: socket ffff880015259000 recvfrom(ffff8800152592a4, 0) = 4
Jul  2 09:56:42 vnfsrv kernel: svc: TCP record, 40 bytes
Jul  2 09:56:42 vnfsrv kernel: svc: socket ffff880015259000 recvfrom(ffff88001607c028, 4056) = 40
Jul  2 09:56:42 vnfsrv kernel: svc: TCP final record (40 bytes)
Jul  2 09:56:42 vnfsrv kernel: svc: got len=40
Jul  2 09:56:42 vnfsrv kernel: svc: svc_authenticate (0)
Jul  2 09:56:42 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff880016576000
Jul  2 09:56:42 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 09:56:42 vnfsrv kernel: svc: server ffff880016576000 waiting for data (to = 900000)
Jul  2 09:56:42 vnfsrv kernel: svc: calling dispatcher
Jul  2 09:56:42 vnfsrv kernel: svc: server ffff88001657a000 waiting for data (to = 900000)
Jul  2 09:56:42 vnfsrv kernel: nfsd_dispatch: vers 4 proc 0
Jul  2 09:56:42 vnfsrv kernel: svc: socket ffff880015259000 sendto([ffff8800165d4000 28... ], 28) = 28 (addr 10.1.7.30, port=740)
Jul  2 09:56:42 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 09:56:42 vnfsrv kernel: svc: socket ffff8800167aad40 TCP (listen) state change 10
Jul  2 09:56:42 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff8800167cc000
Jul  2 09:56:42 vnfsrv kernel: svc: socket ffff880015277500 TCP (listen) state change 1
Jul  2 09:56:42 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 09:56:42 vnfsrv kernel: 4nfsd: connect from unprivileged port: 10.1.7.30, port=55093
Jul  2 09:56:42 vnfsrv kernel: nfsd: connect from 10.1.7.30, port=55093
Jul  2 09:56:42 vnfsrv kernel: svc: svc_setup_socket ffff880016a10d00
Jul  2 09:56:43 vnfsrv kernel: setting up TCP socket for reading
Jul  2 09:56:43 vnfsrv kernel: svc: svc_setup_socket created ffff8800158ce000 (inet ffff880015277500)
Jul  2 09:56:43 vnfsrv kernel: svc: transport ffff8800158ce000 served by daemon ffff88001657a000
Jul  2 09:56:43 vnfsrv kernel: svc: server ffff88001657a000, pool 0, transport ffff8800158ce000, inuse=3
Jul  2 09:56:43 vnfsrv kernel: svc: tcp_recv ffff8800158ce000 data 1 conn 0 close 0
Jul  2 09:56:43 vnfsrv kernel: svc: socket ffff8800158ce000 recvfrom(ffff8800158ce2a4, 0) = 4
Jul  2 09:56:43 vnfsrv kernel: svc: TCP record, 1380 bytes
Jul  2 09:56:43 vnfsrv kernel: svc: socket ffff8800158ce000 recvfrom(ffff880016570564, 2716) = 1380
Jul  2 09:56:43 vnfsrv kernel: svc: TCP final record (1380 bytes)
Jul  2 09:56:43 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff880016576000
Jul  2 09:56:43 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 09:56:43 vnfsrv kernel: svc: server ffff880016576000 waiting for data (to = 900000)
Jul  2 09:56:43 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 09:56:43 vnfsrv kernel: svc: got len=1380
Jul  2 09:56:43 vnfsrv kernel: svc: svc_authenticate (6)
Jul  2 09:56:43 vnfsrv kernel: RPC:       svcauth_gss: argv->iov_len = 1352
Jul  2 09:56:43 vnfsrv kernel: RPC:       Want update, refage=120, age=0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       krb5_encrypt returns 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       gss_import_sec_context_kerberos: returning 0
Jul  2 09:56:43 vnfsrv kernel: RPC:       gss_get_mic_v2
Jul  2 09:56:43 vnfsrv kernel: svc: socket ffff8800158ce000 sendto([ffff880016571000 232... ], 232) = 232 (addr 10.1.7.30, port=55093)
Jul  2 09:56:43 vnfsrv kernel: svc: socket ffff880015277500 TCP data ready (svsk ffff8800158ce000)
Jul  2 09:56:43 vnfsrv kernel: svc: transport ffff8800158ce000 served by daemon ffff880016576000
Jul  2 09:56:43 vnfsrv kernel: svc: socket ffff880015277500 TCP (connected) state change 8 (svsk ffff8800158ce000)
Jul  2 09:56:43 vnfsrv kernel: svc: transport ffff8800158ce000 busy, not enqueued
Jul  2 09:56:43 vnfsrv kernel: svc: socket ffff880015277500 TCP data ready (svsk ffff8800158ce000)
Jul  2 09:56:43 vnfsrv kernel: svc: transport ffff8800158ce000 busy, not enqueued
Jul  2 09:56:43 vnfsrv kernel: svc: socket ffff8800162147c0 TCP data ready (svsk ffff880015259000)
Jul  2 09:56:43 vnfsrv kernel: svc: transport ffff880015259000 served by daemon ffff8800167cc000
Jul  2 09:56:43 vnfsrv kernel: svc_recv: found XPT_CLOSE
Jul  2 09:56:43 vnfsrv kernel: svc: svc_delete_xprt(ffff8800158ce000)
Jul  2 09:56:43 vnfsrv kernel: svc: svc_tcp_sock_detach(ffff8800158ce000)
Jul  2 09:56:43 vnfsrv kernel: svc: server ffff8800167cc000, pool 0, transport ffff880015259000, inuse=2
Jul  2 09:56:43 vnfsrv kernel: svc: tcp_recv ffff880015259000 data 1 conn 0 close 0
Jul  2 09:56:43 vnfsrv kernel: svc: socket ffff880015259000 recvfrom(ffff8800152592a4, 0) = 4
Jul  2 09:56:43 vnfsrv kernel: svc: svc_sock_detach(ffff8800158ce000)
Jul  2 09:56:43 vnfsrv kernel: svc: server ffff880016576000 waiting for data (to = 900000)
Jul  2 09:56:43 vnfsrv kernel: svc: transport ffff8800158ce000 busy, not enqueued
Jul  2 09:56:43 vnfsrv kernel: svc: svc_sock_free(ffff8800158ce000)
Jul  2 09:56:43 vnfsrv kernel: svc: server ffff88001657a000 waiting for data (to = 900000)
Jul  2 09:56:43 vnfsrv kernel: svc: TCP record, 200 bytes
Jul  2 09:56:43 vnfsrv kernel: svc: socket ffff880015259000 recvfrom(ffff88001607c0c8, 3896) = 200
Jul  2 09:56:43 vnfsrv kernel: svc: TCP final record (200 bytes)
Jul  2 09:56:43 vnfsrv kernel: svc: got len=200
Jul  2 09:56:43 vnfsrv kernel: svc: svc_authenticate (6)
Jul  2 09:56:43 vnfsrv kernel: RPC:       svcauth_gss: argv->iov_len = 172
Jul  2 09:56:43 vnfsrv kernel: RPC:       gss_verify_mic_v2
Jul  2 09:56:43 vnfsrv kernel: RPC:       gss_get_mic_v2
Jul  2 09:56:43 vnfsrv kernel: RPC:       Want update, refage=120, age=0
Jul  2 09:56:43 vnfsrv kernel: RPC:       Want update, refage=120, age=0
Jul  2 09:56:48 vnfsrv kernel: svc: svc_process dropit
Jul  2 09:56:48 vnfsrv kernel: svc: xprt ffff880015259000 dropped request
Jul  2 09:56:48 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 09:57:12 vnfsrv kernel: NFSD: laundromat service - starting
Jul  2 09:57:12 vnfsrv kernel: NFSD: laundromat_main - sleeping for 90 seconds
Jul  2 09:57:42 vnfsrv kernel: RPC:       xs_close xprt ffff88001610b800
Jul  2 09:57:42 vnfsrv kernel: RPC:       disconnected transport ffff88001610b800
Jul  2 09:57:42 vnfsrv kernel: RPC:       wake_up_first(ffff88001610b978 "xprt_sending")
Jul  2 09:57:44 vnfsrv kernel: svc: socket ffff8800162147c0 TCP (connected) state change 8 (svsk ffff880015259000)
Jul  2 09:57:44 vnfsrv kernel: svc: transport ffff880015259000 served by daemon ffff8800167cc000
Jul  2 09:57:44 vnfsrv kernel: svc: socket ffff8800162147c0 TCP data ready (svsk ffff880015259000)
Jul  2 09:57:44 vnfsrv kernel: svc: transport ffff880015259000 busy, not enqueued
Jul  2 09:57:44 vnfsrv kernel: svc_recv: found XPT_CLOSE
Jul  2 09:57:44 vnfsrv kernel: svc: svc_delete_xprt(ffff880015259000)
Jul  2 09:57:44 vnfsrv kernel: svc: svc_tcp_sock_detach(ffff880015259000)
Jul  2 09:57:44 vnfsrv kernel: svc: svc_sock_detach(ffff880015259000)
Jul  2 09:57:44 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 09:57:44 vnfsrv kernel: svc: socket ffff8800167aad40 TCP (listen) state change 10
Jul  2 09:57:44 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff880016576000
Jul  2 09:57:44 vnfsrv kernel: svc: socket ffff8800164ed540 TCP (listen) state change 1
Jul  2 09:57:44 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 09:57:44 vnfsrv kernel: nfsd: connect from 10.1.7.30, port=740
Jul  2 09:57:44 vnfsrv kernel: svc: svc_setup_socket ffff880016a2eac0
Jul  2 09:57:44 vnfsrv kernel: setting up TCP socket for reading
Jul  2 09:57:44 vnfsrv kernel: svc: svc_setup_socket created ffff88001669a000 (inet ffff8800164ed540)
Jul  2 09:57:44 vnfsrv kernel: svc: transport ffff88001669a000 served by daemon ffff8800167cc000
Jul  2 09:57:44 vnfsrv kernel: svc: server ffff8800167cc000, pool 0, transport ffff88001669a000, inuse=3
Jul  2 09:57:44 vnfsrv kernel: svc: tcp_recv ffff88001669a000 data 1 conn 0 close 0
Jul  2 09:57:44 vnfsrv kernel: svc: socket ffff88001669a000 recvfrom(ffff88001669a2a4, 0) = 4
Jul  2 09:57:44 vnfsrv kernel: svc: TCP record, 200 bytes
Jul  2 09:57:44 vnfsrv kernel: svc: socket ffff88001669a000 recvfrom(ffff88001607c0c8, 3896) = 200
Jul  2 09:57:44 vnfsrv kernel: svc: TCP final record (200 bytes)
Jul  2 09:57:44 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff88001657a000
Jul  2 09:57:44 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 09:57:44 vnfsrv kernel: svc: server ffff88001657a000 waiting for data (to = 900000)
Jul  2 09:57:44 vnfsrv kernel: svc: server ffff880016576000 waiting for data (to = 900000)
Jul  2 09:57:44 vnfsrv kernel: svc: got len=200
Jul  2 09:57:44 vnfsrv kernel: svc: svc_authenticate (6)
Jul  2 09:57:44 vnfsrv kernel: RPC:       svcauth_gss: argv->iov_len = 172
Jul  2 09:57:44 vnfsrv kernel: RPC:       gss_verify_mic_v2
Jul  2 09:57:44 vnfsrv kernel: RPC:       gss_get_mic_v2
Jul  2 09:57:44 vnfsrv kernel: RPC:       Want update, refage=120, age=61
Jul  2 09:57:49 vnfsrv kernel: svc: svc_process dropit
Jul  2 09:57:49 vnfsrv kernel: svc: xprt ffff88001669a000 dropped request
Jul  2 09:57:49 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 09:58:42 vnfsrv kernel: NFSD: laundromat service - starting
Jul  2 09:58:42 vnfsrv kernel: NFSD: laundromat_main - sleeping for 90 seconds
Jul  2 09:59:45 vnfsrv kernel: svc: socket ffff8800164ed540 TCP (connected) state change 8 (svsk ffff88001669a000)
Jul  2 09:59:45 vnfsrv kernel: svc: transport ffff88001669a000 served by daemon ffff8800167cc000
Jul  2 09:59:45 vnfsrv kernel: svc: socket ffff8800164ed540 TCP data ready (svsk ffff88001669a000)
Jul  2 09:59:45 vnfsrv kernel: svc: transport ffff88001669a000 busy, not enqueued
Jul  2 09:59:45 vnfsrv kernel: svc_recv: found XPT_CLOSE
Jul  2 09:59:45 vnfsrv kernel: svc: svc_delete_xprt(ffff88001669a000)
Jul  2 09:59:45 vnfsrv kernel: svc: svc_tcp_sock_detach(ffff88001669a000)
Jul  2 09:59:45 vnfsrv kernel: svc: svc_sock_detach(ffff88001669a000)
Jul  2 09:59:45 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 09:59:46 vnfsrv kernel: svc: socket ffff8800167aad40 TCP (listen) state change 10
Jul  2 09:59:46 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff8800167cc000
Jul  2 09:59:46 vnfsrv kernel: svc: socket ffff88001503f440 TCP (listen) state change 1
Jul  2 09:59:46 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 09:59:46 vnfsrv kernel: nfsd: connect from 10.1.7.30, port=740
Jul  2 09:59:46 vnfsrv kernel: svc: svc_setup_socket ffff880016accd40
Jul  2 09:59:46 vnfsrv kernel: setting up TCP socket for reading
Jul  2 09:59:46 vnfsrv kernel: svc: svc_setup_socket created ffff8800159f0000 (inet ffff88001503f440)
Jul  2 09:59:46 vnfsrv kernel: svc: transport ffff8800159f0000 served by daemon ffff880016576000
Jul  2 09:59:46 vnfsrv kernel: svc: server ffff880016576000, pool 0, transport ffff8800159f0000, inuse=3
Jul  2 09:59:46 vnfsrv kernel: svc: tcp_recv ffff8800159f0000 data 1 conn 0 close 0
Jul  2 09:59:46 vnfsrv kernel: svc: socket ffff8800159f0000 recvfrom(ffff8800159f02a4, 0) = 4
Jul  2 09:59:46 vnfsrv kernel: svc: TCP record, 200 bytes
Jul  2 09:59:46 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff88001657a000
Jul  2 09:59:46 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 09:59:46 vnfsrv kernel: svc: server ffff88001657a000 waiting for data (to = 900000)
Jul  2 09:59:46 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 09:59:46 vnfsrv kernel: svc: socket ffff8800159f0000 recvfrom(ffff8800166f80c8, 3896) = 200
Jul  2 09:59:46 vnfsrv kernel: svc: TCP final record (200 bytes)
Jul  2 09:59:46 vnfsrv kernel: svc: got len=200
Jul  2 09:59:46 vnfsrv kernel: svc: svc_authenticate (6)
Jul  2 09:59:46 vnfsrv kernel: RPC:       svcauth_gss: argv->iov_len = 172
Jul  2 09:59:46 vnfsrv kernel: RPC:       gss_verify_mic_v2
Jul  2 09:59:46 vnfsrv kernel: RPC:       gss_get_mic_v2
Jul  2 09:59:46 vnfsrv kernel: RPC:       Want update, refage=120, age=0
Jul  2 09:59:51 vnfsrv kernel: svc: svc_process dropit
Jul  2 09:59:51 vnfsrv kernel: svc: xprt ffff8800159f0000 dropped request
Jul  2 09:59:51 vnfsrv kernel: svc: server ffff880016576000 waiting for data (to = 900000)
Jul  2 10:00:12 vnfsrv kernel: NFSD: laundromat service - starting
Jul  2 10:00:12 vnfsrv kernel: NFSD: laundromat_main - sleeping for 90 seconds
Jul  2 10:00:47 vnfsrv kernel: svc: socket ffff88001503f440 TCP (connected) state change 8 (svsk ffff8800159f0000)
Jul  2 10:00:47 vnfsrv kernel: svc: transport ffff8800159f0000 served by daemon ffff880016576000
Jul  2 10:00:47 vnfsrv kernel: svc: socket ffff88001503f440 TCP data ready (svsk ffff8800159f0000)
Jul  2 10:00:47 vnfsrv kernel: svc: transport ffff8800159f0000 busy, not enqueued
Jul  2 10:00:47 vnfsrv kernel: svc_recv: found XPT_CLOSE
Jul  2 10:00:47 vnfsrv kernel: svc: svc_delete_xprt(ffff8800159f0000)
Jul  2 10:00:47 vnfsrv kernel: svc: svc_tcp_sock_detach(ffff8800159f0000)
Jul  2 10:00:47 vnfsrv kernel: svc: svc_sock_detach(ffff8800159f0000)
Jul  2 10:00:47 vnfsrv kernel: svc: server ffff880016576000 waiting for data (to = 900000)
Jul  2 10:00:48 vnfsrv kernel: svc: socket ffff8800167aad40 TCP (listen) state change 10
Jul  2 10:00:48 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff880016576000
Jul  2 10:00:48 vnfsrv kernel: svc: socket ffff880015a44d80 TCP (listen) state change 1
Jul  2 10:00:48 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 10:00:48 vnfsrv kernel: nfsd: connect from 10.1.7.30, port=740
Jul  2 10:00:48 vnfsrv kernel: svc: svc_setup_socket ffff880016acc840
Jul  2 10:00:48 vnfsrv kernel: setting up TCP socket for reading
Jul  2 10:00:48 vnfsrv kernel: svc: svc_setup_socket created ffff8800152d7000 (inet ffff880015a44d80)
Jul  2 10:00:48 vnfsrv kernel: svc: transport ffff8800152d7000 served by daemon ffff8800167cc000
Jul  2 10:00:48 vnfsrv kernel: svc: server ffff8800167cc000, pool 0, transport ffff8800152d7000, inuse=3
Jul  2 10:00:48 vnfsrv kernel: svc: tcp_recv ffff8800152d7000 data 1 conn 0 close 0
Jul  2 10:00:48 vnfsrv kernel: svc: socket ffff8800152d7000 recvfrom(ffff8800152d72a4, 0) = 4
Jul  2 10:00:48 vnfsrv kernel: svc: TCP record, 200 bytes
Jul  2 10:00:48 vnfsrv kernel: svc: socket ffff8800152d7000 recvfrom(ffff88001607c0c8, 3896) = 200
Jul  2 10:00:48 vnfsrv kernel: svc: TCP final record (200 bytes)
Jul  2 10:00:48 vnfsrv kernel: svc: got len=200
Jul  2 10:00:48 vnfsrv kernel: svc: svc_authenticate (6)
Jul  2 10:00:48 vnfsrv kernel: svc: transport ffff8800159c0000 served by daemon ffff88001657a000
Jul  2 10:00:48 vnfsrv kernel: svc: tcp_accept ffff8800159c0000 sock ffff880016a2e840
Jul  2 10:00:48 vnfsrv kernel: svc: server ffff88001657a000 waiting for data (to = 900000)
Jul  2 10:00:48 vnfsrv kernel: svc: server ffff880016576000 waiting for data (to = 900000)
Jul  2 10:00:48 vnfsrv kernel: RPC:       svcauth_gss: argv->iov_len = 172
Jul  2 10:00:48 vnfsrv kernel: RPC:       gss_verify_mic_v2
Jul  2 10:00:48 vnfsrv kernel: RPC:       gss_get_mic_v2
Jul  2 10:00:48 vnfsrv kernel: RPC:       Want update, refage=120, age=62
Jul  2 10:00:53 vnfsrv kernel: svc: svc_process dropit
Jul  2 10:00:53 vnfsrv kernel: svc: xprt ffff8800152d7000 dropped request
Jul  2 10:00:53 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 10:01:42 vnfsrv kernel: NFSD: laundromat service - starting
Jul  2 10:01:42 vnfsrv kernel: NFSD: laundromat_main - sleeping for 90 seconds
Jul  2 10:02:00 vnfsrv kernel: revisit canceled
Jul  2 10:02:00 vnfsrv kernel: svc: svc_sock_free(ffff8800159f0000)
Jul  2 10:02:00 vnfsrv kernel: revisit queued
Jul  2 10:02:00 vnfsrv kernel: svc: transport ffff8800152d7000 served by daemon ffff8800167cc000
Jul  2 10:02:00 vnfsrv kernel: svc: server ffff8800167cc000, pool 0, transport ffff8800152d7000, inuse=3
Jul  2 10:02:00 vnfsrv kernel: svc: got len=200
Jul  2 10:02:00 vnfsrv kernel: svc: transport ffff8800152d7000 served by daemon ffff880016576000
Jul  2 10:02:00 vnfsrv kernel: svc: server ffff880016576000, pool 0, transport ffff8800152d7000, inuse=5
Jul  2 10:02:00 vnfsrv kernel: svc: tcp_recv ffff8800152d7000 data 0 conn 0 close 0
Jul  2 10:02:00 vnfsrv kernel: svc: socket ffff8800152d7000 recvfrom(ffff8800152d72a0, 4) = -11
Jul  2 10:02:00 vnfsrv kernel: RPC: TCP recv_record got -11
Jul  2 10:02:00 vnfsrv kernel: svc: svc_authenticate (6)
Jul  2 10:02:00 vnfsrv kernel: RPC:       svcauth_gss: argv->iov_len = 172
Jul  2 10:02:00 vnfsrv kernel: RPC:       gss_get_mic_v2
Jul  2 10:02:00 vnfsrv kernel: RPC: TCP recvfrom got EAGAIN
Jul  2 10:02:00 vnfsrv kernel: svc: got len=0
Jul  2 10:02:00 vnfsrv kernel: svc: server ffff880016576000 waiting for data (to = 900000)
Jul  2 10:02:00 vnfsrv kernel: RPC:       Want update, refage=120, age=0
Jul  2 10:02:05 vnfsrv kernel: svc: svc_process dropit
Jul  2 10:02:05 vnfsrv kernel: svc: xprt ffff8800152d7000 dropped request
Jul  2 10:02:05 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 10:02:23 vnfsrv kernel: svc: socket ffff880015a44d80 TCP (connected) state change 8 (svsk ffff8800152d7000)
Jul  2 10:02:23 vnfsrv kernel: svc: transport ffff8800152d7000 served by daemon ffff8800167cc000
Jul  2 10:02:23 vnfsrv kernel: svc: socket ffff880015a44d80 TCP data ready (svsk ffff8800152d7000)
Jul  2 10:02:23 vnfsrv kernel: svc: transport ffff8800152d7000 busy, not enqueued
Jul  2 10:02:23 vnfsrv kernel: svc_recv: found XPT_CLOSE
Jul  2 10:02:23 vnfsrv kernel: svc: svc_delete_xprt(ffff8800152d7000)
Jul  2 10:02:23 vnfsrv kernel: svc: svc_tcp_sock_detach(ffff8800152d7000)
Jul  2 10:02:23 vnfsrv kernel: svc: svc_sock_detach(ffff8800152d7000)
Jul  2 10:02:23 vnfsrv kernel: svc: server ffff8800167cc000 waiting for data (to = 900000)
Jul  2 10:02:43 vnfsrv kernel: svc_age_temp_xprts

Regards

Sven

-- 
"Das ist halt der Unterschied: Unix ist ein Betriebssystem mit Tradition,
 die anderen sind einfach von sich aus unlogisch."
                          (Anselm Lingnau in de.comp.os.unix.discussion)
/me ist giggls@ircnet, http://sven.gegg.us/ im WWW
