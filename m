Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.ij.cx ([212.13.201.15]:62161 "EHLO wes.ijneb.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933169Ab0KOTZX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Nov 2010 14:25:23 -0500
Received: from mark (helo=localhost)
	by wes.ijneb.com with local-esmtp (Exim 4.71)
	(envelope-from <mark@pogo.org.uk>)
	id 1PI41w-0006mo-ID
	for linux-nfs@vger.kernel.org; Mon, 15 Nov 2010 18:43:52 +0000
Date: Mon, 15 Nov 2010 18:43:52 +0000 (GMT)
From: Mark Hills <mark@pogo.org.uk>
To: linux-nfs@vger.kernel.org
Subject: Listen backlog set to 64
Message-ID: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I am looking into an issue of hanging clients to a set of NFS servers, on 
a large HPC cluster.

My investigation took me to the RPC code, svc_create_socket().

	if (protocol == IPPROTO_TCP) {
		if ((error = kernel_listen(sock, 64)) < 0)
			goto bummer;
	}

A fixed backlog of 64 connections at the server seems like it could be too 
low on a cluster like this, particularly when the protocol opens and 
closes the TCP connection.

I wondered what is the rationale is behind this number, particuarly as it 
is a fixed value. Perhaps there is a reason why this has no effect on 
nfsd, or is this a FAQ for people on large systems?

The servers show overflow of a listening queue, which I imagine is 
related.

  $ netstat -s
  [...]
  TcpExt:
    6475 times the listen queue of a socket overflowed
    6475 SYNs to LISTEN sockets ignored

The affected servers are old, kernel 2.6.9. But this limit of 64 is 
consistent across that and the latest kernel source.

Thanks

-- 
Mark
