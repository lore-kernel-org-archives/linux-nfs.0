From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/33] More NFS and SUNRPC client side patches
Date: Sat, 19 Apr 2008 16:40:47 -0400
Message-ID: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23662 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757332AbYDSUug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:36 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoZLL026119
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:35 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Highlights include:

      * A fix for an RPCSEC_GSS hang, in which some servers would treat
        the client as being crazy if it tried to destroy an RPCSEC_GSS
        credential that had already been labelled as invalid by an
        RPCSEC_GSS_CREDPROBLEM error in an RPC reply.
      * I found a use-after-free case in call_decode() that was
        introduced by commit 220bcc2afd7011b3e0569fc178331fa983c92c1b.
      * I added code to ensure that we only break the connection _once_
        if we have to resend multiple NFSv4 requests.
      * I also tried to ensure that we don't invalidate a gss_cred which
        may be in use by other requests (basically, by forcing
        gss_refresh to always create a new credential if we find out
        that our current one has been invalidated).
      * I cleaned up xs_nospace() so that our use of the
        transport->sock->flags conforms to the expectations of the rest
        of the socket code.
      * I've reintroduced the use of machine creds when calling
        SETCLIENTID in NFSv4. If such a cred exists, then that will
        ensure that we always authenticate to the same principal name
        when rebooting, thus improving the ability to recover from
        network partitions.
        If there are no machine creds available, then we fall back to
        the existing scheme where we take a user cred.
      * NLM fixes to avoid creating 'phantom locks' on the client side.
      * Fix error handling in the read/write code if rpc_run_task() fails.

Cheers
  Trond
