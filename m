Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:52888 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022Ab2H1QGD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2012 12:06:03 -0400
Received: by wibhr14 with SMTP id hr14so4978906wib.1
        for <linux-nfs@vger.kernel.org>; Tue, 28 Aug 2012 09:06:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFtxgO5if9qDf9Lex+=hPjrQBgy9ZOnQDr+CWvGY2U7dpC3dOQ@mail.gmail.com>
References: <CAFtxgO5if9qDf9Lex+=hPjrQBgy9ZOnQDr+CWvGY2U7dpC3dOQ@mail.gmail.com>
Date: Tue, 28 Aug 2012 12:06:00 -0400
Message-ID: <CAHVgHyX9aDLjYH0QwUCjx8tXwjsdm=MqH2GPY_68P6XHkYGhVQ@mail.gmail.com>
Subject: Re: [NFS v4.1] State manager error 22?
From: Andy Adamson <androsadamson@gmail.com>
To: Jeff Garzik <jeff@garzik.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Which kernel?

Note that there are multiple checks on the successful CREATE_SESSION
response that will trigger the client to reject the CREATE_SESSION
response with -EINVAL.

For example, if the recv maximum response size is greater than the
sent maximum response size, or if the recv maximum number of
operations is less than the sent maximum number of operations.....

-->Andy

On Tue, Aug 28, 2012 at 11:39 AM, Jeff Garzik <jeff@garzik.org> wrote:
> Trying to mount my custom nfs4d server (a 4.1 server) using
>
>      mount -t nfs -o nfsvers=4,minorversion=1 127.0.0.1:/ /test
>
> results in
>
>      NFS: state manager failed on NFSv4 server 127.0.0.1 with error 22
>
> Error 22 is NFS4ERR_INVAL, but that error is never sent on the wire
> (note NFS4_OK is returned for EXCHANGE_ID and CREATE_SESSION):
>
> (RPC message #1 from Linux kernel)
> nfs4d[14205]: client ::ffff:127.0.0.1 connected
> nfs4d[14205]: RPC frag (40 bytes, LAST)
> nfs4d[14205]: RPC: message (40 bytes, xid 3375e730, proc 0)
> nfs4d[14205]: NULL proc invoked
> nfs4d[14205]: RPC reply: 28 bytes, 1 writes
>
> (RPC message #2 from Linux kernel)
> nfs4d[14205]: RPC frag (256 bytes, LAST)
> nfs4d[14205]: RPC: message (256 bytes, xid 3475e730, proc 1)
> nfs4d[14205]: RPC CRED Unix (uid 0 gid 0 len 44)
> nfs4d[14205]: op EXCHANGE_ID (127.0.0.1/localhost.localdomain/1, 1)
> nfs4d[14205]:    clientid 3cde47d62cea0bf6, seq 0, flg 10001
> nfs4d[14205]: compound end (1 args, 1 results, status NFS4_OK)
> nfs4d[14205]: RPC reply: 104 bytes, 1 writes
>
> (RPC message #3 from Linux kernel)
> nfs4d[14205]: RPC frag (216 bytes, LAST)
> nfs4d[14205]: RPC: message (216 bytes, xid 3575e730, proc 1)
> nfs4d[14205]: RPC CRED Unix (uid 0 gid 0 len 44)
> nfs4d[14205]: op CREATE_SESSION (clid 3cde47d62cea0bf6, seq 0, flg 3)
> nfs4d[14205]:    sess id 68035f7e74ffff1d0000000000000000, seq 0, flg 3
> nfs4d[14205]: compound end (1 args, 1 results, status NFS4_OK)
> nfs4d[14205]: RPC reply: 128 bytes, 1 writes
>
> Source code for the server is here, for the curious:
> https://github.com/jgarzik/nfs4d
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
