Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:56501 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630AbaJ0T0O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Oct 2014 15:26:14 -0400
Received: by mail-qa0-f46.google.com with SMTP id s7so4310986qap.33
        for <linux-nfs@vger.kernel.org>; Mon, 27 Oct 2014 12:26:13 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 27 Oct 2014 15:26:10 -0400
To: netdev@kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: nfs stalls over loopback interface (no sk_data_ready events?)
Message-ID: <20141027152610.3568616f@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sending this to netdev since I think I've now determined that this is
not a NFS specific problem. Recently Christoph mentioned that he was
seeing stalls when running xfstests generic/075 test on NFS over the
loopback interface with v3.18-rc1-ish kernel.

The configuration in this case is the nfs server and client on same box
communicating over the lo interface.

Here's are tracepoints from a typical request as it's supposed to work:

       mount.nfs-906   [002] ...1 22711.996969: xprt_transmit: xprt=0xffff8800ce961000 xid=0xa8a34513 status=0
            nfsd-678   [000] ...1 22711.997082: svc_recv: rq_xid=0xa8a34513 status=164
            nfsd-678   [000] ..s8 22711.997185: xprt_lookup_rqst: xprt=0xffff8800ce961000 xid=0xa8a34513 status=0
            nfsd-678   [000] ..s8 22711.997186: xprt_complete_rqst: xprt=0xffff8800ce961000 xid=0xa8a34513 status=140
            nfsd-678   [000] ...1 22711.997236: svc_send: rq_xid=0xa8a34513 dropme=0 status=144
            nfsd-678   [000] ...1 22711.997236: svc_process: rq_xid=0xa8a34513 dropme=0 status=144

...basically, we send a request to the server. Server picks it up and
sends the reply, and then the client IDs that reply and processes it.
This runs along just fine for ~ a minute or so. At some point, the
client stops seeing replies come in:

     kworker/2:2-107   [002] ...1 22741.696070: xprt_transmit: xprt=0xffff8800ce961000 xid=0xc3a84513 status=0
            nfsd-678   [002] .N.1 22741.696917: svc_recv: rq_xid=0xc3a84513 status=208
            nfsd-678   [002] ...1 22741.699890: svc_send: rq_xid=0xc3a84513 dropme=0 status=262252
            nfsd-678   [002] ...1 22741.699891: svc_process: rq_xid=0xc3a84513 dropme=0 status=262252


...a bit more tracepoint work seems to show that we just stop getting
sk_data_ready callbacks on the socket at all. I'm not terribly familiar
with the lower-level socket code, so I figured I'd email here and ask...

Anyone have insight into why this might be happening?

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
