Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:50565 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbZDMXLw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 19:11:52 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2317350rvb.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Apr 2009 16:11:50 -0700 (PDT)
In-Reply-To: <20090413104759.525161b2@dstickney2>
References: <20090413092406.304d04fb@dstickney2> <C81F82EF-81F0-432D-B727-F496F807CEB3@oracle.com>
	<20090413104759.525161b2@dstickney2>
From: Bryan McLellan <btm@loftninjas.org>
Date: Mon, 13 Apr 2009 16:11:35 -0700
Message-ID: <893823750904131611i70621c5t4c5f96d3a9e876e7@mail.gmail.com>
Subject: Re: Unexplained NFS mount hangs
To: Daniel Stickney <dstickney@pronto.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Apr 13, 2009 at 9:47 AM, Daniel Stickney <dstickney@pronto.com> wrote:
> To add a little more info, in a post on April 10th titled "NFSv3 Client Timeout on 2.6.27" Bryan mentioned that his client socket was in state FIN_WAIT2, and server in CLOSE_WAIT, which is exactly what I am seeing here.

Since my problems originated after upgrading to Ubuntu intrepid in a
'etch -> hardy -> intrepid' cycle, and hardy contained 2.6.24, I
wonder if the regression was in:

commit e06799f958bf7f9f8fae15f0c6f519953fb0257c
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Nov 5 15:44:12 2007 -0500

    SUNRPC: Use shutdown() instead of close() when disconnecting a TCP socket

    By using shutdown() rather than close() we allow the RPC client to wait
    for the TCP close handshake to complete before we start trying to reconnect
    using the same port.
    We use shutdown(SHUT_WR) only instead of shutting down both directions,
    however we wait until the server has closed the connection on its side.

    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

$ git describe e06799f958bf7f9f8fae15f0c6f519953fb0257c --contains
v2.6.25-rc1~1146^2~105

I came in today to find that the one machine outside of production
that was hung that I could toy with eventually fixed itself, albeit
five days later.

Apr  8 12:42:34 bvt-was02 kernel: [3706362.490101] nfs: server
file01.prod.example.com not responding, still trying
Apr 13 12:09:59 bvt-was02 kernel: [4136407.174292] nfs: server
file01.prod.example.com OK

There looks like there are a lot of additional timeouts added in
2.6.30-rc1, so perhaps I'll compile from source and wait to see if
this happens again on the test machines.

Bryan
