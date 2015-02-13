Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:27768 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbbBMQaK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2015 11:30:10 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: rq_bc_pa_list manipulated under incorrect lock?
Date: Fri, 13 Feb 2015 11:30:02 -0500
Message-Id: <DB901924-FAA9-4A13-995D-9AB887756371@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

While reviewing xprt_complete_bc_request(), I noticed this:

326         spin_lock(&bc_serv->sv_cb_lock);

327         list_del(&req->rq_bc_pa_list);   <<<<<<<

328         list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
329         wake_up(&bc_serv->sv_cb_waitq);
330         spin_unlock(&bc_serv->sv_cb_lock);

Other places in the code hold xprt->bc_pa_lock when updating
rq_bc_pa_list. Maybe not a big deal because xprt->transport_lock is
held across the lookup and complete calls?

Introduced by commit 2ea24497a1b3 ("SUNRPC: RPC callbacks
may be split across several TCP segments”).

Since I’m new to this code, maybe I misunderstood something.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



