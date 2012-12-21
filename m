Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f50.google.com ([209.85.215.50]:43336 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab2LUIHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2012 03:07:22 -0500
Received: by mail-la0-f50.google.com with SMTP id c1so4568488lah.9
        for <linux-nfs@vger.kernel.org>; Fri, 21 Dec 2012 00:07:20 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 21 Dec 2012 13:37:20 +0530
Message-ID: <CAOn_VZb1Hsv8MpCaZQoixxHpJRfSZdEZ3GgLzdSjawZZuzn33w@mail.gmail.com>
Subject: NFS server connection hang in CLOSE_WAIT state
From: Rajesh Ghanekar <rajeshsg@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
    I have nfs server hung in CLOSE_WAIT state and the corresponding
nfs client hang in FIN_WAIT2 state. NFS client is not retrying as NFS
server isn't calling close() on the socket. The shutdown was initiated
by NFS client and its now waiting for NFS server to send its FIN.

   Actually I am using old version here:
NFS server: 2.6.16 (sles10sp3)
NFS client: 2.6.27 (sles11)

   I see sunrpc client code missing xs_tcp_schedule_linger_timeout()  in 2.6.27:

        case TCP_FIN_WAIT1:
                /* The client initiated a shutdown of the socket */
                xprt->connect_cookie++;
                xprt->reestablish_timeout = 0;
                set_bit(XPRT_CLOSING, &xprt->state);
                smp_mb__before_clear_bit();
                clear_bit(XPRT_CONNECTED, &xprt->state);
                clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
                smp_mb__after_clear_bit();
                xs_tcp_schedule_linger_timeout(xprt,
xs_tcp_fin_timeout);    << This is missing in 2.6.27
                break;


   So its clear that if the above linger timeout had been there
in 2.6.27 the client would have connected back again. But why
nfs service (server) sunrpc logic (svc_recv) hasn't called close on its
part of the socket is yet not clear to me. I would like to know if
anyone has faced this issue and if there are any fixes which I can
individually pick.

   If I do another mount from same NFS client and another
IP of same NFS server, things starts fine. So to make the
original IP of same NFS server work fine, restart of nfs server
will do. But I would like to know why the hang on the transport
from NFS server side.

  Sorry in advance for the noise if expectation is to test with
recent kernels and report accordingly. I can't test with new
kernels.

Thanks,
Rajesh
