From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RPC Question
Date: Thu, 17 Apr 2008 17:37:28 -0400
Message-ID: <1208468248.30399.23.camel@heimdal.trondhjem.org>
References: <969249.1309.qm@web50508.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Usman S. Ansari" <usman.ansari@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:56322 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbYDQVhc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2008 17:37:32 -0400
In-Reply-To: <969249.1309.qm-YaqxewpK01+B9c0Qi4KiSl5cfvJIxWXgQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-04-17 at 13:57 -0700, Usman S. Ansari wrote:
> Hello, I am modifying Linux sunrpc code to work with TOE (TCP offload engine). I have a question about tcp_data_recv function.
> 
> What does flags XPRT_COPY_RECM, XPRT_COPY_XID & XPRT_COPY_DATA mean ? and where can I get description of tcp_read_fraghdr, tcp_read_xid and tcp_read_request.
> 
> If there is any sort of documentaion or flow please let me know.

You've got the original source code right there; why would you need
extra documentation?

Anyhow, the flags XPRT_COPY_* all label different states when reading an
RPC reply from the server:

      * XPRT_COPY_RECM means that we're looking for the record marking
        word in order to figure out how long the datagram is.

      * XPRT_COPY_XID, means we're looking for the request's XID, which
        will allow us to find the original RPC call for which this is
        the reply.

      * Finally, when in the XPRT_COPY_DATA state, the rest of the
        datagram can be copied into the reply xdr_buf.

Trond

