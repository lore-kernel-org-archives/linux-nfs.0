Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59712 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752534AbeENVAF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 May 2018 17:00:05 -0400
Date: Mon, 14 May 2018 17:00:04 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: SETCLIENTID acceptor
Message-ID: <20180514210004.GB29264@fieldses.org>
References: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 09, 2018 at 05:19:41PM -0400, Chuck Lever wrote:
> I'm right on the edge of my understanding of how this all works.
> 
> I've re-keyed my NFS server. Now on my client, I'm seeing this on
> vers=4.0,sec=sys mounts:
> 
> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
> 
> manet is my client, and klimt is my server. I'm mounting with
> NFS/RDMA, so I'm mounting hostname klimt.ib, not klimt.
> 
> Because the client is using krb5i for lease management, the server
> is required to use krb5i for the callback channel (S 3.3.3 of RFC
> 7530).
> 
> After a SETCLIENTID, the client copies the acceptor from the GSS
> context it set up, and uses that to check incoming callback
> requests. I instrumented the client's SETCLIENTID proc, and I see
> this:
> 
> check_gss_callback_principal: acceptor=nfs@klimt.ib.1015granger.net, principal=host@klimt.1015granger.net
> 
> The principal strings are not equal, and that's why the client
> believes the callback credential is bogus. Now I'm trying to
> figure out whether it is the server's callback client or the
> client's callback server that is misbehaving.
> 
> To me, the server's callback principal (host@klimt) seems like it
> is correct. The client would identify as host@manet when making
> calls to the server, for example, so I'd expect the server to
> behave similarly when performing callbacks.
