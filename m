From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFSv4.1 assumptions w.r.t. restarting RPC calls.
Date: Mon, 07 Dec 2009 13:36:52 -0500
Message-ID: <1260211012.32136.48.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36643 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758230AbZLGSgq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 13:36:46 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB7IarEu014937
	for <linux-nfs@vger.kernel.org>; Mon, 7 Dec 2009 10:36:53 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the NFSv4.1 implementation of CLOSE/OPEN_DOWNGRADE is
seriously broken because it assumes that nfs4_close_prepare() is
non-idempotent.

I'm planning a fix for that, but does anybody see any other RPC calls
that have the same problem?

Cheers
  Trond
