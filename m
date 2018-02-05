Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38944 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752986AbeBEQgt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Feb 2018 11:36:49 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 737904902F
        for <linux-nfs@vger.kernel.org>; Mon,  5 Feb 2018 16:36:49 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-122.phx2.redhat.com [10.3.117.122])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 24E205D9CB
        for <linux-nfs@vger.kernel.org>; Mon,  5 Feb 2018 16:36:49 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/1] Remote calls don't need to use privilege ports
Date: Mon,  5 Feb 2018 11:36:46 -0500
Message-Id: <20180205163647.15822-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Over the weekend I did some experimenting with
the remote call code in rpcbind. The code does 
functionally work but is very antiquated when
it comes to the latest NFS versions. 

Since only UDP sockets are used to do remote calls
using the documented interfaces pmap_rmtcall() and callrpc()
calls to NFS will fail (actual times out) since UDP is no 
longer supported. 

The undocumented interface rpc_call() can be used to 
call into NFS since the protocol can specified, which 
also means the PMAPPROC_CALLIT protocol is not used.

It turns out privilege port are not needed to make
remote calls, at least with my testing. I'm thinking 
the only reason privilege ports were being uses was 
a side effect of create_rmtcall_fd() calling 
svc_tli_create() with an unbound socket. 

So the following patch simply binds the socket
before calling svc_tli_create() which means a
non-privilege port will be reserved for remote
calls. 

I'm thinking this is the simplest way to
not pollute the privilege port space. 

Steve Dickson (1):
  rmtcalls: Don't use privileged ports for remote calls.

 src/rpcb_svc_com.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

-- 
2.14.3

