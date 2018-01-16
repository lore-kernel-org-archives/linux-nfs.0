Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52092 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751238AbeAPPb7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Jan 2018 10:31:59 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: backchannel tracepoint expects rpc_clnt
Date: Tue, 16 Jan 2018 10:31:47 -0500
Message-ID: <892E802C-67CA-4F5C-A9F4-D36271A154C3@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

I'm trying to get to the bottom of a backchannel problem, but with
tracepoints enabled things blow up in trace_rpc_task_sleep() because there's
no rpc_clnt (or easy way to get to one) on a backchannel request.

The only reason we're sending the rpc_clnt to that tracepoint is to emit the
cl_clid:

commit 2f048db4680ae19da13df15d352ac02748781ecb
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Sep 4 21:51:44 2013 -0400

    SUNRPC: Add an identifier for struct rpc_clnt

    Add an identifier in order to aid debugging.

Can we rather just use the address of the struct rpc_clnt rather than an
integer in the tracepoint?

Alternatively, I can try to figure out how to have each backchannel request
have a reference to the rpc_clnt, or perhaps make the call to the tracepoint
conditional.

Ben
