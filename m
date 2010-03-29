From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Sunrpc transport reconnection...
Date: Mon, 29 Mar 2010 17:43:07 -0400
Message-ID: <1269898987.15895.95.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51695 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209Ab0C2VoL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Mar 2010 17:44:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Having looked more carefully at the code...

Is there any reason to keep the xprt->connect_timeout? As far as I can
see, it would appear to be completely redundant.

For UDP there is no disconnect/reconnect. The socket is set up once and
for all, so no need for connect_timeout.

In the case of a TCP reconnection, the xprt->reestablish_timeout will do
exponential back-off to prevent reconnecting unnecessarily. The
XPRT_CONNECTING lock then prevents anyone from trying to interfere with
that connect request until it gets a reply, or the TCP layer decides
that the socket has timed out. Again, it appears that
xprt->connect_timeout is redundant.

RDMA reconnection appears to follow the TCP model. Once again, there is
exponential back-off, enforced by XPRT_CONNECTING.

So why do we have xprt->connect_timeout? What is it enforcing?

Trond
