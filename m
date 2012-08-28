Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:53231 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab2H1Pjh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2012 11:39:37 -0400
Received: by lbbgj3 with SMTP id gj3so3347589lbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Aug 2012 08:39:35 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 28 Aug 2012 11:39:34 -0400
Message-ID: <CAFtxgO5if9qDf9Lex+=hPjrQBgy9ZOnQDr+CWvGY2U7dpC3dOQ@mail.gmail.com>
Subject: [NFS v4.1] State manager error 22?
From: Jeff Garzik <jeff@garzik.org>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trying to mount my custom nfs4d server (a 4.1 server) using

     mount -t nfs -o nfsvers=4,minorversion=1 127.0.0.1:/ /test

results in

     NFS: state manager failed on NFSv4 server 127.0.0.1 with error 22

Error 22 is NFS4ERR_INVAL, but that error is never sent on the wire
(note NFS4_OK is returned for EXCHANGE_ID and CREATE_SESSION):

(RPC message #1 from Linux kernel)
nfs4d[14205]: client ::ffff:127.0.0.1 connected
nfs4d[14205]: RPC frag (40 bytes, LAST)
nfs4d[14205]: RPC: message (40 bytes, xid 3375e730, proc 0)
nfs4d[14205]: NULL proc invoked
nfs4d[14205]: RPC reply: 28 bytes, 1 writes

(RPC message #2 from Linux kernel)
nfs4d[14205]: RPC frag (256 bytes, LAST)
nfs4d[14205]: RPC: message (256 bytes, xid 3475e730, proc 1)
nfs4d[14205]: RPC CRED Unix (uid 0 gid 0 len 44)
nfs4d[14205]: op EXCHANGE_ID (127.0.0.1/localhost.localdomain/1, 1)
nfs4d[14205]:    clientid 3cde47d62cea0bf6, seq 0, flg 10001
nfs4d[14205]: compound end (1 args, 1 results, status NFS4_OK)
nfs4d[14205]: RPC reply: 104 bytes, 1 writes

(RPC message #3 from Linux kernel)
nfs4d[14205]: RPC frag (216 bytes, LAST)
nfs4d[14205]: RPC: message (216 bytes, xid 3575e730, proc 1)
nfs4d[14205]: RPC CRED Unix (uid 0 gid 0 len 44)
nfs4d[14205]: op CREATE_SESSION (clid 3cde47d62cea0bf6, seq 0, flg 3)
nfs4d[14205]:    sess id 68035f7e74ffff1d0000000000000000, seq 0, flg 3
nfs4d[14205]: compound end (1 args, 1 results, status NFS4_OK)
nfs4d[14205]: RPC reply: 128 bytes, 1 writes

Source code for the server is here, for the curious:
https://github.com/jgarzik/nfs4d
