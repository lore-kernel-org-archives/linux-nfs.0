From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [PATCH 1/1] nfs: fix race between renewd, umount, and the
 state manager in V4.1
Date: Fri, 22 Jan 2010 15:21:20 -0500
Message-ID: <1264191680.30757.33.camel@localhost>
References: <1264135871-13083-1-git-send-email-batsakis@netapp.com>
	 <1264186039.30757.7.camel@localhost>
	 <B9364369CA66BF45806C2CD86EAB8BA604F35537@SACMVEXC3-PRD.hq.netapp.com>
	 <1264189298.30757.16.camel@localhost>
	 <B9364369CA66BF45806C2CD86EAB8BA604F35581@SACMVEXC3-PRD.hq.netapp.com>
	 <1264191084.30757.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40501 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753376Ab0AVUVY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2010 15:21:24 -0500
In-Reply-To: <1264191084.30757.28.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-01-22 at 15:11 -0500, Trond Myklebust wrote: 
> Then the correct thing to do is to fix the renewd kill process. Once
> that is done, there should be no reason for any sequence_done calls to
> be pending (see reason above).

IOW: we should add a call to atomic_inc_not_zero(&clp->cl_count) in
nfs4_proc_async_renew()/nfs41_proc_async_sequence(), and have them fail
if that attempt to grab a reference fails. Then we should add a call to
nfs_put_client() in their .rpc_release method.

Trond

